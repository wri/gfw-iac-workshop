locals {
  rds_database_identifier = "db${lower(var.environment)}${lower(replace(var.project, " ", ""))}"
}

#
# Security group resources
#
resource "aws_security_group" "postgresql" {
  name   = "sgDb${var.environment}${var.project}"
  vpc_id = module.vpc.id

  tags = {
    Name        = "sgDb${var.environment}${var.project}",
    Project     = var.project,
    Environment = var.environment
  }
}

#
# RDS resources
#
resource "aws_db_subnet_group" "default" {
  name       = local.rds_database_identifier
  subnet_ids = module.vpc.private_subnet_ids

  tags = {
    Name        = local.rds_database_identifier,
    Project     = var.project,
    Environment = var.environment
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 32
  storage_type           = "gp2"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  engine                 = "postgres"
  engine_version         = "11.5"
  identifier             = local.rds_database_identifier
  instance_class         = "db.t3.micro"
  name                   = var.rds_database_name
  username               = var.rds_database_username
  password               = var.rds_database_password
  parameter_group_name   = "default.postgres11"
  vpc_security_group_ids = [aws_security_group.postgresql.id]
}
