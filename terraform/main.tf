data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ecs" {
  source = "./modules/ecs"

  image_url   = var.image_url
  subnet_ids  = data.aws_subnets.default.ids
  vpc_id      = data.aws_vpc.default.id
  db_password = var.db_password
}
