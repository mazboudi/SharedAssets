output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.arn
}

output "security_group_id" {
  description = "ID of the security group attached to the ASG instances"
  value       = aws_security_group.asg-sg.id
}