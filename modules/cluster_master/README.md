# Check Point CloudGuard Network Security Cluster Master Terraform module for AWS

Terraform module which deploys a Check Point CloudGuard Network Security Cluster into a new VPC.

These types of Terraform resources are supported:
* [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [VPC](https://www.terraform.io/docs/providers/aws/r/vpc.html)
* [Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [Network interface](https://www.terraform.io/docs/providers/aws/r/network_interface.html)
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html)
* [EIP](https://www.terraform.io/docs/providers/aws/r/eip.html) - conditional creation
* [IAM Role](https://www.terraform.io/docs/providers/aws/r/iam_role.html) - conditional creation

See the [Deploying a Check Point Cluster in AWS (Amazon Web Services)](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk104418) for additional information

This solution uses the following modules:
- cluster
- amis
- vpc
- cluster_iam_role

## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/checkpointsw/cloudguard-network-security/aws/latest#:~:text=Best%20Practices%20for%20Using%20Our%20Modules).

**Instead of the standard terraform apply command, use the following:**
```
  terraform apply -target=module.{module_name}.aws_route_table.private_subnet_rtb -auto-approve && terraform apply 
  ```

**Example:**
```
provider "aws" {}

module "example_module" {

    source  = "CheckPointSW/cloudguard-network-security/aws//modules/cluster_master"
    version = "1.0.0"


    // --- VPC Network Configuration ---
    vpc_cidr = "10.0.0.0/16"
    public_subnets_map = {
      "us-east-1a" = 1
    }
    private_subnets_map = {
      "us-east-1a" = 2
    }
    subnets_bit_length = 8

    // --- EC2 Instance Configuration ---
    gateway_name = "Check-Point-Cluster-tf"
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
    predefined_role = ""

    // --- Check Point Settings ---
    gateway_version = "R81.20-BYOL"
    admin_shell = "/etc/cli.sh"
    gateway_SICKey = "12345678"
    gateway_password_hash = ""
    gateway_maintenance_mode_password_hash = "" # For R81.10 and below the gateway_password_hash is used also as maintenance-mode password.

    // --- Quick connect to Smart-1 Cloud (Recommended) ---
    memberAToken = ""
    memberBToken = ""
  
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
  - To create an Elastic IP and associate it to each cluster member instance:
  ```
  allocate_and_associate_eip = "true"
  ```
  - To create IAM Role:
  ```
  predefined_role = ""
  ```

  ### Optional re-deploy of cluster member:
  In case of re-deploying one cluster member, make sure that it's in STANDBY state, and the second member is the ACTIVE one.
  Follow the commands below in order to re-deploy (replace MEMBER with a or b):
  - terraform taint module.launch_cluster_into_vpc.aws_instance.member-MEMBER-instance
  - terraform plan (review the changes)
  - terraform apply
  - In Smart Console: reset SIC with the re-deployed member and install policy

## Inputs

| Name                                   | Description                                                                                                                                                                      | Type         | Allowed Values                                                                                                 |
|----------------------------------------|----------------------------|--------------|---------------------------------------------------------------------------------------------------------------|
| vpc_cidr                               | The CIDR block of the VPC                                                                                                                                                        | string       |                                                                                                            |
| public_subnets_map                     | A map of pairs {availability-zone = subnet-suffix-number}. Each entry creates a subnet. Minimum 1 pair (e.g., {"us-east-1a" = 1}).                                              | map          |                                                                                                            |
| private_subnets_map                    | A map of pairs {availability-zone = subnet-suffix-number}. Each entry creates a subnet. Minimum 1 pair (e.g., {"us-east-1a" = 2}).                                              | map          |                                                                                                            |
| subnets_bit_length                     | Number of additional bits to extend the VPC CIDR. For example, with a VPC CIDR ending in /16 and subnets_bit_length = 4, resulting subnet will have length /20.                   | number       |                                                                                                            |
| gateway_name                           | (Optional) The name tag of the Security Gateway instances                                                                                                                        | string       | **Default:** Check-Point-Cluster-tf                                                                    |
| gateway_instance_type                  | The instance type of the Security Gateways                                                                                                                                       | string       | c5.large, c5.xlarge, m6a.large, etc.<br>**Default:** c5.xlarge                                                |
| key_name                               | The EC2 Key Pair name to allow SSH access to the instance                                                                                                                        | string       |                                                                                                            |
| allocate_and_associate_eip             | Allocate and associate Elastic IP for each cluster member, in addition to the shared cluster Elastic IP.                                                                         | bool         | true/false<br>**Default:** true                                                                               |
| volume_size                            | Root volume size (GB) - minimum 100                                                                                                                                              | number       | **Default:** 100                                                                                       |
| volume_encryption                      | KMS or CMK key Identifier. Use key ID, alias, or ARN (e.g., alias/aws/ebs).                                                                                                     | string       | **Default:** alias/aws/ebs                                                                             |
| enable_instance_connect                | Enable AWS Instance Connect. Supporting regions are listed [here](https://aws.amazon.com/about-aws/whats-new/2019/06/introducing-amazon-ec2-instance-connect/).                   | bool         | true/false<br>**Default:** false                                                                              |
| disable_instance_termination           | Prevent accidental termination. Note: When set, `terraform destroy` may not work properly.                                                                                       | bool         | true/false<br>**Default:** false                                                                              |
| metadata_imdsv2_required               | Deploy the instance with metadata v2 token requirement                                                                                                                          | bool         | true/false<br>**Default:** true                                                                               |
| instance_tags                          | (Optional) A map of tags (key=value) to add to Gateway EC2 Instances                                                                                                             | map(string)  | **Default:** {}                                                                                        |
| predefined_role                        | (Optional) Predefined IAM role to attach to the cluster profile                                                                                                                  | string       |                                                                                                            |
| gateway_version                        | Gateway version and license                                                                                                                                                      | string       | R81.10-BYOL, R81.20-BYOL, R82-BYOL, etc.<br>**Default:** R81.20-BYOL                                          |
| admin_shell                            | Set the admin shell to enable advanced CLI configuration                                                                                                                         | string       | /etc/cli.sh, /bin/bash, /bin/csh, /bin/tcsh<br>**Default:** /etc/cli.sh                                       |
| gateway_SICKey                         | Secure Internal Communication key for trusted connection (at least 8 alphanumeric characters)                                                                                    | string       | **Default:** "12345678"                                                                                |
| gateway_password_hash                  | (Optional) Admin user's password hash (use `openssl passwd -6 PASSWORD`).                                                                                                        | string       |                                                                                                            |
| memberAToken                           | (Optional) Quick connect token for Smart-1 Cloud, for Member A.                                                                                                                  | string       |                                                                                                            |
| memberBToken                           | (Optional) Quick connect token for Smart-1 Cloud, for Member B.                                                                                                                  | string       |                                                                                                            |
| resources_tag_name                     | (Optional) Prefix for resource tags                                                                                                                                              | string       |                                                                                                            |
| gateway_hostname                       | (Optional) Hostname of the gateway (appended with member-a/b).                                                                             | string       |                                                                                                            |
| allow_upload_download                  | Automatically download Blade Contracts and other important data.                                                                           | bool         | true/false<br>**Default:** true                                                                               |
| enable_cloudwatch                      | Report Check Point-specific CloudWatch metrics                                                                                                                                  | bool         | true/false<br>**Default:** false                                                                              |
| gateway_bootstrap_script               | (Optional) Commands to run on the initial boot, separated by semicolons (;).                                                                                                     | string       |                                                                                                            |
| primary_ntp                            | (Optional) IPv4 address of the primary Network Time Protocol (NTP) server                                                                                                        | string       | **Default:** 169.254.169.123                                                                           |
| secondary_ntp                          | (Optional) IPv4 address of the secondary Network Time Protocol (NTP) server                                                                                                      | string       | **Default:** 0.pool.ntp.org                                                                            |
| gateway_maintenance_mode_password_hash | (Optional) Maintenance-mode password hash (use `grub2-mkpasswd-pbkdf2` for hash generation).                                                                                     | string       |                                                                                                            |
 security_rules | List of security rules for ingress and egress.                                                         | list(object({<br/>    direction   = string    <br/>from_port   = any    <br/>to_port     = any <br/>protocol    = any <br/>cidr_blocks = list(any)<br/>}))         | **Default:** []|



## Outputs
| Name               | Description                                         |
|--------------------|-----------------------------------------------------|
| ami_id             | The ami id of the deployed Security Cluster members |
| cluster_public_ip  | The public address of the cluster                   |
| member_a_public_ip | The public address of member A                      |
| member_b_public_ip | The public address of member B                      |
| member_a_ssh       | SSH command to member A                             |
| member_b_ssh       | SSH command to member B                             |
| member_a_url       | URL to the member A portal                          |
| member_b_url       | URL to the member B portal                          |
