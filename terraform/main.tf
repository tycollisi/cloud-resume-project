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

module "cloud_resume_cdn" {
  source = "../modules/cloudfront_distribution/"
  domain_name = module.cloud_resume.bucket_regional_domain_name
  bucket_name = "collisi-cloud-resume"
  acm_certificate_arn = data.aws_acm_certificate.cloud_resume.arn
  aliases = [ "www.tylers-resume.com", "tylers-resume.com" ]
  default_root_object = "index.html"
  cloudfront_oac_name = "cloud-resume-origin-acl" 
}

module "cloud_resume" {
  source                 = "../modules/s3-static-website"
  bucket_name            = "collisi-cloud-resume"
  acm_certificate_arn    = data.aws_acm_certificate.cloud_resume.arn
}

module "s3_object_upload" {
  source = "../modules/s3_object_upload"
  bucket = "collisi-cloud-resume"
  files = [
  {
    key          = "index.html"
    source       = "../website/index.html"
    content_type = "text/html"
  },
  {
    key          = "resume.css"
    source       = "../website/resume.css"
    content_type = "text/css"
  }
]

  depends_on = [ module.cloud_resume ]
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.cloud_resume.zone_id 
  name    = "www.tylers-resume.com" 
  type    = "A"

  alias {
    name                   = module.cloud_resume_cdn.domain_name 
    zone_id                = module.cloud_resume_cdn.hosted_zone_id 
    evaluate_target_health = true
  }

  depends_on = [ module.cloud_resume_cdn ]
}

resource "aws_route53_record" "cloud_resume" {
  zone_id = data.aws_route53_zone.cloud_resume.zone_id 
  name    = "tylers-resume.com" 
  type    = "A"

  alias {
    name                   = module.cloud_resume_cdn.domain_name 
    zone_id                = module.cloud_resume_cdn.hosted_zone_id 
    evaluate_target_health = true
  }

  depends_on = [ module.cloud_resume_cdn ]
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




