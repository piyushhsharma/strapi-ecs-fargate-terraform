terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Modules
module "vpc" {
  source = "./modules/vpc"
  
  providers = {
    aws = aws
  }
}

module "alb" {
  source = "./modules/alb"
  
  providers = {
    aws = aws
  }
  
  depends_on = [module.vpc]
}

module "rds" {
  source = "./modules/rds"
  
  providers = {
    aws = aws
  }
  
  depends_on = [module.vpc]
}

module "iam" {
  source = "./modules/iam"
  
  providers = {
    aws = aws
  }
}

module "ecr" {
  source = "./modules/ecr"
  
  providers = {
    aws = aws
  }
}

module "ecs" {
  source = "./modules/ecs"
  
  providers = {
    aws = aws
  }
  
  depends_on = [module.vpc, module.alb, module.rds, module.iam, module.ecr]
}
