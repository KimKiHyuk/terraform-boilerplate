variable "cidr_block" {
  type = string
}

resource "aws_vpc" "aws_terraform_vpc" {
  tags = {
    Name = "myapp"
  }
  cidr_block = var.cidr_block
}


output "output_vpc_id" {
  description = "output subnet id"
  value = aws_vpc.aws_terraform_vpc.id
}