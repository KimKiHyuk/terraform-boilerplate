variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

variable "region" {
    type = string
    default = "us-east-2"
}

variable "tag_name" {
  type    = string
  default = "myapp"
}
