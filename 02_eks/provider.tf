# Provider configuration for AWS, Kubernetes, and Helm in Terraform
terraform {
  required_providers {
    aws        = { source = "hashicorp/aws", version = ">= 5.50" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    helm       = { source = "hashicorp/helm", version = "~> 2.13" }
  }
}

provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket       = "terraform-state-gitops-project-302879626612"
    key          = "02_eks/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}

# locals {
#   aws_region           = "eu-central-1"
#   eks_cluster_endpoint = module.eks.cluster_endpoint
#   eks_cluster_ca       = base64decode(module.eks.cluster_certificate_authority_data)
# }

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.this.token
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.this.token
#   }
# }
