# Check Point CloudGuard Network Transit Gateway Auto Scaling Group Terraform module for AWS

Terraform module which deploys a Check Point CloudGuard Network Security Gateway Auto Scaling Group for Transit Gateway with an optional Management Server into an existing VPC.

These types of Terraform resources are supported:
* [AWS Instance](https://www.terraform.io/docs/providers/aws/r/instance.html)
* [Security Group](https://www.terraform.io/docs/providers/aws/r/security_group.html)
* [Network interface](https://www.terraform.io/docs/providers/aws/r/network_interface.html)
* [CloudWatch Metric Alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm)
* [EIP](https://www.terraform.io/docs/providers/aws/r/eip.html)
* [Launch template](https://www.terraform.io/docs/providers/aws/r/launch_template.html)
* [Auto Scaling Group](https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html)
* [IAM Role](https://www.terraform.io/docs/providers/aws/r/iam_role.html) - conditional creation

See the [CloudGuard Network for AWS Transit Gateway R80.10 and Higher Deployment Guide](https://sc1.checkpoint.com/documents/IaaS/WebAdminGuides/EN/CP_CloudGuard_AWS_Transit_Gateway/Content/Topics-AWS-TGW-R80-10-AG/Introduction.htm) for additional information

This solution uses the following modules:
- autoscale
- management
- cme_iam_role


## Usage
Follow best practices for using CGNS modules on [the root page](https://registry.terraform.io/modules/checkpointsw/cloudguard-network-security/aws/latest#:~:text=Best%20Practices%20for%20Using%20Our%20Modules).


**Example:**
```
provider "aws" {}

module "example_module" {

    source  = "CheckPointSW/cloudguard-network-security/aws//modules/tgw_asg"
    version = "1.0.0"
    
    // --- Network Configuration ---
    vpc_id = "vpc-12345678"
    gateways_subnets = ["subnet-123b5678", "subnet-123a4567"]
    
    // --- General Settings ---
    key_name = "publickey"
    enable_volume_encryption = true
    enable_instance_connect = false
    disable_instance_termination = false
    allow_upload_download = true
    
    // --- Check Point CloudGuard Network Security Gateways Auto Scaling Group Configuration ---
    gateway_name = "Check-Point-gateway"
    gateway_instance_type = "c5.xlarge"
    gateways_min_group_size = 2
    gateways_max_group_size = 8
    gateway_version = "R81.20-BYOL"
    gateway_password_hash = ""
    gateway_maintenance_mode_password_hash = "" # For R81.10 and below the gateway_password_hash is used also as maintenance-mode password.
    gateway_SICKey = "12345678"
    enable_cloudwatch = true
    asn = "6500"
    
    // --- Check Point CloudGuard Network Security Management Server Configuration ---
    management_deploy = true
    management_instance_type = "m5.xlarge"
    management_version = "R81.20-BYOL"
    management_password_hash = ""
    management_maintenance_mode_password_hash = "" # For R81.10 and below the management_password_hash is used also as maintenance-mode password.
    management_permissions = "Create with read-write permissions"
    management_predefined_role = ""
    gateways_blades = true
    admin_cidr = "0.0.0.0/0"
    gateways_addresses = "0.0.0.0/0"
    gateway_management = "Locally managed"
    
    // --- Automatic Provisioning with Security Management Server Settings ---
    control_gateway_over_public_or_private_address = "private"
    management_server = "management-server"
    configuration_template = "template-name"
    ```

  - Conditional creation
    - To create a Security Management server with IAM Role:
    ```
    management_permissions = "Create with read permissions" | "Create with read-write permissions" | "Create with assume role permissions (specify an STS role ARN)"
    ```
    - To enable cloudwatch for ASG:
    ```
    enable_cloudwatch = true
    ```
    Note: enabling cloudwatch will automatically create IAM role with cloudwatch:PutMetricData permission
    - To deploy Security Management Server:
    ```
    management_deploy = true
  }
   ```


## Inputs

| Name                                      | Description                                                                                                                        | Type         | Allowed Values                                                                                         |
|-------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|--------------|-------------------------------------------------------------------------------------------------------|
| vpc_id                                    | Select an existing VPC                                                                                                             | string       |                                                                                                    |
| gateways_subnets                          | Select at least 2 public subnets in the VPC. If deploying a Security Management Server, it will be in the first subnet             | list(string) |                                                                                                    |
| key_name                                  | The EC2 Key Pair name to allow SSH access to the instances                                                                         | string       |                                                                                                    |
| enable_volume_encryption                  | Encrypt Environment instances volume with default AWS KMS key                                                                      | bool         | true/false<br>**Default:** true                                                                      |
| enable_instance_connect                   | Enable SSH connection over AWS web console. Supporting regions [here](https://aws.amazon.com/about-aws/whats-new/2019/06/introducing-amazon-ec2-instance-connect/) | bool         | true/false<br>**Default:** false                                                                     |
| disable_instance_termination              | Prevent accidental termination of an instance                                                                                      | bool         | true/false<br>**Default:** false                                                                     |
| metadata_imdsv2_required                  | Deploy instance with metadata v2 token required                                                                                    | bool         | true/false<br>**Default:** true                                                                      |
| allow_upload_download                     | Automatically download Blade Contracts and other data                                                                              | bool         | true/false<br>**Default:** true                                                                      |
| gateway_name                              | (Optional) Name tag of the Security Gateway instances                                                                              | string       | <br>**Default:** Check-Point-Gateway                                                             |
| gateway_instance_type                     | Instance type of the Security Gateways                                                                                            | string       | - c5.large<br>- c5.xlarge<br>- m6a.xlarge<br>**Default:** c5.xlarge                                   |
| gateways_min_group_size                   | Minimum number of Security Gateways                                                                                               | number       | <br>**Default:** 2                                                                               |
| gateways_max_group_size                   | Maximum number of Security Gateways                                                                                               | number       | <br>**Default:** 10                                                                              |
| gateway_version                           | Gateway version and license                                                                                                       | string       | - R81.20-BYOL<br>- R82-PAYG-NGTP<br>**Default:** R81.20-BYOL                                         |
| gateway_password_hash                     | (Optional) Admin user's password hash                                                                                            | string       |                                                                                                    |
| gateway_SIC_Key                           | Secure Internal Communication key                                                                                                | string       | <br>**Default:** "12345678"                                                                       |
| enable_cloudwatch                         | Report Check Point-specific CloudWatch metrics                                                                                   | bool         | true/false<br>**Default:** false                                                                     |
| asn                                       | Organization Autonomous System Number (ASN) identifying the routing domain                                                       | string       | <br>**Default:** 6500                                                                             |
| management_deploy                         | Set to 'false' to use an existing Security Management Server                                                                      | bool         | true/false<br>**Default:** true                                                                      |
| management_instance_type                  | Instance type of the Security Management Server                                                                                  | string       | - m5.large<br>- m6i.large<br>**Default:** m5.xlarge                                                  |
| management_version                        | License for the Security Management Server                                                                                       | string       | - R81.20-BYOL<br>- R82-BYOL<br>**Default:** R81.20-BYOL                                              |
| management_password_hash                  | (Optional) Admin user's password hash                                                                                            | string       |                                                                                                    |
| management_permissions                    | IAM role for the instance profile                                                                                                | string       | - None<br>- Use existing<br>- Create with read-write permissions<br>**Default:** Create with read-write permissions |
| gateways_blades                           | Enable the Intrusion Prevention System, Application Control, Anti-Virus, and Anti-Bot Blades                                     | bool         | true/false<br>**Default:** true                                                                      |
| admin_cidr                                | Allow web, SSH, and graphical clients only from this network                                                                     | string       |                                                                                                    |
| gateway_addresses                         | Allow gateways only from this network                                                                                           | string       |                                                                                                    |
| gateway_management                        | Select 'Over the internet' if gateways aren't accessed via private IP                                                             | string       | - Locally managed<br>- Over the internet<br>**Default:** Locally managed                             |
| control_gateway_over_public_or_private_address | Determines if gateways use private or public address                                                                             | string       | - private<br>- public<br>**Default:** private                                                        |
| management_server                         | (Optional) Name representing the Security Management Server                                                                       | string       | <br>**Default:** management-server                                                               |
| configuration_template                    | (Optional) Security Gateway configuration template                                                                               | string       | <br>**Default:** tgw_asg-configuration                                                           |
| gateway_maintenance_mode_password_hash    | Maintenance-mode password hash                                                                                                   | string       |                                                                                                    |
| management_maintenance_mode_password_hash | Maintenance-mode password hash for Security Management Server                                                                   | string       |                                                                                                    |


## Outputs
| Name                     | Description                                                                                                                                                                                                                                                 |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| management_instance_name | The deployed Security Management AWS instance name                                                                                                                                                                                                          |
| management_public_ip     | The deployed Security Management Server AWS public ip                                                                                                                                                                                                       |
| management_url           | URL to the portal of the deployed Security Management Server                                                                                                                                                                                                |
| autoscaling_group_name   | The name of the deployed AutoScaling Group                                                                                                                                                                                                                  |
| configuration_template   | The name that represents the configuration template. Configurations required to automatically provision the Gateways in the Auto Scaling Group, such as what Security Policy to install and which Blades to enable, will be placed under this template name |
| controller_name          | The name that represents the controller. Configurations required to connect to your AWS environment, such as credentials and regions, will be placed under this controller name                                                                             |

## Revision History
In order to check the template version, please refer to [sk116585](https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk116585)

| Template Version | Description                                                                                   |
|------------------|-----------------------------------------------------------------------------------------------|
| 20241027         | R82 version support                                                                           |
| 20240704         | - R80.40 version deprecation.<br/>- R81 version deprecation.                                  |
| 20240515         | Add support for requiring use instance metadata service version 2 (IMDSv2) only               |
| 20231012         | Update AWS Terraform provider version to 5.20.1                                               |
| 20230923         | Add support for C5d instance type                                                             |
| 20230914         | Add support for maintenance mode password                                                     |
| 20230829         | Change default Check Point version to R81.20                                                  |
| 20230806         | Add support for c6in instance type                                                            | 
| 20230626         | Fixed missing x-chkp-* tags on Auto Scale Group                                               |
| 20221226         | Support ASG Launch Template instead of Launch Configuration                                   |
| 20221123         | R81.20 version support                                                                        |
| 20220606         | New instance type support                                                                     |
| 20210329         | First release of Check Point Transit Gateway Auto Scaling Group Terraform module for AWS      |

## License

This project is licensed under the MIT License - see the [LICENSE](../../LICENSE) file for details
