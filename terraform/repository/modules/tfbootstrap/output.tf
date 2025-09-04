
# Outputs used to create GitHub resources
output "gha_iam_role" {
  value = aws_iam_role.github_actions.arn
}
output "tfstate_bucket_name" {
  value = aws_s3_bucket.tfstate.bucket
}
output "tfstate_dynamodb_table_name" {
  value = aws_dynamodb_table.tfstate.name
}

output "ecr_node_repo_url" {
  value = aws_ecr_repository.node.repository_url
}

output "ecr_server_repo_url" {
  value = aws_ecr_repository.server.repository_url
}

output "ecr_node_repo_name" {
  value = aws_ecr_repository.node.name
}

output "ecr_server_repo_name" {
  value = aws_ecr_repository.server.name
}

output "ecr_monitor_repo_name" {
  value = aws_ecr_repository.monitor.name
}

output "ecr_monitor_repo_url" {
  value = aws_ecr_repository.monitor.repository_url
}

output "ecr_utils_repo_name" {
  value = aws_ecr_repository.utils.name
}

output "ecr_utils_repo_url" {
  value = aws_ecr_repository.utils.repository_url
}
