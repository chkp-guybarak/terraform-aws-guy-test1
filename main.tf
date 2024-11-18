resource "aws_subnet" "minimal_subnet" {
  vpc_id            = var.vpc_id
  cidr_block        = var.cidr_block
  availability_zone = var.availability_zone

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
