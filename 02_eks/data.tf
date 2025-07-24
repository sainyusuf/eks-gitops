### Data block
data "aws_caller_identity" "current" {}
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "terraform-state-gitops-project-302879626612"
    key    = "01_infrastructure/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}
data "aws_acm_certificate" "eks_service" {
  domain = "tukang-awan.com"
}
