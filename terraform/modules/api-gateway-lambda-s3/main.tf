#
# IAM resources
#
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "default" {
  name               = "lambda${var.environment}${var.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "default_lambda_policy" {
  role       = aws_iam_role.default.name
  policy_arn = var.aws_lambda_service_role_policy_arn
}

resource "aws_iam_role_policy_attachment" "default_s3_policy" {
  role       = aws_iam_role.default.name
  policy_arn = var.aws_s3_policy_arn
}

#
# API Gateway resources
#
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

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.default.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.default.id
  resource_id   = aws_api_gateway_rest_api.default.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.default.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.default.invoke_arn
}

resource "aws_api_gateway_deployment" "default" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = aws_api_gateway_rest_api.default.id
  stage_name  = "default"
}

#
# Lambda resources
#
resource "aws_lambda_function" "default" {
  filename = "${var.lambda_function_filename}"

  function_name = "func${var.environment}${var.name}"

  handler     = var.lambda_function_handler
  role        = aws_iam_role.default.arn
  memory_size = 128
  runtime     = "python3.7"
  timeout     = 10

  environment {
    variables = {
      ENVIRONMENT = var.environment
      S3_BUCKET   = aws_s3_bucket.default.id
    }
  }

  source_code_hash = filesha256(var.lambda_function_filename)

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_lambda_permission" "default" {
  statement_id  = "perm${var.environment}${var.name}"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.default.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource within the
  # API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*/*"
}

#
# S3 resources
#
resource "aws_s3_bucket" "default" {
  bucket = "${lower(replace(var.project, " ", ""))}-${lower(var.environment)}-${lower(var.name)}-${var.aws_region}"
  acl    = "private"

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
