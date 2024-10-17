# Create S3 bucket for state storage
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = var.s3_bucket_name

#   lifecycle {
#     prevent_destroy = true
#   }
# }

data aws_s3_bucket terraform_state {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = data.aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = data.aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create DynamoDB table for state locking
# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = var.dynamodb_table_name
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

# Call the networking module
module "networking" {
  source      = "./modules/networking"
  environment = var.environment
  vpc_cidr            = "10.0.0.0/16"
  public_subnets_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-west-2a", "us-west-2b"]
  app_name    = var.app_name
}

module "bastion" {
  source           = "./modules/bastion"
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_ids[0]
  key_pair_name    = "haf_bastion_keypair"
  app_name        = var.app_name
}

# Call the ASG module
module "asg" {
  source = "./modules/asg"

  environment     =  var.environment
  vpc_id          = module.networking.vpc_id
  subnet_ids      = module.networking.private_subnet_ids
  instance_type   = "t2.large"
  key_pair_name   = "haf_ecs_ec2_keypair"
  desired_capacity = 1
  ecs_cluster_name = module.ecs.cluster_name
  ecs_instance_profile_name = module.ecs.instance_profile_name
  app_name      = var.app_name
  bastion_security_group_id = module.bastion.bastion_security_group_id
}

# Call the ECS module
module "ecs" {
  source = "./modules/ecs"

  cluster_name  = "${var.app_name}-${var.environment}-ecs-cluster"
  environment   = var.environment
  asg_arn       = module.asg.asg_arn
  services      = ["web-frontend-service", "web-backend-service"]
}

# module "route53" {
#   source = "./modules/route53"

#   domain_name   = var.environment == "prod" ? "${var.domain_name}" : "${var.environment}.${var.domain_name}"
#   environment   = var.environment
#   alb_dns_name  = module.alb.alb_dns_name
#   alb_zone_id   = module.alb.alb_zone_id
#   sans          = ["www", "api"]  # Add or remove subdomains as needed
# }

# If you don't have a valid SSL certificate, you can use a self-signed one for testing:
# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.environment == "prod" ? "*.${var.domain_name}" : "*.${var.environment}.${var.domain_name}"
#   validation_method = "DNS"

#   subject_alternative_names = [
#      var.environment == "prod" ? "www.${var.domain_name}" : "www.${var.environment}.${var.domain_name}",
#      var.environment == "prod" ? "api.${var.domain_name}" : "api.${var.environment}.${var.domain_name}"]

#   lifecycle {
#     create_before_destroy = true
#   }
#   tags = {
#     Environment = var.environment
#   }
# }

#This has some specific routing rules
module "alb" {
  source            = "./modules/alb"
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  #certificate_arn   = aws_acm_certificate.cert.arn
  certificate_arn   = "arn:aws:iam::203918864279:server-certificate/CSC"
  app_name          = var.app_name
}

# Add this to your existing main.tf

module "secret_rotation_lambda" {
  source      = "./modules/secret_rotation_lambda"
  environment = var.environment
  vpc_id      = module.networking.vpc_id
  subnet_ids  = module.networking.private_subnet_ids
  db_host     = module.database.db_instance_address
  secret_arn  = module.database.secret_arn
  app_name    = var.app_name
}

# # Call the database module
module "database" {
  source = "./modules/database"

  environment          = var.environment
  vpc_id               = module.networking.vpc_id
  subnet_ids           = module.networking.private_subnet_ids
  private_subnet_cidrs = module.networking.private_subnet_cidrs

  db_name         = "myapp_db"
  db_username     = "admin"  # This will be the default username
  instance_class  = "db.t3.small"
  allocated_storage = 20
  app_name      = var.app_name
  bastion_security_group_id = module.bastion.bastion_security_group_id
  ecs_security_group_id   = module.asg.security_group_id
  rotation_lambda_arn = module.secret_rotation_lambda.lambda_arn
}

# Call the ECR module
module "ecr" {
  source = "./modules/ecr"

  repository_names = ["web-backend", "web-frontend"]
  environment      = var.environment
}

