terraform {
  required_version = ">=1.1.3"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_role_policy" "server_mgmt_lambda_assume_role_policy" {
  name = "server_mgmt_lambda_assume_role_policy"
  role = aws_iam_role.server_mgmt_shutdown.id
  policy = jsonencode(
      {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  )
}

resource "aws_iam_role" "server_mgmt_shutdown" {
  name ="server_mgmt_shutdown"
}

resource "aws_lambda_function" "server_mgmt_shutdown_server" {
  function_name = "shutdown_server"
  filename = "function.zip"
  role = aws_iam_role.server_mgmt_shutdown.arn
  handler = "function.handler"
  runtime = "python3.9"
}
