variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "region" {
  type = string
}
variable "subnet" {
  type = string
}

variable "cidr_block" {
  type = string
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "aws_sg" {
  source     = "../../modules/aws/security"
}

module "aws_vpc" {
  source     = "../../modules/aws/vpc"
  cidr_block = var.cidr_block
  subnet     = var.subnet
}