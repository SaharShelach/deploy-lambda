terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_lambda_function" "hello_lambda" {
  filename      = "lambda_function.zip"
  function_name = "hello-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  source_code_hash = filebase64sha256("lambda_function.zip")
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

resource "aws_lambda_function_url" "lambda_function_url" {
  function_name = aws_lambda_function.hello_lambda.arn
  authorization_type = "NONE"
}

output "function_url" {
  description = "Function URL."
  value = aws_lambda_function_url.lambda_function_url.function_url
}}
