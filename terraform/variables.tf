variable "project" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "environment" {
  type        = string
  description = "An environment namespace for the infrastructure."
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "bucket_name" {
  type        = string
  description = "An S3 bucket to be created and used by the associated modules."
}

variable "aws_lambda_basic_exec_role_policy_arn" {
  default = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

variable "aws_s3_read_only_policy_arn" {
  default = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
