# module "argocd_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.58.0.0"

#   role_name = "${local.prefix}-argocd-sa"

#   role_policy_arns = {
#     ecr_read = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   }

#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["argocd:argocd-server"]
#     }
#   }

#   tags = var.tags
# }

# module "argocd" {
#   source                  = "../modules/argocd"
#   argocd_version          = "8.0.17"
#   argocd_values_file_path = "argocd_values.yaml"
#   directory_path          = "files/argocd"
#   argocd_irsa_role_arn    = module.argocd_irsa.iam_role_arn
#   acm_certificate_arn     = data.aws_acm_certificate.eks_service.arn
# }

# module "argocd_dns_ingress" {
#   depends_on       = [module.argocd]
#   source           = "../modules/dns_record_ingress"
#   hosted_zone_name = "tukang-awan.com"
#   ingress_name     = "argocd-server-ingress"
#   server_namespace = "argocd"
#   subdomain_name   = "argocd"
#   cluster_name     = module.eks.cluster_name
# }
