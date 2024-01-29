data "aws_s3_bucket" "bucket" {
  bucket = var.bucket
}

resource "aws_s3_object" "object" {
  for_each = { for obj in var.files : obj.key => obj }

  bucket = data.aws_s3_bucket.bucket.id
  key = each.value.key
  source = each.value.source
  etag = filemd5(each.value.source)
  content_type = each.value.content_type
}
