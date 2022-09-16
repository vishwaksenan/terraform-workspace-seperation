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
  region = "${terraform.workspace == "temp-app-prod" ? var.region_prod : var.region_dev}"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_instance" "temp_aws_instance" {
  provider = aws
  ami           = "${terraform.workspace == "temp-app-prod" ? var.ami_prod : var.ami_dev}"
  instance_type = var.instance_type
  tags = {
    Name = "${terraform.workspace == "temp-app-prod" ? "prodEc2" : "devEc2"}"
  }
}