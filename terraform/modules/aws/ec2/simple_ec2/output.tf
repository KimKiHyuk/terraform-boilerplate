output "public_ip" {
  value = aws_instance.instance-template.public_ip
}

output "private_ip" {
  value = aws_instance.instance-template.private_ip
}