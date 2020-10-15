variable "cidr_block" {
  type = string
}

resource "aws_vpc" "vpc-template" {
  tags = {
    Name = "myapp"
  }
  cidr_block = var.cidr_block
}


output "output_vpc_id" {
  description = "output vpc id"
  value = aws_vpc.vpc-template.id
}

output "output_default_route_table_id" {
  value = aws_vpc.vpc-template.default_route_table_id
}