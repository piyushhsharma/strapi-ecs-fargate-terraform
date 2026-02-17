terraform {
  required_version = ">= 1.0"
}

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "vpc_id" {
  description = "Existing VPC ID (optional)"
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "Existing public subnet IDs (optional)"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "Existing private subnet IDs (optional)"
  type        = list(string)
  default     = []
}

locals {
  vpc_id = var.vpc_id != "" ? var.vpc_id : aws_vpc.this[0].id
  public_subnets  = length(var.public_subnets) > 0 ? var.public_subnets : aws_subnet.public[*].id
  private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : aws_subnet.private[*].id
}

# Create VPC if not provided
resource "aws_vpc" "this" {
  count = var.vpc_id == "" ? 1 : 0

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }

  lifecycle {
    create_before_destroy = true
  }
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

  lifecycle {
    create_before_destroy = true
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

  lifecycle {
    create_before_destroy = true
  }
}

# Internet Gateway for public subnets
resource "aws_internet_gateway" "this" {
  count = var.vpc_id == "" ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    Name = "${var.project_name}-igw"
  }

  lifecycle {
    create_before_destroy = true
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

  lifecycle {
    create_before_destroy = true
  }
}

# Associate route table with public subnets
resource "aws_route_table_association" "public" {
  count = var.vpc_id == "" ? 2 : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id

  lifecycle {
    create_before_destroy = true
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}
