output "api_endpoint" {
  value       = module.lambda_api.api_endpoint
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

output "ecr_registry_id" {
  value       = aws_ecr_repository.default.registry_id
  description = "Registry ID for the ECR repository."
}

output "fargate_api_endpoint" {
  value       = module.fargate_api.api_endpoint
  description = "API Gateway endpoint responsible for proxying requests to the ECS service."
}
