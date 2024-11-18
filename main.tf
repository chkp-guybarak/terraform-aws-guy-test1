module "minimal_vpc" {
  source = "github.com/chkp-guybarak/terraform-aws-guy-test1//modules/minimal_vpc?ref=1.1.4"

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  name                 = "example-minimal-vpc"
  tags = {
    Environment = "Test"
    Team        = "DevOps"
  }
}

module "minimal_subnet" {
  source = "github.com/chkp-guybarak/terraform-aws-guy-test1//modules/minimal_subnet?ref=1.1.4"

  vpc_id            = module.minimal_vpc.vpc_id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  name              = "example-minimal-subnet"
  tags = {
    Environment = "Test"
    Team        = "DevOps"
  }
}

output "vpc_id" {
  value = module.minimal_vpc.vpc_id
}

output "subnet_id" {
  value = module.minimal_subnet.subnet_id
}
