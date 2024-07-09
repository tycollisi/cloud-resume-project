data "aws_s3_bucket" "bucket" {
  bucket = var.bucket
}

resource "aws_s3_object" "object" {
  for_each = { for obj in var.files : obj.key => obj }

  bucket = data.aws_s3_bucket.bucket.id
  key = each.value.key
  source = try(each.value.source, null)
  etag = each.value.source != null ? filemd5(each.value.source) : null
  content_type = try(each.value.content_type, null)
}
