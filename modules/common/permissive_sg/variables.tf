variable "vpc_id" {
  type = string
}
variable "resources_tag_name" {
  type = string
  description = "(Optional)"
  default = ""
}
variable "gateway_name" {
  type = string
  description = "(Optional) The name tag of the Security Gateway instances"
  default = "Check-Point-Gateway-tf"
}
variable "security_rules" {
  description = "List of security rules for ingress and egress"
  type        = list(object({
    direction   = string  # "ingress" or "egress"
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}