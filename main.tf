
module "minimal_vpc" {
  source = "./modules/minimal_vpc"

  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  name                 = "example-minimal-vpc"
  tags = {
    Environment = "Test"
    Team        = "DevOps"
  }
}


output "vpc_id" {
  value = module.minimal_vpc.vpc_id
}

