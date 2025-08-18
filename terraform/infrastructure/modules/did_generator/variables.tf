variable "seed" {
  description = "Seed for deterministic DID generation"
  type        = string
  sensitive   = true
} 

variable "ECR_UTILS_REPO_URL" {
  description = "URL of Amazon ECR repository for indy utils"
  type        = string
}