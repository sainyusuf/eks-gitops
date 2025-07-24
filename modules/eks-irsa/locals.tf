locals {
  ## Extract OIDC Provider URL (without https://)
  oidc_provider      = replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")
  role_name          = "${var.application_name}-role"
  policy_name        = "${var.application_name}-policy"
  policy_description = "IAM policy for ${var.application_name} service account"
  policy_file_path   = "${var.policy_dir_path}/${var.policy_file_name}"
}
