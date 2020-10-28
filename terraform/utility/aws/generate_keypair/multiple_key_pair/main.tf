provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "multiple_key" {
    source = "/infra/terraform/modules/aws/keypair"
    count = var.key_count
    name = "${var.name}-${count.index}"
}
