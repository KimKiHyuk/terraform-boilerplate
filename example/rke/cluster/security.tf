resource "aws_security_group" "k8s_node" {
  vpc_id = data.aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-${var.env}-node-sg"
    "kubernetes.io/cluster/${var.cluster_id}" = "owned"
  }
}

resource "aws_key_pair" "k8s_node_key" {
  key_name   = "${var.name}-${var.env}-node-key"
  public_key = file("k8s.pem.pub")
}


