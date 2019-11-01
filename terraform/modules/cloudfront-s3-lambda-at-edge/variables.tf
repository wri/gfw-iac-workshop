variable "project" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "environment" {
  type        = string
  description = "An environment namespace for the infrastructure."
}

variable "name" {
  type        = string
  description = "A name for the module instance."
}

variable "bucket_name" {
  type        = string
  description = "Bucket name used as the CloudFront distribution origin."
}

variable "bucket_regional_domain_name" {
  type        = string
  description = "Bucket region-specific domain name."
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

variable "cdn_origin_access_identity" {
  type        = string
  description = "Full path for the CloudFront origin access identity."
}

variable "cdn_price_class" {
  default     = "PriceClass_100"
  type        = string
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, or PriceClass_100."
}

variable "cdn_viewer_protocol_policy" {
  default     = "redirect-to-https"
  type        = string
  description = "The protocol users can use to access the files in the origin. One of allow-all, https-only, or redirect-to-https."
}

variable "cdn_min_ttl" {
  default     = "0"
  type        = string
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin."
}

variable "cdn_default_ttl" {
  default     = "60"
  type        = string
  description = "The default amount of time that an object is in a CloudFront cache before CloudFront forwards another request to your origin."
}

variable "cdn_max_ttl" {
  default     = "86400"
  type        = string
  description = "The maximum amount of time that an object is in a CloudFront cache before CloudFront forwards another request to your origin."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}
