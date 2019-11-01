module "dynamic_api" {
  source = "./modules/api-gateway-lambda-s3"

  name = "S3GetACL"

  bucket_name = aws_s3_bucket.default.id

  lambda_function_filename         = data.archive_file.get_bucket_acl.output_path
  lambda_function_source_code_hash = data.archive_file.get_bucket_acl.output_base64sha256
  lambda_iam_role_arn              = aws_iam_role.lambda_basic_exec_s3.arn
  lambda_function_handler          = "index.handler"

  project     = var.project
  environment = var.environment

  tags = {}
}

module "static_site" {
  source = "./modules/cloudfront-s3-lambda-at-edge"

  name = "AddSecurityHeader"

  bucket_name                 = aws_s3_bucket.default.id
  bucket_regional_domain_name = aws_s3_bucket.default.bucket_regional_domain_name

  lambda_function_filename         = data.archive_file.security_headers.output_path
  lambda_function_source_code_hash = data.archive_file.security_headers.output_base64sha256
  lambda_iam_role_arn              = aws_iam_role.lambda_basic_exec.arn
  lambda_function_handler          = "index.handler"

  cdn_origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
  cdn_price_class            = "PriceClass_All"
  cdn_viewer_protocol_policy = "redirect-to-https"
  cdn_min_ttl                = 0
  cdn_default_ttl            = 60
  cdn_max_ttl                = 86400

  project     = var.project
  environment = var.environment

  tags = {}
}
