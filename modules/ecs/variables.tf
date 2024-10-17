variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  type        = string
}

variable "services" {
  description = "List of services to deploy"
  type        = list(string)
  default   = []
}