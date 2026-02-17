# Create VPC if not provided
resource "aws_vpc" "this" {
  count = var.vpc_id == "" ? 1 : 0

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

locals {
  vpc_id = var.vpc_id != "" ? var.vpc_id : aws_vpc.this[0].id
}

# Create public subnets if not provided
resource "aws_subnet" "public" {
  count = length(var.public_subnets) > 0 ? 0 : 2

  vpc_id                  = local.vpc_id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index}"
  }
}

# Create private subnets if not provided
resource "aws_subnet" "private" {
  count = length(var.private_subnets) > 0 ? 0 : 2

  vpc_id            = local.vpc_id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-${count.index}"
  }
}

locals {
  public_subnets  = length(var.public_subnets) > 0 ? var.public_subnets : aws_subnet.public[*].id
  private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : aws_subnet.private[*].id
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "this" {
  count = var.vpc_id == "" ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Route table for public subnets
resource "aws_route_table" "public" {
  count = var.vpc_id == "" ? 1 : 0

  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count = var.vpc_id == "" ? 2 : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
