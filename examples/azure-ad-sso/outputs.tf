output "application_id" {
  description = "Application (client) ID of the Azure AD application"
  value       = module.azure_ad.application_id
}

output "object_id" {
  description = "Object ID of the Azure AD application"
  value       = module.azure_ad.object_id
}

output "client_secret" {
  description = "Client secret for the Azure AD application"
  value       = module.azure_ad.client_secret
  sensitive   = true
}

output "tenant_id" {
  description = "Tenant ID of the Azure AD"
  value       = var.tenant_id
}

output "service_principal_id" {
  description = "Object ID of the service principal"
  value       = module.azure_ad.service_principal_id
}

output "service_principal_app_id" {
  description = "Application ID of the service principal"
  value       = module.azure_ad.service_principal_app_id
}

output "oauth2_authorization_url" {
  description = "OAuth 2.0 authorization endpoint URL"
  value       = "https://login.microsoftonline.com/${var.tenant_id}/oauth2/v2.0/authorize"
}

output "oauth2_token_url" {
  description = "OAuth 2.0 token endpoint URL"
  value       = "https://login.microsoftonline.com/${var.tenant_id}/oauth2/v2.0/token"
}

output "openid_configuration_url" {
  description = "OpenID Connect configuration endpoint URL"
  value       = "https://login.microsoftonline.com/${var.tenant_id}/v2.0/.well-known/openid_configuration"
}

output "saml_metadata_url" {
  description = "SAML 2.0 metadata endpoint URL"
  value       = "https://login.microsoftonline.com/${var.tenant_id}/federationmetadata/2007-06/federationmetadata.xml"
}

output "group_ids" {
  description = "Object IDs of the created Azure AD groups"
  value       = module.azure_ad.group_ids
}

output "app_role_ids" {
  description = "IDs of the created application roles"
  value       = module.azure_ad.app_role_ids
} 