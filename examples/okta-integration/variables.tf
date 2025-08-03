variable "okta_org_name" {
  description = "Okta organization name"
  type        = string
}

variable "okta_base_url" {
  description = "Okta base URL (okta.com or oktapreview.com)"
  type        = string
  default     = "okta.com"
}

variable "okta_api_token" {
  description = "Okta API token"
  type        = string
  sensitive   = true
}

variable "app_name" {
  description = "Name of the Okta application"
  type        = string
  default     = "example-app"
}

variable "app_description" {
  description = "Description of the Okta application"
  type        = string
  default     = "Example application for SSO integration"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "create_saml_app" {
  description = "Whether to create a SAML application"
  type        = bool
  default     = true
}

variable "sso_url" {
  description = "SAML SSO URL (Assertion Consumer Service URL)"
  type        = string
  default     = "https://example.com/saml/acs"
}

variable "audience" {
  description = "SAML audience (Entity ID)"
  type        = string
  default     = "https://example.com"
}

variable "destination" {
  description = "SAML destination URL"
  type        = string
  default     = "https://example.com/saml/acs"
}

variable "create_oauth_app" {
  description = "Whether to create an OAuth application"
  type        = bool
  default     = false
}

variable "oauth_app_type" {
  description = "OAuth application type (web, native, browser, service)"
  type        = string
  default     = "web"
  validation {
    condition     = contains(["web", "native", "browser", "service"], var.oauth_app_type)
    error_message = "OAuth app type must be one of: web, native, browser, service."
  }
}

variable "redirect_uris" {
  description = "OAuth redirect URIs"
  type        = list(string)
  default = [
    "https://example.com/auth/callback"
  ]
}

variable "post_logout_redirect_uris" {
  description = "OAuth post-logout redirect URIs"
  type        = list(string)
  default = [
    "https://example.com/logout"
  ]
}

variable "attribute_statements" {
  description = "SAML attribute statements"
  type = list(object({
    type      = string
    name      = string
    namespace = string
    values    = list(string)
  }))
  default = [
    {
      type      = "EXPRESSION"
      name      = "email"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
      values    = ["user.email"]
    },
    {
      type      = "EXPRESSION"
      name      = "firstName"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
      values    = ["user.firstName"]
    },
    {
      type      = "EXPRESSION"
      name      = "lastName"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
      values    = ["user.lastName"]
    }
  ]
}

variable "groups" {
  description = "Okta groups to create and assign to the application"
  type = map(object({
    name        = string
    description = string
    type        = string
  }))
  default = {
    "app-users" = {
      name        = "Application Users"
      description = "Users with access to the application"
      type        = "OKTA_GROUP"
    }
    "app-admins" = {
      name        = "Application Administrators"
      description = "Administrators with full access to the application"
      type        = "OKTA_GROUP"
    }
  }
}

variable "users" {
  description = "Users to assign to the application"
  type = map(object({
    email      = string
    first_name = string
    last_name  = string
    login      = string
  }))
  default = {}
}

variable "signon_policies" {
  description = "Sign-on policies for the application"
  type = map(object({
    name        = string
    description = string
    priority    = number
    type        = string
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "okta-integration"
    ManagedBy   = "terraform"
  }
} 