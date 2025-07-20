# User Pool Configuration
variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
}

variable "client_name" {
  description = "Name of the Cognito User Pool Client"
  type        = string
}

# Password Policy
variable "password_policy" {
  description = "Password policy for the user pool"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_numbers   = bool
    require_symbols   = bool
    require_uppercase = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

# Security and Authentication
variable "advanced_security_mode" {
  description = "Advanced security mode for the user pool"
  type        = string
  default     = "ENFORCED"
  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "explicit_auth_flows" {
  description = "List of authentication flows"
  type        = list(string)
  default = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# OAuth Configuration
variable "generate_client_secret" {
  description = "Should the client have a client secret"
  type        = bool
  default     = true
}

variable "allowed_oauth_flows" {
  description = "List of allowed OAuth flows"
  type        = list(string)
  default     = ["code", "implicit"]
}

variable "allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes"
  type        = list(string)
  default     = ["phone", "email", "openid", "profile"]
}

variable "callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
  default     = []
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = []
}

# Token Configuration
variable "access_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the access token is no longer valid"
  type        = number
  default     = 60
}

variable "id_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid"
  type        = number
  default     = 60
}

variable "refresh_token_validity" {
  description = "Time limit, between 60 minutes and 10 years, after which the refresh token is no longer valid"
  type        = number
  default     = 30
}

variable "token_validity_units" {
  description = "Configuration block for units in which the validity times are represented in"
  type = object({
    access_token  = string
    id_token      = string
    refresh_token = string
  })
  default = {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

# Domain Configuration
variable "domain_name" {
  description = "Domain name for the user pool"
  type        = string
  default     = null
}

variable "domain_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = null
}

# Schema Attributes
variable "schema_attributes" {
  description = "List of schema attributes for the user pool"
  type = list(object({
    name                = string
    attribute_data_type = string
    required            = bool
    mutable             = bool
  }))
  default = [
    {
      name                = "email"
      attribute_data_type = "String"
      required            = true
      mutable             = true
    }
  ]
}

# SAML Providers
variable "saml_providers" {
  description = "Map of SAML identity providers"
  type = map(object({
    provider_name              = string
    metadata_url              = string
    sso_redirect_binding_uri  = string
    slo_redirect_binding_uri  = string
    attribute_mapping         = map(string)
  }))
  default = {}
}

# Identity Pool Configuration
variable "create_identity_pool" {
  description = "Whether to create a Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "identity_pool_name" {
  description = "Name of the Cognito Identity Pool"
  type        = string
  default     = ""
}

variable "allow_unauthenticated_identities" {
  description = "Whether the identity pool supports unauthenticated logins"
  type        = bool
  default     = false
}

variable "server_side_token_check" {
  description = "Whether server-side token validation is enabled for the identity provider's token"
  type        = bool
  default     = false
}

variable "identity_pool_saml_providers" {
  description = "List of SAML provider ARNs for the identity pool"
  type        = list(string)
  default     = []
}

# Role Mappings
variable "role_mappings" {
  description = "List of role mappings for the identity pool"
  type = list(object({
    identity_provider         = string
    ambiguous_role_resolution = string
    type                      = string
    mapping_rules = list(object({
      claim      = string
      match_type = string
      role_arn   = string
      value      = string
    }))
  }))
  default = []
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
} 