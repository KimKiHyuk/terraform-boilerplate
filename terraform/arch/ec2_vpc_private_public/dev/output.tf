output "public_ip" {
  value = module.aws_ec2_public.public_ip
}

output "private_ip" {
  value = module.aws_ec2_private.private_ip
}

output "ssh_private_key_pem" {
  value = module.aws_key_pair.ssh_private_key_pem
}

output "ssh_public_key_pem" {
  value = module.aws_key_pair.ssh_public_key_pem
}