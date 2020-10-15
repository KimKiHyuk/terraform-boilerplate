variable "access_key" {

}

variable "secret_key" {

}

variable "region" {

}

variable "tag_name" {
    type = string
    default = "myapp"
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


module "aws_vpc" {
    source = "../../../modules/aws/vpc" # root path로 바꾸기
    cidr_block = "10.10.0.0/16"
}

module "aws_private_subnet" {
    source = "../../../modules/aws/subnet"
    subnet = "10.10.21.0/24" # cidr_block 으로 변경
    vpc_id = module.aws_vpc.output_vpc_id
    public_subnet = false # 변수명 변경
}

module "aws_public_subnet" {
    source = "../../../modules/aws/subnet"
    subnet = "10.10.20.0/24" # cidr_block 으로 변경
    vpc_id = module.aws_vpc.output_vpc_id
    public_subnet = true # 변수명 변경
}

module "aws_vpc_network" {
    source = "../../../modules/aws/network/igw_nat_subnet"
    vpc_id = module.aws_vpc.output_vpc_id
    subnet_id = module.aws_public_subnet.output_subnet_id
}


## route 설정

resource "aws_route_table" "public-route" {
  vpc_id =  module.aws_vpc.output_vpc_id
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = module.aws_vpc_network.igw_id
  }

  tags = {
      Name = var.tag_name
  }
}

resource "aws_default_route_table" "private-route" {
  default_route_table_id = module.aws_vpc.output_default_route_table_id
  tags = {
      Name = var.tag_name
  }
}

# for 문으로 간략화

resource "aws_route_table_association" "to-public" {
  subnet_id = module.aws_public_subnet.output_subnet_id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "to-private" {
  subnet_id = module.aws_private_subnet.output_subnet_id
  route_table_id = aws_default_route_table.private-route.default_route_table_id
}




## ec2 연결

module "aws_sg" {
    source = "../../../modules/aws/security"
    vpc_id = module.aws_vpc.output_vpc_id
    name = "my_sg_group"
}

module "aws_ec2_public" {
    source = "../../../modules/aws/ec2"
    sg_groups = [module.aws_sg.output_sg_id]
    public_access = true
    subnet_id = module.aws_public_subnet.output_subnet_id
}

module "aws_ec2_private" {
    source = "../../../modules/aws/ec2"
    sg_groups = [module.aws_sg.output_sg_id]
    public_access = false
    subnet_id = module.aws_private_subnet.output_subnet_id
}