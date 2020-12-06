output "alb_name" {
  value = aws_lb.staging.dns_name
}

output "dns_name_servers" {
  value = module.route53.name_server
}