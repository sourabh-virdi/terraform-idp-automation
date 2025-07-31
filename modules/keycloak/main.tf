# Keycloak Realm
resource "keycloak_realm" "main" {
  realm                = var.realm_name
  enabled              = var.realm_enabled
  display_name         = var.realm_display_name
  display_name_html    = var.realm_display_name_html
  
  # Login settings
  login_with_email_allowed    = var.login_with_email_allowed
  duplicate_emails_allowed    = var.duplicate_emails_allowed
  reset_password_allowed      = var.reset_password_allowed
  remember_me                 = var.remember_me
  verify_email               = var.verify_email
  login_theme                = var.login_theme
  account_theme              = var.account_theme
  admin_theme                = var.admin_theme
  email_theme                = var.email_theme

  # Registration settings
  registration_allowed       = var.registration_allowed
  registration_email_as_username = var.registration_email_as_username
  edit_username_allowed      = var.edit_username_allowed

  # SSL settings
  ssl_required = var.ssl_required

  # Session settings
  sso_session_idle_timeout          = var.sso_session_idle_timeout
  sso_session_max_lifespan          = var.sso_session_max_lifespan
  offline_session_idle_timeout      = var.offline_session_idle_timeout
  offline_session_max_lifespan      = var.offline_session_max_lifespan
  offline_session_max_lifespan_enabled = var.offline_session_max_lifespan_enabled
  
  # Access code settings
  access_code_lifespan         = var.access_code_lifespan
  access_code_lifespan_login   = var.access_code_lifespan_login
  access_code_lifespan_user_action = var.access_code_lifespan_user_action

  # Token settings
  access_token_lifespan               = var.access_token_lifespan
  access_token_lifespan_for_implicit_flow = var.access_token_lifespan_for_implicit_flow
  
  # Password policy
  password_policy = var.password_policy

  # Custom attributes
  attributes = var.realm_attributes
}

# Keycloak OpenID Connect Client
resource "keycloak_openid_client" "main" {
  for_each = var.openid_clients

  realm_id    = keycloak_realm.main.id
  client_id   = each.value.client_id
  name        = each.value.name
  description = each.value.description
  enabled     = each.value.enabled

  access_type                = each.value.access_type
  valid_redirect_uris        = each.value.valid_redirect_uris
  valid_post_logout_redirect_uris = each.value.valid_post_logout_redirect_uris
  web_origins               = each.value.web_origins
  admin_url                 = each.value.admin_url
  base_url                  = each.value.base_url
  root_url                  = each.value.root_url

  standard_flow_enabled          = each.value.standard_flow_enabled
  implicit_flow_enabled          = each.value.implicit_flow_enabled
  direct_access_grants_enabled   = each.value.direct_access_grants_enabled
  service_accounts_enabled       = each.value.service_accounts_enabled

  # PKCE settings
  pkce_code_challenge_method = each.value.pkce_code_challenge_method

  # Client authentication
  client_authenticator_type = each.value.client_authenticator_type
  client_secret            = each.value.client_secret

  # Token settings
  access_token_lifespan = each.value.access_token_lifespan

  # Additional attributes
  extra_config = each.value.extra_config
}

# Keycloak SAML Client
resource "keycloak_saml_client" "main" {
  for_each = var.saml_clients

  realm_id  = keycloak_realm.main.id
  client_id = each.value.client_id
  name      = each.value.name

  sign_documents              = each.value.sign_documents
  sign_assertions            = each.value.sign_assertions
  encrypt_assertions         = each.value.encrypt_assertions
  client_signature_required  = each.value.client_signature_required

  valid_redirect_uris = each.value.valid_redirect_uris
  base_url           = each.value.base_url
  master_saml_processing_url = each.value.master_saml_processing_url

  name_id_format             = each.value.name_id_format
  root_url                   = each.value.root_url
  signing_certificate        = each.value.signing_certificate
  signing_private_key        = each.value.signing_private_key
  encryption_certificate     = each.value.encryption_certificate

  # IDP initiated SSO settings
  idp_initiated_sso_url_name = each.value.idp_initiated_sso_url_name
  idp_initiated_sso_relay_state = each.value.idp_initiated_sso_relay_state

  # Assertion settings
  assertion_consumer_post_url      = each.value.assertion_consumer_post_url
  assertion_consumer_redirect_url  = each.value.assertion_consumer_redirect_url
  logout_service_post_binding_url  = each.value.logout_service_post_binding_url
  logout_service_redirect_binding_url = each.value.logout_service_redirect_binding_url

  # Additional configuration
  extra_config = each.value.extra_config
}

# Keycloak Groups
resource "keycloak_group" "main" {
  for_each = var.groups

  realm_id = keycloak_realm.main.id
  name     = each.value.name
  parent_id = each.value.parent_id

  attributes = each.value.attributes
}

# Keycloak Users
resource "keycloak_user" "main" {
  for_each = var.users

  realm_id = keycloak_realm.main.id
  username = each.value.username
  enabled  = each.value.enabled

  email      = each.value.email
  first_name = each.value.first_name
  last_name  = each.value.last_name

  email_verified = each.value.email_verified
  
  attributes = each.value.attributes

  initial_password {
    value     = each.value.initial_password
    temporary = each.value.temporary_password
  }
}

# Group Memberships
resource "keycloak_user_groups" "main" {
  for_each = var.user_group_memberships

  realm_id = keycloak_realm.main.id
  user_id  = keycloak_user.main[each.value.user_key].id
  group_ids = [for group_key in each.value.group_keys : keycloak_group.main[group_key].id]
}

# Realm Roles
resource "keycloak_realm_role" "main" {
  for_each = var.realm_roles

  realm_id    = keycloak_realm.main.id
  name        = each.value.name
  description = each.value.description
  attributes  = each.value.attributes
}

# Client Roles for OpenID Connect clients
resource "keycloak_openid_client_role" "main" {
  for_each = var.client_roles

  realm_id    = keycloak_realm.main.id
  client_id   = keycloak_openid_client.main[each.value.client_key].id
  name        = each.value.name
  description = each.value.description
  attributes  = each.value.attributes
}

# User Role Mappings
resource "keycloak_user_realm_role_mapping" "realm_roles" {
  for_each = var.user_realm_role_mappings

  realm_id = keycloak_realm.main.id
  user_id  = keycloak_user.main[each.value.user_key].id
  role_ids = [for role_key in each.value.role_keys : keycloak_realm_role.main[role_key].id]
}

# Identity Provider - SAML
resource "keycloak_saml_identity_provider" "main" {
  for_each = var.saml_identity_providers

  realm                    = keycloak_realm.main.id
  alias                    = each.value.alias
  display_name            = each.value.display_name
  enabled                 = each.value.enabled
  store_token             = each.value.store_token
  add_read_token_role_on_create = each.value.add_read_token_role_on_create
  trust_email             = each.value.trust_email
  link_only               = each.value.link_only
  first_broker_login_flow_alias = each.value.first_broker_login_flow_alias

  # SAML settings
  single_sign_on_service_url    = each.value.single_sign_on_service_url
  single_logout_service_url     = each.value.single_logout_service_url
  backchannel_supported         = each.value.backchannel_supported
  name_id_policy_format         = each.value.name_id_policy_format
  post_binding_response         = each.value.post_binding_response
  post_binding_authn_request    = each.value.post_binding_authn_request
  post_binding_logout           = each.value.post_binding_logout
  want_assertions_signed        = each.value.want_assertions_signed
  want_assertions_encrypted     = each.value.want_assertions_encrypted
  force_authn                   = each.value.force_authn
  validate_signature            = each.value.validate_signature
  signing_certificate           = each.value.signing_certificate
  signature_algorithm           = each.value.signature_algorithm

  # Attribute mapping
  extra_config = each.value.extra_config
}

# Identity Provider - OpenID Connect
resource "keycloak_oidc_identity_provider" "main" {
  for_each = var.oidc_identity_providers

  realm                    = keycloak_realm.main.id
  alias                    = each.value.alias
  display_name            = each.value.display_name
  enabled                 = each.value.enabled
  store_token             = each.value.store_token
  add_read_token_role_on_create = each.value.add_read_token_role_on_create
  trust_email             = each.value.trust_email
  link_only               = each.value.link_only
  first_broker_login_flow_alias = each.value.first_broker_login_flow_alias

  # OIDC settings
  authorization_url       = each.value.authorization_url
  token_url              = each.value.token_url
  user_info_url          = each.value.user_info_url
  jwks_url               = each.value.jwks_url
  logout_url             = each.value.logout_url
  client_id              = each.value.client_id
  client_secret          = each.value.client_secret
  default_scopes         = each.value.default_scopes
  validate_signature     = each.value.validate_signature
  use_jwks_url           = each.value.use_jwks_url
  pkce_enabled           = each.value.pkce_enabled

  # Additional configuration
  extra_config = each.value.extra_config
}

# Client Scope
resource "keycloak_openid_client_default_scopes" "main" {
  for_each = var.client_default_scopes

  realm_id  = keycloak_realm.main.id
  client_id = keycloak_openid_client.main[each.value.client_key].id

  default_scopes = each.value.default_scopes
}

# Protocol Mappers
resource "keycloak_openid_user_attribute_protocol_mapper" "main" {
  for_each = var.user_attribute_mappers

  realm_id  = keycloak_realm.main.id
  client_id = keycloak_openid_client.main[each.value.client_key].id
  name      = each.value.name

  user_attribute   = each.value.user_attribute
  claim_name       = each.value.claim_name
  claim_value_type = each.value.claim_value_type

  add_to_id_token     = each.value.add_to_id_token
  add_to_access_token = each.value.add_to_access_token
  add_to_userinfo     = each.value.add_to_userinfo
} 