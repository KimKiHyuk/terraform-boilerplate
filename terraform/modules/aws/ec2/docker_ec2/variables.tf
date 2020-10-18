variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "sg_groups" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "public_access" {
  type    = bool
  default = false
}

variable "name" {
  type    = string
  default = "myapp"
}

variable "key_name" {
  type = string
}

variable "out_port" {
  type = string
}

variable "in_port" {
  type = string
}

variable "docker_image" {
  type = string
}