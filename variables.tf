variable "region" {
  description = "The region."
  type        = string
}

variable "access_key" {
  description = "The access key for AWS authentication."
  type        = string
}

variable "secret_key" {
  description = "The secret key for AWS authentication."
  type        = string
  sensitive   = true
}