variable "steward_seed" {
  description = "Seed for steward DID generation"
  type        = string
  sensitive   = true
}

variable "node_seed" {
  description = "Seed for node indy keys generation"
  type        = string
  sensitive   = true
}

variable "node_name" {
  description = "Name of the node"
  type        = string
}

variable "steward_name" {
  description = "Name of the steward"
  type        = string
}

variable "public_ip" {
  description = "Public IP address for the node"
  type        = string
}

variable "private_ip" {
  description = "Private IP address for the node"
  type        = string
}

variable "node_port" {
  description = "Node port (default: 9701)"
  type        = string
  default     = "9701"
}

variable "client_port" {
  description = "Client port (default: 9702)"
  type        = string
  default     = "9702"
}

variable "network_name" {
  description = "Network name (default: sandbox)"
  type        = string
  default     = "sandbox"
} 