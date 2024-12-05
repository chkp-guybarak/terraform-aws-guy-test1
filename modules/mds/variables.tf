// Module: Check Point CloudGuard Network Multi-Domain Server into an existing VPC

// --- VPC Network Configuration ---
variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
  description = "To access the instance from the internet, make sure the subnet has a route to the internet"
}

// --- EC2 Instance Configuration ---
variable "mds_name" {
  type = string
  description = "(Optional) The name tag of the Multi-Domain Server instance"
  default = "Check-Point-MDS-tf"
}
variable "mds_instance_type" {
  type = string
  description = "The instance type of the Multi-Domain Server"
  default = "m5.2xlarge"
}
module "validate_instance_type" {
  source = "../modules/common/instance_type"

  chkp_type = "mds"
  instance_type = var.mds_instance_type
}
variable "key_name" {
  type = string
  description = "The EC2 Key Pair name to allow SSH access to the instance"
}
variable "volume_size" {
  type = number
  description = "Root volume size (GB) - minimum 100"
  default = 100
}
resource "null_resource" "volume_size_too_small" {
  // Will fail if var.volume_size is less than 100
  count = var.volume_size >= 100 ? 0 : "variable volume_size must be at least 100"
}
variable "volume_encryption" {
  type = string
  description = "KMS or CMK key Identifier: Use key ID, alias or ARN. Key alias should be prefixed with 'alias/' (e.g. for KMS default alias 'aws/ebs' - insert 'alias/aws/ebs')"
  default = "alias/aws/ebs"
}
variable "enable_instance_connect" {
  type = bool
  description = "Enable SSH connection over AWS web console"
  default = false
}
variable "disable_instance_termination" {
  type = bool
  description = "Prevents an instance from accidental termination"
  default = false
}
variable "metadata_imdsv2_required" {
  type = bool
  description = "Set true to deploy the instance with metadata v2 token required"
  default = true
}
variable "instance_tags" {
  type = map(string)
  description = "(Optional) A map of tags as key=value pairs. All tags will be added to the Multi-Domain Server EC2 Instance"
  default = {}
}

// --- IAM Permissions (ignored when the installation type is not Primary Multi-Domain Server) ---
variable "iam_permissions" {
  type = string
  description = "IAM role to attach to the instance profile"
  default = "Create with read permissions"
}
variable "predefined_role" {
  type = string
  description = "(Optional) A predefined IAM role to attach to the instance profile. Ignored if var.iam_permissions is not set to 'Use existing'"
  default = ""
}
variable "sts_roles" {
  type = list(string)
  description = "(Optional) The IAM role will be able to assume these STS Roles (list of ARNs). Ignored if var.iam_permissions is set to 'None' or 'Use existing'"
  default = []
}

// --- Check Point Settings ---
variable "mds_version" {
  type = string
  description = "Multi-Domain Server version and license"
  default = "R81.20-BYOL"
}
module "validate_mds_version" {
  source = "../modules/common/version_license"

  chkp_type = "mds"
  version_license = var.mds_version
}
variable "mds_admin_shell" {
  type = string
  description = "Set the admin shell to enable advanced command line configuration"
  default = "/etc/cli.sh"
}
variable "mds_password_hash" {
  type = string
  description = "(Optional) Admin user's password hash (use command 'openssl passwd -6 PASSWORD' to get the PASSWORD's hash)"
  default = ""
}
variable "mds_maintenance_mode_password_hash" {
  description = "(optional) Check Point recommends setting Admin user's password and maintenance-mode password for recovery purposes. For R81.10 and below the Admin user's password is used also as maintenance-mode password. (To generate a password hash use the command 'grub2-mkpasswd-pbkdf2' on Linux and paste it here)."
  type = string
  default = ""
}

// --- Multi-Domain Server Settings ---
variable "mds_hostname" {
  type = string
  description = "(Optional) Multi-Domain Server prompt hostname"
  default = ""
}
variable "mds_SICKey" {
  type = string
  description = "Mandatory if deploying a Secondary Multi-Domain Server or Multi-Domain Log Server,  the Secure Internal Communication key creates trusted connections between Check Point components. Choose a random string consisting of at least 8 alphanumeric characters"
  default = ""
}
variable "allow_upload_download" {
  type = bool
  description = "Automatically download Blade Contracts and other important data. Improve product experience by sending data to Check Point"
  default = true
}
variable "mds_installation_type" {
  type = string
  description = "Determines the Multi-Domain Server installation type"
  default = "Primary Multi-Domain Server"
}
variable "admin_cidr" {
  type = string
  description = "(CIDR) Allow web, ssh, and graphical clients only from this network to communicate with the Multi-Domain Server"
  default = "0.0.0.0/0"
}
variable "gateway_addresses" {
  type = string
  description = "(CIDR) Allow gateways only from this network to communicate with the Multi-Domain Server"
  default = "0.0.0.0/0"
}
variable "primary_ntp" {
  type = string
  description = "(Optional) The IPv4 addresses of Network Time Protocol primary server"
  default = "169.254.169.123"
}
variable "secondary_ntp" {
  type = string
  description = "(Optional) The IPv4 addresses of Network Time Protocol secondary server"
  default = "0.pool.ntp.org"
}
variable "mds_bootstrap_script" {
  type = string
  description = "(Optional) Semicolon (;) separated commands to run on the initial boot"
  default = ""
}