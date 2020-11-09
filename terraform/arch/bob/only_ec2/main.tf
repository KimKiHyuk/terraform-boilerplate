provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  json_data = jsondecode(file("./data.json"))
}

module "aws_vpc" {
  source     = "../../../modules/aws/vpc"
  cidr_block = "10.10.0.0/16"
}

module "aws_private_subnet" {
  source     = "../../../modules/aws/subnet"
  cidr_block = "10.10.21.0/24"
  vpc_id     = module.aws_vpc.vpc_id
  is_public  = false
}

module "aws_public_subnet" {
  source     = "../../../modules/aws/subnet"
  cidr_block = "10.10.20.0/24"
  vpc_id     = module.aws_vpc.vpc_id
  is_public  = true
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
    Name = "ec2::Route-public"
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
    Name = "ec2::Route-private"
  }
}

resource "aws_route_table_association" "to-private" {
  subnet_id      = module.aws_private_subnet.subnet_id
  route_table_id = aws_route_table.private-route.id
}



## ec2 연결

module "public_aws_key_pair" {
  source = "../../../modules/aws/keypair"
  name   = "ec2::public::key"
}

module "private_aws_key_pair" {
  source = "../../../modules/aws/keypair"
  count  = length(local.json_data.privateData.server)
  name   = local.json_data.privateData.server[count.index].name
}

module "aws_sg" {
  source = "../../../modules/aws/security"
  vpc_id = module.aws_vpc.vpc_id
  name   = "ec2_sg_group"
}

module "aws_ec2_public" {
  source        = "../../../modules/aws/ec2/simple_ec2"
  count         = length(local.json_data.publicData.server.*)
  name          = local.json_data.publicData.server[count.index].name
  sg_groups     = [module.aws_sg.sg_id]
  key_name      = module.public_aws_key_pair.key_name
  public_access = true
  subnet_id     = module.aws_public_subnet.subnet_id
}

module "aws_ec2_private" {
  source        = "../../../modules/aws/ec2/simple_ec2"
  count         = length(local.json_data.privateData.server)
  name          = local.json_data.privateData.server[count.index].name
  sg_groups     = [module.aws_sg.sg_id]
  key_name      = module.private_aws_key_pair[count.index].key_name
  public_access = false
  subnet_id     = module.aws_private_subnet.subnet_id
}