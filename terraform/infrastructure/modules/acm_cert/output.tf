output "acm_cert_arn" {
  value       = aws_acm_certificate.cert.arn
  description = "ARN of the ACM certificate"
}

output "zone_id" {
  value       = data.aws_route53_zone.selected.zone_id
  description = "Zone ID of the Route 53 zone"
}
