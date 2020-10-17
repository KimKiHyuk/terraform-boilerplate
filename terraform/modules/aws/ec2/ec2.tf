resource "aws_instance" "instance-template" {
    ami = "ami-07efac79022b86107"
    instance_type = var.instance_type
    vpc_security_group_ids = var.sg_groups
    subnet_id = var.subnet_id
    key_name = var.key_name
    tags = {
        Name = var.name
    }
    associate_public_ip_address = var.public_access
}