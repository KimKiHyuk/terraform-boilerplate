terraform {
  backend "local" {
    path = "./ec2_with_nginx_terraform.tfstate"
    workspace_dir = "."
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


module "aws_vpc" {
  source     = "../../../modules/aws/vpc"
  cidr_block = "10.10.0.0/16"
}


module "aws_public_subnet" {
  source     = "../../../modules/aws/subnet"
  cidr_block = "10.10.10.0/24"
  vpc_id     = module.aws_vpc.vpc_id
  is_public  = true
}


## ec2 연결

module "aws_sg" {
  source = "../../../modules/aws/security"
  vpc_id = module.aws_vpc.vpc_id
  name   = "my_sg_group"
}

module "aws_ec2_public" {
  source        = "../../../modules/aws/ec2/docker_ec2"
  name          = "auto_generated_public_ec2"
  sg_groups     = [module.aws_sg.sg_id]
  key_name      = "test-key"
  public_access = true
  subnet_id     = module.aws_public_subnet.subnet_id

  docker_image  = "nginx"
  in_port       = "80"
  out_port      = "80"
  key_path      = "../../../../../test-key.pem"
}