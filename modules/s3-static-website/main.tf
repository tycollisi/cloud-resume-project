resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [ aws_s3_bucket_public_access_block.public_access_block ]
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
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false 
  block_public_policy     = false 
  ignore_public_acls      = false 
  restrict_public_buckets = false 
}

resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.bucket.id

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
