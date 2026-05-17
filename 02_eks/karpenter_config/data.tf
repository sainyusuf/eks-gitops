### Data Sources

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

# Get karpenter state
data "terraform_remote_state" "karpenter" {
  backend = "s3"
  config = {
    bucket = "terraform-state-gitops-project-302879626612"
    key    = "02_eks_karpenter/terraform.tfstate"
    region = "eu-central-1"
  }
}
