variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ASG"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.large"
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 1
}

variable "app_name" {
  description = "Application Name"
  type = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_instance_profile_name" {
  description = "Name of the ECS instance profile"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security group ID of the bastion host"
  type        = string
}

