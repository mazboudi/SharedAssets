variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Private Subnet IDs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.small"
}

variable "allocated_storage" {
  description = "Allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "admin"
}

variable "app_name" {
  description = "Application Name"
  type = string
}

variable "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID of the ECS instances (Auto Scaling Group)"
  type        = string
}

# Add this to the existing file

variable "rotation_lambda_arn" {
  description = "ARN of the Lambda function for secret rotation"
  type        = string
}
