variable "subnet" {
  type = string
}
resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.aws_terraform_vpc.id
  tags = {
    Name = "myapp"
  }
  cidr_block = var.subnet
}