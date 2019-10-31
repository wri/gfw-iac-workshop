variable "project" {}

variable "environment" {}

variable "aws_region" {}

variable "name" {}

variable "lambda_function_filename" {}

variable "lambda_function_handler" {}

variable "aws_lambda_service_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "aws_s3_policy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
