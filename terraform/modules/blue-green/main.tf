# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.app_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-alb-sg"
    Environment = var.environment
  }
}

# ECS Task Security Group
resource "aws_security_group" "ecs" {
  name        = "${var.app_name}-blue-green-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow traffic from ALB"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-blue-green-ecs-sg"
    Environment = var.environment
  }
}

# Use existing IAM roles
data "aws_iam_role" "ecs_execution" {
  name = "strapi-ecs-execution-role"
}

data "aws_iam_role" "ecs_task" {
  name = "strapi-ecs-task-role"
}

# CodeDeploy Role for ECS
resource "aws_iam_role" "codedeploy" {
  name = "${var.app_name}-codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-codedeploy-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}


# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7

  tags = {
    Name        = "/ecs/${var.app_name}"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.app_name}-blue-green-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.app_name}-blue-green-alb"
    Environment = var.environment
  }
}

# Target Groups
resource "aws_lb_target_group" "blue" {
  name     = "${var.app_name}-blue-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval           = 30
    matcher            = "200-399"
    path              = "/admin"
    port              = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.app_name}-blue-tg"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "green" {
  name     = "${var.app_name}-green-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval           = 30
    matcher            = "200-399"
    path              = "/admin"
    port              = "traffic-port"
    protocol           = "HTTP"
    timeout            = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.app_name}-green-tg"
    Environment = var.environment
  }
}

# ALB Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "strapi" {
  family                   = "${var.app_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = data.aws_iam_role.ecs_execution.arn
  task_role_arn           = data.aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = var.image_url
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = "dummy" },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "strapi" },
        { name = "DATABASE_USERNAME", value = "strapiuser" },
        { name = "DATABASE_PASSWORD", value = var.db_password }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.app_name}"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = {
    Name        = "${var.app_name}-task"
    Environment = var.environment
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.app_name}-cluster"
    Environment = var.environment
  }
}

# ECS Service with Blue/Green support
resource "aws_ecs_service" "main" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Use CodeDeploy as deployment controller
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Attach both Blue and Green target groups
  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  # Enable deployment circuit breaker
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [
    aws_ecs_task_definition.strapi,
    aws_lb_target_group.blue,
    aws_lb_target_group.green
  ]

  tags = {
    Name        = "${var.app_name}-service"
    Environment = var.environment
  }
}

# CodeDeploy Application
resource "aws_codedeploy_app" "main" {
  name             = "${var.app_name}-app"
  compute_platform = "ECS"

  tags = {
    Name        = "${var.app_name}-app"
    Environment = var.environment
  }
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "main" {
  app_name               = aws_codedeploy_app.main.name
  deployment_group_name  = "${var.app_name}-dg"
  service_role_arn      = aws_iam_role.codedeploy.arn
  deployment_config_name  = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  # Blue/Green deployment type
  deployment_style {
    deployment_type = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  # Auto rollback configuration
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"]
  }

  # Load balancer info
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
    }
  }

  # ECS service configuration
  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.main.name
  }

  # Load balancer target groups
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.main.arn]
      }

      target_group {
        name = aws_lb_target_group.blue.name
      }

      target_group {
        name = aws_lb_target_group.green.name
      }
    }
  }

  tags = {
    Name        = "${var.app_name}-dg"
    Environment = var.environment
  }
}

# SNS Topic for deployment notifications
resource "aws_sns_topic" "deployment" {
  name = "${var.app_name}-deployment-notifications"

  tags = {
    Name        = "${var.app_name}-deployment-notifications"
    Environment = var.environment
  }
}
