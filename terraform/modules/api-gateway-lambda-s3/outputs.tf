output "api_endpoint" {
  value       = "${aws_api_gateway_deployment.default.invoke_url}"
  description = "API Gateway endpoint responsible for proxying requests to the Lambda function."
}
