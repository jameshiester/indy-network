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

resource "aws_security_group" "ec2_security_group" {
  name        = format("%s-%s-%s", var.Prefix, "indy-client", var.EnvCode)
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6543
    to_port     = 6543
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9702
    to_port     = 9702
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9704
    to_port     = 9702
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 9702
    to_port     = 9702
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 9704
    to_port     = 9702
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

module "ec2_node1" {
  source                 = "./modules/ec2"
  Prefix                 = var.Prefix
  ClientSecurityGroupID = aws_security_group.ec2_security_group.id
  SolTag                 = var.SolTag
  EnvCode                = var.EnvCode
  env_tag                = var.EnvTag
  GenesisBucketArn       = aws_s3_bucket.genesis_bucket.arn
  GenesisPoolFileKey     = aws_s3_object.pool_transactions.key
  GenesisDomainFileKey   = aws_s3_object.domain_transactions.key
  ComposeKey             = aws_s3_object.docker_compose_yml.key
  node_name_1            = module.node_genesis_1.node_name
  node_name_2            = module.node_genesis_2.node_name
  ECR_NODE_REPO          = var.ECR_NODE_REPO
  EnvTag                 = var.EnvTag
  NetworkSecurityGroupID = aws_security_group.node_security_group.id
  NetworkName            = var.NETWORK_NAME
  node_seed_arn_1        = aws_secretsmanager_secret.node_seed_1.arn
  node_seed_arn_2        = aws_secretsmanager_secret.node_seed_2.arn
  NodeIP                 = aws_eip.one.public_ip
  ClientIP               = aws_eip.one.private_ip
  NetworkInterfaceID     = aws_network_interface.public_1.id
  EIPAllocationID        = aws_eip.one.id
  private_subnets        = module.vpc.private_subnets
  public_subnets         = module.vpc.public_subnets
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr               = local.vpc_cidr
  azs                    = local.azs
}

module "ec2_node2" {
  source                 = "./modules/ec2"
  ClientSecurityGroupID = aws_security_group.ec2_security_group.id
  Prefix                 = var.Prefix
  SolTag                 = var.SolTag
  EnvCode                = var.EnvCode
  env_tag                = var.EnvTag
  GenesisBucketArn       = aws_s3_bucket.genesis_bucket.arn
  GenesisPoolFileKey     = aws_s3_object.pool_transactions.key
  GenesisDomainFileKey   = aws_s3_object.domain_transactions.key
  ComposeKey             = aws_s3_object.docker_compose_yml.key
  node_name_1            = module.node_genesis_3.node_name
  node_name_2            = module.node_genesis_4.node_name
  ECR_NODE_REPO          = var.ECR_NODE_REPO
  EnvTag                 = var.EnvTag
  NetworkSecurityGroupID = aws_security_group.node_security_group.id
  NetworkName            = var.NETWORK_NAME
  node_seed_arn_1        = aws_secretsmanager_secret.node_seed_3.arn
  node_seed_arn_2        = aws_secretsmanager_secret.node_seed_4.arn
  NodeIP                 = aws_eip.two.public_ip
  ClientIP               = aws_eip.two.private_ip
  NetworkInterfaceID     = aws_network_interface.public_2.id
  EIPAllocationID        = aws_eip.two.id
  private_subnets        = module.vpc.private_subnets
  public_subnets         = module.vpc.public_subnets
  vpc_id                 = module.vpc.vpc_id
  vpc_cidr               = local.vpc_cidr
  azs                    = local.azs
}
