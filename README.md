# Terraform Modules for CloudGuard Network Security (CGNS) - AWS

## Introduction
This repository provides a structured set of Terraform modules for deploying Check Point CloudGuard Network Security in Amazon Web Services (AWS). These modules automate the creation of Virtual Private Clouds (VPCs), Security Gateways, High-Availability architectures, and more, enabling secure and scalable cloud deployments.

## Repository Structure
`Submodules`: Contains modular, reusable, production-grade Terraform components, each with its own documentation.

`Examples`: Demonstrates how to use the modules.

## Available Submodules

**Submodules:**


**Internal Submodules:**

___

# Best Practices for Using CloudGuard Modules

## Step 1: Use the Required Module
Add the required module in your Terraform configuration file (`main.tf`) to deploy resources. For example:

```hcl
provider "aws" { }

module "example_module" {
  source  = "CheckPointSW/cloudguard-network-security/aws//modules/{module_name}"
  version = "{chosen_version}"
  # Add the required inputs
}
```
---

## Step 2: Open the Terminal
Ensure you have the AWS CLI installed and navigate to the directory containing your main.tf file: is located, using the appropriate terminal: 

- **Linux/macOS**: **Terminal**.
- **Windows**: **PowerShell** or **Command Prompt**.

---

## Step 3: Set Environment Variables and Log in with AWS CLI
Set up your AWS credentials and configure the default region by setting environment variables:


### Linux/macOS
```hcl
export AWS_ACCESS_KEY_ID="{your-access-key-id}"
export AWS_SECRET_ACCESS_KEY="{your-secret-access-key}"
export AWS_DEFAULT_REGION="{your-region}"

aws configure

```
### PowerShell (Windows)
```hcl
$env:AWS_ACCESS_KEY_ID="{your-access-key-id}"
$env:AWS_SECRET_ACCESS_KEY="{your-secret-access-key}"
$env:AWS_DEFAULT_REGION="{your-region}"

aws configure
```
### Command Prompt (Windows)
```hcl
set AWS_ACCESS_KEY_ID="{your-access-key-id}"
set AWS_SECRET_ACCESS_KEY="{your-secret-access-key}"
set AWS_DEFAULT_REGION="{your-region}"

aws configure
```
---


## Step 4: Deploy with Terraform
Use Terraform commands to deploy resources securely.

### Initialize Terraform
Prepare the working directory and download required provider plugins:
```hcl
terraform init
```

### Plan Deployment
Preview the changes Terraform will make:
```hcl
terraform plan
```
### Apply Deployment
Apply the planned changes and deploy the resources:
```hcl
terraform apply
```
Note: The terraform apply command might vary slightly depending on the submodule configurations. Pay close attention to any additional instructions provided in the submodules' documentation to ensure correct usage and handling of the resources.