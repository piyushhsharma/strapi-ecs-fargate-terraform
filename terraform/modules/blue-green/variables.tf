variable "app_name" {
  type        = string
  description = "Application name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "image_url" {
  type        = string
  description = "Docker image URL for Strapi application"
}

variable "db_password" {
  type        = string
  description = "Database password for Strapi"
  sensitive   = true
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs"
}

variable "desired_count" {
  type        = number
  description = "Desired number of tasks"
}

variable "cpu" {
  type        = number
  description = "CPU units for task"
}

variable "memory" {
  type        = number
  description = "Memory for task"
}

variable "container_port" {
  type        = number
  description = "Container port"
}
