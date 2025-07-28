# Application Outputs
output "application_id" {
  description = "The Application (Client) ID of the Azure AD application"
  value       = azuread_application.main.client_id
}

output "application_object_id" {
  description = "The Object ID of the Azure AD application"
  value       = azuread_application.main.object_id
}

output "application_name" {
  description = "The display name of the Azure AD application"
  value       = azuread_application.main.display_name
}

output "application_identifier_uris" {
  description = "The identifier URIs of the Azure AD application"
  value       = azuread_application.main.identifier_uris
}

# Service Principal Outputs
output "service_principal_id" {
  description = "The Object ID of the service principal"
  value       = azuread_service_principal.main.object_id
}

output "service_principal_app_id" {
  description = "The Application (Client) ID of the service principal"
  value       = azuread_service_principal.main.client_id
}

output "service_principal_display_name" {
  description = "The display name of the service principal"
  value       = azuread_service_principal.main.display_name
}

# Application Secret Outputs
output "application_secret_key_id" {
  description = "The Key ID of the application secret"
  value       = var.create_application_secret ? azuread_application_password.main[0].key_id : null
}

output "application_secret_value" {
  description = "The value of the application secret"
  value       = var.create_application_secret ? azuread_application_password.main[0].value : null
  sensitive   = true
}

# Groups Outputs
output "groups" {
  description = "Map of created Azure AD groups"
  value = {
    for k, v in azuread_group.main : k => {
      object_id    = v.object_id
      display_name = v.display_name
      description  = v.description
      mail_nickname = v.mail_nickname
    }
  }
}

output "group_object_ids" {
  description = "Object IDs of all created groups"
  value       = { for k, v in azuread_group.main : k => v.object_id }
}

# Demo Users Outputs
output "demo_users" {
  description = "Map of created demo users"
  value = {
    for k, v in azuread_user.demo_users : k => {
      object_id           = v.object_id
      user_principal_name = v.user_principal_name
      display_name        = v.display_name
    }
  }
}

output "demo_user_object_ids" {
  description = "Object IDs of all demo users"
  value       = { for k, v in azuread_user.demo_users : k => v.object_id }
}

# Administrative Unit Outputs
output "administrative_unit_id" {
  description = "Object ID of the administrative unit"
  value       = var.create_administrative_unit ? azuread_administrative_unit.main[0].object_id : null
}

output "administrative_unit_display_name" {
  description = "Display name of the administrative unit"
  value       = var.create_administrative_unit ? azuread_administrative_unit.main[0].display_name : null
}

# App Role Assignments Outputs
output "group_app_role_assignments" {
  description = "Map of group app role assignments"
  value = {
    for k, v in azuread_app_role_assignment.group_assignments : k => {
      id                  = v.id
      app_role_id         = v.app_role_id
      principal_object_id = v.principal_object_id
      resource_object_id  = v.resource_object_id
    }
  }
}

output "user_app_role_assignments" {
  description = "Map of user app role assignments"
  value = {
    for k, v in azuread_app_role_assignment.user_assignments : k => {
      id                  = v.id
      app_role_id         = v.app_role_id
      principal_object_id = v.principal_object_id
      resource_object_id  = v.resource_object_id
    }
  }
}

# Tenant Information
output "tenant_id" {
  description = "The Tenant ID"
  value       = data.azuread_client_config.current.tenant_id
}

output "current_client_id" {
  description = "The Client ID of the current Azure AD client"
  value       = data.azuread_client_config.current.client_id
}

# OAuth URLs (for reference)
output "oauth_endpoints" {
  description = "OAuth endpoints for the Azure AD tenant"
  value = {
    authorization_endpoint = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/authorize"
    token_endpoint        = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/token"
    userinfo_endpoint     = "https://graph.microsoft.com/oidc/userinfo"
    jwks_uri              = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/discovery/v2.0/keys"
    issuer                = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
  }
} 