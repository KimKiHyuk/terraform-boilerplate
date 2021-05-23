

output "vpc_id" {
  description = "output vpc id"
  value       = aws_vpc.vpc-template.id
}

output "default_route_table_id" {
  value = aws_vpc.vpc-template.default_route_table_id
}