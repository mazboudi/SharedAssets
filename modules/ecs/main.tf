resource "aws_ecs_cluster" "ecs-cluster" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

resource "aws_ecs_capacity_provider" "ecs-capacity_provider" {
  name = "${var.cluster_name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = var.asg_arn

    managed_scaling {
      maximum_scaling_step_size = 100
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs-capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.ecs-capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs-capacity_provider.name
  }
}

# Create ECS Services
resource "aws_ecs_service" "ecs-service" {
  for_each         = toset(var.services)

  name            = "${each.key}"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  deployment_controller {
    type = "EXTERNAL"
  }
}

# IAM role for ECS instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.cluster_name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.cluster_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# IAM role for ECS Task
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.cluster_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
data "aws_iam_policy" "AWSOpsWorksCloudWatchLogs" {
  arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}
data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy-Attach" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "${data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn}"
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds-Attach" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "${data.aws_iam_policy.AWSOpsWorksCloudWatchLogs.arn}"
}

resource "aws_iam_role_policy_attachment" "SecretsManagerReadWrite-Attach" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "${data.aws_iam_policy.SecretsManagerReadWrite.arn}"
}