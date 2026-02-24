data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Blue/Green deployment for Strapi
module "strapi" {
  source = "./modules/blue-green"

  app_name       = var.app_name
  environment    = var.environment
  image_url      = var.image_url
  db_password    = var.db_password
  vpc_id         = data.aws_vpc.default.id
  subnet_ids     = data.aws_subnets.default.ids
  desired_count  = var.desired_count
  cpu            = var.cpu
  memory         = var.memory
  container_port = var.container_port
}
