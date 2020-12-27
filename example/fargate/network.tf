resource "aws_vpc" "cluster_vpc" {
  tags = {
    Name = "ecs-vpc"
  }
  cidr_block = "10.30.0.0/16"
}

data "aws_availability_zones" "available" {

}

resource "aws_subnet" "cluster" {
  vpc_id            = aws_vpc.cluster_vpc.id
  count             = length(data.aws_availability_zones.available.names)
  cidr_block        = "10.30.${10 + count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "ecs-subnet"
  }
}


resource "aws_internet_gateway" "cluster_igw" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = "ecs-igw"
  }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.cluster_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cluster_igw.id
  }

  tags = {
    Name = "ecs-route-table"
  }
}

resource "aws_route_table_association" "to-public" {
  count          = length(aws_subnet.cluster)
  subnet_id      = aws_subnet.cluster[count.index].id
  route_table_id = aws_route_table.public_route.id
}