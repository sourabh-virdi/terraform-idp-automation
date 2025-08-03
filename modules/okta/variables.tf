# Application Configuration
variable "app_name" {
  description = "Name of the Okta application"
  type        = string
}

variable "app_description" {
  description = "Description of the Okta application"
  type        = string
  default     = ""
}

variable "app_status" {
  description = "Status of the application"
  type        = string
  default     = "ACTIVE"
}

# SAML Application Settings
variable "create_saml_app" {
  description = "Whether to create a SAML application"
  type        = bool
  default     = false
}

variable "preconfigured_app" {
  description = "Name of the preconfigured app"
  type        = string
  default     = null
}

variable "auto_submit_toolbar" {
  description = "Display auto submit toolbar"
  type        = bool
  default     = false
}

variable "hide_ios" {
  description = "Do not display application icon on mobile app"
  type        = bool
  default     = false
}

variable "hide_web" {
  description = "Do not display application icon to users"
  type        = bool
  default     = false
}

variable "default_relay_state" {
  description = "Identifies a specific application resource in an IDP initiated SSO scenario"
  type        = string
  default     = ""
}

variable "sso_url" {
  description = "Single Sign On URL"
  type        = string
  default     = ""
}

variable "recipient" {
  description = "The location where the app may present the SAML assertion"
  type        = string
  default     = ""
}

variable "destination" {
  description = "Identifies the location where the SAML response is intended to be sent"
  type        = string
  default     = ""
}

variable "audience" {
  description = "Audience Restriction"
  type        = string
  default     = ""
}

variable "subject_name_id_template" {
  description = "Template for app user's username when a user is assigned to the app"
  type        = string
  default     = "$${user.userName}"
}

variable "subject_name_id_format" {
  description = "Identifies the SAML processing rules"
  type        = string
  default     = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
}

variable "response_signed" {
  description = "Determines whether the SAML auth response message is digitally signed"
  type        = bool
  default     = true
}

variable "assertion_signed" {
  description = "Determines whether the SAML assertion is digitally signed"
  type        = bool
  default     = true
}

variable "signature_algorithm" {
  description = "Signature algorithm used to digitally sign the assertion and response"
  type        = string
  default     = "RSA_SHA256"
}

variable "digest_algorithm" {
  description = "Determines the digest algorithm used to digitally sign the SAML assertion and response"
  type        = string
  default     = "SHA256"
}

variable "honor_force_authn" {
  description = "Prompt user to re-authenticate if SP asks for it"
  type        = bool
  default     = false
}

variable "authn_context_class_ref" {
  description = "Identifies the SAML authentication context class for the assertion's authentication statement"
  type        = string
  default     = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
}

# SAML Attribute Statements
variable "attribute_statements" {
  description = "List of SAML attribute statements"
  type = list(object({
    type      = string
    name      = string
    namespace = string
    values    = list(string)
  }))
  default = []
}

variable "group_attribute_statements" {
  description = "List of SAML group attribute statements"
  type = list(object({
    type   = string
    name   = string
    filter = string
  }))
  default = []
}

# Single Logout
variable "single_logout" {
  description = "SAML Single Logout settings"
  type = object({
    url                = string
    logout_request_url = string
  })
  default = null
}

# OAuth Application Settings
variable "create_oauth_app" {
  description = "Whether to create an OAuth application"
  type        = bool
  default     = false
}

variable "oauth_org_url" {
  description = "Okta organization URL for OAuth endpoints"
  type        = string
  default     = ""
}

variable "oauth_app_type" {
  description = "The type of client application"
  type        = string
  default     = "web"
}

variable "consent_method" {
  description = "Indicates whether user consent is required or implicit"
  type        = string
  default     = "TRUSTED"
}

variable "response_types" {
  description = "List of OAuth 2.0 response type strings"
  type        = list(string)
  default     = ["code"]
}

variable "grant_types" {
  description = "List of OAuth 2.0 grant type strings"
  type        = list(string)
  default     = ["authorization_code"]
}

variable "redirect_uris" {
  description = "List of URIs for use in the redirect-based flow"
  type        = list(string)
  default     = []
}

variable "post_logout_redirect_uris" {
  description = "List of URIs for redirection after logout"
  type        = list(string)
  default     = []
}

variable "login_uri" {
  description = "URI that initiates login"
  type        = string
  default     = null
}

variable "logo_uri" {
  description = "URI that references a logo for the client"
  type        = string
  default     = null
}

variable "client_basic_secret" {
  description = "OAuth client secret string (used for client_secret_basic auth method)"
  type        = string
  default     = null
}

variable "custom_client_id" {
  description = "Custom client ID"
  type        = string
  default     = null
}

variable "omit_secret" {
  description = "This tells the provider not to persist the OAuth client secret"
  type        = bool
  default     = false
}

variable "client_uri" {
  description = "URI to a web page providing information about the client"
  type        = string
  default     = null
}

variable "policy_uri" {
  description = "URI to a web page providing the client's policy document"
  type        = string
  default     = null
}

variable "tos_uri" {
  description = "URI to a web page providing the client's terms of service document"
  type        = string
  default     = null
}

variable "issuer_mode" {
  description = "Indicates whether the Okta Authorization Server uses the original Okta org domain URL"
  type        = string
  default     = "CUSTOM_URL"
}

variable "auto_key_rotation" {
  description = "Requested key rotation mode"
  type        = bool
  default     = true
}

variable "pkce_required" {
  description = "Require Proof Key for Code Exchange (PKCE) for additional verification key rotation mode"
  type        = bool
  default     = false
}

variable "refresh_token_leeway" {
  description = "Grace period for token rotation"
  type        = number
  default     = 30
}

variable "refresh_token_rotation" {
  description = "Refresh token rotation behavior"
  type        = string
  default     = "STATIC"
}

variable "wildcard_redirect" {
  description = "Indicates if the client is allowed to use wildcard matching of redirect_uris"
  type        = string
  default     = "DISABLED"
}

# JWKS
variable "jwks" {
  description = "JSON Web Key Set for verifying JWTs"
  type = object({
    kid = string
    kty = string
    use = string
    x5c = list(string)
    e   = string
    n   = string
  })
  default = null
}

# Groups Claim
variable "groups_claim" {
  description = "Groups claim configuration"
  type = object({
    type        = string
    filter_type = string
    name        = string
    value       = string
  })
  default = null
}

# Groups
variable "groups" {
  description = "Map of Okta groups to create"
  type = map(object({
    name        = string
    description = string
    skip_users  = bool
  }))
  default = {}
}

# Group Rules
variable "group_rules" {
  description = "Map of group rules"
  type = map(object({
    name               = string
    status             = string
    group_assignments  = list(string)
    expression_type    = string
    expression_value   = string
    users_excluded     = list(string)
  }))
  default = {}
}

# Users
variable "users" {
  description = "Map of Okta users to create"
  type = map(object({
    first_name                = string
    last_name                 = string
    login                     = string
    email                     = string
    password                  = string
    password_hash             = string
    old_password              = string
    recovery_question         = string
    recovery_answer           = string
    city                      = string
    cost_center               = string
    country_code              = string
    department                = string
    display_name              = string
    division                  = string
    employee_number           = string
    honorific_prefix          = string
    honorific_suffix          = string
    locale                    = string
    manager                   = string
    manager_id                = string
    middle_name               = string
    mobile_phone              = string
    nick_name                 = string
    organization              = string
    postal_address            = string
    preferred_language        = string
    primary_phone             = string
    profile_url               = string
    second_email              = string
    state                     = string
    street_address            = string
    timezone                  = string
    title                     = string
    user_type                 = string
    zip_code                  = string
    custom_profile_attributes = map(string)
    password_policy_id        = string
  }))
  default = {}
}

# Group Memberships
variable "group_memberships" {
  description = "Map of group memberships"
  type = map(object({
    group_key = string
    user_keys = list(string)
  }))
  default = {}
}

# App User Assignments
variable "saml_user_assignments" {
  description = "SAML app user assignments"
  type = map(object({
    user_key = string
    username = string
    password = string
    profile  = map(string)
  }))
  default = {}
}

variable "oauth_user_assignments" {
  description = "OAuth app user assignments"
  type = map(object({
    user_key = string
    username = string
    password = string
    profile  = map(string)
  }))
  default = {}
}

# App Group Assignments
variable "saml_group_assignments" {
  description = "SAML app group assignments"
  type = list(object({
    group_key = string
    priority  = number
    profile   = map(string)
  }))
  default = []
}

variable "oauth_group_assignments" {
  description = "OAuth app group assignments"
  type = list(object({
    group_key = string
    priority  = number
    profile   = map(string)
  }))
  default = []
}

# Policies
variable "signon_policies" {
  description = "Map of sign-on policies"
  type = map(object({
    name            = string
    status          = string
    description     = string
    priority        = number
    groups_included = list(string)
    groups_excluded = list(string)
  }))
  default = {}
}

variable "signon_policy_rules" {
  description = "Map of sign-on policy rules"
  type = map(object({
    name                         = string
    policy_key                   = string
    priority                     = number
    status                       = string
    access                       = string
    authtype                     = string
    mfa_required                 = bool
    mfa_prompt                   = string
    mfa_remember_device          = bool
    mfa_lifetime                 = number
    session_idle                 = number
    session_lifetime             = number
    session_persistent           = bool
    users_excluded               = list(string)
    network_includes             = list(string)
    network_excludes             = list(string)
    network_connection           = string
    risc_level                   = string
    factor_sequence = list(object({
      primary_criteria_factor_type = string
      primary_criteria_provider    = string
      secondary_criteria = list(object({
        factor_type = string
        provider    = string
      }))
    }))
  }))
  default = {}
} 