resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  subnets            = local.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"
  
  health_check {
    path              = "/"
    protocol          = "HTTP"
    matcher           = "200"
    interval_seconds  = 30
    timeout_seconds   = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}
