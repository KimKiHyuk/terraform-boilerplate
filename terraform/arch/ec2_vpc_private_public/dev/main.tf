provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


module "aws_vpc" {
  source     = "../../../modules/aws/vpc" # root path로 바꾸기
  cidr_block = "10.10.0.0/16"
}

module "aws_private_subnet" {
  source     = "../../../modules/aws/subnet"
  cidr_block = "10.10.21.0/24"
  vpc_id     = module.aws_vpc.vpc_id
  is_public  = false # 변수명 변경
}

module "aws_public_subnet" {
  source     = "../../../modules/aws/subnet"
  cidr_block = "10.10.20.0/24" # cidr_block 으로 변경
  vpc_id     = module.aws_vpc.vpc_id
  is_public  = true # 변수명 변경
}

module "aws_vpc_network" {
  source    = "../../../modules/aws/network/igw_nat_subnet"
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

module "aws_key_pair" {
  source = "../../../modules/aws/keypair"
  name   = "ec2-key"
}

module "aws_sg" {
  source = "../../../modules/aws/security"
  vpc_id = module.aws_vpc.vpc_id
  name   = "my_sg_group"
}

module "aws_ec2_public" {
  source        = "../../../modules/aws/ec2"
  name          = "auto_generated_public_ec2"
  sg_groups     = [module.aws_sg.sg_id]
  key_name      = module.aws_key_pair.key_name
  public_access = true
  subnet_id     = module.aws_public_subnet.subnet_id
}

module "aws_ec2_private" {
  source        = "../../../modules/aws/ec2"
  name          = "auto_generated_private_ec2"
  sg_groups     = [module.aws_sg.sg_id]
  key_name      = module.aws_key_pair.key_name
  public_access = false
  subnet_id     = module.aws_private_subnet.subnet_id
}