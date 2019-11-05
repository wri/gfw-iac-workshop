variable "project" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "environment" {
  type        = string
  description = "An environment namespace for the infrastructure."
}

variable "bucket_name" {
  type        = string
  description = "Bucket name to retrieve ACL metadata for."
}

variable "lambda_function_filename" {
  type        = string
  description = "Filename for the Lambda function code archive."
}

variable "lambda_function_source_code_hash" {
  type        = string
  description = "Lambda function code archive hash."
}

variable "lambda_iam_role_arn" {
  type        = string
  description = "IAM role ARN to be assumed by the Lambda function."
}

variable "lambda_function_handler" {
  type        = string
  description = "Handler method for the Lambda function."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}
