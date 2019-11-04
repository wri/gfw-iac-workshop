module "lambda_api" {
  source = "./modules/api-gateway-lambda-s3"

  bucket_name = aws_s3_bucket.default.id

  lambda_function_filename         = data.archive_file.get_bucket_acl.output_path
  lambda_function_source_code_hash = data.archive_file.get_bucket_acl.output_base64sha256
  lambda_iam_role_arn              = aws_iam_role.lambda_basic_exec_s3.arn
  lambda_function_handler          = "index.handler"

  project     = var.project
  environment = var.environment

  tags = {}
}

module "static_site" {
  source = "./modules/cloudfront-s3-lambda-at-edge"

  bucket_name                 = aws_s3_bucket.default.id
  bucket_regional_domain_name = aws_s3_bucket.default.bucket_regional_domain_name

  lambda_function_filename         = data.archive_file.security_headers.output_path
  lambda_function_source_code_hash = data.archive_file.security_headers.output_base64sha256
  lambda_iam_role_arn              = aws_iam_role.lambda_basic_exec_edge.arn
  lambda_function_handler          = "index.handler"

  cdn_origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
  cdn_price_class            = "PriceClass_All"
  cdn_viewer_protocol_policy = "redirect-to-https"
  cdn_min_ttl                = 0
  cdn_default_ttl            = 60
  cdn_max_ttl                = 86400

  project     = var.project
  environment = var.environment

  tags = {}
}

resource "aws_ecs_task_definition" "default" {
  family                   = "${var.environment}${var.project}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/task-definitions/hello_world_rds.json.tmpl", {
    image = "${var.ecr_repository_uri}:latest"

    container_name = var.container_name
    container_port = var.container_port

    postgres_name     = var.rds_database_name
    postgres_username = var.rds_database_username
    postgres_password = var.rds_database_password
    postgres_host     = aws_db_instance.default.address
    postgres_port     = aws_db_instance.default.port

    project     = var.project
    environment = var.environment
    aws_region  = var.aws_region

    log_group_name = "HelloWorldRDS"
  })
}

module "fargate_api" {
  source = "./modules/api-gateway-fargate"

  vpc_id                 = module.vpc.id
  vpc_private_subnet_ids = module.vpc.private_subnet_ids

  container_name = var.container_name
  container_port = var.container_port

  task_definition_arn    = aws_ecs_task_definition.default.arn
  desired_count          = 1
  deployment_min_percent = 100
  deployment_max_percent = 200

  project     = var.project
  environment = var.environment

  tags = {}
}
