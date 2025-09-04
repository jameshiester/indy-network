# Outputs
output "genesis_bucket_name" {
  description = "Name of the S3 bucket containing genesis files"
  value       = aws_s3_bucket.genesis_bucket.bucket
}

output "compose_bucket_name" {
  description = "Name of the S3 bucket containing compose files"
  value       = aws_s3_bucket.compose_bucket.bucket
}