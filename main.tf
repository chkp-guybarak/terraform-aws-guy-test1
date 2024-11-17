module "minimal_vpc" {
  source              = "./minimal_vpc"
  cidr_block          = "10.0.0.0/16"
  enable_dns_support  = true
  enable_dns_hostnames = true
  name                = "my_minimal_vpc"
  tags = {
    Environment = "dev"
  }
}

module "minimal_subnet" {
  source              = "./minimal_subnet"
  vpc_id              = module.minimal_vpc.vpc_id
  cidr_block          = "10.0.1.0/24" # Subnet CIDR block
  availability_zone   = "eu-west-2a"
  name                = "my_minimal_subnet"
  tags = {
    Environment = "dev"
  }
}
