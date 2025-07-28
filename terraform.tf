terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Provider configurations with common settings
provider "aws" {
  # AWS provider will use environment variables or IAM roles
  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION
}

provider "azuread" {
  # Azure AD provider will use environment variables or CLI authentication
  # AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID
}

provider "azurerm" {
  features {}
  # Azure Resource Manager provider
}