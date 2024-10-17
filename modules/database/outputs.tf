output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.mysql.arn
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.mysql.db_name
}

output "secret_arn" {
  description = "The ARN of the secret storing the database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.mysql.address
}
