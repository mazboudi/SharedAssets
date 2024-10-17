output "repository_urls" {
  description = "URLs of the created ECR repositories"
  value = {
    for name, repo in aws_ecr_repository.repos : name => repo.repository_url
  }
}

output "repository_arns" {
  description = "ARNs of the created ECR repositories"
  value = {
    for name, repo in aws_ecr_repository.repos : name => repo.arn
  }
}
