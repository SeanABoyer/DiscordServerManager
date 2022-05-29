terraform {
  required_version = ">=1.1.3"
}

provider "aws" {
  region = "us-west-2"
}
resource "aws_iam_role_policy" "server_mgmt" {
    name = "server_mgmt"
    role = aws_iam_role.server_mgmt.id
    policy = jsonencode(
      {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Action": "route53:ListResourceRecordSets",
                "Resource": "arn:aws:route53:::hostedzone/*"
            }
        ]
      }
    )
}

resource "aws_iam_role" "server_mgmt" {
  name ="server_mgmt"
  assume_role_policy = jsonencode(
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

resource "aws_lambda_function" "server_mgmt_shutdown_server" {
  function_name = "shutdown_server"
  filename = "function_stop.zip"
  role = aws_iam_role.server_mgmt.arn
  handler = "function.handler"
  runtime = "python3.9"
}

# resource "aws_lambda_function" "server_mgmt_start_server" {
#   function_name = "start_server"
#   filename = "function_start.zip"
#   role = aws_iam_role.server_mgmt.arn
#   handler = "function.handler"
#   runtime = "python3.9"
# }