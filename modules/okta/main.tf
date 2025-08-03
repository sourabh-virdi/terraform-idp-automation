# Okta Application (SAML 2.0)
resource "okta_app_saml" "main" {
  count = var.create_saml_app ? 1 : 0

  label                    = var.app_name
  description              = var.app_description
  status                   = var.app_status
  preconfigured_app        = var.preconfigured_app
  auto_submit_toolbar      = var.auto_submit_toolbar
  hide_ios                 = var.hide_ios
  hide_web                 = var.hide_web
  default_relay_state      = var.default_relay_state
  sso_url                  = var.sso_url
  recipient                = var.recipient
  destination              = var.destination
  audience                 = var.audience
  subject_name_id_template = var.subject_name_id_template
  subject_name_id_format   = var.subject_name_id_format
  response_signed          = var.response_signed
  assertion_signed         = var.assertion_signed
  signature_algorithm      = var.signature_algorithm
  digest_algorithm         = var.digest_algorithm
  honor_force_authn        = var.honor_force_authn
  authn_context_class_ref  = var.authn_context_class_ref

  # Attribute statements
  dynamic "attribute_statements" {
    for_each = var.attribute_statements
    content {
      type         = attribute_statements.value.type
      name         = attribute_statements.value.name
      namespace    = attribute_statements.value.namespace
      values       = attribute_statements.value.values
    }
  }

  # Group attribute statements
  dynamic "group_attribute_statements" {
    for_each = var.group_attribute_statements
    content {
      type   = group_attribute_statements.value.type
      name   = group_attribute_statements.value.name
      filter = group_attribute_statements.value.filter
    }
  }

  # Single logout
  dynamic "single_logout" {
    for_each = var.single_logout != null ? [var.single_logout] : []
    content {
      url                 = single_logout.value.url
      logout_request_url  = single_logout.value.logout_request_url
    }
  }

  lifecycle {
    ignore_changes = [users, groups]
  }
}

# Okta Application (OAuth 2.0/OpenID Connect)
resource "okta_app_oauth" "main" {
  count = var.create_oauth_app ? 1 : 0

  label                      = var.app_name
  type                       = var.oauth_app_type
  consent_method             = var.consent_method
  response_types             = var.response_types
  grant_types                = var.grant_types
  redirect_uris              = var.redirect_uris
  post_logout_redirect_uris  = var.post_logout_redirect_uris
  login_uri                  = var.login_uri
  logo_uri                   = var.logo_uri

  # Client credentials
  client_basic_secret        = var.client_basic_secret
  client_id                  = var.custom_client_id
  omit_secret                = var.omit_secret
  client_uri                 = var.client_uri
  policy_uri                 = var.policy_uri
  tos_uri                    = var.tos_uri

  # OIDC settings
  issuer_mode                = var.issuer_mode
  auto_key_rotation          = var.auto_key_rotation
  auto_submit_toolbar        = var.auto_submit_toolbar
  hide_ios                   = var.hide_ios
  hide_web                   = var.hide_web

  # PKCE settings
  pkce_required              = var.pkce_required

  # Refresh token settings
  refresh_token_leeway       = var.refresh_token_leeway
  refresh_token_rotation     = var.refresh_token_rotation

  # Wildcard redirect
  wildcard_redirect          = var.wildcard_redirect

  # JSON Web Key
  dynamic "jwks" {
    for_each = var.jwks != null ? [var.jwks] : []
    content {
      kid = jwks.value.kid
      kty = jwks.value.kty
      use = jwks.value.use
      x5c = jwks.value.x5c
      e   = jwks.value.e
      n   = jwks.value.n
    }
  }

  # Groups claim
  dynamic "groups_claim" {
    for_each = var.groups_claim != null ? [var.groups_claim] : []
    content {
      type        = groups_claim.value.type
      filter_type = groups_claim.value.filter_type
      name        = groups_claim.value.name
      value       = groups_claim.value.value
    }
  }

  lifecycle {
    ignore_changes = [users, groups]
  }
}

# Okta Groups
resource "okta_group" "main" {
  for_each = var.groups

  name        = each.value.name
  description = each.value.description
  skip_users  = each.value.skip_users
}

# Group Rules
resource "okta_group_rule" "main" {
  for_each = var.group_rules

  name               = each.value.name
  status             = each.value.status
  group_assignments  = [for group_key in each.value.group_assignments : okta_group.main[group_key].id]
  expression_type    = each.value.expression_type
  expression_value   = each.value.expression_value
  users_excluded     = each.value.users_excluded
}

# Users
resource "okta_user" "main" {
  for_each = var.users

  first_name            = each.value.first_name
  last_name             = each.value.last_name
  login                 = each.value.login
  email                 = each.value.email
  password              = each.value.password
  password_hash         = each.value.password_hash
  old_password          = each.value.old_password
  recovery_question     = each.value.recovery_question
  recovery_answer       = each.value.recovery_answer
  city                  = each.value.city
  cost_center           = each.value.cost_center
  country_code          = each.value.country_code
  department            = each.value.department
  display_name          = each.value.display_name
  division              = each.value.division
  employee_number       = each.value.employee_number
  honorific_prefix      = each.value.honorific_prefix
  honorific_suffix      = each.value.honorific_suffix
  locale                = each.value.locale
  manager               = each.value.manager
  manager_id            = each.value.manager_id
  middle_name           = each.value.middle_name
  mobile_phone          = each.value.mobile_phone
  nick_name             = each.value.nick_name
  organization          = each.value.organization
  postal_address        = each.value.postal_address
  preferred_language    = each.value.preferred_language
  primary_phone         = each.value.primary_phone
  profile_url           = each.value.profile_url
  second_email          = each.value.second_email
  state                 = each.value.state
  street_address        = each.value.street_address
  timezone              = each.value.timezone
  title                 = each.value.title
  user_type             = each.value.user_type
  zip_code              = each.value.zip_code

  # Custom profile attributes
  custom_profile_attributes = each.value.custom_profile_attributes

  # Password policy
  dynamic "password_policy_id" {
    for_each = each.value.password_policy_id != null ? [each.value.password_policy_id] : []
    content {
      password_policy_id = password_policy_id.value
    }
  }
}

# Group Memberships
resource "okta_group_memberships" "main" {
  for_each = var.group_memberships

  group_id = okta_group.main[each.value.group_key].id
  users    = [for user_key in each.value.user_keys : okta_user.main[user_key].id]
}

# App User Assignments (SAML)
resource "okta_app_user" "saml_assignments" {
  for_each = var.create_saml_app ? var.saml_user_assignments : {}

  app_id   = okta_app_saml.main[0].id
  user_id  = okta_user.main[each.value.user_key].id
  username = each.value.username
  password = each.value.password

  # Profile attributes
  profile = jsonencode(each.value.profile)
}

# App User Assignments (OAuth)
resource "okta_app_user" "oauth_assignments" {
  for_each = var.create_oauth_app ? var.oauth_user_assignments : {}

  app_id   = okta_app_oauth.main[0].id
  user_id  = okta_user.main[each.value.user_key].id
  username = each.value.username
  password = each.value.password

  # Profile attributes
  profile = jsonencode(each.value.profile)
}

# App Group Assignments (SAML)
resource "okta_app_group_assignments" "saml_group_assignments" {
  count = var.create_saml_app && length(var.saml_group_assignments) > 0 ? 1 : 0

  app_id = okta_app_saml.main[0].id

  dynamic "group" {
    for_each = var.saml_group_assignments
    content {
      id       = okta_group.main[group.value.group_key].id
      priority = group.value.priority
      profile  = jsonencode(group.value.profile)
    }
  }
}

# App Group Assignments (OAuth)
resource "okta_app_group_assignments" "oauth_group_assignments" {
  count = var.create_oauth_app && length(var.oauth_group_assignments) > 0 ? 1 : 0

  app_id = okta_app_oauth.main[0].id

  dynamic "group" {
    for_each = var.oauth_group_assignments
    content {
      id       = okta_group.main[group.value.group_key].id
      priority = group.value.priority
      profile  = jsonencode(group.value.profile)
    }
  }
}

# Policies
resource "okta_policy_signon" "main" {
  for_each = var.signon_policies

  name            = each.value.name
  type            = "OKTA_SIGN_ON"
  status          = each.value.status
  description     = each.value.description
  priority        = each.value.priority
  groups_included = [for group_key in each.value.groups_included : okta_group.main[group_key].id]
  groups_excluded = [for group_key in each.value.groups_excluded : okta_group.main[group_key].id]
}

# Sign-on Policy Rules
resource "okta_policy_rule_signon" "main" {
  for_each = var.signon_policy_rules

  name                         = each.value.name
  policy_id                    = okta_policy_signon.main[each.value.policy_key].id
  priority                     = each.value.priority
  status                       = each.value.status
  access                       = each.value.access
  authtype                     = each.value.authtype
  mfa_required                 = each.value.mfa_required
  mfa_prompt                   = each.value.mfa_prompt
  mfa_remember_device          = each.value.mfa_remember_device
  mfa_lifetime                 = each.value.mfa_lifetime
  session_idle                 = each.value.session_idle
  session_lifetime             = each.value.session_lifetime
  session_persistent           = each.value.session_persistent
  users_excluded               = each.value.users_excluded
  network_includes             = each.value.network_includes
  network_excludes             = each.value.network_excludes
  network_connection           = each.value.network_connection
  risc_level                   = each.value.risc_level

  # Factors
  dynamic "factor_sequence" {
    for_each = each.value.factor_sequence
    content {
      primary_criteria_factor_type = factor_sequence.value.primary_criteria_factor_type
      primary_criteria_provider    = factor_sequence.value.primary_criteria_provider

      dynamic "secondary_criteria" {
        for_each = factor_sequence.value.secondary_criteria
        content {
          factor_type = secondary_criteria.value.factor_type
          provider    = secondary_criteria.value.provider
        }
      }
    }
  }
} 