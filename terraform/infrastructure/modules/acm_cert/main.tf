locals {
  tags = {
    Environment = var.EnvTag
    EnvCode     = var.EnvCode
    Solution    = var.SolTag
  }
}

data "aws_region" "current" {}

data "aws_route53_zone" "selected" {
  name         = var.Domain
  private_zone = false

}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.Subdomain != "" ? "${var.Subdomain}.${var.Domain}" : var.Domain
  validation_method = "DNS"
  tags              = local.tags

}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo_resource in aws_acm_certificate.cert.domain_validation_options : dvo_resource.domain_name => {
      name   = dvo_resource.resource_record_name
      record = dvo_resource.resource_record_value
      type   = dvo_resource.resource_record_type
    }
  }
  zone_id         = data.aws_route53_zone.selected.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
  depends_on      = [aws_acm_certificate.cert]
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
  depends_on              = [aws_route53_record.cert_validation]
}