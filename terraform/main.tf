module "s3_rw_test" {
  source = "./modules/api-gateway-lambda-s3"

  name                     = "S3ReadWriteTest"
  lambda_function_filename = "${path.module}/lambda-functions/s3-rw-test/s3-rw-test.zip"
  lambda_function_handler  = "s3-rw-test.handler"

  project     = var.project
  environment = var.environment
  aws_region  = var.aws_region
}
