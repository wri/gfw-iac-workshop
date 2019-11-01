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
  description = ""
}

variable "key_name" {
  type        = string
  description = ""
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = ""
}

variable "public_subnet_cidr_blocks" {
  type        = "list"
  default     = ["10.0.0.0/24"]
  description = ""
}

variable "private_subnet_cidr_blocks" {
  type        = "list"
  default     = ["10.0.1.0/24"]
  description = ""
}

variable "availability_zones" {
  type        = "list"
  default     = ["us-east-1a"]
  description = ""
}

variable "bastion_ami" {
  type        = string
  description = ""
}

variable "bastion_instance_type" {
  default     = "t3.nano"
  type        = string
  description = ""
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}
