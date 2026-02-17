resource "aws_lb" "this" {
  name               = "strapi-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = []
}

resource "aws_lb_target_group" "this" {
  name        = "strapi-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id     = var.vpc_id
  target_type = "ip"
}
