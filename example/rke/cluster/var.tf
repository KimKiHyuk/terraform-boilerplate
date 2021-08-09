variable "env" {
  type    = string
  default = "dev"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "name" {
  type    = string
  default = "k8s"
}
variable "region" {
  type    = string
  default = "ap-northeast-2"
}
variable "access_key" {}
variable "secret_key" {}


variable "docker_install_url" {
  default = "https://releases.rancher.com/install-docker/19.03.sh"
}

variable "cluster_id" {
  default = "rke"
}