data "aws_s3_bucket" "bucket" {
  bucket = var.bucket
}

resource "aws_s3_object" "object" {
  for_each = var.files

  bucket = data.aws_s3_bucket.bucket.id
  key = each.key
  source = each.value

  etag = filemd5(each.value)
}
