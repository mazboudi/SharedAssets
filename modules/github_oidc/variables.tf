variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repos" {
  description = "List of GitHub repository names"
  type        = list(string)
}

variable "iam_policy_arn" {
  description = "ARN of the IAM policy to attach to the GitHub Actions role"
  type        = string
}
