variable "project" {
  type        = string
  description = "A project specific tag that will be applied to all resources that support them."
}

variable "environment" {
  type        = string
  description = "An environment specific tag that will be applied to all resources that support them."
}

variable "origin_bucket_name" {
  type        = string
  description = "A name for the S3 bucket used as the CloudFront distribution origin."
}

variable "cdn_price_class" {
  default     = "PriceClass_All"
  type        = string
  description = "The price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
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
