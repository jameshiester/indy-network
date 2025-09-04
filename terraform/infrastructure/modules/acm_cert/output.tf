output "zone_id" {
  value       = data.aws_route53_zone.selected.zone_id
  description = "Zone ID of the Route 53 zone"
}

output "acm_cert_arn" {
  value       = aws_acm_certificate_validation.cert.certificate_arn
  description = "ARN of the ACM certificate"
}

output "certificate_domain" {
  description = "Domain name for the certificate"
  value       = aws_acm_certificate.cert.domain_name
}

output "certificate_validation_domains" {
  description = "All domains being validated"
  value       = aws_acm_certificate.cert.subject_alternative_names
}
