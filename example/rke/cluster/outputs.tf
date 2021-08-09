output "ssh_username" {
  value = "ubuntu"
}

output "master_node_private_ip" {
  value = aws_instance.rke_main.private_ip
}

output "worker_node_private_ip" {
  value = aws_instance.rke_node[*].private_ip
}
