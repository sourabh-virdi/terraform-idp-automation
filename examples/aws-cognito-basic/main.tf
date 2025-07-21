terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# Basic AWS Cognito setup
module "cognito" {
  source = "../../modules/aws-cognito"

  # Basic configuration
  user_pool_name = var.user_pool_name
  client_name    = var.client_name
  environment    = var.environment

  # Application URLs
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Password policy
  password_policy = var.password_policy

  # MFA configuration
  mfa_configuration          = var.mfa_configuration
  software_token_mfa_enabled = var.software_token_mfa_enabled
  sms_mfa_enabled           = var.sms_mfa_enabled

  # Advanced security
  advanced_security_mode = var.advanced_security_mode

  # Custom domain (optional)
  domain_name = var.domain_name

  # Identity pool (optional)
  create_identity_pool = var.create_identity_pool
  identity_pool_name   = var.identity_pool_name

  # Lambda triggers (optional)
  lambda_triggers = var.lambda_triggers

  # Tags
  tags = var.tags
} 