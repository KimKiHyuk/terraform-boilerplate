variable "cidr_block" {
  type = string
}
variable "is_public" {
  type = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "tag_name" {
  type = string
  default = "myapp"
}
