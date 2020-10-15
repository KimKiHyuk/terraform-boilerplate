resource "aws_internet_gateway" "igw-template" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.tag_name
  }
}

output "igw_id" {
  value = aws_internet_gateway.igw-template.id
}