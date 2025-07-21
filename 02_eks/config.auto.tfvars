github_organization = "sainyusuf"
github_repository   = "eks-gitops"
region              = "eu-central-1"

workload = {
  name        = "gitops-project"
  description = "This is a GitOps project for managing EKS clusters using Terraform and GitHub Actions."
  tags = {
    managed_by     = "Husain"
    TechnicalOwner = "Husain Yusuf"
    ProductOwner   = "HSN"
    workload       = "gitops-project"
    environment    = "prod"
    tools          = "terraform"
  }
}

tags = {
  "Environment" = "Prod"
  "Owner"       = "Husain"
  "GitHubRepo"  = "eks-gitops"
}
