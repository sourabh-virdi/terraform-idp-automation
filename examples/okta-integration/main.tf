terraform {
  required_version = ">= 1.0"
  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 4.0"
    }
  }
}

provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}

# Okta integration setup
module "okta" {
  source = "../../modules/okta"

  # Basic configuration
  app_name        = var.app_name
  app_description = var.app_description
  environment     = var.environment

  # SAML application (optional)
  create_saml_app = var.create_saml_app
  sso_url         = var.sso_url
  audience        = var.audience
  destination     = var.destination

  # OAuth application (optional)
  create_oauth_app = var.create_oauth_app
  oauth_app_type   = var.oauth_app_type
  redirect_uris    = var.redirect_uris
  post_logout_redirect_uris = var.post_logout_redirect_uris

  # Attribute mapping
  attribute_statements = var.attribute_statements

  # Group assignments
  groups = var.groups

  # User assignments
  users = var.users

  # Authentication policies
  signon_policies = var.signon_policies

  # Tags
  tags = var.tags
} 