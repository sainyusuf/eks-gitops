# Outputs for EKS cluster layer

# Cluster information
output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.cluster_version
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "EKS node security group ID"
  value       = module.eks.node_security_group_id
}

# IRSA role outputs
output "ebs_csi_iam_role_arn" {
  description = "EBS CSI driver IAM role ARN"
  value       = module.ebs_csi_irsa.iam_role_arn
}

output "efs_csi_iam_role_arn" {
  description = "EFS CSI driver IAM role ARN"
  value       = module.efs_csi_irsa.iam_role_arn
}

output "alb_controller_iam_role_arn" {
  description = "ALB controller IAM role ARN"
  value       = module.alb_irsa.iam_role_arn
}
