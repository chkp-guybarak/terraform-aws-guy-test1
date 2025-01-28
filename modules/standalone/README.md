# Check Point CloudGuard Network Security Management Server & Security Gateway (Standalone) Terraform module for AWS

Terraform module which deploys a Check Point CloudGuard Network Security Gateway & Management (Standalone) instance into an existing VPC.

These types of Terraform resources are supported:
* [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [Security group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [Network interface](https://www.terraform.io/docs/providers/aws/r/network_interface.html)
* [EIP](https://www.terraform.io/docs/providers/aws/r/eip.html) - conditional creation
* [Route](https://www.terraform.io/docs/providers/aws/r/route.html) - conditional creation


This solution uses the following modules:
- amis


## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/checkpointsw/cloudguard-network-security/aws/latest#:~:text=Best%20Practices%20for%20Using%20Our%20Modules).


**Example:**
```
provider "aws" {}

module "example_module" {

    source  = "CheckPointSW/cloudguard-network-security/aws//modules/standalone"
    version = "1.0.0"

    // --- VPC Network Configuration ---
    vpc_id = "vpc-12345678"
    public_subnet_id = "subnet-123456"
    private_subnet_id = "subnet-345678"
    private_route_table = "rtb-12345678"

    // --- EC2 Instance Configuration ---
    standalone_name = "Check-Point-Standalone-tf"
    standalone_instance_type = "c5.xlarge"
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
    standalone_version = "R81.20-BYOL"
    admin_shell = "/etc/cli.sh"
    standalone_password_hash = ""
    standalone_maintenance_mode_password_hash = ""
    // --- Advanced Settings ---
    resources_tag_name = "tag-name"
    standalone_hostname = "standalone-tf"
    allow_upload_download = true
    enable_cloudwatch = false
    standalone_bootstrap_script = "echo 'this is bootstrap script' > /home/admin/bootstrap.txt"
    primary_ntp = ""
    secondary_ntp = ""
    admin_cidr = "0.0.0.0/0"
    gateway_addresses = "0.0.0.0/0"
}
  ```

- Conditional creation
  - To create an Elastic IP and associate it to the Standalone instance:
  ```
  allocate_and_associate_eip = true
  ```
  - To create route from '0.0.0.0/0' to the Standalone instance, please provide route table:
  ```
  private_route_table = "rtb-12345678"
  ```



## Inputs

| Name                                   | Description                                                                                                                                                  | Type         | Allowed Values                                                                                     |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|---------------------------------------------------------------------------------------------------|
| vpc_id                                 | The VPC ID in which to deploy                                                                                                                               | string       |                                                                                                |
| public_subnet_id                       | Public subnet for Security Gateway & Management (Standalone)                                                                                                | string       |                                                                                                |
| private_subnet_id                      | Private subnet for Security Gateway & Management (Standalone)                                                                                               | string       |                                                                                                |
| private_route_table                    | Sets `0.0.0.0/0` route in the specified route table (e.g., rtb-12a34567)                                                                                     | string       |                                                                                                |
| standalone_name                        | (Optional) Name tag of the Standalone instance                                                                                                              | string       | **Default:** Check-Point-Standalone-tf                                                   |
| standalone_instance_type               | Instance type of the Standalone instance                                                                                                                    | string       | - c5.large<br>- c5.xlarge<br>- m6a.large<br>**Default:** c5.xlarge                                |
| key_name                               | EC2 Key Pair name to allow SSH access                                                                                                                       | string       |                                                                                                |
| allocate_and_associate_eip             | Allocates and associates an Elastic IP                                                                                                                      | bool         | true/false<br>**Default:** true                                                                  |
| volume_size                            | Root volume size (GB) - minimum 100                                                                                                                         | number       | **Default:** 100                                                                          |
| volume_encryption                      | KMS or CMK key identifier (e.g., alias/aws/ebs)                                                                                                            | string       | **Default:** alias/aws/ebs                                                               |
| enable_instance_connect                | Enable SSH connection over AWS web console                                                                                                                 | bool         | true/false<br>**Default:** false                                                                 |
| disable_instance_termination           | Prevent accidental termination                                                                                                                             | bool         | true/false<br>**Default:** false                                                                 |
| metadata_imdsv2_required               | Deploy instance with metadata v2 token required                                                                                                            | bool         | true/false<br>**Default:** true                                                                  |
| instance_tags                          | (Optional) Map of tags as key-value pairs                                                                                                                  | map(string)  |                                                                                                |
| standalone_version                     | Standalone version and license                                                                                                                             | string       | - R81.10-BYOL<br>- R82-BYOL<br>**Default:** R81.20-BYOL                                          |
| admin_shell                            | Set admin shell for advanced configurations                                                                                                                | string       | - /etc/cli.sh<br>- /bin/bash<br>- /bin/csh<br>**Default:** /etc/cli.sh                           |
| standalone_password_hash               | (Optional) Admin user's password hash                                                                                                                      | string       |                                                                                                |
| resources_tag_name                     | (Optional) Name tag prefix for resources                                                                                                                   | string       |                                                                                                |
| standalone_hostname                    | (Optional) Standalone instance prompt hostname                                                                                                             | string       |                                                                                                |
| allow_upload_download                  | Automatically download Blade Contracts and other data                                                                                                       | bool         | true/false<br>**Default:** true                                                                  |
| enable_cloudwatch                      | Report Check Point-specific CloudWatch metrics                                                                                                             | bool         | true/false<br>**Default:** false                                                                 |
| standalone_bootstrap_script            | (Optional) Semicolon-separated commands to run during initial boot                                                                                         | string       |                                                                                                |
| primary_ntp                            | (Optional) IPv4 address of the primary Network Time Protocol server                                                                                        | string       | **Default:** 169.254.169.123                                                             |
| secondary_ntp                          | (Optional) IPv4 address of the secondary Network Time Protocol server                                                                                      | string       | **Default:** 0.pool.ntp.org                                                              |
| admin_cidr                             | CIDR for allowing access to Management Server                                                                                                              | string       | **Default:** 0.0.0.0/0                                                                    |
| gateway_addresses                      | CIDR for allowing gateway access to Management Server                                                                                                       | string       | **Default:** 0.0.0.0/0                                                                    |
| standalone_maintenance_mode_password_hash | (Optional) Admin user's password hash for maintenance mode                                                                                                 | string       |                                                                                                |


## Outputs
| Name                     | Description                                                                  |
|--------------------------|------------------------------------------------------------------------------|
| standalone_instance_id   | The deployed Security Gateway & Management (Standalone) AWS instance id      |
| standalone_instance_name | The deployed Security Gateway & Management (Standalone) AWS instance name    |
| standalone_public_ip     | The deployed Security Gateway & Management (Standalone) AWS public address   |
| standalone_ssh           | SSH command to the Security Gateway & Management (Standalone)                |
| standalone_url           | URL to the portal of the deployed Security Gateway & Management (Standalone) |

## Revision History
In order to check the template version, please refer to [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description                                                                                                      |
|------------------|------------------------------------------------------------------------------------------------------------------|
| 20241027         | R82 version support                                                                                              |
| 20210309         | First release of Check Point Security Management Server & Security Gateway (Standalone) Terraform module for AWS |

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details