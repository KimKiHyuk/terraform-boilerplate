resource "aws_instance" "instance-template" {
  ami                    = "ami-07efac79022b86107"
  instance_type          = var.instance_type
  vpc_security_group_ids = var.sg_groups
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  tags = {
    Name = var.name
  }
  associate_public_ip_address = var.public_access

  provisioner "file" {
    source      = "../../../../../scripts/deploy_with_docker.sh"
    destination = "/tmp/script.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = ""
    private_key = file(var.key_path)
    host     = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh ${var.docker_image} ${var.in_port} ${var.out_port}",
    ]
  }
}