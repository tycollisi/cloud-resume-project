variable "bucket_name" {
  type = string
  #default = "collisi-cloud-resume"
}

variable "index_html_s3_key" {
  description = "Name of the object once it is in the bucket"
  type        = string
}

variable "index_html_source_path" {
  type = string
}

variable "resume_css_s3_key" {
  description = "Name of the object once it is in the bucket"
  type        = string
}

variable "resume_css_source_path" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID"
  type = string
}

variable "record_name" {
  description = "Route53 Record Name"
  type = string
}

variable "apex_record_name" {
  description = "Apex Route53 Record Name"
  type = string
}
