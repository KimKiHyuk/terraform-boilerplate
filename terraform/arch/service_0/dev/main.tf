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

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "public_access" {
  type = bool
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "aws_sg" {
  source = "../../../modules/aws/security"
  vpc_id = module.aws_vpc.output_vpc_id
}

module "aws_vpc" {
  source     = "../../../modules/aws/vpc"
  cidr_block = var.cidr_block
  subnet     = var.subnet
}

module "aws_ec2" {
  source        = "../../../modules/aws/ec2"
  instance_type = var.instance_type
  sg_groups = [module.aws_sg.output_sg_id]
  subnet_id = module.aws_vpc.output_subnet_id
  public_access = var.public_access
}

output "instance_ip" {
    value = module.aws_ec2.instance_ip
}