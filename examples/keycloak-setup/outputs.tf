output "realm_id" {
  description = "ID of the Keycloak realm"
  value       = module.keycloak.realm_id
}

output "realm_name" {
  description = "Name of the Keycloak realm"
  value       = var.realm_name
}

output "client_ids" {
  description = "IDs of the created OIDC clients"
  value       = module.keycloak.client_ids
}

output "client_secrets" {
  description = "Secrets of the created OIDC clients"
  value       = module.keycloak.client_secrets
  sensitive   = true
}

output "user_ids" {
  description = "IDs of the created users"
  value       = module.keycloak.user_ids
}

output "group_ids" {
  description = "IDs of the created groups"
  value       = module.keycloak.group_ids
}

output "realm_role_ids" {
  description = "IDs of the created realm roles"
  value       = module.keycloak.realm_role_ids
}

output "openid_configuration_url" {
  description = "OpenID Connect configuration endpoint URL"
  value       = "${var.keycloak_url}/realms/${var.realm_name}/.well-known/openid_configuration"
}

output "token_endpoint" {
  description = "OAuth 2.0 token endpoint URL"
  value       = "${var.keycloak_url}/realms/${var.realm_name}/protocol/openid-connect/token"
}

output "authorization_endpoint" {
  description = "OAuth 2.0 authorization endpoint URL"
  value       = "${var.keycloak_url}/realms/${var.realm_name}/protocol/openid-connect/auth"
}

output "userinfo_endpoint" {
  description = "OAuth 2.0 userinfo endpoint URL"
  value       = "${var.keycloak_url}/realms/${var.realm_name}/protocol/openid-connect/userinfo"
}

output "jwks_uri" {
  description = "JSON Web Key Set URI"
  value       = "${var.keycloak_url}/realms/${var.realm_name}/protocol/openid-connect/certs"
}

output "issuer" {
  description = "OAuth 2.0 issuer identifier"
  value       = "${var.keycloak_url}/realms/${var.realm_name}"
}

output "realm_admin_url" {
  description = "URL to access the realm admin console"
  value       = "${var.keycloak_url}/admin/master/console/#/${var.realm_name}"
}

output "identity_provider_ids" {
  description = "IDs of the configured identity providers"
  value       = module.keycloak.identity_provider_ids
} 