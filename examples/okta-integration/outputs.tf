output "saml_app_id" {
  description = "ID of the SAML application"
  value       = module.okta.saml_app_id
}

output "oauth_app_id" {
  description = "ID of the OAuth application"
  value       = module.okta.oauth_app_id
}

output "saml_metadata_url" {
  description = "SAML metadata URL"
  value       = module.okta.saml_metadata_url
}

output "saml_sso_url" {
  description = "SAML SSO URL"
  value       = module.okta.saml_sso_url
}

output "oauth_client_id" {
  description = "OAuth client ID"
  value       = module.okta.oauth_client_id
}

output "oauth_client_secret" {
  description = "OAuth client secret"
  value       = module.okta.oauth_client_secret
  sensitive   = true
}

output "okta_sign_on_url" {
  description = "Okta sign-on URL for the application"
  value       = "https://${var.okta_org_name}.${var.okta_base_url}/app/${module.okta.saml_app_id}/sso/saml"
}

output "oauth_authorization_url" {
  description = "OAuth authorization endpoint URL"
  value       = "https://${var.okta_org_name}.${var.okta_base_url}/oauth2/default/v1/authorize"
}

output "oauth_token_url" {
  description = "OAuth token endpoint URL"
  value       = "https://${var.okta_org_name}.${var.okta_base_url}/oauth2/default/v1/token"
}

output "oauth_userinfo_url" {
  description = "OAuth userinfo endpoint URL"
  value       = "https://${var.okta_org_name}.${var.okta_base_url}/oauth2/default/v1/userinfo"
}

output "openid_configuration_url" {
  description = "OpenID Connect configuration endpoint URL"
  value       = "https://${var.okta_org_name}.${var.okta_base_url}/oauth2/default/.well-known/openid_configuration"
}

output "group_ids" {
  description = "IDs of the created Okta groups"
  value       = module.okta.group_ids
}

output "user_ids" {
  description = "IDs of the assigned users"
  value       = module.okta.user_ids
}

output "app_links" {
  description = "Application links for user access"
  value = {
    saml_app_link  = "https://${var.okta_org_name}.${var.okta_base_url}/app/${module.okta.saml_app_id}"
    oauth_app_link = "https://${var.okta_org_name}.${var.okta_base_url}/app/${module.okta.oauth_app_id}"
  }
} 