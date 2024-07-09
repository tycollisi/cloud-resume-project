locals {
  s3_origin_id = "${var.bucket_name}.s3.us-east-1.amazonaws.com"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = var.domain_name 
    origin_access_control_id = aws_cloudfront_origin_access_control.cdn_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  default_root_object = var.default_root_object 

  aliases = var.aliases 

  default_cache_behavior {
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

resource "aws_cloudfront_origin_access_control" "cdn_oac" {
  name                              = var.cloudfront_oac_name 
  description                       = "cloudfront origin access control for cloud resume"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
