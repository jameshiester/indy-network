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

data "aws_caller_identity" "current" {}

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh")
  vars = {
    aws_region              = var.Region
    node_name_1        = var.node_name_1
    node_name_2        = var.node_name_2
    node_seed_arn_1    = var.node_seed_arn_1
    node_seed_arn_2    = var.node_seed_arn_2
    network_name            = var.NetworkName
    node_ip                 = var.NodeIP
    client_ip               = var.ClientIP
    compose_bucket          = var.GenesisBucketArn
    compose_key             = var.ComposeKey
    genesis_pool_file_key   = var.GenesisPoolFileKey
    genesis_domain_file_key = var.GenesisDomainFileKey
    ecr_node_repo           = var.ECR_NODE_REPO
    account_id              = data.aws_caller_identity.current.account_id
  }
}

resource "aws_instance" "indy_node" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.medium"
  iam_instance_profile   = var.InstanceProfileName
  user_data              = data.template_file.user_data.rendered
  tags                   = local.tags

  network_interface {
    device_index         = 0
    network_interface_id = var.NetworkInterfaceID
  }
}

resource "aws_eip_association" "node1" {
  allocation_id = var.EIPAllocationID
  instance_id   = aws_instance.indy_node.id
}