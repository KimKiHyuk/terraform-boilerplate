variable "subnet" {
  type = string
}
resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.aws_terraform_vpc.id
  tags = {
    Name = "myapp"
  }
  cidr_block = var.subnet
}


output "output_subnet_id" {
    description = "output subnet id"
    value = aws_subnet.my_subnet.id
}