variable "vpc_id" {
  description = "The ID of the VPC to associate with the subnet"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
}

variable "name" {
  description = "Name tag for the subnet"
  type        = string
}

variable "tags" {
  description = "Additional tags for the subnet"
  type        = map(string)
  default     = {}
}
