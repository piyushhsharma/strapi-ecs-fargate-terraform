output "alb_dns" {
  description = "Application Load Balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "Application Load Balancer URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecs_cluster" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "ecr_repository" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}
