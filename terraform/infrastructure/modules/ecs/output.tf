# Output ALB DNS name for GitHub Actions job output
output "alb_dns_name" {
  value = aws_lb.mswebapp.dns_name
}