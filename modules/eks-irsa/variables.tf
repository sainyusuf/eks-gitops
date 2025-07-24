variable "application_name" {
  description = "Name of the application using the EKS Pod Identity"
  type        = string
}
variable "policy_dir_path" {
  description = "Path to the IAM policy directory relative to the root"
  type        = string
  default     = "policy"
}
variable "policy_file_name" {
  description = "Name of the IAM policy file"
  type        = string
}
variable "namespace" {
  description = "Kubernetes namespace where the service account is located"
  type        = string
}
variable "service_account" {
  description = "Name of the Kubernetes service account"
  type        = string
}
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
