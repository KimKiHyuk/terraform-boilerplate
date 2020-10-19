provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


module "aws_vpc" {
  source     = "/infra/terraform/modules/aws/vpc"
  cidr_block = "10.10.0.0/16"
}

module "aws_private_subnet" {
  source     = "/infra/terraform/modules/aws/subnet"
  cidr_block = "10.10.21.0/24"
  vpc_id     = module.aws_vpc.vpc_id
  is_public  = false
}

module "aws_public_subnet" {
  source     = "/infra/terraform/modules/aws/subnet"
  cidr_block = "10.10.20.0/24"
  vpc_id     = module.aws_vpc.vpc_id
  is_public  = true
}

module "aws_vpc_network" {
  source    = "/infra/terraform/modules/aws/network/igw_nat_subnet"
  vpc_id    = module.aws_vpc.vpc_id
  subnet_id = module.aws_public_subnet.subnet_id
}


# public route 설정

resource "aws_route_table" "public-route" {
  vpc_id = module.aws_vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.aws_vpc_network.igw_id
  }

  tags = {
    Name = var.tag_name
  }
}

resource "aws_route_table_association" "to-public" {
  subnet_id      = module.aws_public_subnet.subnet_id
  route_table_id = aws_route_table.public-route.id
}


# private route 설정

resource "aws_route_table" "private-route" {
  vpc_id = module.aws_vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = module.aws_vpc_network.nat_gateway_id
  }

  tags = {
    Name = var.tag_name
  }
}

resource "aws_route_table_association" "to-private" {
  subnet_id      = module.aws_private_subnet.subnet_id
  route_table_id = aws_route_table.private-route.id
}



## ec2 연결

module "aws_sg" {
  source = "/infra/terraform/modules/aws/security"
  vpc_id = module.aws_vpc.vpc_id
  name   = "my_sg_group"
}

module "aws_ec2_public" {
  source        = "/infra/terraform/modules/aws/ec2/docker_ec2"
  name          = "auto_generated_public_ec2"
  sg_groups     = [module.aws_sg.sg_id]
  key_name      = "test-key"
  public_access = true
  subnet_id     = module.aws_public_subnet.subnet_id

  docker_image = "nginx"
  in_port      = "80"
  out_port     = "80"
  key_path     = "./test-key.pem"
}

module "aws_ec2_private" {
  source        = "/infra/terraform/modules/aws/ec2/simple_ec2"
  name          = "auto_generated_private_ec2"
  sg_groups     = [module.aws_sg.sg_id]
  key_name      = "test-key"
  public_access = false
  subnet_id     = module.aws_private_subnet.subnet_id
}