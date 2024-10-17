terraform {
  backend "s3" {
    bucket         = "haf-dev-tf-state"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
