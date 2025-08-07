terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0.0"
    }
  }
  backend "s3" {
    encrypt              = true
    bucket               = "terraform-state-root-jh-dev"
    region               = "us-east-1"
    key                  = "indy-network.tfstate"
    profile              = "default"
    workspace_key_prefix = "indy-network/repository"
  }
}

provider "github" {
  owner = var.GitHubOrg
}

provider "aws" {
  alias   = "development"
  profile = "default"
  region  = var.Region
  default_tags {
    tags = {
      Environment = "Development"
      Provisioner = "Terraform"
      Solution    = "AWS-GHA-TF-MSFT"
    }
  }
}

provider "aws" {
  alias   = "testing"
  profile = "default"
  region  = var.Region
  default_tags {
    tags = {
      Environment = "Testing"
      Provisioner = "Terraform"
    }
  }
}

provider "aws" {
  alias   = "production"
  profile = "default"
  region  = var.Region
  default_tags {
    tags = {
      Environment = "Production"
      Provisioner = "Terraform"
    }
  }
}