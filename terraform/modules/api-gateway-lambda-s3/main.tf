#
# API Gateway resources
#
resource "aws_api_gateway_rest_api" "default" {
  name = "api${var.environment}${var.project}"
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
  uri                     = aws_lambda_function.api_handler.invoke_arn
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
  uri                     = aws_lambda_function.api_handler.invoke_arn
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
resource "aws_lambda_function" "api_handler" {
  function_name    = "func${var.environment}${var.project}GetS3ACL"
  filename         = var.lambda_function_filename
  source_code_hash = var.lambda_function_source_code_hash
  role             = var.lambda_iam_role_arn
  runtime          = "python3.7"
  handler          = var.lambda_function_handler
  memory_size      = 128
  timeout          = 5
  publish          = true

  environment {
    variables = {
      ENVIRONMENT = var.environment
      S3_BUCKET   = var.bucket_name
    }
  }

  tags = merge(
    {
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "perm${var.environment}${var.project}GetS3ACL"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.api_handler.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource within the
  # API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*/*"
}
