data "aws_route53_zone" "front" {
  name         = var.name
  private_zone = false
}

resource "aws_route53_record" "front" {
  zone_id = data.aws_route53_zone.front.zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = var.lb.dns_name
    zone_id                = var.lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.front.zone_id
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}