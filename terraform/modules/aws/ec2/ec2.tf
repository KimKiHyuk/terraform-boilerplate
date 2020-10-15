variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "sg_groups" {
    type = list(string)
}

variable "subnet_id" {
    type = string
} 

variable "public_access" {
  type = bool
  default = false
}


resource "aws_instance" "instance-template" {
    ami = "ami-07efac79022b86107"
    instance_type = var.instance_type
    vpc_security_group_ids = var.sg_groups
    subnet_id = var.subnet_id
    tags = {
        Name = "myapp"
    }
    associate_public_ip_address = var.public_access
}

output "instance_ip" {
    value = aws_instance.instance-template.public_ip
}