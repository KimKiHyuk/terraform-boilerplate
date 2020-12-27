output "alb_name" {
  value = aws_lb.staging.dns_name
}

output "cert_arn" {
  value = aws_acm_certificate.cert.arn
}