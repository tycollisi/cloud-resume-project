variable "bucket" {
  description = "Name of the S3 bucket files will be uploaded to."
  type = string
}

variable "files" {
  description = "A list of maps, each containing the key, source, and content_type of an S3 object."
  type = list(object({
    key          = string
    source       = string
    content_type = string
  }))
}

