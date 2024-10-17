variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "secret_arn" {
  description = "ARN of the secret in Secrets Manager"
  type        = string
}

variable "app_name" {
  description = "Application Name"
  type = string
}