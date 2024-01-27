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
  index_html_s3_key      = "index.html"
  index_html_source_path = "../website/index.html"
  resume_css_s3_key      = "resume.css"
  resume_css_source_path = "../website/resume.css"
  acm_certificate_arn    = data.aws_acm_certificate.cloud_resume.arn
  zone_id                = data.aws_route53_zone.cloud_resume.zone_id
  record_name            = "*.tylers-resume.com"
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




