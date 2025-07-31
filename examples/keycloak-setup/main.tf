terraform {
  required_version = ">= 1.0"
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "~> 4.0"
    }
  }
}

provider "keycloak" {
  client_id     = var.keycloak_client_id
  username      = var.keycloak_username
  password      = var.keycloak_password
  url           = var.keycloak_url
  initial_login = false
}

# Keycloak setup
module "keycloak" {
  source = "../../modules/keycloak"

  # Basic configuration
  realm_name         = var.realm_name
  realm_display_name = var.realm_display_name
  realm_enabled      = var.realm_enabled

  # OIDC clients
  oidc_clients = var.oidc_clients

  # Users
  users = var.users

  # Groups
  groups = var.groups

  # Roles
  realm_roles = var.realm_roles

  # Identity providers
  identity_providers = var.identity_providers

  # Tags
  tags = var.tags
} 