terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket       = "terraform-state-gitops-project-302879626612"
    key          = "01_infrastructure/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}
