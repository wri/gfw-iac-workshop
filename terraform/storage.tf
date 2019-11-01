resource "aws_cloudfront_origin_access_identity" "default" {}

data "aws_iam_policy_document" "s3_read_only" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.default.arn}",
      "${aws_s3_bucket.default.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "cdn_read_only" {
  bucket = "${aws_s3_bucket.default.id}"
  policy = "${data.aws_iam_policy_document.s3_read_only.json}"
}

resource "aws_s3_bucket" "default" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Project     = var.project,
    Environment = var.environment
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket       = "${aws_s3_bucket.default.id}"
  key          = "index.html"
  content      = "Hello, world."
  content_type = "text/html"
}
