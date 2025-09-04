# Tagging and naming
variable "Prefix" {
  description = "Prefix used to name all resources"
  type        = string
}

variable "SOLTAG" {
  description = "Solution tag value. All resources are created with a 'Solution' tag name and the value you set here"
  type        = string
}

# Regions
variable "Region" {
  description = "AWS depoloyment region"
  type        = string
  default     = "us-east-1"
}


variable "SERVER_CONTAINER_NAME" {
  description = "Name of the server container"
  type        = string
}

variable "MONITOR_CONTAINER_NAME" {
  description = "Name of the monitor container"
  type        = string
}


variable "EnvCode" {
  description = "2 character code used to name all resources e.g. 'pd' for production"
  type        = string
}

variable "EnvTag" {
  description = "Environment tag value. All resources are created with an 'Environment' tag name and the value you set here"
  type        = string
}

# Networking
variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
}

# Networking
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets"
  type        = list(string)
}

variable "server_ecr_repo" {
  description = "Name of Amazon ECR repository for indy server"
  type        = string
}

variable "monitor_ecr_repo" {
  description = "Name of Amazon ECR repository for indy monitor"
  type        = string
}

variable "ecs_service" {
  description = "Name of Amazon ECS Service"
  type        = string
}

variable "ecs_cluster" {
  description = "Name of Amazon ECS Cluster"
  type        = string
}

variable "steward_seed_arn" {
  description = "ARN of the secret used to hold the steward seed"
  type        = string
}

variable "steward_did" {
  description = "DID of the steward"
  type        = string
}

variable "network_name" {
  description = "Network name (default: sandbox)"
  type        = string
  default     = "sandbox"
}

variable "genesis_bucket_name" {
  description = "Name of the S3 bucket containing genesis files"
  type        = string
}

variable "domain_transactions_key" {
  description = "Key of the domain transactions file in the S3 bucket"
  type        = string
}

variable "pool_transactions_key" {
  description = "Key of the pool transactions file in the S3 bucket"
  type        = string
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of the secret for the database"
  type        = string
}

variable "db_host" {
  description = "host for the database"
  type        = string
}

variable "db_port" {
  description = "host for the database"
  type        = number
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "GenesisUrl" {
  description = "Url for the genesis file"
  type        = string
}

variable "MonitorPort" {
  description = "Port for the monitor container"
  type        = number
  default     = 9000
}

variable "DOMAIN" {
  description = "Domain name"
  type        = string
}