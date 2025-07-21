variable "aws_region" {
  description = "AWS region for Cognito deployment"
  type        = string
  default     = "us-east-1"
}

variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  default     = "example-user-pool"
}

variable "client_name" {
  description = "Name of the Cognito User Pool client"
  type        = string
  default     = "example-client"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "callback_urls" {
  description = "List of allowed callback URLs for OAuth flows"
  type        = list(string)
  default = [
    "https://localhost:3000/auth/callback",
    "https://example.com/auth/callback"
  ]
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default = [
    "https://localhost:3000/logout",
    "https://example.com/logout"
  ]
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_uppercase = bool
    require_numbers   = bool
    require_symbols   = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}

variable "mfa_configuration" {
  description = "MFA configuration (OFF, OPTIONAL, or REQUIRED)"
  type        = string
  default     = "OPTIONAL"
  validation {
    condition     = contains(["OFF", "OPTIONAL", "REQUIRED"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, OPTIONAL, or REQUIRED."
  }
}

variable "software_token_mfa_enabled" {
  description = "Enable software token MFA (TOTP)"
  type        = bool
  default     = true
}

variable "sms_mfa_enabled" {
  description = "Enable SMS MFA"
  type        = bool
  default     = false
}

variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, or ENFORCED)"
  type        = string
  default     = "AUDIT"
  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "domain_name" {
  description = "Custom domain name for Cognito (optional)"
  type        = string
  default     = null
}

variable "create_identity_pool" {
  description = "Whether to create a Cognito Identity Pool"
  type        = bool
  default     = false
}

variable "identity_pool_name" {
  description = "Name of the Cognito Identity Pool"
  type        = string
  default     = null
}

variable "lambda_triggers" {
  description = "Lambda triggers for Cognito events"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "cognito-example"
    ManagedBy   = "terraform"
  }
} 