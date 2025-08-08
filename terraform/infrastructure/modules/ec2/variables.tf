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

variable "GenesisBucketArn" {
  description = "Arn for genesis file bucket"
  type        = string
}

variable "NetworkInterfaceID" {
  description = "ID of the network interface"
  type        = string
}

variable "EIPAllocationID" {
  description = "ID of the EIP"
  type        = string
}

variable "NodeIP" {
  description = "IP address of the node"
  type        = string
}

variable "ClientIP" {
  description = "IP address of the client"
  type        = string
}

variable "GenesisPoolFileKey" {
  description = "key for genesis pool transaction file"
  type        = string
}

variable "GenesisDomainFileKey" {
  description = "key for genesis domain transaction file"
  type        = string
}

variable "ComposeKey" {
  description = "key for genesis domain transaction file"
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

variable "env_tag" {
  description = "Environment tag value. All resources are created with an 'Environment' tag name and the value you set here"
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

variable "node_seed_arn_1" {
  description = "ARN of the secret used to hold the node 1 seed"
  type        = string
}

variable "node_seed_arn_2" {
  description = "ARN of the secret used to hold the node 2 seed"
  type        = string
}


variable "NetworkSecurityGroupID" {
  description = "ID of the node network security group"
  type        = string
}

variable "ClientSecurityGroupID" {
  description = "ID of the client network security group"
  type        = string
}

variable "NetworkName" {
  description = "Network name (default: sandbox)"
  type        = string
  default     = "sandbox"
}
variable "ECR_NODE_REPO" {
  description = "Name of Amazon ECR repository for indy node"
  type        = string
}