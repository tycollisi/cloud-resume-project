provider "aws" {
  region  = var.aws_region
  profile = var.cli_profile
  default_tags {
    tags = {
      environment     = var.environment
      owner           = "tyler_collisi"
      deployment_type = "manual_terraform"
    }
  }
}

terraform {
  required_version = "1.7.1"

  backend "s3" {
    bucket = "ty-terraform-backend"
    key    = "cloud-resume/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table       = "ty-terraform-statelock"
    workspace_key_prefix = "terraform-state"
  }
}

module "cloud_resume" {
  source                 = "../modules/s3-static-website"
  bucket_name            = "collisi-cloud-resume"
  acm_certificate_arn    = data.aws_acm_certificate.cloud_resume.arn
  zone_id                = data.aws_route53_zone.cloud_resume.zone_id
  record_name            = "*.tylers-resume.com"
  apex_record_name       = "tylers-resume.com"
}

module "s3_object_upload" {
  source = "../modules/s3_object_upload"
  bucket = "collisi-cloud-resume"
  files = {
    "index.html" = "../website/index.html"
    "resume.css" = "../website/resume.css"
  }

  depends_on = [ module.cloud_resume ]
}

data "aws_acm_certificate" "cloud_resume" {
  domain      = "*.tylers-resume.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "cloud_resume" {
  name         = "tylers-resume.com"
  private_zone = false
}




