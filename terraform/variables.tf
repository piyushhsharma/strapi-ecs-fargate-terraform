variable "image_url" {
  type        = string
  description = "Docker image URL for Strapi application"
  default     = "piyushhsharma/jaspal-strapi:latest"
}

variable "db_password" {
  type        = string
  description = "Database password for Strapi"
  default     = "piyush@04"
  sensitive   = true
}
