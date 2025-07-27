module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.37.1"

  cluster_name    = "gitops-prod-eks"
  cluster_version = "1.33"
  create_kms_key  = true

  vpc_id     = data.terraform_remote_state.infra.outputs.shared_vpc_id_prod
  subnet_ids = data.terraform_remote_state.infra.outputs.shared_vpc_id_prod_private_subnet_ids

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = false

  cluster_addons = {
    vpc-cni                = { most_recent = true }
    coredns                = { most_recent = true }
    kube-proxy             = { most_recent = true }
    eks-pod-identity-agent = { most_recent = true }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
    aws-efs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.efs_csi_irsa.iam_role_arn
    }
  }


  authentication_mode = "API_AND_CONFIG_MAP"
  access_entries = {
    # argo_cd_admin = {
    #   principal_arn     = module.argocd_irsa.iam_role_arn
    #   kubernetes_groups = ["system:masters"]
    # }
    cicd_runner = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/gitops-project-github-actions-deploy-role"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
    admin_user = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/adminCloudHsn"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
    local_user = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/husain_local"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["t3.large"]
      min_size       = 1
      max_size       = 4
      desired_size   = 1
      capacity_type  = "ON_DEMAND"
      labels = {
        "karpenter.sh/controller" = "true"
      }
      # taints = local.critical_addon_taints
    }
  }

  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30

  node_security_group_tags = {
    "karpenter.sh/discovery/shared-service-prod-eks" = "true"
  }

  tags = var.tags
}

# module "eks_managed_addon" {
#   depends_on = [module.eks.eks_managed_node_groups]

#   source            = "aws-ia/eks-blueprints-addons/aws"
#   version           = "~> 1.0"
#   cluster_name      = module.eks.cluster_name
#   cluster_endpoint  = module.eks.cluster_endpoint
#   oidc_provider_arn = module.eks.oidc_provider_arn
#   cluster_version   = module.eks.cluster_version

#   enable_cert_manager                 = true
#   enable_aws_load_balancer_controller = true
#   aws_load_balancer_controller = {
#     service_account_role_arn = module.alb_irsa.iam_role_arn
#     create_service_account   = true
#     service_account_name     = "aws-load-balancer-controller"
#   }
# }

# module "ebs_csi_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.58.0"

#   role_name             = "${local.prefix}-ebs-csi"
#   attach_ebs_csi_policy = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
#     }
#   }
#   tags = var.tags
# }

# module "efs_csi_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.58.0"

#   role_name             = "${local.prefix}-efs-csi"
#   attach_efs_csi_policy = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
#     }
#   }
#   tags = var.tags
# }

# module "alb_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.58.0"

#   role_name                              = "${local.prefix}-alb"
#   attach_load_balancer_controller_policy = true

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#     }
#   }
#   tags = var.tags
# }

# resource "aws_ec2_tag" "subnet_discovery" {
#   for_each    = toset(data.terraform_remote_state.infra.outputs.shared_vpc_id_prod_private_subnet_ids)
#   resource_id = each.value
#   key         = "karpenter.sh/discovery/${module.eks.cluster_name}"
#   value       = "true"
# }

# resource "kubernetes_namespace" "external_secrets" {
#   metadata {
#     name = "external-secrets"
#   }
# }

# resource "helm_release" "external_secrets" {
#   depends_on = [kubernetes_namespace.external_secrets, aws_iam_role.eso]
#   name       = "external-secrets"
#   repository = "https://charts.external-secrets.io"
#   chart      = "external-secrets"
#   namespace  = kubernetes_namespace.external_secrets.metadata[0].name
#   version    = "0.18.1"

#   values = [
#     templatefile("files/external-secrets/values.yaml", {
#       eso_iam_role_arn = aws_iam_role.eso.arn
#     })
#   ]
# }

# resource "kubernetes_manifest" "cluster_secret_store" {
#   depends_on = [helm_release.external_secrets]
#   manifest = {
#     apiVersion = "external-secrets.io/v1"
#     kind       = "ClusterSecretStore"
#     metadata = {
#       name = "cluster-secret-store"
#     }
#     spec = {
#       provider = {
#         aws = {
#           region  = var.region
#           service = "SecretsManager"
#           auth = {
#             jwt = {
#               serviceAccountRef = {
#                 name      = "external-secrets"
#                 namespace = "external-secrets"
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_manifest" "cluster_secret_parameter_store" {
#   depends_on = [helm_release.external_secrets]
#   manifest = {
#     apiVersion = "external-secrets.io/v1"
#     kind       = "ClusterSecretStore"
#     metadata = {
#       name = "cluster-parameter-secret-store"
#     }
#     spec = {
#       provider = {
#         aws = {
#           region  = var.region
#           service = "ParameterStore"
#           auth = {
#             jwt = {
#               serviceAccountRef = {
#                 name      = "external-secrets"
#                 namespace = "external-secrets"
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }
