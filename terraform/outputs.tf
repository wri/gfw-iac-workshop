output "api_endpoint" {
  value       = "${module.dynamic_api.api_endpoint}"
  description = "API Gateway endpoint responsible for proxying requests to the Lambda function."
}
