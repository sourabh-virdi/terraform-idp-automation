# Keycloak Configuration
variable "keycloak_base_url" {
  description = "Base URL of the Keycloak server"
  type        = string
  default     = "http://localhost:8080"
}

# Realm Configuration
variable "realm_name" {
  description = "Name of the Keycloak realm"
  type        = string
}

variable "realm_enabled" {
  description = "Whether the realm is enabled"
  type        = bool
  default     = true
}

variable "realm_display_name" {
  description = "Display name of the realm"
  type        = string
  default     = null
}

variable "realm_display_name_html" {
  description = "HTML display name of the realm"
  type        = string
  default     = null
}

# Login Settings
variable "login_with_email_allowed" {
  description = "Whether login with email is allowed"
  type        = bool
  default     = true
}

variable "duplicate_emails_allowed" {
  description = "Whether duplicate emails are allowed"
  type        = bool
  default     = false
}

variable "reset_password_allowed" {
  description = "Whether password reset is allowed"
  type        = bool
  default     = true
}

variable "remember_me" {
  description = "Whether remember me is enabled"
  type        = bool
  default     = true
}

variable "verify_email" {
  description = "Whether email verification is required"
  type        = bool
  default     = false
}

variable "login_theme" {
  description = "Login theme"
  type        = string
  default     = "keycloak"
}

variable "account_theme" {
  description = "Account theme"
  type        = string
  default     = "keycloak"
}

variable "admin_theme" {
  description = "Admin theme"
  type        = string
  default     = "keycloak"
}

variable "email_theme" {
  description = "Email theme"
  type        = string
  default     = "keycloak"
}

# Registration Settings
variable "registration_allowed" {
  description = "Whether user registration is allowed"
  type        = bool
  default     = false
}

variable "registration_email_as_username" {
  description = "Whether to use email as username during registration"
  type        = bool
  default     = false
}

variable "edit_username_allowed" {
  description = "Whether users can edit their username"
  type        = bool
  default     = false
}

# SSL Settings
variable "ssl_required" {
  description = "SSL requirement level"
  type        = string
  default     = "external"
  validation {
    condition     = contains(["all", "external", "none"], var.ssl_required)
    error_message = "SSL required must be one of: all, external, none."
  }
}

# Session Settings
variable "sso_session_idle_timeout" {
  description = "SSO session idle timeout in seconds"
  type        = string
  default     = "30m"
}

variable "sso_session_max_lifespan" {
  description = "SSO session max lifespan in seconds"
  type        = string
  default     = "10h"
}

variable "offline_session_idle_timeout" {
  description = "Offline session idle timeout"
  type        = string
  default     = "30d"
}

variable "offline_session_max_lifespan" {
  description = "Offline session max lifespan"
  type        = string
  default     = "60d"
}

variable "offline_session_max_lifespan_enabled" {
  description = "Whether offline session max lifespan is enabled"
  type        = bool
  default     = false
}

# Access Code Settings
variable "access_code_lifespan" {
  description = "Access code lifespan in seconds"
  type        = string
  default     = "1m"
}

variable "access_code_lifespan_login" {
  description = "Access code lifespan for login in seconds"
  type        = string
  default     = "30m"
}

variable "access_code_lifespan_user_action" {
  description = "Access code lifespan for user action in seconds"
  type        = string
  default     = "5m"
}

# Token Settings
variable "access_token_lifespan" {
  description = "Access token lifespan in seconds"
  type        = string
  default     = "5m"
}

variable "access_token_lifespan_for_implicit_flow" {
  description = "Access token lifespan for implicit flow in seconds"
  type        = string
  default     = "15m"
}

# Password Policy
variable "password_policy" {
  description = "Password policy string"
  type        = string
  default     = "length(8) and digits(1) and lowerCase(1) and upperCase(1) and specialChars(1)"
}

# Realm Attributes
variable "realm_attributes" {
  description = "Custom realm attributes"
  type        = map(string)
  default     = {}
}

# OpenID Connect Clients
variable "openid_clients" {
  description = "Map of OpenID Connect clients to create"
  type = map(object({
    client_id   = string
    name        = string
    description = string
    enabled     = bool
    access_type = string
    valid_redirect_uris = list(string)
    valid_post_logout_redirect_uris = list(string)
    web_origins = list(string)
    admin_url   = string
    base_url    = string
    root_url    = string
    standard_flow_enabled = bool
    implicit_flow_enabled = bool
    direct_access_grants_enabled = bool
    service_accounts_enabled = bool
    pkce_code_challenge_method = string
    client_authenticator_type = string
    client_secret = string
    access_token_lifespan = number
    extra_config = map(string)
  }))
  default = {}
}

# SAML Clients
variable "saml_clients" {
  description = "Map of SAML clients to create"
  type = map(object({
    client_id = string
    name      = string
    sign_documents = bool
    sign_assertions = bool
    encrypt_assertions = bool
    client_signature_required = bool
    valid_redirect_uris = list(string)
    base_url = string
    master_saml_processing_url = string
    name_id_format = string
    root_url = string
    signing_certificate = string
    signing_private_key = string
    encryption_certificate = string
    idp_initiated_sso_url_name = string
    idp_initiated_sso_relay_state = string
    assertion_consumer_post_url = string
    assertion_consumer_redirect_url = string
    logout_service_post_binding_url = string
    logout_service_redirect_binding_url = string
    extra_config = map(string)
  }))
  default = {}
}

# Groups
variable "groups" {
  description = "Map of groups to create"
  type = map(object({
    name      = string
    parent_id = string
    attributes = map(list(string))
  }))
  default = {}
}

# Users
variable "users" {
  description = "Map of users to create"
  type = map(object({
    username = string
    enabled  = bool
    email    = string
    first_name = string
    last_name  = string
    email_verified = bool
    attributes = map(list(string))
    initial_password = string
    temporary_password = bool
  }))
  default = {}
}

# User Group Memberships
variable "user_group_memberships" {
  description = "Map of user group memberships"
  type = map(object({
    user_key   = string
    group_keys = list(string)
  }))
  default = {}
}

# Realm Roles
variable "realm_roles" {
  description = "Map of realm roles to create"
  type = map(object({
    name        = string
    description = string
    attributes  = map(list(string))
  }))
  default = {}
}

# Client Roles
variable "client_roles" {
  description = "Map of client roles to create"
  type = map(object({
    client_key  = string
    name        = string
    description = string
    attributes  = map(list(string))
  }))
  default = {}
}

# User Realm Role Mappings
variable "user_realm_role_mappings" {
  description = "Map of user realm role mappings"
  type = map(object({
    user_key  = string
    role_keys = list(string)
  }))
  default = {}
}

# SAML Identity Providers
variable "saml_identity_providers" {
  description = "Map of SAML identity providers"
  type = map(object({
    alias = string
    display_name = string
    enabled = bool
    store_token = bool
    add_read_token_role_on_create = bool
    trust_email = bool
    link_only = bool
    first_broker_login_flow_alias = string
    single_sign_on_service_url = string
    single_logout_service_url = string
    backchannel_supported = bool
    name_id_policy_format = string
    post_binding_response = bool
    post_binding_authn_request = bool
    post_binding_logout = bool
    want_assertions_signed = bool
    want_assertions_encrypted = bool
    force_authn = bool
    validate_signature = bool
    signing_certificate = string
    signature_algorithm = string
    extra_config = map(string)
  }))
  default = {}
}

# OIDC Identity Providers
variable "oidc_identity_providers" {
  description = "Map of OIDC identity providers"
  type = map(object({
    alias = string
    display_name = string
    enabled = bool
    store_token = bool
    add_read_token_role_on_create = bool
    trust_email = bool
    link_only = bool
    first_broker_login_flow_alias = string
    authorization_url = string
    token_url = string
    user_info_url = string
    jwks_url = string
    logout_url = string
    client_id = string
    client_secret = string
    default_scopes = string
    validate_signature = bool
    use_jwks_url = bool
    pkce_enabled = bool
    extra_config = map(string)
  }))
  default = {}
}

# Client Default Scopes
variable "client_default_scopes" {
  description = "Map of client default scopes"
  type = map(object({
    client_key = string
    default_scopes = list(string)
  }))
  default = {}
}

# User Attribute Mappers
variable "user_attribute_mappers" {
  description = "Map of user attribute protocol mappers"
  type = map(object({
    client_key = string
    name = string
    user_attribute = string
    claim_name = string
    claim_value_type = string
    add_to_id_token = bool
    add_to_access_token = bool
    add_to_userinfo = bool
  }))
  default = {}
} 