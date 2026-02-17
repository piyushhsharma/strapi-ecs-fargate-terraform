output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = local.public_subnets
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = local.private_subnets
}
