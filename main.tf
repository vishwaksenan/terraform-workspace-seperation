terraform {
  backend "remote" {
    organization = "tempdev"
    workspaces {
      prefix = "temp-app-"
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
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
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
  name = "iam_for_lambda"

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