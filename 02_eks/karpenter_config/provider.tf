# Provider configuration for Karpenter Config layer
# Kubernetes provider connects to EXISTING cluster with Karpenter CRDs installed

terraform {
  required_providers {
    aws        = { source = "hashicorp/aws", version = ">= 5.50" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    time       = { source = "hashicorp/time", version = "~> 0.9" }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket       = "terraform-state-gitops-project-302879626612"
    key          = "02_eks_karpenter_config/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
  }
}

# Kubernetes provider connects to existing cluster
provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.cluster.outputs.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name", data.terraform_remote_state.cluster.outputs.cluster_name
    ]
  }
}
