terraform {
  required_version = ">= 1.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.40"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}

# Azure AD SSO setup
module "azure_ad" {
  source = "../../modules/azure-ad"

  # Basic configuration
  application_name = var.application_name
  sign_in_audience = var.sign_in_audience

  # Web application settings
  web_settings = var.web_settings

  # App roles
  app_roles = var.app_roles

  # Required resource access (API permissions)
  required_resource_access = var.required_resource_access

  # Groups
  groups = var.groups

  # Tags
  tags = var.tags
} 