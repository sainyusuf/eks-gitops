# Provider configuration for EKS cluster layer
# Note: NO Kubernetes or Helm providers here - cluster doesn't exist yet during initial apply

terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.50" }
  }
}

provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket       = "terraform-state-gitops-project-302879626612"
    key          = "02_eks_cluster/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
