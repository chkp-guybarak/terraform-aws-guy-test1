# Check Point CloudGuard Network Security Gateway Terraform module for AWS

Terraform module which deploys a Check Point CloudGuard Network Security Gateway into an existing VPC.

These types of Terraform resources are supported:
* [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [Security group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [Network interface](https://www.terraform.io/docs/providers/aws/r/network_interface.html)
* [EIP](https://www.terraform.io/docs/providers/aws/r/eip.html) - conditional creation
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html) - conditional creation

See the [Automatically Provision a CloudGuard Security Gateway in AWS](https://supportcenter.us.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk131434) for additional information

This solution uses the following modules:
- amis


## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/checkpointsw/cloudguard-network-security/aws/latest#:~:text=Best%20Practices%20for%20Using%20Our%20Modules).

**Example:**
```
provider "aws" {}

module "example_module" {

    source  = "CheckPointSW/cloudguard-network-security/aws//modules/gateway"
    version = "1.0.2"

    // --- VPC Network Configuration ---
    vpc_id = "vpc-12345678"
    public_subnet_id = "subnet-123456"
    private_subnet_id = "subnet-345678"
    private_route_table = "rtb-12345678"

    // --- EC2 Instance Configuration ---
    gateway_name = "Check-Point-Gateway-tf"
    gateway_instance_type = "c5.xlarge"
    key_name = "publickey"
    allocate_and_associate_eip = true
    volume_size = 100
    volume_encryption = "alias/aws/ebs"
    enable_instance_connect = false
    disable_instance_termination = false
    instance_tags = {
      key1 = "value1"
      key2 = "value2"
    }

    // --- Check Point Settings ---
    gateway_version = "R81.20-BYOL"
    admin_shell = "/etc/cli.sh"
    gateway_SICKey = "12345678"
    gateway_password_hash = ""
    gateway_maintenance_mode_password_hash = "" # For R81.10 and below the gateway_password_hash is used also as maintenance-mode password.
  
    // --- Quick connect to Smart-1 Cloud (Recommended) ---
    gateway_TokenKey = ""
  
    // --- Advanced Settings ---
    resources_tag_name = "tag-name"
    gateway_hostname = "gw-hostname"
    allow_upload_download = true
    enable_cloudwatch = false
    gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"
    primary_ntp = ""
    secondary_ntp = ""

    // --- Automatic Provisioning with Security Management Server Settings (optional) ---
    control_gateway_over_public_or_private_address =  "private"
    management_server = ""
    configuration_template = ""
}
  ```

- Conditional creation
  - To create an Elastic IP and associate it to the Gateway instance:
  ```
  allocate_and_associate_eip = true
  ```
  - To create route from '0.0.0.0/0' to the Security Gateway instance, please provide route table:
  ```
  private_route_table = "rtb-12345678"
  ```

## Inputs

| Name                                           | Description                                                                                                             | Type        | Allowed values                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|-------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| vpc_id                                         | The VPC id in which to deploy                                                                                           | string      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| public_subnet_id                               | The public subnet of the security gateway                                                                              | string      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| private_subnet_id                              | The private subnet of the security gateway                                                                             | string      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| private_route_table                            | Sets '0.0.0.0/0' route to the Gateway instance in the specified route table (e.g. rtb-12a34567)                          | string      | **Default:** ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| gateway_name                                   | (Optional) The name tag of the Security Gateway instance                                                                | string      | **Default:** Check-Point-Gateway-tf                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| gateway_instance_type                          | The instance type of the Security Gateways                                                                             | string      | - c4.large<br/>- c4.xlarge<br/>- c5.large<br/>- c5.xlarge<br/>- c5.2xlarge<br/>- c5.4xlarge<br/>- c5.9xlarge<br/>- c5.12xlarge<br/>- c5.18xlarge<br/>- c5.24xlarge<br/>- c5n.large<br/>- c5n.xlarge<br/>- c5n.2xlarge<br/>- c5n.4xlarge<br/>- c5n.9xlarge<br/>- c5n.18xlarge<br/>- c5d.large<br/>- c5d.xlarge<br/>- c5d.2xlarge<br/>- c5d.4xlarge<br/>- c5d.9xlarge<br/>- c5d.12xlarge<br/>- c5d.18xlarge<br/>- c5d.24xlarge<br/>- m5.large<br/>- m5.xlarge<br/>- m5.2xlarge<br/>- m5.4xlarge<br/>- m5.8xlarge<br/>- m5.12xlarge<br/>- m5.16xlarge<br/>- m5.24xlarge<br/>- m6i.large<br/>- m6i.xlarge<br/>- m6i.2xlarge<br/>- m6i.4xlarge<br/>- m6i.8xlarge<br/>- m6i.12xlarge<br/>- m6i.16xlarge<br/>- m6i.24xlarge<br/>- m6i.32xlarge<br/>- c6i.large<br/>- c6i.xlarge<br/>- c6i.2xlarge<br/>- c6i.4xlarge<br/>- c6i.8xlarge<br/>- c6i.12xlarge<br/>- c6i.16xlarge<br/>- c6i.24xlarge<br/>- c6i.32xlarge<br/>- c6in.large<br/>- c6in.xlarge<br/>- c6in.2xlarge<br/>- c6in.4xlarge<br/>- c6in.8xlarge<br/>- c6in.12xlarge<br/>- c6in.16xlarge<br/>- c6in.24xlarge<br/>- c6in.32xlarge<br/>- r5.large<br/>- r5.xlarge<br/>- r5.2xlarge<br/>- r5.4xlarge<br/>- r5.8xlarge<br/>- r5.12xlarge<br/>- r5.16xlarge<br/>- r5.24xlarge<br/>- r5a.large<br/>- r5a.xlarge<br/>- r5a.2xlarge<br/>- r5a.4xlarge<br/>- r5a.8xlarge<br/>- r5a.12xlarge<br/>- r5a.16xlarge<br/>- r5a.24xlarge<br/>- r5b.large<br/>- r5b.xlarge<br/>- r5b.2xlarge<br/>- r5b.4xlarge<br/>- r5b.8xlarge<br/>- r5b.12xlarge<br/>- r5b.16xlarge<br/>- r5b.24xlarge<br/>- r5n.large<br/>- r5n.xlarge<br/>- r5n.2xlarge<br/>- r5n.4xlarge<br/>- r5n.8xlarge<br/>- r5n.12xlarge<br/>- r5n.16xlarge<br/>- r5n.24xlarge<br/>- r6i.large<br/>- r6i.xlarge<br/>- r6i.2xlarge<br/>- r6i.4xlarge<br/>- r6i.8xlarge<br/>- r6i.12xlarge<br/>- r6i.16xlarge<br/>- r6i.24xlarge<br/>- r6i.32xlarge<br/>- m6a.large<br/>- m6a.xlarge<br/>- m6a.2xlarge<br/>- m6a.4xlarge<br/>- m6a.8xlarge<br/>- m6a.12xlarge<br/>- m6a.16xlarge<br/>- m6a.24xlarge<br/>- m6a.32xlarge<br/>- m6a.48xlarge<br/>**Default:** c5.xlarge                                                                                                                                                                                                                                                             |
| key_name                                       | The EC2 Key Pair name to allow SSH access to the instance                                                                 | string      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| allocate_and_associate_eip                     | If set to true, an elastic IP will be allocated and associated with the launched instance                                 | bool        | true/false<br/>**Default:** true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| volume_size                                    | Root volume size (GB) - minimum 100                                                                                      | number      | **Default:** 100                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| volume_encryption                              | KMS or CMK key Identifier: Use key ID, alias, or ARN. Key alias should be prefixed with 'alias/' (e.g., 'alias/aws/ebs')  | string      | **Default:** alias/aws/ebs                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| enable_instance_connect                        | Enable SSH connection over AWS web console. Supporting regions [AWS docs](https://aws.amazon.com/about-aws/whats-new/...) | bool        | true/false<br/>**Default:** false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| disable_instance_termination                   | Prevents an instance from accidental termination. Note: Once true, terraform destroy won't work                          | bool        | true/false<br/>**Default:** false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| metadata_imdsv2_required                       | Set true to deploy the instance with metadata v2 token required                                                         | bool        | true/false<br/>**Default:** true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| instance_tags                                  | A map of tags as key=value pairs. All tags will be added to the Security Gateway EC2 Instance                            | map(string) | **Default:** {}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| gateway_version                                | Gateway version and license                                                                                            | string      | - R81.10-BYOL<br/>- R81.10-PAYG-NGTP<br/>- R81.10-PAYG-NGTX<br/>- R81.20-BYOL<br/>- R81.20-PAYG-NGTP<br/>- R81.20-PAYG-NGTX<br/>- R82-BYOL<br/>- R82-PAYG-NGTP<br/>- R82-PAYG-NGTX<br/>**Default:** R81.20-BYOL                                                                                                                                                                                                                                                                                                                                                                                                   |
| admin_shell                                    | Set the admin shell to enable advanced command-line configuration                                                      | string      | - /etc/cli.sh<br/>- /bin/bash<br/>- /bin/csh<br/>- /bin/tcsh<br/>**Default:** /etc/cli.sh                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| gateway_SIC_Key                                | The Secure Internal Communication key for trusted connection between Check Point components. Choose a random 8+ string | string      |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| gateway_password_hash                          | (Optional) Admin user's password hash (use 'openssl passwd -6 PASSWORD' to generate hash)                                | string      | **Default:** ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| allow_upload_download                          | Automatically download Blade Contracts and other important data                                                        | bool        | true/false<br/>**Default:** true                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| enable_cloudwatch                              | Report Check Point specific CloudWatch metrics                                                                         | bool        | true/false<br/>**Default:** false                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| gateway_bootstrap_script                       | (Optional) Semicolon (;) separated commands to run on the initial boot                                                 | string      | **Default:** ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| primary_ntp                                    | (Optional) IPv4 address of Network Time Protocol primary server                                                        | string      | **Default:** 169.254.169.123                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| secondary_ntp                                  | (Optional) IPv4 address of Network Time Protocol secondary server                                                      | string      | **Default:** 0.pool.ntp.org                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| control_gateway_over_public_or_private_address | Determines if the Security Gateway is provisioned using its private or public address                                  | string      | - public<br/>- private<br/>**Default:** private                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| management_server                              | (Optional) Name that represents the Security Management Server in auto provisioning                                    | string      | **Default:** ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| configuration_template                         | (Optional) Name of a Security Gateway configuration template in auto provisioning                                      | string      | **Default:** ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| gateway_maintenance_mode_password_hash         | (Optional) Admin user's password and maintenance-mode password. For R81.10 and below, Admin password used as both      | string      | **Default:** ""                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| security_rules | List of security rules for ingress and egress.                                                         | list(object(<br/>{    direction   = string    <br/>from_port   = any    <br/>to_port     = any <br/>protocol    = any <br/>cidr_blocks = list(any)}))         | ****Default:**** []|






## Outputs
To display the outputs defined by the module, create an `outputs.tf` file with the following structure:
```
output "instance_public_ip" {
  value = module.{module_name}.instance_public_ip
}
```
| Name                  | Description                                        |
|-----------------------|----------------------------------------------------|
| ami_id                | The ami id of the deployed Security Gateway        |
| permissive_sg_id      | The permissive security group id                   |
| permissive_sg_name    | The permissive security group id name              |
| gateway_url           | URL to the portal of the deployed Security Gateway |
| gateway_public_ip     | The deployed Security Gateway Server AWS public ip |
| gateway_instance_id   | The deployed Security Gateway AWS instance id      |
| gateway_instance_name | The deployed Security Gateway AWS instance name    |
