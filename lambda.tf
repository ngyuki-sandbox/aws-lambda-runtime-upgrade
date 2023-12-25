
variable "region" {
  type = string
}

variable "allowed_account_ids" {
  type = list(string)
}

variable "default_tags" {
  type = map(string)
}

variable "project" {
  type    = string
  default = "lambda-runtime-upgrade"
}

provider "aws" {
  region              = var.region
  allowed_account_ids = var.allowed_account_ids
  default_tags {
    tags = var.default_tags
  }
}

data "archive_file" "main" {
  type        = "zip"
  source_file = "index.mjs"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "main" {
  function_name = var.project
  role          = aws_iam_role.main.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 60

  filename         = data.archive_file.main.output_path
  source_code_hash = data.archive_file.main.output_base64sha256

  publish = true
}

resource "aws_lambda_alias" "main" {
  name             = split(".", aws_lambda_function.main.runtime)[0]
  function_name    = aws_lambda_function.main.function_name
  function_version = aws_lambda_function.main.version
}

resource "aws_lambda_alias" "stable" {
  name             = "stable"
  function_name    = aws_lambda_function.main.function_name
  function_version = aws_lambda_function.main.version
}

output "lambda" {
  value = {
    name    = aws_lambda_function.main.function_name
    version = aws_lambda_function.main.version
    alias   = aws_lambda_alias.main.name
  }
}

resource "aws_iam_role" "main" {
  name                  = var.project
  force_detach_policies = true

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "main" {
  name = aws_iam_role.main.name
  role = aws_iam_role.main.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ],
        "Resource" : "*"
      },
    ]
  })
}
