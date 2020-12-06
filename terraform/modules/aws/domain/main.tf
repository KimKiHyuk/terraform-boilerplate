resource "aws_route53_zone" "zone" {
  name = var.name
}


resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.zone.zone_id}" # Replace with your zone ID
  name    = "keykim.me"
  type    = "A"

  alias {
    name                   = var.lb.dns_name
    zone_id                = var.lb.zone_id
    evaluate_target_health = true
  }
}