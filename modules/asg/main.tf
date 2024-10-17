data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "asg-template" {
  name_prefix   = "${local.short_name}-launch-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
              EOF
  )

  iam_instance_profile {
    name = var.ecs_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.asg-sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.short_name}-asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${local.short_name}-asg"
  vpc_zone_identifier = var.subnet_ids
  max_size            = length(var.subnet_ids)
  min_size            = 1
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.asg-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.short_name}-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "asg-sg" {
  name        = "${local.short_name}-asg-sg"
  description = "Security group for ASG instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.short_name}-asg-sg"
  }
}
