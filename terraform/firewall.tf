#
# Bastion security group resources
#
resource "aws_security_group_rule" "bastion_ssh_ingress" {
  type             = "ingress"
  from_port        = 22
  to_port          = 22
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = "${module.vpc.bastion_security_group_id}"
}

resource "aws_security_group_rule" "bastion_ssh_egress" {
  type        = "egress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${module.vpc.cidr_block}"]

  security_group_id = "${module.vpc.bastion_security_group_id}"
}

resource "aws_security_group_rule" "bastion_http_egress" {
  type             = "egress"
  from_port        = "80"
  to_port          = "80"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = "${module.vpc.bastion_security_group_id}"
}

resource "aws_security_group_rule" "bastion_https_egress" {
  type             = "egress"
  from_port        = "443"
  to_port          = "443"
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = "${module.vpc.bastion_security_group_id}"
}

#
# RDS security group resources
#
resource "aws_security_group_rule" "rds_ecs_ingress" {
  type      = "ingress"
  from_port = aws_db_instance.default.port
  to_port   = aws_db_instance.default.port
  protocol  = "tcp"

  security_group_id        = aws_security_group.postgresql.id
  source_security_group_id = module.fargate_api.ecs_security_group_id
}

resource "aws_security_group_rule" "rds_bastion_ingress" {
  type      = "ingress"
  from_port = aws_db_instance.default.port
  to_port   = aws_db_instance.default.port
  protocol  = "tcp"

  security_group_id        = aws_security_group.postgresql.id
  source_security_group_id = module.vpc.bastion_security_group_id
}

#
# ECS security group resources
#
resource "aws_security_group_rule" "ecs_bastion_ingress" {
  type      = "ingress"
  from_port = var.container_port
  to_port   = var.container_port
  protocol  = "tcp"

  security_group_id        = module.fargate_api.ecs_security_group_id
  source_security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "ecs_bastion_http_ingress" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = module.fargate_api.ecs_security_group_id
  source_security_group_id = module.vpc.bastion_security_group_id
}

resource "aws_security_group_rule" "ecs_rds_egress" {
  type      = "egress"
  from_port = aws_db_instance.default.port
  to_port   = aws_db_instance.default.port
  protocol  = "tcp"

  security_group_id        = module.fargate_api.ecs_security_group_id
  source_security_group_id = aws_security_group.postgresql.id
}
