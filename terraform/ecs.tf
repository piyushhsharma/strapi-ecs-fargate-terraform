resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "strapi" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = var.project_name
      image = var.image_url
      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.postgres.address },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = "strapi" },
        { name = "DATABASE_USERNAME", value = var.db_username },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "URL", value = "http://${aws_lb.this.dns_name}" },
        { name = "APP_KEYS", value = "generated-app-key" },
        { name = "API_TOKEN_SALT", value = "generated-salt" },
        { name = "ADMIN_JWT_SECRET", value = "generated-jwt-secret" },
        { name = "JWT_SECRET", value = "generated-jwt-secret" },
        { name = "TRANSFER_TOKEN_SALT", value = "generated-transfer-salt" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  lifecycle {
    ignore_changes = [container_definitions]
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.strapi.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.private_subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.project_name
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.this]

  tags = {
    Name = "${var.project_name}-service"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [task_definition]
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs"
  }

  lifecycle {
    prevent_destroy = false
  }
}
