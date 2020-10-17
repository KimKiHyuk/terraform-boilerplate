output "eip_ip" {
    value= aws_eip.eip-template.public_ip
}

output "nat_gateway_id" {
  value = aws_nat_gateway.ngw-template.id
}

output "igw_id" {
  value = aws_internet_gateway.igw-template.id
}