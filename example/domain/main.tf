provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_route53_zone" "front" {
  name          = var.domain
  force_destroy = true
}