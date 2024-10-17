resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${local.short_name}-mysql-credentials"
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = "mysql"
    host     = aws_db_instance.mysql.endpoint
  })
}

# Add this to the existing file

resource "aws_secretsmanager_secret_rotation" "db_credentials" {
  secret_id           = aws_secretsmanager_secret.db_credentials.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = 30
  }
}


resource "aws_db_subnet_group" "mysql" {
  name       = "${local.short_name}-mysql-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${local.short_name}-mysql-subnet-group"
    Environment = var.environment
  }
}

resource "aws_db_instance" "mysql" {
  identifier        = "${local.short_name}-mysql-instance"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  multi_az               = true  # Enable Multi-AZ
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]

  backup_retention_period = 7
  skip_final_snapshot     = true
  deletion_protection     = false

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  parameter_group_name = aws_db_parameter_group.mysql.name

  # Enable storage encryption
  storage_encrypted = true

  # Enable Performance Insights
#   performance_insights_enabled = true
#   performance_insights_retention_period = 7  # 7 days retention

  # Enable auto minor version upgrade
  auto_minor_version_upgrade = true

  # Enable enhanced monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  tags = {
    Name        = "${local.short_name}-mysql-instance"
    Environment = var.environment
  }
}

resource "aws_security_group" "mysql" {
  name        = "${local.short_name}-mysql-sg"
  description = "Security group for MySQL database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from private subnets"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ecs_security_group_id]
  }

#add the bastion host   
    ingress {
        description     = "MySQL from bastion host"
        from_port       = 3306
        to_port         = 3306
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
    Name        = "${local.short_name}-mysql-sg"
    Environment = var.environment
  }
}

resource "aws_db_parameter_group" "mysql" {
  family = "mysql8.0"
  name   = "${local.short_name}-mysql-params"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = {
    Name        = "${local.short_name}-mysql-params"
    Environment = var.environment
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  name               = "${local.short_name}-rds-enhanced-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  role       = aws_iam_role.rds_enhanced_monitoring.name
}
