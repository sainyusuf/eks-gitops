variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the ArgoCD Ingress / ALB"
  type        = string
  default     = null
}
variable "argocd_version" {
  description = "Version of ArgoCD to deploy"
  type        = string
  default     = "8.0.17"
}
variable "argocd_values_file_path" {
  description = "Values for ArgoCD Helm chart from root project directory."
  type        = string
  default     = "argocd_values.yaml"
}
variable "argocd_irsa_role_arn" {
  description = "ARN of the IAM role for ArgoCD service account"
  type        = string
  default     = null
}
variable "create_argocd" {
  description = "Create ArgoCD"
  type        = bool
  default     = true
}
variable "directory_path" {
  description = "The path to the directory containing the values.yaml file."
  type        = string
  default     = "files"
}
variable "namespace_argocd" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "ssl_policy" {
  description = "The AWS SSL security policy for the ALB HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}
variable "ca_cert_file" {
  description = "Path to the CA certificate file."
  type        = string
  default     = ""
}
