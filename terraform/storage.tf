resource "aws_s3_bucket" "default" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Project     = var.project,
    Environment = var.environment
  }
}
