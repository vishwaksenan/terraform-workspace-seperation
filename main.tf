terraform {
  backend "remote" {
    organization = "tempdev"
    workspaces {
      prefix = "temp-"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = terraform.workspace == "temp-app-prod" ? var.region_prod : var.region_dev
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

resource "aws_instance" "temp_aws_instance" {
  provider      = aws
  ami           = terraform.workspace == "temp-app-prod" ? var.ami_prod : var.ami_dev
  instance_type = var.instance_type
  tags = {
    Name = "${terraform.workspace == "temp-app-prod" ? "prodEc2" : "devEc2"}"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = terraform.workspace == "temp-app-prod" ? "iam_for_lambda" : "iam_for_lambda_dev"

  assume_role_policy = <<EOF
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
EOF
}

data "archive_file" "python_lambda_hello_world" {
  type        = "zip"
  source_dir  = "${path.module}/python-lambda"
  output_path = "${path.module}/python-lambda/python-lambda.zip"
}

resource "aws_lambda_function" "terraform_lambda" {
  filename      = "${path.module}/python-lambda/python-lambda.zip"
  function_name = "first_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "hello-world.lambda_handler"
  runtime       = "python3.8"
}