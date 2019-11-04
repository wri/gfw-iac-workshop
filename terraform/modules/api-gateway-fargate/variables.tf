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

variable "vpc_id" {
  type        = string
  description = "ID of the VPC for ECS resources."
}

variable "vpc_private_subnet_ids" {
  type        = list(any)
  description = "A list of VPC public subnet IDs."
}

variable "container_name" {
  type        = string
  description = "The name of the container to associate with the load balancer."
}

variable "container_port" {
  type        = number
  description = "The port on the container to associate with the load balancer."
}

variable "task_definition_arn" {
  type        = string
  description = "ARN of the ECS task definition used by the ECS task."
}

variable "desired_count" {
  type        = number
  description = "The number of instances of the task definition to place and keep running."
}

variable "deployment_min_percent" {
  type        = number
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment."
}

variable "deployment_max_percent" {
  type        = number
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}
