resource "aws_ecr_repository" "repos" {
  for_each = toset(var.repository_names)

  name                 = each.key
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

# resource "aws_ecr_lifecycle_policy" "repos" {
#   for_each   = toset(var.repository_names)
#   repository = aws_ecr_repository.repos[each.key].name

#   policy = jsonencode({
#     rules = [{
#       rulePriority = 1
#       description  = "Keep last 10 images"
#       selection = {
#         tagStatus     = "any"
#         countType     = "imageCountMoreThan"
#         countNumber   = 10
#       }
#       action = {
#         type = "expire"
#       }
#     }]
#   })
# }
