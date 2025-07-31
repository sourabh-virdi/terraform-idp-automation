# Realm Outputs
output "realm_id" {
  description = "ID of the Keycloak realm"
  value       = keycloak_realm.main.id
}

output "realm_name" {
  description = "Name of the Keycloak realm"
  value       = keycloak_realm.main.realm
}

output "realm_display_name" {
  description = "Display name of the Keycloak realm"
  value       = keycloak_realm.main.display_name
}

# OpenID Connect Client Outputs
output "openid_clients" {
  description = "Map of OpenID Connect clients"
  value = {
    for k, v in keycloak_openid_client.main : k => {
      id        = v.id
      client_id = v.client_id
      name      = v.name
      enabled   = v.enabled
    }
  }
}

output "openid_client_ids" {
  description = "Map of OpenID Connect client IDs"
  value       = { for k, v in keycloak_openid_client.main : k => v.client_id }
}

# SAML Client Outputs
output "saml_clients" {
  description = "Map of SAML clients"
  value = {
    for k, v in keycloak_saml_client.main : k => {
      id        = v.id
      client_id = v.client_id
      name      = v.name
    }
  }
}

output "saml_client_ids" {
  description = "Map of SAML client IDs"
  value       = { for k, v in keycloak_saml_client.main : k => v.client_id }
}

# Group Outputs
output "groups" {
  description = "Map of created groups"
  value = {
    for k, v in keycloak_group.main : k => {
      id   = v.id
      name = v.name
      path = v.path
    }
  }
}

output "group_ids" {
  description = "Map of group IDs"
  value       = { for k, v in keycloak_group.main : k => v.id }
}

# User Outputs
output "users" {
  description = "Map of created users"
  value = {
    for k, v in keycloak_user.main : k => {
      id         = v.id
      username   = v.username
      email      = v.email
      first_name = v.first_name
      last_name  = v.last_name
      enabled    = v.enabled
    }
  }
}

output "user_ids" {
  description = "Map of user IDs"
  value       = { for k, v in keycloak_user.main : k => v.id }
}

# Realm Role Outputs
output "realm_roles" {
  description = "Map of created realm roles"
  value = {
    for k, v in keycloak_realm_role.main : k => {
      id          = v.id
      name        = v.name
      description = v.description
    }
  }
}

output "realm_role_ids" {
  description = "Map of realm role IDs"
  value       = { for k, v in keycloak_realm_role.main : k => v.id }
}

# Client Role Outputs
output "client_roles" {
  description = "Map of created client roles"
  value = {
    for k, v in keycloak_openid_client_role.main : k => {
      id          = v.id
      name        = v.name
      description = v.description
      client_id   = v.client_id
    }
  }
}

# Identity Provider Outputs
output "saml_identity_providers" {
  description = "Map of SAML identity providers"
  value = {
    for k, v in keycloak_saml_identity_provider.main : k => {
      alias        = v.alias
      display_name = v.display_name
      enabled      = v.enabled
    }
  }
}

output "oidc_identity_providers" {
  description = "Map of OIDC identity providers"
  value = {
    for k, v in keycloak_oidc_identity_provider.main : k => {
      alias        = v.alias
      display_name = v.display_name
      enabled      = v.enabled
    }
  }
}

# Realm URLs
output "realm_urls" {
  description = "Important realm URLs"
  value = {
    auth_url       = "${var.keycloak_base_url}/realms/${keycloak_realm.main.realm}"
    token_url      = "${var.keycloak_base_url}/realms/${keycloak_realm.main.realm}/protocol/openid-connect/token"
    userinfo_url   = "${var.keycloak_base_url}/realms/${keycloak_realm.main.realm}/protocol/openid-connect/userinfo"
    jwks_url       = "${var.keycloak_base_url}/realms/${keycloak_realm.main.realm}/protocol/openid-connect/certs"
    issuer         = "${var.keycloak_base_url}/realms/${keycloak_realm.main.realm}"
    admin_console  = "${var.keycloak_base_url}/admin/master/console/#/realms/${keycloak_realm.main.realm}"
  }
}

# Summary Information
output "summary" {
  description = "Summary of created resources"
  value = {
    realm_name           = keycloak_realm.main.realm
    openid_clients_count = length(keycloak_openid_client.main)
    saml_clients_count   = length(keycloak_saml_client.main)
    groups_count         = length(keycloak_group.main)
    users_count          = length(keycloak_user.main)
    realm_roles_count    = length(keycloak_realm_role.main)
    client_roles_count   = length(keycloak_openid_client_role.main)
  }
} 