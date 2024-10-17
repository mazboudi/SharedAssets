variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the bastion host"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the key pair for the bastion host"
  type        = string
}

variable "app_name" {
  description = "Application Name"
  type = string
}