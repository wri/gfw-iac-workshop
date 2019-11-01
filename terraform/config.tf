provider "aws" {
  version = "~> 2.33.0"
  region  = var.aws_region
}

provider "archive" {
  version = "~> 1.3.0"
}
