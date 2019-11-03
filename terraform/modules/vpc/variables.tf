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

variable "region" {
  type        = string
  description = "A valid AWS region to house VPC resources."
}

variable "key_name" {
  type        = string
  description = "A key pair used to control login access to EC2 instances."
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "The CIDR range for the entire VPC."
}

variable "public_subnet_cidr_blocks" {
  type        = list
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  description = "A list of CIDR ranges for public subnets."
}

variable "private_subnet_cidr_blocks" {
  type        = list
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  description = "A list of CIDR ranges for private subnets."
}

variable "availability_zones" {
  type        = list
  default     = ["us-east-1a", "us-east-1b"]
  description = "A list of availability zones for subnet placement."
}

variable "bastion_ami" {
  type        = string
  description = "An AMI ID for the bastion."
}

variable "bastion_instance_type" {
  default     = "t3.nano"
  type        = string
  description = "An instance type for the bastion."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}
