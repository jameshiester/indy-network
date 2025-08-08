# Tagging and naming
variable "Prefix" {
  description = "Prefix used to name all resources"
  type        = string
}

variable "SolTag" {
  description = "Solution tag value. All resources are created with a 'Solution' tag name and the value you set here"
  type        = string
}

# Regions
variable "Region" {
  description = "AWS depoloyment region"
  type        = string
  default     = "us-east-1"
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

variable "EnvCode" {
  description = "2 character code used to name all resources e.g. 'pd' for production"
  type        = string
}

variable "EnvTag" {
  description = "Environment tag value. All resources are created with an 'Environment' tag name and the value you set here"
  type        = string
}

variable "ECR_NODE_REPO" {
  description = "Name of Amazon ECR repository for indy node"
  type        = string
}

variable "ECR_SERVER_REPO" {
  description = "Name of Amazon ECR repository for indy server"
  type        = string
}

# Web App Build
variable "node_ecr_repo" {
  description = "Name of Amazon ECR repository for indy node"
  type        = string
}

variable "server_ecr_repo" {
  description = "Name of Amazon ECR repository for indy server"
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

variable "node_name_1" {
  description = "Name for node 1"
  type        = string
}

variable "node_name_2" {
  description = "Name for node 2"
  type        = string
}

variable "node_name_3" {
  description = "Name for node 3"
  type        = string
}

variable "node_name_4" {
  description = "Name for node 4"
  type        = string
}

variable "node_seed_arn_1" {
  description = "ARN of the secret used to hold the node 1 seed"
  type        = string
}

variable "node_seed_arn_2" {
  description = "ARN of the secret used to hold the node 2 seed"
  type        = string
}

variable "node_seed_arn_3" {
  description = "ARN of the secret used to hold the node 3 seed"
  type        = string
}

variable "node_seed_arn_4" {
  description = "ARN of the secret used to hold the node 4 seed"
  type        = string
}

variable "network_name" {
  description = "Network name (default: sandbox)"
  type        = string
  default     = "sandbox"
} 