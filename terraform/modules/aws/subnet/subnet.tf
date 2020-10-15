variable "subnet" {
  type = string
}
variable "public_subnet" {
  type = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "tag_name" {
  type = string
  default = "myapp"
}

resource "aws_subnet" "subnet-template" {
  vpc_id = var.vpc_id
  tags = {
    Name = var.tag_name
  }

  map_public_ip_on_launch = var.public_subnet
  cidr_block = var.subnet
}


output "output_subnet_id" {
    description = "output subnet id"
    value = aws_subnet.subnet-template.id
}