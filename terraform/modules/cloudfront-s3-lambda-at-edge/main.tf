#
# Lambda resources
#
resource "aws_lambda_function" "cdn_handler" {
  function_name    = "func${var.environment}${var.project}AddHeaders"
  filename         = var.lambda_function_filename
  source_code_hash = var.lambda_function_source_code_hash
  role             = var.lambda_iam_role_arn
  runtime          = "nodejs10.x"
  handler          = var.lambda_function_handler
  memory_size      = 128
  timeout          = 3
  publish          = true

  tags = merge(
    {
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

#
# CloudFront resources
#
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = "s3Origin"

    s3_origin_config {
      origin_access_identity = var.cdn_origin_access_identity
    }
  }

  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  comment             = "Static Site (${var.project}, ${var.environment})"
  default_root_object = "index.html"

  price_class = var.cdn_price_class

  default_cache_behavior {
    allowed_methods  = ["HEAD", "GET"]
    cached_methods   = ["HEAD", "GET"]
    target_origin_id = "s3Origin"

    lambda_function_association {
      event_type = "viewer-response"
      lambda_arn = aws_lambda_function.cdn_handler.qualified_arn
    }

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = var.cdn_viewer_protocol_policy
    min_ttl                = var.cdn_min_ttl
    default_ttl            = var.cdn_default_ttl
    max_ttl                = var.cdn_max_ttl
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
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}
