resource "aws_security_group" "external_alb_security_group" {
  count = local.alb_condition ? 1 : 0
  description = "External ALB security group"
  vpc_id = var.vpc_id

  egress {
    from_port = local.encrypted_protocol_condition ? 9443 : 9080
    protocol = "tcp"
    to_port = local.encrypted_protocol_condition ? 9443 : 9080
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    protocol = "tcp"
    to_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  dynamic "ingress" {
    for_each = [for rule in var.security_rules : rule if rule.direction == "ingress"]
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
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
}

module "external_load_balancer" {
  source = "../../modules/load_balancer"

  load_balancers_type = var.load_balancers_type
  instances_subnets = var.gateways_subnets
  prefix_name = "${var.prefix}-External"
  internal = false
  security_groups = local.alb_condition ? [aws_security_group.external_alb_security_group[0].id] : []
  tags = {}
  vpc_id = var.vpc_id
  load_balancer_protocol = var.load_balancer_protocol
  target_group_port = local.encrypted_protocol_condition ? 9443 : 9080
  listener_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? "443" : "80"
  certificate_arn = local.encrypted_protocol_condition ? var.certificate : ""
  health_check_port = var.load_balancers_type == "Network Load Balancer" ? 8117 : null
  health_check_protocol = var.load_balancers_type == "Network Load Balancer" ? "TCP" : null
}

module "autoscale" {
  source = "../../modules/autoscale"


  prefix = var.prefix
  asg_name = var.asg_name
  vpc_id = var.vpc_id
  subnet_ids = var.gateways_subnets
  gateway_name = "${var.provision_tag}-security-gateway"
  gateway_instance_type = var.gateway_instance_type
  key_name = var.key_name
  enable_volume_encryption = var.enable_volume_encryption
  enable_instance_connect = var.enable_instance_connect
  metadata_imdsv2_required = var.metadata_imdsv2_required
  minimum_group_size = var.gateways_min_group_size
  maximum_group_size = var.gateways_max_group_size
  target_groups = tolist([module.external_load_balancer.target_group_arn])
  gateway_version = var.gateway_version
  admin_shell = var.admin_shell
  gateway_password_hash = var.gateway_password_hash
  gateway_maintenance_mode_password_hash = var.gateway_maintenance_mode_password_hash
  gateway_SICKey = var.gateway_SICKey
  allow_upload_download = var.allow_upload_download
  enable_cloudwatch = var.enable_cloudwatch
  gateway_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; echo 'Adding quickstart identifier to cloud-version'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: autoscale_qs' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"autoscale_qs\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; echo -e '\nFinished Bootstrap script\n'"
  management_server = "${var.provision_tag}-management"
  configuration_template = "${var.provision_tag}-template"
}

data "aws_region" "current"{}

module "management" {

  count = local.deploy_management_condition ? 1 : 0
  source = "../../modules/management"

  vpc_id = var.vpc_id
  subnet_id = var.gateways_subnets[0]
  management_name = "${var.provision_tag}-management"
  management_instance_type = var.management_instance_type
  key_name = var.key_name
  volume_encryption = var.enable_volume_encryption ? "alias/aws/ebs" : ""
  enable_instance_connect = var.enable_instance_connect
  disable_instance_termination = var.disable_instance_termination
  metadata_imdsv2_required = var.metadata_imdsv2_required
  iam_permissions = "Create with read-write permissions"
  management_version = var.management_version
  admin_shell = var.admin_shell
  management_password_hash = var.management_password_hash
  management_maintenance_mode_password_hash = var.management_maintenance_mode_password_hash
  allow_upload_download = var.allow_upload_download
  admin_cidr = var.admin_cidr
  gateway_addresses = var.gateways_addresses
  management_bootstrap_script = "echo -e '\nStarting Bootstrap script\n'; echo 'Adding quickstart identifier to cloud-version'; cv_path='/etc/cloud-version'\n if test -f \"$cv_path\"; then sed -i '/template_name/c\\template_name: management_qs' /etc/cloud-version; fi; cv_json_path='/etc/cloud-version.json'\n cv_json_path_tmp='/etc/cloud-version-tmp.json'\n if test -f \"$cv_json_path\"; then cat \"$cv_json_path\" | jq '.template_name = \"'\"management_qs\"'\"' > \"$cv_json_path_tmp\"; mv \"$cv_json_path_tmp\" \"$cv_json_path\"; fi; echo 'Creating CME configuration'; autoprov_cfg -f init AWS -mn ${var.provision_tag}-management -tn ${var.provision_tag}-template -cn ${var.provision_tag}-controller -po ${var.gateways_policy} -otp ${var.gateway_SICKey} -r ${data.aws_region.current.name} -ver ${split("-", var.gateway_version)[0]} -iam; ${var.gateways_blades} && autoprov_cfg -f set template -tn ${var.provision_tag}-template -ips -appi -av -ab; echo -e '\nFinished Bootstrap script\n'"
}

resource "aws_security_group" "internal_security_group" {
  count = local.deploy_servers_condition ? 1 : 0
  vpc_id = var.vpc_id

  egress {
    from_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    protocol = "tcp"
    to_port = local.provided_port_condition ? var.service_port : local.encrypted_protocol_condition ? 443 : 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = local.encrypted_protocol_condition ? 443 : 80
    protocol = "tcp"
    to_port = local.encrypted_protocol_condition ? 443 : 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = -1
    protocol = "icmp"
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "internal_load_balancer" {
  count = local.deploy_servers_condition ? 1 : 0
  source = "../../modules/load_balancer"

  load_balancers_type = var.load_balancers_type
  instances_subnets = var.servers_subnets
  prefix_name = "${var.prefix}-Internal"
  internal = true
  security_groups = local.alb_condition ? [aws_security_group.internal_security_group[0].id] : []
  tags = {
    x-chkp-management = "${var.provision_tag}-management"
    x-chkp-template = "${var.provision_tag}-template"
  }
  vpc_id = var.vpc_id
  load_balancer_protocol = var.load_balancer_protocol
  target_group_port = local.encrypted_protocol_condition ? 443 : 80
  listener_port = local.encrypted_protocol_condition ? "443" : "80"
  certificate_arn = local.encrypted_protocol_condition ? var.certificate : ""
}

module "custom_autoscale" {
  count = local.deploy_servers_condition ? 1 : 0
  source = "../../modules/custom_autoscale"

  prefix = var.prefix
  asg_name = var.asg_name
  vpc_id = var.vpc_id
  servers_subnets = var.servers_subnets
  server_ami = var.server_ami
  server_name = "${var.provision_tag}-server"
  servers_instance_type = var.servers_instance_type
  key_name = var.key_name
  servers_min_group_size = var.gateways_min_group_size
  servers_max_group_size = var.gateways_max_group_size
  servers_target_groups = module.internal_load_balancer[0].target_group_id
  deploy_internal_security_group = local.nlb_condition ? true : false
  source_security_group = local.nlb_condition ? "" : aws_security_group.internal_security_group[0].id
}