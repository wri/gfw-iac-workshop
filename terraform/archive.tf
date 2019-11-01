data "archive_file" "get_bucket_acl" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/get_bucket_acl/src"
  output_path = "${path.module}/lambda-functions/get_bucket_acl.zip"
}

data "archive_file" "security_headers" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/security_headers/src"
  output_path = "${path.module}/lambda-functions/security_headers.zip"
}
