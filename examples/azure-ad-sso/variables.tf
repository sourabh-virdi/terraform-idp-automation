variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "application_name" {
  description = "Name of the Azure AD application"
  type        = string
  default     = "example-enterprise-app"
}

variable "sign_in_audience" {
  description = "Supported account types for the application"
  type        = string
  default     = "AzureADMyOrg"
  validation {
    condition = contains([
      "AzureADMyOrg",
      "AzureADMultipleOrgs",
      "AzureADandPersonalMicrosoftAccount",
      "PersonalMicrosoftAccount"
    ], var.sign_in_audience)
    error_message = "Sign-in audience must be one of: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount, PersonalMicrosoftAccount."
  }
}

variable "web_settings" {
  description = "Web application settings"
  type = object({
    redirect_uris = list(string)
    logout_url    = optional(string)
    home_page_url = optional(string)
  })
  default = {
    redirect_uris = [
      "https://localhost:3000/auth/callback",
      "https://example.com/auth/callback"
    ]
    logout_url    = "https://example.com/logout"
    home_page_url = "https://example.com"
  }
}

variable "app_roles" {
  description = "Application roles to create"
  type = list(object({
    display_name = string
    description  = string
    value        = string
    allowed_member_types = list(string)
  }))
  default = [
    {
      display_name = "Administrator"
      description  = "Application administrators with full access"
      value        = "Admin"
      allowed_member_types = ["User"]
    },
    {
      display_name = "User"
      description  = "Standard application users"
      value        = "User"
      allowed_member_types = ["User"]
    }
  ]
}

variable "required_resource_access" {
  description = "Required API permissions for the application"
  type = list(object({
    resource_app_id = string
    resource_access = list(object({
      id   = string
      type = string
    }))
  }))
  default = [
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      resource_access = [
        {
          id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
          type = "Scope"
        },
        {
          id   = "b340eb25-3456-403f-be2f-af7a0d370277" # User.ReadBasic.All
          type = "Scope"
        }
      ]
    }
  ]
}

variable "groups" {
  description = "Azure AD groups to create and manage"
  type = map(object({
    display_name     = string
    description      = string
    security_enabled = bool
    mail_enabled     = bool
    owners           = list(string)
    members          = list(string)
  }))
  default = {
    "app-admins" = {
      display_name     = "Application Administrators"
      description      = "Administrators for the enterprise application"
      security_enabled = true
      mail_enabled     = false
      owners           = []
      members          = []
    }
    "app-users" = {
      display_name     = "Application Users"
      description      = "Standard users for the enterprise application"
      security_enabled = true
      mail_enabled     = false
      owners           = []
      members          = []
    }
  }
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "azure-ad-sso"
    ManagedBy   = "terraform"
  }
} 