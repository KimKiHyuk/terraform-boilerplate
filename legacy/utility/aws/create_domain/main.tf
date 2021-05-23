provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "domain" {
  source = "../../../modules/aws/domain/create"
  name   = "keykim.me"
}