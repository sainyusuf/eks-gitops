data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "main" {
  name = var.eks_cluster_name
}

## IAM Role for Service Account (IRSA)
resource "aws_iam_role" "this" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account}"
        }
      }
    }]
  })
}

# Attach Policies to IRSA Role
resource "aws_iam_policy" "this" {
  name        = local.policy_name
  description = local.policy_description

  policy = (file("${path.root}/${local.policy_file_path}"))
}

# Attach IAM Policy to the IRSA Role
resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
