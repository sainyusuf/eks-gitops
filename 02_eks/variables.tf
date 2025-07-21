# Variables
variable "github_organization" {
  type        = string
  description = "Your GitHub organization name"
}

variable "github_repository" {
  type        = string
  description = "Your GitHub repository name"
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "workload" {
  description = "The metadata of the workload"
  type = object({
    name        = string
    description = string
    tags        = map(string)
  })
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
