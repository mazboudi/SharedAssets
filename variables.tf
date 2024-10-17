variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}

variable "environment" {
  description = "Deployment environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Allowed values for input_parameter are \"dev\", \"uat\", or \"prod\"."
  }
}

variable "app_name" {
  description = "Application Name"
  default     = "haf"
}

variable "domain_name" {
  description = "Name of the S3 bucket for Terraform state storage"
  default     = "hireafractional.com"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  default     = "terraform-state-lock"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state storage"
  default     = "my-terraform-state-bucket"
}
