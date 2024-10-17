variable "repository_names" {
  description = "List of ECR repository names to create"
  type        = list(string)
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}
