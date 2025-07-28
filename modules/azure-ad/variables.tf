# Application Configuration
variable "application_name" {
  description = "Display name for the Azure AD application"
  type        = string
}

variable "application_description" {
  description = "Description for the Azure AD application"
  type        = string
  default     = ""
}

variable "sign_in_audience" {
  description = "Sign-in audience for the application"
  type        = string
  default     = "AzureADMyOrg"
}

# Application URIs
variable "identifier_uris" {
  description = "List of identifier URIs for the application"
  type        = list(string)
  default     = []
}

variable "homepage_url" {
  description = "Homepage URL for the application"
  type        = string
  default     = null
}

variable "logout_url" {
  description = "Logout URL for the application"
  type        = string
  default     = null
}

variable "privacy_statement_url" {
  description = "Privacy statement URL for the application"
  type        = string
  default     = null
}

variable "terms_of_service_url" {
  description = "Terms of service URL for the application"
  type        = string
  default     = null
}

# API Permissions
variable "api_permissions" {
  description = "API permissions configuration"
  type = object({
    mapped_claims_enabled          = bool
    requested_access_token_version = number
    oauth2_permission_scopes = list(object({
      admin_consent_description  = string
      admin_consent_display_name = string
      enabled                    = bool
      id                         = string
      type                       = string
      user_consent_description   = string
      user_consent_display_name  = string
      value                      = string
    }))
  })
  default = null
}

# App Roles
variable "app_roles" {
  description = "List of app roles for the application"
  type = list(object({
    allowed_member_types = list(string)
    description          = string
    display_name         = string
    enabled              = bool
    id                   = string
    value                = string
  }))
  default = []
}

# Optional Claims
variable "optional_claims" {
  description = "Optional claims configuration"
  default     = null
}

# Web Application Settings
variable "web_settings" {
  description = "Web application settings"
  default     = null
}

# Single Page Application Settings
variable "spa_settings" {
  description = "Single page application settings"
  default     = null
}

# Public Client Settings
variable "public_client_settings" {
  description = "Public client settings"
  default     = null
}

# Required Resource Access
variable "required_resource_access" {
  description = "Required resource access (API permissions)"
  type = list(object({
    resource_app_id = string
    resource_access = list(object({
      id   = string
      type = string
    }))
  }))
  default = []
}

# Service Principal Configuration
variable "app_role_assignment_required" {
  description = "Whether app role assignment is required for this service principal"
  type        = bool
  default     = false
}

variable "service_principal_description" {
  description = "Description for the service principal"
  type        = string
  default     = ""
}

variable "notification_email_addresses" {
  description = "List of notification email addresses"
  type        = list(string)
  default     = []
}

# SAML Settings
variable "saml_settings" {
  description = "SAML single sign-on settings"
  default     = null
}

# Application Secret
variable "create_application_secret" {
  description = "Whether to create an application secret"
  type        = bool
  default     = false
}

variable "application_secret_display_name" {
  description = "Display name for the application secret"
  type        = string
  default     = "terraform-generated"
}

variable "application_secret_end_date" {
  description = "End date for the application secret"
  type        = string
  default     = null
}

# Groups
variable "groups" {
  description = "Map of Azure AD groups to create"
  type = map(object({
    display_name            = string
    description             = string
    security_enabled        = bool
    mail_enabled            = bool
    mail_nickname           = string
    prevent_duplicate_names = bool
    assignable_to_role      = bool
    owners                  = list(string)
    members                 = list(string)
  }))
  default = {}
}

# App Role Assignments
variable "group_app_role_assignments" {
  description = "App role assignments for groups"
  type = map(object({
    app_role_id = string
    group_key   = string
  }))
  default = {}
}

variable "user_app_role_assignments" {
  description = "App role assignments for users"
  type = map(object({
    app_role_id    = string
    user_object_id = string
  }))
  default = {}
}

# Demo Users
variable "demo_users" {
  description = "Demo users to create (for testing purposes)"
  type = map(object({
    user_principal_name   = string
    display_name          = string
    given_name            = string
    surname               = string
    mail_nickname         = string
    password              = string
    force_password_change = bool
    usage_location        = string
    job_title             = string
    department            = string
    company_name          = string
  }))
  default = {}
}

variable "demo_user_group_memberships" {
  description = "Group memberships for demo users"
  type = map(object({
    group_key = string
    user_key  = string
  }))
  default = {}
}

# Administrative Unit
variable "create_administrative_unit" {
  description = "Whether to create an administrative unit"
  type        = bool
  default     = false
}

variable "administrative_unit_name" {
  description = "Name of the administrative unit"
  type        = string
  default     = ""
}

variable "administrative_unit_description" {
  description = "Description of the administrative unit"
  type        = string
  default     = ""
}

variable "administrative_unit_hidden_membership" {
  description = "Whether the administrative unit has hidden membership"
  type        = bool
  default     = false
}

variable "administrative_unit_user_members" {
  description = "User members of the administrative unit"
  type        = map(string)
  default     = {}
}

variable "administrative_unit_group_members" {
  description = "Group members of the administrative unit"
  type        = map(string)
  default     = {}
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = list(string)
  default     = []
} 