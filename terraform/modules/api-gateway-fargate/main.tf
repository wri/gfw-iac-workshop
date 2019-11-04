#
# API Gateway resources
#
resource "aws_api_gateway_vpc_link" "default" {
  name        = "link${var.environment}${var.name}"
  target_arns = [aws_lb.default.arn]
}

resource "aws_api_gateway_rest_api" "default" {
  name = "api${var.environment}${var.name}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  parent_id   = aws_api_gateway_rest_api.default.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "nlb" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = "${aws_api_gateway_vpc_link.default.id}"
  uri                     = "http://${aws_lb.default.dns_name}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_rest_api.default.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "nlb_root" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = "${aws_api_gateway_vpc_link.default.id}"
  uri                     = "http://${aws_lb.default.dns_name}"
}

resource "aws_api_gateway_deployment" "default" {
  depends_on = [
    "aws_api_gateway_integration.nlb",
    "aws_api_gateway_integration.nlb_root",
  ]

  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name  = "default"
}

#
# Security Group Resources
#
resource "aws_security_group" "default" {
  name   = "sgEcsService${var.environment}${var.name}"
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name        = "sgEcsService${var.environment}${var.name}",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_security_group_rule" "ecs_https_egress" {
  type             = "egress"
  from_port        = 443
  to_port          = 443
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}

data "aws_subnet" "private_subnet" {
  count = length(var.vpc_private_subnet_ids)
  id    = var.vpc_private_subnet_ids[count.index]
}

resource "aws_security_group_rule" "ecs_nlb_ingress" {
  type        = "ingress"
  from_port   = var.container_port
  to_port     = var.container_port
  protocol    = "tcp"
  cidr_blocks = data.aws_subnet.private_subnet.*.cidr_block

  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "nlb_http_ingress" {
  type             = "ingress"
  from_port        = 80
  to_port          = 80
  protocol         = "tcp"
  cidr_blocks      = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]

  security_group_id = aws_security_group.default.id
}


#
# NLB Resources
#
resource "aws_lb" "default" {
  name                             = "nlb${var.environment}${var.name}"
  internal                         = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true

  subnets = var.vpc_private_subnet_ids

  tags = merge(
    {
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_lb_target_group" "default" {
  name = "tg${var.environment}${var.name}"

  health_check {
    protocol          = "TCP"
    interval          = "30"
    healthy_threshold = "3"
    # For Network Load Balancers, this value must be the same as the healthy_threshold.
    unhealthy_threshold = "3"
  }

  port     = "80"
  protocol = "TCP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  tags = merge(
    {
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_lb_listener" "default" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.default.id
    type             = "forward"
  }
}

#
# ECS Resources
#
resource "aws_ecs_cluster" "default" {
  name = "ecs${var.environment}${var.name}Cluster"
}

resource "aws_ecs_service" "default" {
  name            = "${var.environment}${var.name}"
  cluster         = aws_ecs_cluster.default.id
  task_definition = var.task_definition_arn

  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.deployment_min_percent
  deployment_maximum_percent         = var.deployment_max_percent

  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.default.id]
    subnets         = var.vpc_private_subnet_ids
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.default.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [
    "aws_lb_listener.default",
  ]
}

#
# CloudWatch Resources
#
resource "aws_cloudwatch_log_group" "default" {
  name              = "log${var.environment}${var.name}"
  retention_in_days = 30
}
