variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "app_name" {
  description = "Application Name"
  type = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Range"
  type = string
}

variable "public_subnets_cidrs" {
  description = "Public Subnets CIDR Range"
  type = list(string)
}

variable "private_subnets_cidrs" {
  description = "Private Subnets CIDR Range"
  type = list(string)
}

variable "availability_zones" {
  description = "Availability Zones"
  type = list(string)
}