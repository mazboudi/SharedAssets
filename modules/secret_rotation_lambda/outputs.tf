output "lambda_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.secret_rotation.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.secret_rotation.function_name
}
