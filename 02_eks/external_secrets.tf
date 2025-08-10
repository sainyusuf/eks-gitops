data "aws_iam_policy_document" "eso_allow" {
  statement {
    sid    = "ReadRDSMasterSecret"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "ssm:GetParameter*"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "eso_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
  }
}

resource "aws_iam_policy" "eso_trust" {
  name   = "eso-trust-policy"
  policy = data.aws_iam_policy_document.eso_allow.json
}

resource "aws_iam_role" "eso" {
  name               = "eso-role"
  description        = "Role for External Secrets Operator"
  assume_role_policy = data.aws_iam_policy_document.eso_trust.json
}

resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso_trust.arn
}
