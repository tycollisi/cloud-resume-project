variable "bucket_name" {
  type = string
  #default = "collisi-cloud-resume"
}

variable "acm_certificate_arn" {
  type = string
}

variable "aliases" {
  description = "CDN Alternate Domain Names"
  type = list(string)
}

variable "default_root_object" {
  description = "CloudFront Distribution root object. Content served when root domain is accessed."
  type = string
}

variable "cloudfront_oac_name" {
  description = "CloudFront Origin Access Control Name"
  type = string
}

variable "domain_name" {
  description = "s3 bucket regional domain name"
  type = string
}
