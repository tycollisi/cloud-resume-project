resource "aws_s3_bucket" "cloud_resume" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.cloud_resume.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [ aws_s3_bucket_public_access_block.cloud_resume ]
}

data "aws_iam_policy_document" "public_read" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.cloud_resume.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_public_access_block" "cloud_resume" {
  bucket = aws_s3_bucket.cloud_resume.id

  block_public_acls       = false 
  block_public_policy     = false 
  ignore_public_acls      = false 
  restrict_public_buckets = false 
}

resource "aws_s3_bucket_website_configuration" "cloud-resume" {
  bucket = aws_s3_bucket.cloud_resume.id

  index_document {
    suffix = "index.html"
  }

  #error_document {
  #  key = "error.html"
  #}

  // note: this block can be routing_rule or routing_rules. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration for more info
  #routing_rule {
  #  condition {
  #    key_prefix_equals = "docs/"
  #  }
  #  redirect {
  #    replace_key_prefix_with = "documents/"
  #  }
  #}
}

resource "aws_route53_record" "cloud_resume" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = "A"

  alias {
    // connected to cloudfront distribution?
    name                   = aws_cloudfront_distribution.cloud_resume.domain_name
    zone_id                = aws_cloudfront_distribution.cloud_resume.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cloud_resume_apex" {
  zone_id = var.zone_id
  name    = var.apex_record_name 
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cloud_resume.domain_name
    zone_id                = aws_cloudfront_distribution.cloud_resume.hosted_zone_id
    evaluate_target_health = true
  }
}


locals {
  s3_origin_id = "${var.bucket_name}.s3.us-east-1.amazonaws.com"
}

resource "aws_cloudfront_distribution" "cloud_resume" {
  origin {
    domain_name              = aws_s3_bucket.cloud_resume.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cloud_resume.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = [ var.record_name, var.apex_record_name ]

  default_cache_behavior {
    #cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_origin_access_control" "cloud_resume" {
  name                              = "cloud-resume-origin-acl"
  description                       = "cloudfront origin access control for cloud resume"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
