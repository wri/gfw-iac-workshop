output "cdn_endpoint" {
  value       = "${aws_cloudfront_distribution.cdn.domain_name}"
  description = "CloudFront endpoint responsible for fronting the contents of an S3 bucket."
}
