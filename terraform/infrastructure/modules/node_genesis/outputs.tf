# All outputs for nodes_genesis_file.csv format
output "steward_name" {
  description = "Steward name"
  value       = data.external.genesis_info.result.steward_name
}

output "validator_alias" {
  description = "Validator alias"
  value       = data.external.genesis_info.result.validator_alias
}

output "node_ip_address" {
  description = "Node IP address"
  value       = data.external.genesis_info.result.node_ip_address
}

output "node_port" {
  description = "Node port"
  value       = data.external.genesis_info.result.node_port
}

output "client_ip_address" {
  description = "Client IP address"
  value       = data.external.genesis_info.result.client_ip_address
}

output "client_port" {
  description = "Client port"
  value       = data.external.genesis_info.result.client_port
}

output "validator_verkey" {
  description = "Validator verkey"
  value       = data.external.genesis_info.result.validator_verkey
}

output "validator_bls_key" {
  description = "Validator BLS key"
  value       = data.external.genesis_info.result.validator_bls_key
}

output "validator_bls_pop" {
  description = "Validator BLS proof of possession"
  value       = data.external.genesis_info.result.validator_bls_pop
}

output "steward_did" {
  description = "Steward DID"
  value       = data.external.genesis_info.result.steward_did
}

output "steward_verkey" {
  description = "Steward verkey"
  value       = data.external.genesis_info.result.steward_verkey
}

# Additional outputs
output "network_name" {
  description = "Network name"
  value       = data.external.genesis_info.result.network_name
}

output "created_at" {
  description = "Creation timestamp"
  value       = data.external.genesis_info.result.created_at
}

output "node_name" {
  description = "Generated node name"
  value       = var.node_name
}

output "steward_name_generated" {
  description = "Generated steward name"
  value       = random_string.steward_name.result
}

# Sensitive outputs
output "steward_seed" {
  description = "The steward seed used for generation"
  value       = var.steward_seed
  sensitive   = true
}

output "node_seed" {
  description = "The node seed used for generation"
  value       = var.node_seed
  sensitive   = true
} 