resource "aws_route53_zone" "front" {
  name          = var.name
  force_destroy = true
}