data "archive_file" "get_bucket_acl" {
  type        = "zip"
  source_dir  = "${path.module}/lambda-functions/get_bucket_acl/src"
  output_path = "${path.module}/lambda-functions/get_bucket_acl.zip"
}
