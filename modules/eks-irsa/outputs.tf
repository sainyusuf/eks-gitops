output "iam_role_arn" {
  description = "ARN of the IAM role created for the service account"
  value       = aws_iam_role.this.arn
}
output "iam_role_name" {
  description = "Name of the IAM role created for the service account"
  value       = aws_iam_role.this.name
}
