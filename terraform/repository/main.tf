resource "github_branch" "dev" {
  repository = var.GitHubRepo
  branch     = "dev"
}

resource "github_branch" "test" {
  repository = var.GitHubRepo
  branch     = "test"
}

locals {
  gha_environment = ["dev", "test", "prod"]

  gha_iam_role = {
    dev  = module.tfbootstrap_dev.gha_iam_role
    test = module.tfbootstrap_test.gha_iam_role
    prod = module.tfbootstrap_prod.gha_iam_role
  }
  tfstate_bucket_name = {
    dev  = module.tfbootstrap_dev.tfstate_bucket_name
    test = module.tfbootstrap_test.tfstate_bucket_name
    prod = module.tfbootstrap_prod.tfstate_bucket_name
  }
  tfstate_dynamodb_table = {
    dev  = module.tfbootstrap_dev.tfstate_dynamodb_table_name
    test = module.tfbootstrap_test.tfstate_dynamodb_table_name
    prod = module.tfbootstrap_prod.tfstate_dynamodb_table_name
  }
}

# Create GitHub Environments
resource "github_repository_environment" "env" {
  for_each = toset(local.gha_environment)

  environment = each.value
  repository  = var.GitHubRepo

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

# Fetch latest TLS cert from GitHub to authenticate requests
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Check if GitHub Actions OIDC provider already exists
data "aws_iam_openid_connect_provider" "github_actions_existing" {
  url = "https://token.actions.githubusercontent.com"
}

# Create OIDC Provider for GitHub Actions only if it doesn't exist
resource "aws_iam_openid_connect_provider" "github_actions" {
  count = data.aws_iam_openid_connect_provider.github_actions_existing.arn == null ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Use existing provider if it exists, otherwise use the newly created one
locals {
  github_actions_provider_arn = data.aws_iam_openid_connect_provider.github_actions_existing.arn != null ? data.aws_iam_openid_connect_provider.github_actions_existing.arn : aws_iam_openid_connect_provider.github_actions[0].arn
}

module "tfbootstrap_dev" {
  source = "./modules/tfbootstrap"
  providers = {
    aws = aws.development
  }
  Region            = var.Region
  Prefix            = var.Prefix
  EnvCode           = "dv"
  GitHubOrg         = var.GitHubOrg
  GitHubRepo        = var.GitHubRepo
  GitHubEnv         = "dev"
  GitHubProviderArn = local.github_actions_provider_arn
}


module "tfbootstrap_test" {
  source = "./modules/tfbootstrap"
  providers = {
    aws = aws.testing
  }
  Region            = var.Region
  Prefix            = var.Prefix
  EnvCode           = "ts"
  GitHubOrg         = var.GitHubOrg
  GitHubRepo        = var.GitHubRepo
  GitHubEnv         = "test"
  GitHubProviderArn = local.github_actions_provider_arn

}

module "tfbootstrap_prod" {
  source = "./modules/tfbootstrap"
  providers = {
    aws = aws.production
  }
  Region            = var.Region
  Prefix            = var.Prefix
  EnvCode           = "pd"
  GitHubOrg         = var.GitHubOrg
  GitHubRepo        = var.GitHubRepo
  GitHubEnv         = "prod"
  GitHubProviderArn = local.github_actions_provider_arn

}

resource "github_repository_environment_deployment_policy" "dev" {
  repository     = var.GitHubRepo
  environment    = github_repository_environment.env["dev"].environment
  branch_pattern = "dev*"
}

resource "github_repository_environment_deployment_policy" "dev2test" {
  repository     = var.GitHubRepo
  environment    = github_repository_environment.env["test"].environment
  branch_pattern = "dev*"
}

resource "github_repository_environment_deployment_policy" "test" {
  repository     = var.GitHubRepo
  environment    = github_repository_environment.env["test"].environment
  branch_pattern = "test*"
}

resource "github_repository_environment_deployment_policy" "test2prod" {
  repository     = var.GitHubRepo
  environment    = github_repository_environment.env["prod"].environment
  branch_pattern = "test*"
}

resource "github_repository_environment_deployment_policy" "prod" {
  repository     = var.GitHubRepo
  environment    = github_repository_environment.env["prod"].environment
  branch_pattern = "main"
}

# Create GitHub branch protection policy
resource "github_branch_protection" "main" {
  repository_id          = var.GitHubRepo
  pattern                = "main"
  require_signed_commits = true

  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
}

resource "github_actions_environment_secret" "AWS_ROLE" {
  for_each = github_repository_environment.env

  repository      = var.GitHubRepo
  environment     = each.value.environment
  secret_name     = "AWS_ROLE"
  plaintext_value = lookup(local.gha_iam_role, each.value.environment, null)
}

# Terraform state S3 bucket name
resource "github_actions_environment_secret" "TF_STATE_BUCKET_NAME" {
  for_each = github_repository_environment.env

  repository      = var.GitHubRepo
  environment     = each.value.environment
  secret_name     = "TF_STATE_BUCKET_NAME"
  plaintext_value = lookup(local.tfstate_bucket_name, each.value.environment, null)
}

# Terraform state S3 bucket key
resource "github_actions_environment_secret" "TF_STATE_BUCKET_KEY" {
  for_each = github_repository_environment.env

  repository      = var.GitHubRepo
  environment     = each.value.environment
  secret_name     = "TF_STATE_BUCKET_KEY"
  plaintext_value = "terraform/${var.GitHubRepo}/${each.value.environment}.tfstate"
}

# Terraform state locking DynamoDB table
resource "github_actions_environment_secret" "TF_STATE_DYNAMODB_TABLE" {
  for_each = github_repository_environment.env

  repository      = var.GitHubRepo
  environment     = each.value.environment
  secret_name     = "TF_STATE_DYNAMODB_TABLE"
  plaintext_value = lookup(local.tfstate_dynamodb_table, each.value.environment, null)
}


### Create GitHub Environment Variables

# Locals used for constructing GitHub Variables
locals {
  # Declare GitHub Environments variables
  environment_variables_common = {
    # Deployment region e.g. eu-west-1
    TF_VAR_REGION = "us-east-1"
    # Deployment Availability Zone 1 e.g. eu-west-1a
    TF_VAR_AZ01 = "us-east-1a"
    # Deployment Availability Zone 2 e.g. eu-west-1b
    TF_VAR_AZ02       = "us-east-1b"
    TF_VAR_PREFIX     = var.Prefix
    TF_VAR_SOLTAG     = "INDY-NETWORK"
    TF_VAR_GITHUBREPO = format("%s%s%s", var.GitHubOrg, "/", var.GitHubRepo)
    # The first two octets of the CIDR IP address range e.g. 10.0
    TF_VAR_VPCCIDR      = "10.0.0.0/16"
    TF_VAR_IMAGETAG     = "1.0.0"
    TF_VAR_NETWORK_NAME = "NAESB"
  }
  # Declare dev specific GitHub Environments variables
  environment_variables_dev = merge(
    local.environment_variables_common,
    {
      TF_VAR_ENVCODE        = "dv"
      TF_VAR_ENVTAG         = "Development"
      TF_VAR_DBINSTANCESIZE = "db.t4g.micro"
      TF_STATE_BUCKET_NAME  = module.tfbootstrap_dev.tfstate_bucket_name
      TF_STATE_BUCKET_KEY   = "terraform/${var.GitHubRepo}/dev.tfstate"
    }
  )
  # Declare test specific GitHub Environments variables
  environment_variables_test = merge(
    local.environment_variables_common,
    {
      TF_VAR_ENVCODE = "ts"
      TF_VAR_ENVTAG  = "Testing"
    }
  )
  # Declare prod specific GitHub Environments variables
  environment_variables_prod = merge(
    local.environment_variables_common,
    {
      TF_VAR_ENVCODE = "pd"
      TF_VAR_ENVTAG  = "Production"
    }
  )
}

# Create GitHub Environment Variables
resource "github_actions_environment_variable" "dev" {
  for_each = local.environment_variables_dev

  repository    = var.GitHubRepo
  environment   = github_repository_environment.env["dev"].environment
  variable_name = each.key
  value         = each.value
}

resource "github_actions_environment_variable" "test" {
  for_each = local.environment_variables_test

  repository    = var.GitHubRepo
  environment   = github_repository_environment.env["test"].environment
  variable_name = each.key
  value         = each.value
}

resource "github_actions_environment_variable" "prod" {
  for_each = local.environment_variables_prod

  repository    = var.GitHubRepo
  environment   = github_repository_environment.env["prod"].environment
  variable_name = each.key
  value         = each.value
}