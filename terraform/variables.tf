variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "strapi"
}

variable "vpc_id" {
  description = "Existing VPC ID (optional)"
  type        = string
  default     = ""
}

variable "public_subnets" {
  description = "Existing public subnet IDs (optional)"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "Existing private subnet IDs (optional)"
  type        = list(string)
  default     = []
}

variable "image_url" {
  description = "ECR image URL for Strapi"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "strapiuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
