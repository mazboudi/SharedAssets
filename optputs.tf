output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.asg.asg_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_capacity_provider_name" {
  description = "Name of the ECS capacity provider"
  value       = module.ecs.capacity_provider_name
}

output "ecs_task_execution_role_arn" {
  description = ""
  value       = module.ecs.task_execution_role_arn
}

output "ecr_repository_urls" {
  description = "URLs of the created ECR repositories"
  value       = module.ecr.repository_urls
}

output "ecr_repository_arns" {
  description = "ARNs of the created ECR repositories"
  value       = module.ecr.repository_arns
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = module.bastion.bastion_public_ip
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the ALB"
  value       = module.alb.alb_zone_id
}

output "web_frontend_target_group_arn" {
  description = "ARN of the web frontend target group"
  value       = module.alb.web_frontend_target_group_arn
}

output "web_backend_target_group_arn" {
  description = "ARN of the web backend target group"
  value       = module.alb.web_backend_target_group_arn
}

output "secret_rotation_lambda_function_name" {
  description = "Name of the secret rotation Lambda function"
  value       = module.secret_rotation_lambda.lambda_function_name
}

output "github_service_role_arn" {
  description = "the ARN of the service role that Github will use to attach to"
  value       = aws_iam_role.github-service-role.arn
}
