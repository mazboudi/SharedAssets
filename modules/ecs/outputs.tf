output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.ecs-cluster.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.ecs-cluster.arn
}

output "capacity_provider_name" {
  description = "Name of the ECS capacity provider"
  value       = aws_ecs_capacity_provider.ecs-capacity_provider.name
}

output "instance_profile_name" {
  description = "Name of the ECS instance profile"
  value       =  aws_iam_instance_profile.ecs_instance_profile.name
}

output "task_execution_role_arn" {
  description = ""
  value       =  aws_iam_role.ecs_task_role.arn
}
