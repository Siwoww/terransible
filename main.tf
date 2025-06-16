resource "aws_vpc" "main-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "main-vpc-${random_id.random}"
  }
}

resource "aws_internet_gateway" "main-internet-gateway" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "terransible-igw-${random_id.random}"
  }
}

resource "random_id" "random" {
  byte_length = 2
}