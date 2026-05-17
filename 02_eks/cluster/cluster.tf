# EKS Cluster Configuration
# This file contains the core EKS cluster configuration including:
# - Control plane setup
# - VPC integration
# - Access entries (IAM users/roles)
# - Fargate profiles for system workloads
# - Managed addons (VPC-CNI, CoreDNS, kube-proxy, etc.)

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name               = "gitops-prod-eks"
  kubernetes_version = "1.35"

  kms_key_enable_default_policy = true

  vpc_id     = data.terraform_remote_state.infra.outputs.shared_vpc_id_prod
  subnet_ids = data.terraform_remote_state.infra.outputs.shared_vpc_id_prod_private_subnet_ids

  endpoint_private_access = true
  endpoint_public_access  = true

  enable_irsa = true
  # Disable auto cluster creator since we're defining access entries manually
  enable_cluster_creator_admin_permissions = false

  addons = {
    vpc-cni = { most_recent = true }
    # CoreDNS is deployed in karpenter layer after nodes are available
    kube-proxy             = { most_recent = true }
    eks-pod-identity-agent = { most_recent = true }
  }

  authentication_mode = "API_AND_CONFIG_MAP"
  access_entries = {
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

  # Fargate profiles for system workloads
  fargate_profiles = {
    karpenter = {
      name = "karpenter"
      selectors = [
        { namespace = "karpenter" }
      ]
      tags = merge(var.tags, {
        Purpose = "Karpenter-Controller"
      })
    }
  }

  enabled_log_types                      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  create_cloudwatch_log_group            = true
  cloudwatch_log_group_retention_in_days = 30

  tags = var.tags
}

# Add Karpenter discovery tag to cluster security group
resource "aws_ec2_tag" "cluster_sg_karpenter_discovery" {
  resource_id = module.eks.cluster_security_group_id
  key         = "karpenter.sh/discovery/${module.eks.cluster_name}"
  value       = "true"
}
