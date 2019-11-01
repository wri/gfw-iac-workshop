data "aws_ami" "amazon_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

module "vpc" {
  source = "./modules/vpc"

  name        = "vpc${var.environment}${var.project}"
  region      = var.aws_region
  key_name    = var.aws_key_name
  bastion_ami = data.aws_ami.amazon_linux_ami.id

  project     = var.project
  environment = var.environment

  tags = {}
}
