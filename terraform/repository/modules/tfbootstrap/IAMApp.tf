# This file contains IAM permissions required to deploy and destroy the application using Github Actions
# WARNING: Consider restricting to actions and resources required by GitHub to deploy your solution through the GitHub Actions pipeline
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "SampleApp" {
  statement {
    actions = [
      "cloudformation:CreateResource",
      "cloudformation:DeleteResource",
      "cloudformation:DescribeStacks",
      "cloudformation:GetResource",
      "cloudformation:GetResourceRequestStatus",
      "cloudformation:UpdateResource",
      "ec2:AcceptVpcEndpointConnections",
      "ec2:AssociateAddress",
      "ec2:AssociateVpcCidrBlock",
      "ec2:CreateEgressOnlyInternetGateway",
      "ec2:CreateNetworkInterface",
      "ec2:CreateTags",
      "ec2:CreateVpcEndpoint",
      "ec2:CreateVpcEndpointServiceConfiguration",
      "ec2:DeleteEgressOnlyInternetGateway",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteVpcEndpoints",
      "ec2:DeleteVpcEndpointServiceConfiguration",
      "ec2:DeleteVpcEndpointServiceConfigurations",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAddressesAttribute",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeEgressOnlyInternetGateways",
      "ec2:DescribeFlowLogs",
      "ec2:DescribeImages",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "iam:AddRoleToInstanceProfile",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcEndpointConnections",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServiceConfigurations",
      "ec2:DescribeVpcEndpointServicePermissions",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcs",
      "ec2:DisassociateAddress",
      "ec2:DisassociateRouteTable",
      "ec2:DisassociateVpcCidrBlock",
      "ec2:ModifySecurityGroupRules",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ModifyVpcEndpoint",
      "ec2:ModifyVpcEndpointServiceConfiguration",
      "ec2:ModifyVpcEndpointServicePermissions",
      "ec2:RejectVpcEndpointConnections",
      "ec2:ReleaseAddress",
      "ec2:ReplaceRouteTableAssociation",
      "ecr:CreateRepository",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecs:CreateCluster",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerAttributes",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:SetSecurityGroups",
      "firehose:CreateDeliveryStream",
      "firehose:DeleteDeliveryStream",
      "firehose:DescribeDeliveryStream",
      "firehose:TagDeliveryStream",
      "glue:CreateConnection",
      "glue:CreateCrawler",
      "glue:CreateDatabase",
      "glue:DeleteConnection",
      "glue:DeleteCrawler",
      "glue:DeleteDatabase",
      "glue:DeleteDatabase",
      "glue:GetConnection",
      "glue:GetCrawler",
      "glue:GetDatabase",
      "glue:GetTags",
      "glue:ListCrawlers",
      "glue:TagResource",
      "glue:UntagResource",
      "glue:UpdateConnection",
      "glue:UpdateCrawler",
      "glue:UpdateDatabase",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:TagInstanceProfile",
      "kms:CreateKey",
      "kms:ListAliases",
      "lambda:CreateFunction",
      "lambda:DeleteFunction",
      "lambda:GetFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:InvokeFunction",
      "lambda:ListFunctions",
      "lambda:ListVersionsByFunction",
      "lambda:TagResource",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "resource-groups:CreateGroup",
      "resource-groups:UpdateGroupQuery",
      "secretsmanager:DeleteSecret",
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "SNS:AddPermission",
      "SNS:CreateTopic",
      "SNS:DeleteTopic",
      "SNS:GetSubscriptionAttributes",
      "SNS:GetTopicAttributes",
      "SNS:ListSubscriptionsByTopic",
      "SNS:ListTagsForResource",
      "sns:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:Subscribe",
      "SNS:Unsubscribe"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "ec2:AllocateAddress",
      "ec2:CreateNatGateway"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:elastic-ip/*"
    ]
  }
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutResourcePolicy",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DeleteSecret",
      "secretsmanager:DescribeSecret",
      "secretsmanager:TagResource"
    ]
    resources = ["arn:aws:secretsmanager:*:*:secret:rds-db-credentials/*"]
  }
  statement {
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:PutSecretValue",
      "secretsmanager:TagResource",
      "secretsmanager:DescribeSecret",
      "secretsmanager:RotateSecret",
      "secretsmanager:CancelRotateSecret"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["rds:*"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ec2:DetachNetworkInterface",
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]
  }
  statement {
    actions = [
      "ec2:DeleteNetworkAclEntry",
      "ec2:CreateNetworkAclEntry"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:network-acl/*"
    ]
  }
  statement {
    actions = [
      "ec2:AttachInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:DetachInternetGateway"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:internet-gateway/*"
    ]
  }
  statement {
    actions = [
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:natgateway/*"
    ]
  }
  statement {
    actions = [
      "ec2:DetachNetworkInterface",
      "ec2:DeleteNetworkInterface"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
    ]
  }
  statement {
    actions = [
      "ec2:AssociateRouteTable",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:DeleteRoute",
      "ec2:DeleteRouteTable"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:route-table/*"
    ]
  }
  statement {
    actions = [
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:security-group/*"
    ]
  }
  statement {
    actions = [
      "ec2:AssociateRouteTable",
      "ec2:CreateNatGateway",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:subnet/*"
    ]
  }
  statement {
    actions = [
      "ec2:CreateFlowLogs",
      "ec2:DeleteFlowLogs"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:vpc-flow-log/*"
    ]
  }
  statement {
    actions = [
      "ec2:AttachInternetGateway",
      "ec2:CreateFlowLogs",
      "ec2:CreateRouteTable",
      "ec2:CreateSecurityGroup",
      "ec2:CreateSubnet",
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcAttribute",
      "ec2:DetachInternetGateway"
    ]
    resources = [
      "arn:aws:ec2:${var.Region}:${data.aws_caller_identity.current.account_id}:vpc/*"
    ]
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:DeleteLifecyclePolicy",
      "ecr:DeleteRepository",
      "ecr:DescribeImages",
      "ecr:GetLifecyclePolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListTagsForResource",
      "ecr:PutImage",
      "ecr:PutLifecyclePolicy",
      "ecr:TagResource",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:${var.Region}:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
  }
  statement {
    actions = [
      "ecs:DeleteCluster",
      "ecs:DescribeClusters",
      "ecs:TagResource"
    ]
    resources = [
      "arn:aws:ecs:${var.Region}:${data.aws_caller_identity.current.account_id}:cluster/*"
    ]
  }
  statement {
    actions = [
      "ecs:CreateService",
      "ecs:DeleteService",
      "ecs:DescribeServices",
      "ecs:TagResource",
      "ecs:UpdateService"
    ]
    resources = [
      "arn:aws:ecs:${var.Region}:${data.aws_caller_identity.current.account_id}:service/*/*"
    ]
  }
  statement {
    actions = [
      "ecs:DeregisterTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:TagResource"
    ]
    resources = [
      "arn:aws:ecs:${var.Region}:${data.aws_caller_identity.current.account_id}:task-definition/*:*"
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:${var.Region}:${data.aws_caller_identity.current.account_id}:listener/app/*/*/*"
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:${var.Region}:${data.aws_caller_identity.current.account_id}:loadbalancer/*"
    ]
  }
  statement {
    actions = [
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes"
    ]
    resources = [
      "arn:aws:elasticloadbalancing:${var.Region}:${data.aws_caller_identity.current.account_id}:targetgroup/*/*"
    ]
  }
  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateServiceLinkedRole",
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetPolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:DetachRolePolicy",
      "iam:TagRole"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
    ]
  }
  statement {
    actions = [
      "kms:CreateAlias",
      "kms:DeleteAlias"
    ]
    resources = [
      "arn:aws:kms:${var.Region}:${data.aws_caller_identity.current.account_id}:alias/*"
    ]
  }
  statement {
    actions = [
      "kms:CreateAlias",
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DeleteAlias",
      "kms:DescribeKey",
      "kms:EnableKeyRotation",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListResourceTags",
      "kms:PutKeyPolicy",
      "kms:RetireGrant",
      "kms:ScheduleKeyDeletion",
      "kms:TagResource"
    ]
    resources = [
      "arn:aws:kms:${var.Region}:${data.aws_caller_identity.current.account_id}:key/*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:ListTagsLogGroup",
      "logs:PutRetentionPolicy",
      "logs:TagResource"
    ]
    resources = [
      "arn:aws:logs:${var.Region}:${data.aws_caller_identity.current.account_id}:log-group:*"
    ]
  }
  statement {
    actions = [
      "resource-groups:DeleteGroup",
      "resource-groups:GetGroup",
      "resource-groups:GetGroupConfiguration",
      "resource-groups:GetGroupQuery",
      "resource-groups:GetTags",
      "resource-groups:Tag"
    ]
    resources = [
      "arn:aws:resource-groups:${var.Region}:${data.aws_caller_identity.current.account_id}:group/*"
    ]
  }
  statement {
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }
}