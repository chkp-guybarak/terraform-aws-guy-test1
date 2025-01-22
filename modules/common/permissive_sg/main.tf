resource "aws_security_group" "permissive_sg" {
  description = "Permissive security group"
  vpc_id = var.vpc_id
  
  dynamic "ingress" {
    for_each = [for rule in var.security_rules : rule if rule.direction == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }  

  dynamic ingress {
    for_each = length([for rule in var.security_rules : rule if rule.direction == "ingress"]) == 0 ? [1] : []
    content{
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = [for rule in var.security_rules : rule if rule.direction == "egress"]
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }  

  dynamic egress {
    for_each = length([for rule in var.security_rules : rule if rule.direction == "egress"]) == 0 ? [1] : []
    content{
        from_port    = 0
        to_port      = 0
        protocol     = "-1"
        cidr_blocks  = ["0.0.0.0/0"]
    }
  }
  
  name_prefix = format("%s-PermissiveSecurityGroup", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) // Group name
  tags = {
    Name = format("%s-PermissiveSecurityGroup", var.resources_tag_name != "" ? var.resources_tag_name : var.gateway_name) // Resource name
  }
}