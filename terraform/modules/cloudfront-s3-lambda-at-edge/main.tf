#
# S3 resources
#
data "aws_iam_policy_document" "s3_read_only" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.origin.arn}",
      "${aws_s3_bucket.origin.arn}/*",
    ]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.default.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "origin" {
  bucket = "${aws_s3_bucket.origin.id}"
  policy = "${data.aws_iam_policy_document.s3_read_only.json}"
}

resource "aws_s3_bucket" "origin" {
  bucket = "${var.origin_bucket_name}"
  acl    = "private"

  tags = merge(
    {
      "Project"     = format("%s", var.project),
      "Environment" = format("%s", var.environment)
    },
    var.tags
  )
}

resource "aws_s3_bucket_object" "index" {
  bucket       = "${aws_s3_bucket.origin.id}"
  key          = "index.html"
  content      = "Hello, world."
  content_type = "text/html"
}

#
# IAM resources
#
data "aws_iam_policy_document" "lambda_edge_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_basic_exec" {
  name               = "lambda${var.project}${var.environment}BasicExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_edge_assume_role.json}"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = "${aws_iam_role.lambda_basic_exec.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#
# Lambda resources
#
data "archive_file" "security_headers" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/security-headers/src"
  output_path = "${path.module}/lambda-functions/security-headers.zip"
}

resource "aws_lambda_function" "security_headers" {
  function_name    = "func${var.project}${var.environment}AddSecurityHeaders"
  filename         = "${data.archive_file.security_headers.output_path}"
  source_code_hash = "${data.archive_file.security_headers.output_base64sha256}"
  role             = "${aws_iam_role.lambda_basic_exec.arn}"
  runtime          = "nodejs10.x"
  handler          = "index.handler"
  memory_size      = 128
  timeout          = 3
  publish          = true
}

#
# CloudFront resources
#
resource "aws_cloudfront_origin_access_identity" "default" {}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "${aws_s3_bucket.origin.bucket_regional_domain_name}"
    origin_id   = "s3Origin"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  comment             = "Static Site (${var.project}, ${var.environment})"
  default_root_object = "index.html"

  price_class = "${var.cdn_price_class}"

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "s3Origin"

    lambda_function_association {
      event_type = "viewer-response"
      lambda_arn = "${aws_lambda_function.security_headers.qualified_arn}"
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "${var.cdn_viewer_protocol_policy}"
    min_ttl                = "${var.cdn_min_ttl}"
    default_ttl            = "${var.cdn_default_ttl}"
    max_ttl                = "${var.cdn_max_ttl}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(
    {
      "Project"     = format("%s", var.project),
      "Environment" = format("%s", var.environment)
    },
    var.tags
  )
}
