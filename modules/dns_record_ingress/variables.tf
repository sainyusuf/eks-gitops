variable "record_type" {
  description = "The type of DNS record to create (e.g., A, CNAME, etc.)."
  type        = string
  default     = "A"
}
variable "ttl" {
  description = "The TTL (Time to Live) for the DNS record."
  type        = number
  default     = 10080
}
variable "hosted_zone_name" {
  description = "The name of the hosted zone where the DNS record will be created."
  type        = string
}
variable "ingress_name" {
  description = "The ingress name for the DNS record."
  type        = string
}
variable "server_namespace" {
  description = "The namespace of the server for the DNS record."
  type        = string
}
variable "subdomain_name" {
  description = "The subdomain name for the DNS record."
  type        = string
}
variable "cluster_name" {
  description = "The name of the EKS cluster where the service is running."
  type        = string
}
