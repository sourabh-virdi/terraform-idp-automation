# SAML Application Outputs
output "saml_app_id" {
  description = "ID of the SAML application"
  value       = var.create_saml_app ? okta_app_saml.main[0].id : null
}

output "saml_app_name" {
  description = "Name of the SAML application"
  value       = var.create_saml_app ? okta_app_saml.main[0].name : null
}

output "saml_app_label" {
  description = "Label of the SAML application"
  value       = var.create_saml_app ? okta_app_saml.main[0].label : null
}

output "saml_app_sign_on_mode" {
  description = "Sign-on mode of the SAML application"
  value       = var.create_saml_app ? okta_app_saml.main[0].sign_on_mode : null
}

output "saml_metadata" {
  description = "SAML metadata for the application"
  value       = var.create_saml_app ? okta_app_saml.main[0].metadata : null
}

output "saml_metadata_url" {
  description = "SAML metadata URL for the application"
  value       = var.create_saml_app ? okta_app_saml.main[0].metadata_url : null
}

output "saml_certificate" {
  description = "SAML signing certificate"
  value       = var.create_saml_app ? okta_app_saml.main[0].certificate : null
}

output "saml_key_id" {
  description = "SAML key ID"
  value       = var.create_saml_app ? okta_app_saml.main[0].key_id : null
}

# OAuth Application Outputs
output "oauth_app_id" {
  description = "ID of the OAuth application"
  value       = var.create_oauth_app ? okta_app_oauth.main[0].id : null
}

output "oauth_app_name" {
  description = "Name of the OAuth application"
  value       = var.create_oauth_app ? okta_app_oauth.main[0].name : null
}

output "oauth_app_label" {
  description = "Label of the OAuth application"
  value       = var.create_oauth_app ? okta_app_oauth.main[0].label : null
}

output "oauth_client_id" {
  description = "OAuth client ID"
  value       = var.create_oauth_app ? okta_app_oauth.main[0].client_id : null
}

output "oauth_client_secret" {
  description = "OAuth client secret"
  value       = var.create_oauth_app ? okta_app_oauth.main[0].client_secret : null
  sensitive   = true
}

output "oauth_app_sign_on_mode" {
  description = "Sign-on mode of the OAuth application"
  value       = var.create_oauth_app ? okta_app_oauth.main[0].sign_on_mode : null
}

# Groups Outputs
output "groups" {
  description = "Map of created Okta groups"
  value = {
    for k, v in okta_group.main : k => {
      id          = v.id
      name        = v.name
      description = v.description
      type        = v.type
    }
  }
}

output "group_ids" {
  description = "Map of group names to IDs"
  value       = { for k, v in okta_group.main : k => v.id }
}

# Users Outputs
output "users" {
  description = "Map of created Okta users"
  value = {
    for k, v in okta_user.main : k => {
      id                  = v.id
      login               = v.login
      email               = v.email
      first_name          = v.first_name
      last_name           = v.last_name
      display_name        = v.display_name
      status              = v.status
      admin_roles         = v.admin_roles
    }
  }
}

output "user_ids" {
  description = "Map of user keys to IDs"
  value       = { for k, v in okta_user.main : k => v.id }
}

# Group Rules Outputs
output "group_rules" {
  description = "Map of created group rules"
  value = {
    for k, v in okta_group_rule.main : k => {
      id                = v.id
      name              = v.name
      status            = v.status
      expression_type   = v.expression_type
      expression_value  = v.expression_value
    }
  }
}

# Policies Outputs
output "signon_policies" {
  description = "Map of created sign-on policies"
  value = {
    for k, v in okta_policy_signon.main : k => {
      id          = v.id
      name        = v.name
      type        = v.type
      status      = v.status
      description = v.description
      priority    = v.priority
    }
  }
}

output "signon_policy_rules" {
  description = "Map of created sign-on policy rules"
  value = {
    for k, v in okta_policy_rule_signon.main : k => {
      id        = v.id
      name      = v.name
      status    = v.status
      priority  = v.priority
      policy_id = v.policy_id
    }
  }
}

# App Assignments Outputs
output "saml_user_assignments" {
  description = "SAML application user assignments"
  value = {
    for k, v in okta_app_user.saml_assignments : k => {
      id       = v.id
      app_id   = v.app_id
      user_id  = v.user_id
      username = v.username
    }
  }
}

output "oauth_user_assignments" {
  description = "OAuth application user assignments"
  value = {
    for k, v in okta_app_user.oauth_assignments : k => {
      id       = v.id
      app_id   = v.app_id
      user_id  = v.user_id
      username = v.username
    }
  }
}

# Application URLs
output "saml_app_urls" {
  description = "Important SAML application URLs"
  value = var.create_saml_app ? {
    sign_on_url     = okta_app_saml.main[0].sign_on_mode == "SAML_2_0" ? "https://${replace(okta_app_saml.main[0].name, " ", "")}.okta.com/app/${okta_app_saml.main[0].name}/${okta_app_saml.main[0].id}/sso/saml" : null
    metadata_url    = okta_app_saml.main[0].metadata_url
    acs_url         = okta_app_saml.main[0].http_post_binding
    entity_id       = okta_app_saml.main[0].entity_key
  } : null
}

output "oauth_app_urls" {
  description = "Important OAuth application URLs"  
  value = var.create_oauth_app ? {
    client_id           = okta_app_oauth.main[0].client_id
    authorization_url   = "https://${var.oauth_org_url}/oauth2/default/v1/authorize"
    token_url          = "https://${var.oauth_org_url}/oauth2/default/v1/token"
    userinfo_url       = "https://${var.oauth_org_url}/oauth2/default/v1/userinfo"
    jwks_url           = "https://${var.oauth_org_url}/oauth2/default/v1/keys"
    issuer             = "https://${var.oauth_org_url}/oauth2/default"
  } : null
}

# Summary Information
output "summary" {
  description = "Summary of created resources"
  value = {
    saml_app_created    = var.create_saml_app
    oauth_app_created   = var.create_oauth_app
    groups_count        = length(okta_group.main)
    users_count         = length(okta_user.main)
    group_rules_count   = length(okta_group_rule.main)
    policies_count      = length(okta_policy_signon.main)
  }
} 