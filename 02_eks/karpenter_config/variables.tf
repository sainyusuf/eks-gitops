# Variables
variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Prod"
    GitHubRepo  = "eks-gitops"
    Owner       = "Husain"
  }
}
