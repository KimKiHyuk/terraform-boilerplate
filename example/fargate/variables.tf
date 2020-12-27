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

variable "tag_name" {
  type    = string
  default = "service"
}

variable "domain" {
  type = string
}

variable "container_port" {
  type    = number
  default = 80
}


variable "host_port" {
  type    = number
  default = 80
}

variable "tpl_path" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "app_name" {
  type = string
}