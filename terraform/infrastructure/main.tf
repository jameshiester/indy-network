data "aws_availability_zones" "available" {}

locals {
  vpc_cidr                     = "10.0.0.0/16"
  azs                          = slice(data.aws_availability_zones.available.names, 0, 3)
  preferred_maintenance_window = "sun:05:00-sun:06:00"

  tags = {
    EnvCode     = var.EnvCode
    Environment = var.EnvTag
    Solution    = var.SolTag
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name               = format("%s%s%s%s", var.Prefix, "vpc", var.EnvCode, "01")
  cidr               = local.vpc_cidr
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 3)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 6)]
  intra_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 9)]

  create_database_subnet_group = true

  tags = local.tags
}

# Generate random passwords for steward and node seeds
resource "random_password" "steward_seed_1" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "steward_seed_2" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "steward_seed_3" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "steward_seed_4" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "node_seed_1" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "node_seed_2" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "node_seed_3" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "node_seed_4" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Node Genesis Module Instances
module "node_genesis_1" {
  source       = "./modules/node_genesis"
  node_name    = "1"
  steward_name = var.NETWORK_NAME

  steward_seed = random_password.steward_seed_1.result
  node_seed    = random_password.node_seed_1.result
  public_ip    = aws_eip.one.public_ip
  private_ip   = aws_eip.one.private_ip
  network_name = var.NETWORK_NAME

}

module "node_genesis_2" {
  source       = "./modules/node_genesis"
  node_name    = "2"
  steward_name = var.NETWORK_NAME
  steward_seed = random_password.steward_seed_2.result
  node_seed    = random_password.node_seed_2.result
  public_ip    = aws_eip.one.public_ip
  private_ip   = aws_eip.one.private_ip
  network_name = var.NETWORK_NAME
  depends_on   = [module.node_genesis_1]
}

module "node_genesis_3" {
  source       = "./modules/node_genesis"
  node_name    = "3"
  steward_name = var.NETWORK_NAME
  steward_seed = random_password.steward_seed_3.result
  node_seed    = random_password.node_seed_3.result
  public_ip    = aws_eip.two.public_ip
  private_ip   = aws_eip.two.private_ip
  network_name = var.NETWORK_NAME
  depends_on   = [module.node_genesis_2]
}

module "node_genesis_4" {
  source       = "./modules/node_genesis"
  node_name    = "4"
  steward_name = var.NETWORK_NAME
  steward_seed = random_password.steward_seed_4.result
  node_seed    = random_password.node_seed_4.result
  public_ip    = aws_eip.two.public_ip
  private_ip   = aws_eip.two.private_ip
  network_name = var.NETWORK_NAME
  depends_on   = [module.node_genesis_3]
}