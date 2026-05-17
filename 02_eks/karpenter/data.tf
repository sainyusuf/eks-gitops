### Data block
data "aws_caller_identity" "current" {}

# Get infrastructure state
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "terraform-state-gitops-project-302879626612"
    key    = "01_infrastructure/terraform.tfstate"
    region = "eu-central-1"
  }
}

# Get cluster state
data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-gitops-project-302879626612"
    key    = "02_eks_cluster/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}
