provider "aws" {
  region = var.aws_region
  profile = var.cli_profile
}

# Backend State
# Change key based on profile
#terraform {
#  required_version = "1.6.3"
#  
#  backend "s3" {
#    bucket = "ty-terraform-backend"
#    key = "your-project-here/terraform.tfstate"
#    region = "us-east-1"
#
#    dynamodb_table = "ty-terraform-state"
#    workspace_key_prefix = "terraform-state"
#  }
#}
