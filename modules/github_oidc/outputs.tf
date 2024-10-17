output "github_oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "github_actions_role_arns" {
  description = "ARNs of the IAM roles for GitHub Actions"
  value       = { for repo, role in aws_iam_role.github_actions : repo => role.arn }
}