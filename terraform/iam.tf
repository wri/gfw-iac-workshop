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

resource "aws_iam_role" "lambda_basic_exec_s3" {
  name               = "lambda${var.environment}${var.project}S3BasicExecRole"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_basic_exec_s3.name
  policy_arn = var.aws_lambda_basic_exec_role_policy_arn
}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.lambda_basic_exec_s3.name
  policy_arn = var.aws_s3_read_only_policy_arn
}
