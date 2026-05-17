# Variables
variable "region" {
  description = "The AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
