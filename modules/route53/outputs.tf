output "zone_id" {
  description = "The hosted zone ID of the Route 53 zone"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The name servers for the Route 53 zone"
  value       = aws_route53_zone.main.name_servers
}

output "domain_records" {
  description = "List of created domain records"
  value       = concat([aws_route53_record.apex.name], [for record in aws_route53_record.sans : record.name])
}
