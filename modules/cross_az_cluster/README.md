# Check Point CloudGuard Network Security Cross AZ Cluster Terraform module for AWS

Terraform module which deploys a Check Point CloudGuard Network Security Cross AZ Cluster into an existing VPC on AWS.

These types of Terraform resources are supported:
* [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [Network interface](https://www.terraform.io/docs/providers/aws/r/network_interface.html)
* [EIP](https://www.terraform.io/docs/providers/aws/r/eip.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html) - conditional creation
* [IAM Role](https://www.terraform.io/docs/providers/aws/r/iam_role.html) - conditional creation

See the [Deploying a Check Point Cluster in AWS (Amazon Web Services)](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_for_AWS_Cross_AZ_Cluster/Default.htm) for additional information

This solution uses the following modules:
- amis
- cluster_iam_role


## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/checkpointsw/cloudguard-network-security/aws/latest#:~:text=Best%20Practices%20for%20Using%20Our%20Modules).


**Example:**
```
provider "aws" {}

module "example_module" {

    source  = "CheckPointSW/cloudguard-network-security/aws//modules/cross_az_cluster"
    version = "1.0.0"

    // --- VPC Network Configuration ---
    vpc_id = "vpc-12345678"
    public_subnet_ids = ["subnet-abc123", "subnet-def456"]
    private_subnet_ids = ["subnet-abc234", "subnet-def567"]
    private_route_table = "rtb-12345678"
  

    // --- EC2 Instance Configuration ---
    gateway_name = "Check-Point-Cluster-tf"
    gateway_instance_type = "c5.xlarge"
    key_name = "publickey"
    volume_size = 100
    volume_encryption = "alias/aws/ebs"
    enable_instance_connect = false
    disable_instance_termination = false
    instance_tags = {
      key1 = "value1"
      key2 = "value2"
    }
    predefined_role = ""

    // --- Check Point Settings ---
    gateway_version = "R81.20-BYOL"
    admin_shell = "/etc/cli.sh"
    gateway_SICKey = "12345678"
    gateway_password_hash = ""
  
    // --- Quick connect to Smart-1 Cloud (Recommended) ---
    memberAToken = ""
    memberBToken = ""
    gateway_maintenance_mode_password_hash = "" # For R81.10 and below the gateway_password_hash is used also as maintenance-mode password.

    // --- Advanced Settings ---
    resources_tag_name = "tag-name"
    gateway_hostname = "gw-hostname"
    allow_upload_download = true
    enable_cloudwatch = false
    gateway_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"
    primary_ntp = ""
    secondary_ntp = ""
}
  ```

- Conditional creation
  - To create IAM Role:
  ```
  predefined_role = ""
  ```
  - To create route from '0.0.0.0/0' to the Active Cluster member instance, please provide route table:
  ```
  private_route_table = "rtb-12345678"
  ```

  ### Optional re-deploy of cluster member:
  In case of re-deploying one cluster member, make sure that it's in STANDBY state, and the second member is the ACTIVE one.
  Follow the commands below in order to re-deploy (replace MEMBER with a or b):
  - terraform taint aws_instance.member-MEMBER-instance
  - terraform plan (review the changes)
  - terraform apply
  - In Smart Console: reset SIC with the re-deployed member and install policy

## Inputs

| Name                                   | Description                                                                                                                                                     | Type         | Allowed Values                                                                                                       |
|----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|---------------------------------------------------------------------------------------------------------------------|
| vpc_id                                 | The VPC id in which to deploy                                                                                                                                  | string       |                                                                                                                  |
| public_subnet_ids                      | List of public subnet IDs to launch resources into. At least 2                                                                                                 | list(string) |                                                                                                                  |
| private_subnet_ids                     | List of private subnet IDs to launch resources into. At least 2                                                                                                | list(string) |                                                                                                                  |
| private_route_table                    | (Optional) Set 0.0.0.0/0 route to the Active Cluster member instance in this route table. Route table cannot have an existing 0.0.0.0/0 route                  | string       |                                                                                                                  |
| gateway_name                           | (Optional) The name tag of the Security Gateway instances                                                                                                      | string       | **Default:** Check-Point-Cluster-tf                                                                          |
| gateway_instance_type                  | The instance type of the Security Gateways                                                                                                                     | string       | - c5.large<br>- c5.xlarge<br>- m6a.large<br>**Default:** c5.xlarge                                                  |
| key_name                               | The EC2 Key Pair name to allow SSH access to the instance                                                                                                      | string       |                                                                                                                  |
| volume_size                            | Root volume size (GB) - minimum 100                                                                                                                           | number       | **Default:** 100                                                                                            |
| volume_type                            | General Purpose SSD Volume Type                                                                                                                               | string       | - gp3<br>- gp2<br>**Default:** gp3                                                                                 |
| volume_encryption                      | KMS or CMK key Identifier: Use key ID, alias, or ARN. Key alias should be prefixed with 'alias/'.                                                             | string       | **Default:** alias/aws/ebs                                                                                  |
| enable_instance_connect                | Enable AWS Instance Connect. Supporting regions can be found [here](https://aws.amazon.com/about-aws/whats-new/2019/06/introducing-amazon-ec2-instance-connect/) | bool         | true/false<br>**Default:** false                                                                                   |
| disable_instance_termination           | Prevents an instance from accidental termination. Note: Once this attribute is true terraform destroy won't work properly                                      | bool         | true/false<br>**Default:** false                                                                                   |
| metadata_imdsv2_required               | Set true to deploy the instance with metadata v2 token required                                                                                              | bool         | true/false<br>**Default:** true                                                                                    |
| instance_tags                          | (Optional) A map of tags as key=value pairs. All tags will be added to the Gateway EC2 Instances                                                              | map(string)  |                                                                                                                  |
| predefined_role                        | (Optional) A predefined IAM role to attach to the cluster profile                                                                                            | string       |                                                                                                                  |
| gateway_version                        | Gateway version and license                                                                                                                                  | string       | - R81.20-BYOL<br>- R81.20-PAYG-NGTP<br>- R82-BYOL<br>**Default:** R81.20-BYOL                                       |
| admin_shell                            | Set the admin shell to enable advanced command line configuration                                                                                            | string       | - /etc/cli.sh<br>- /bin/bash<br>- /bin/csh<br>**Default:** /etc/cli.sh                                             |
| gateway_SICKey                         | The Secure Internal Communication key for trusted connection between Check Point components. At least 8 alphanumeric characters required                     | string       | **Default:** 12345678                                                                                       |
| gateway_password_hash                  | (Optional) Admin user's password hash                                                                                                                        | string       |                                                                                                                  |
| memberAToken                           | (Recommended) Quick connect to Smart-1 Cloud. Follow SK180501 for instructions.                                                                              | string       |                                                                                                                  |
| memberBToken                           | (Recommended) Quick connect to Smart-1 Cloud. Follow SK180501 for instructions.                                                                              | string       |                                                                                                                  |
| resources_tag_name                     | (Optional) Name tag prefix of the resources                                                                                                                  | string       |                                                                                                                  |
| gateway_hostname                       | (Optional) The host name will be appended with member-a/b accordingly. The name must not contain reserved words. Refer to SK40179.                           | string       |                                                                                                                  |
| allow_upload_download                  | Automatically download Blade Contracts and other important data                                                                                              | bool         | true/false<br>**Default:** true                                                                                    |
| enable_cloudwatch                      | Report Check Point specific CloudWatch metrics                                                                                                              | bool         | true/false<br>**Default:** false                                                                                   |
| gateway_bootstrap_script               | (Optional) Semicolon (;) separated commands to run on the initial boot                                                                                       | string       |                                                                                                                  |
| primary_ntp                            | (Optional) The IPv4 addresses of Network Time Protocol primary server                                                                                       | string       | **Default:** 169.254.169.123                                                                               |
| secondary_ntp                          | (Optional) The IPv4 addresses of Network Time Protocol secondary server                                                                                     | string       | **Default:** 0.pool.ntp.org                                                                                |
| gateway_maintenance_mode_password_hash | (Optional) Check Point recommends setting Admin user's password and maintenance-mode password.                                                              | string       |                                                                                                                  |
 security_rules | List of security rules for ingress and egress.                                                         | list(object({<br/>    direction   = string    <br/>from_port   = any    <br/>to_port     = any <br/>protocol    = any <br/>cidr_blocks = list(any)<br/>}))         | **Default:** []|



## Outputs
| Name               | Description                                                  |
|--------------------|--------------------------------------------------------------|
| ami_id             | The ami id of the deployed Security Cross AZ Cluster members |
| cluster_public_ip  | The public address of the cluster                            |
| member_a_public_ip | The public address of member A                               |
| member_b_public_ip | The public address of member B                               |
| member_a_ssh       | SSH command to member A                                      |
| member_b_ssh       | SSH command to member B                                      |
| member_a_url       | URL to the member A portal                                   |
| member_b_url       | URL to the member B portal                                   |
