variable "GitHubRepo" {
  description = "GitHub repository name"
  type        = string
  default     = "indy-network"
}

variable "GitHubOrg" {
  description = "GitHub Organization Name / User Name"
  type        = string
  default     = "jameshiester"
}

# Regions
variable "Region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "Domain" {
  description = "DNS Name"
  type        = string
}

variable "Prefix" {
  description = "Prefix used to name all resources"
  type        = string
  default     = "indy"
}