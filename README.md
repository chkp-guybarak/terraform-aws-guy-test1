# TF-TEST Modules Repository

This repository contains multiple independent Terraform modules:

- [minimal_subnet](./minimal_subnet): A module to create a minimal subnet.
- [minimal_vpc](./minimal_vpc): A module to create a minimal VPC.

Each module can be used independently. Use the appropriate subdirectory as the source when referencing a module.

## Example Usage

To use the `minimal_subnet` module:
```hcl
module "minimal_subnet" {
  source = "github.com/your-org/TF-TEST//minimal_subnet?ref=minimal_subnet/v1.0.0"
}
