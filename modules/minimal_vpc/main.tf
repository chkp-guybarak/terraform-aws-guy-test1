
resource "aws_vpc" "minimal_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

module "minimal_subnet" {
  source = "../minimal_subnet"

  vpc_id            = aws_vpc.minimal_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  name              = "example-minimal-subnet"
  tags = {
    Environment = "Test"
    Team        = "DevOps"
  }
}
