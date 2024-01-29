variable "bucket" {
  description = "Name of the S3 bucket files will be uploaded to."
  type = string
}

variable "files" {
  type = map(string)
}
