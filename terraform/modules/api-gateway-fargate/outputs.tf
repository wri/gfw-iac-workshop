output "api_endpoint" {
  value       = "${aws_api_gateway_deployment.default.invoke_url}"
  description = "API Gateway endpoint responsible for proxying requests to the ECS service."
}

output "ecs_security_group_id" {
  value       = "${aws_security_group.default.id}"
  description = "Security group ID of the ECS service security group."
}
