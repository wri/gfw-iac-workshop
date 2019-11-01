output "api_endpoint" {
  value       = module.dynamic_api.api_endpoint
  description = "API Gateway endpoint responsible for proxying requests to the Lambda function."
}

output "cdn_endpoint" {
  value       = "https://${module.static_site.cdn_endpoint}"
  description = "CloudFront endpoint responsible for fronting the contents of an S3 bucket."
}

output "bastion_hostname" {
  value       = module.vpc.bastion_hostname
  description = "Bastion hostname for SSH access."
}
