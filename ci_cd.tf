locals {
    github_repos = [
      "web-frontend",
      "web-backend-django"
    ]
}

resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-policy"
  path        = "/"
  description = "IAM policy for GitHub Actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect: "Allow",
        Action: [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecr:GetAuthorizationToken"
        ],
        Resource: "*"
      }
    ]
  })
}

module "github_oidc" {
  source = "./modules/github_oidc"

  github_org  = "Hireafractional"
  github_repos = local.github_repos
  iam_policy_arn = aws_iam_policy.github_actions.arn
}

#Create a service role for Github to atttach to 
resource "aws_iam_role" "github-service-role" {
  name               = "GitHubAction-AssumeRoleWithAction"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            Effect: "Allow",
            Principal: {
                Federated: "${module.github_oidc.github_oidc_provider_arn}"
            },
            Action: "sts:AssumeRoleWithWebIdentity",
            Condition: {
                StringEquals: {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                StringLike: {
                    "token.actions.githubusercontent.com:sub": "repo:Hireafractional/*"
                }
            }
        }
    ]
  })
}

#Attach the managed policy roles.
data "aws_iam_policy" "AmazonECS_FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
data "aws_iam_policy" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}
data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy_attachment" "AmazonECS_FullAccess-Attach" {
  role       = "${aws_iam_role.github-service-role.name}"
  policy_arn = "${data.aws_iam_policy.AmazonECS_FullAccess.arn}"
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds-Attach" {
  role       = "${aws_iam_role.github-service-role.name}"
  policy_arn = "${data.aws_iam_policy.EC2InstanceProfileForImageBuilderECRContainerBuilds.arn}"
}

resource "aws_iam_role_policy_attachment" "SecretsManagerReadWrite-Attach" {
  role       = "${aws_iam_role.github-service-role.name}"
  policy_arn = "${data.aws_iam_policy.SecretsManagerReadWrite.arn}"
}

