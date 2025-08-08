locals {
  tags = {
    Environment = var.env_tag
    EnvCode     = var.EnvCode
    Solution    = var.SolTag
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = format("%s%s%s%s", var.Prefix, "ec2", var.EnvCode, "securitygroup")
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

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

resource "aws_iam_role" "instance_role" {
  name = format("%s-%s-%s-%s", var.Prefix, "ec2-indy-node", var.EnvCode, "instanceprofile")
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
    resources = ["${var.GenesisBucketArn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [var.node_seed_arn_1, var.node_seed_arn_2]
  }
}

resource "aws_iam_role_policy" "instance_policy" {
  name   = format("%s-%s-%s-%s", var.Prefix, "ec2-indy-node", var.EnvCode, "instancepolicy")
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.instance_policy.json
}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    aws_region              = var.Region
    indy_node_name_1        = var.node_name_1
    indy_node_name_2        = var.node_name_2
    indy_node_seed_arn_1    = var.node_seed_arn_1
    indy_node_seed_arn_2    = var.node_seed_arn_2
    network_name            = var.NetworkName
    node_ip                 = var.NodeIP
    client_ip               = var.ClientIP
    compose_bucket          = var.GenesisBucketArn
    compose_key             = var.ComposeKey
    genesis_pool_file_key   = var.GenesisPoolFileKey
    genesis_domain_file_key = var.GenesisDomainFileKey
    ecr_node_repo           = var.ECR_NODE_REPO
  }
}

resource "aws_instance" "indy_node" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id, var.NetworkSecurityGroupID]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  user_data              = file("${path.module}/user-data.sh")
  tags                   = local.tags

  network_interface {
    device_index         = 0
    network_interface_id = var.NetworkInterfaceID
  }
}

resource "aws_eip_association" "node1" {
  allocation_id = var.EIPAllocationID
  instance_id   = aws_instance.node1.id
}