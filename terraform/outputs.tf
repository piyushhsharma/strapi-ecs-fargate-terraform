output "cluster_name" {
  value = module.strapi.cluster_name
}

output "service_name" {
  value = module.strapi.service_name
}

output "task_definition_arn" {
  value = module.strapi.task_definition_arn
}

output "alb_dns_name" {
  value = module.strapi.alb_dns_name
}

output "alb_arn" {
  value = module.strapi.alb_arn
}

output "blue_target_group_arn" {
  value = module.strapi.blue_target_group_arn
}

output "green_target_group_arn" {
  value = module.strapi.green_target_group_arn
}

output "codedeploy_app_name" {
  value = module.strapi.codedeploy_app_name
}

output "codedeploy_deployment_group_name" {
  value = module.strapi.codedeploy_deployment_group_name
}

output "application_url" {
  value = "http://${module.strapi.alb_dns_name}"
}
