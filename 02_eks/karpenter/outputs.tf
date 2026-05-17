# Outputs for Karpenter layer

output "karpenter_iam_role_arn" {
  description = "Karpenter controller IAM role ARN"
  value       = module.karpenter.iam_role_arn
}

output "karpenter_node_iam_role_name" {
  description = "Karpenter node IAM role name"
  value       = module.karpenter.node_iam_role_name
}

output "karpenter_queue_name" {
  description = "Karpenter SQS queue name"
  value       = module.karpenter.queue_name
}
