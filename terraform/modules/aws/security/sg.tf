variable vpc_id {
  type = string
}

variable name {
  type = string
  default = "default-key"
}

resource "aws_security_group" "sg-template" {
  name        = var.name
  description = "{var.name} - hello world!"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "output_sg_id" {
    description = "output sg id"
    value = aws_security_group.sg-template.id
}
