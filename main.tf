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
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "dynamodb:Scan",
            "Resource": [
                "arn:aws:dynamodb:*:422847484598:table/*/index/*",
                "arn:aws:dynamodb:us-west-2:422847484598:table/${aws_dynamodb_table.manageableEC2Instances.name}"
            ]
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

#Lets each tf config opt in to being able to be managed when they insert a record into the table
resource "aws_dynamodb_table" "manageableEC2Instances"{
  name = "ManageableEC2Instances"
  hash_key = "ec2ID"
  read_capacity = 20
  write_capacity = 20
  attribute {
    name = "ec2ID"
    type = "S"
  }
}

resource "aws_lambda_function" "server_mgmt_shutdown_server" {
  function_name = "shutdown_server"
  filename = "function_stop.zip"
  role = aws_iam_role.server_mgmt.arn
  handler = "function_stop.handler"
  runtime = "python3.9"
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.manageableEC2Instances.name
    }
  }
}

# resource "aws_lambda_function" "server_mgmt_start_server" {
#   function_name = "start_server"
#   filename = "function_start.zip"
#   role = aws_iam_role.server_mgmt.arn
#   handler = "function_start.handler"
#   runtime = "python3.9"
#   environment {
#     variables = {
#       foo = "bar"
#     }
#   }
# }