variable "region_dev" {
  type    = string
  default = "ap-southeast-1"
}

variable "region_prod" {
  type    = string
  default = "eu-west-2"
}

variable "ami_dev" {
  type    = string
  default = "ami-0b89f7b3f054b957e"
}

variable "ami_prod" {
  type    = string
  default = "ami-00785f4835c6acf64"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}