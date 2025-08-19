resource "aws_iam_role" "instance_role" {
  name = format("%s-%s-%s", var.Prefix, "ec2-indy-node", var.EnvCode)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_instance_profile" "instance_profile" {
  path = "/"
  role = aws_iam_role.instance_role.name
  tags = local.tags
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "iam:GetRole",
      "iam:GetUser",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "sts:GetCallerIdentity"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.genesis_bucket.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.compose_bucket.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [aws_secretsmanager_secret.node_seed_1.arn, aws_secretsmanager_secret.node_seed_2.arn, aws_secretsmanager_secret.node_seed_3.arn, aws_secretsmanager_secret.node_seed_4.arn]
  }
}

resource "aws_iam_role_policy" "instance_policy" {
  name   = format("%s-%s-%s-%s", var.Prefix, "ec2-indy-node", var.EnvCode, "instancepolicy")
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.instance_policy.json
}

resource "aws_cloudwatch_log_group" "indy_node_log_group" {
  name              = format("%s-%s-%s", var.Prefix, "indy-node", var.EnvCode)
  retention_in_days = 30
  tags              = local.tags
}

module "ec2_node1" {
  source                 = "./modules/ec2"
  azs                    = local.azs
  ClientIP               = aws_eip.one.public_ip
  ClientSecurityGroupID  = aws_security_group.ec2_security_group.id
  ComposeBucketName      = aws_s3_bucket.compose_bucket.bucket
  ComposeKey             = aws_s3_object.docker_compose_yml.key
  ECR_NODE_REPO          = var.ECR_NODE_REPO_URL
  EIPAllocationID        = aws_eip.one.id
  env_tag                = var.EnvTag
  EnvCode                = var.EnvCode
  EnvTag                 = var.EnvTag
  GenesisBucketName      = aws_s3_bucket.genesis_bucket.bucket
  GenesisDomainFileKey   = aws_s3_object.domain_transactions.key
  GenesisPoolFileKey     = aws_s3_object.pool_transactions.key
  InstanceProfileName    = aws_iam_instance_profile.instance_profile.name
  LogGroupName           = aws_cloudwatch_log_group.indy_node_log_group.name
  NetworkInterfaceID     = aws_network_interface.public_1.id
  NetworkName            = var.NETWORK_NAME
  NetworkSecurityGroupID = aws_security_group.node_security_group.id
  node_name_1            = module.node_genesis_1.node_name
  node_name_2            = module.node_genesis_2.node_name
  node_seed_arn_1        = aws_secretsmanager_secret.node_seed_1.arn
  node_seed_arn_2        = aws_secretsmanager_secret.node_seed_2.arn
  NodeIP                 = aws_eip.one.private_ip
  Prefix                 = var.Prefix
  private_subnets        = module.vpc.private_subnets
  public_subnets         = module.vpc.public_subnets
  SOLTAG                 = var.SOLTAG
  vpc_cidr               = local.vpc_cidr
  vpc_id                 = module.vpc.vpc_id
}


module "ec2_node2" {
  source                 = "./modules/ec2"
  azs                    = local.azs
  ClientIP               = aws_eip.one.public_ip
  ClientSecurityGroupID  = aws_security_group.ec2_security_group.id
  ComposeBucketName      = aws_s3_bucket.compose_bucket.bucket
  ComposeKey             = aws_s3_object.docker_compose_yml.key
  ECR_NODE_REPO          = var.ECR_NODE_REPO_URL
  EIPAllocationID        = aws_eip.two.id
  env_tag                = var.EnvTag
  EnvCode                = var.EnvCode
  EnvTag                 = var.EnvTag
  GenesisBucketName      = aws_s3_bucket.genesis_bucket.bucket
  GenesisDomainFileKey   = aws_s3_object.domain_transactions.key
  GenesisPoolFileKey     = aws_s3_object.pool_transactions.key
  InstanceProfileName    = aws_iam_instance_profile.instance_profile.name
  LogGroupName           = aws_cloudwatch_log_group.indy_node_log_group.name
  NetworkInterfaceID     = aws_network_interface.public_2.id
  NetworkName            = var.NETWORK_NAME
  NetworkSecurityGroupID = aws_security_group.node_security_group.id
  node_name_1            = module.node_genesis_3.node_name
  node_name_2            = module.node_genesis_4.node_name
  node_seed_arn_1        = aws_secretsmanager_secret.node_seed_3.arn
  node_seed_arn_2        = aws_secretsmanager_secret.node_seed_4.arn
  NodeIP                 = aws_eip.one.private_ip
  Prefix                 = var.Prefix
  private_subnets        = module.vpc.private_subnets
  public_subnets         = module.vpc.public_subnets
  SOLTAG                 = var.SOLTAG
  vpc_cidr               = local.vpc_cidr
  vpc_id                 = module.vpc.vpc_id
}