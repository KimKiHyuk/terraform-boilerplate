variable "root_path" {
  type = string
  default = "."
}
variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "public_cnt" {
    type = number
}


variable "private_cnt" {
    type = number
}