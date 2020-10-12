variable "cidr_block" {
  type = string
}

resource "aws_vpc" "aws_terraform_vpc" {
  tags = {
    Name = "myapp"
  }
  cidr_block = var.cidr_block
}
