variable "domain_name" {
  description = "The primary domain name for the Route 53 hosted zone"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
}

variable "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "The hosted zone ID of the Application Load Balancer"
  type        = string
}

variable "sans" {
  description = "List of Subject Alternative Names (subdomains)"
  type        = list(string)
  default     = []
}
