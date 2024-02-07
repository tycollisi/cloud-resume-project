variable "bucket_name" {
  type = string
  #default = "collisi-cloud-resume"
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

#variable "apex_record_name" {
#  description = "Apex Route53 Record Name"
#  type = string
#}
