resource "aws_eip" "eip-template" {
  vpc=true
}

resource "aws_nat_gateway" "ngw-template" {
  allocation_id = aws_eip.eip-template.id
  subnet_id = var.subnet_id
  tags = {
      Name = var.tag_name
  }
}

