data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.name}-${var.env}-vpc"]
  }
}


data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.name}-${var.env}-public-subnet*"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["${var.name}-${var.env}-private-subnet*"]
  }
}


resource "aws_instance" "rke_main" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  subnet_id              = tolist(data.aws_subnet_ids.private.ids)[0]
  key_name               = aws_key_pair.k8s_node_key.id
  iam_instance_profile   = aws_iam_instance_profile.rke_aws.name
  vpc_security_group_ids = [aws_security_group.k8s_node.id]

  root_block_device {
    volume_size = 80
  }

  provisioner "remote-exec" {
    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s.pem")
    }

    inline = [
      "curl ${var.docker_install_url} | sh",
      "sudo usermod -aG docker ubuntu",
    ]
  }

  tags = {
    Name = "${var.name}-${var.env}-main"
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }
}




resource "aws_instance" "rke_node" {
  count                  = 2
  subnet_id              = tolist(data.aws_subnet_ids.private.ids)[count.index % length(data.aws_subnet_ids.private.ids)]
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.medium"
  key_name               = aws_key_pair.k8s_node_key.id
  iam_instance_profile   = aws_iam_instance_profile.rke_aws.name
  vpc_security_group_ids = [aws_security_group.k8s_node.id]

  root_block_device {
    volume_size = 80
  }
  
  provisioner "remote-exec" {
    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("k8s.pem")
    }

    inline = [
      "curl ${var.docker_install_url} | sh",
      "sudo usermod -aG docker ubuntu",
    ]
  }


  tags = {
    Name = "${var.name}-${var.env}-worker-${count.index}"
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }

}

