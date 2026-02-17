output "alb_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "alb_url" {
  description = "URL of the Application Load Balancer"
  value       = "http://${aws_lb.this.dns_name}"
}

output "ecs_cluster" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "ecr_repository" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.strapi.name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.postgres.endpoint
}
