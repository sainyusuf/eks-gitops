terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.8.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.30.0"
    }
  }
}
