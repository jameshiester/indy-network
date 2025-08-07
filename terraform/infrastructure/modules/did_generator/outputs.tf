output "seed" {
  description = "The seed used for DID generation"
  value       = var.seed
  sensitive   = true
}

output "did" {
  description = "The generated DID"
  value       = data.external.did_info.result.did
}

output "verkey" {
  description = "The generated verkey"
  value       = data.external.did_info.result.verkey
}

output "did_name" {
  description = "The randomly generated DID name"
  value       = random_string.did_name.result
}

output "wallet_name" {
  description = "The randomly generated wallet name"
  value       = random_string.wallet_name.result
} 