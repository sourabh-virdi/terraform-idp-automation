# Data sources
data "azuread_client_config" "current" {}

# Azure AD Application
resource "azuread_application" "main" {
  display_name     = var.application_name
  description      = var.application_description
  sign_in_audience = var.sign_in_audience

  # Application URIs
  identifier_uris = var.identifier_uris

  # OAuth2 permissions
  dynamic "api" {
    for_each = var.api_permissions != null ? [var.api_permissions] : []
    content {
      mapped_claims_enabled          = api.value.mapped_claims_enabled
      requested_access_token_version = api.value.requested_access_token_version

      dynamic "oauth2_permission_scope" {
        for_each = api.value.oauth2_permission_scopes
        content {
          admin_consent_description  = oauth2_permission_scope.value.admin_consent_description
          admin_consent_display_name = oauth2_permission_scope.value.admin_consent_display_name
          enabled                    = oauth2_permission_scope.value.enabled
          id                         = oauth2_permission_scope.value.id
          type                       = oauth2_permission_scope.value.type
          user_consent_description   = oauth2_permission_scope.value.user_consent_description
          user_consent_display_name  = oauth2_permission_scope.value.user_consent_display_name
          value                      = oauth2_permission_scope.value.value
        }
      }
    }
  }

  # App roles
  dynamic "app_role" {
    for_each = var.app_roles
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      enabled              = app_role.value.enabled
      id                   = app_role.value.id
      value                = app_role.value.value
    }
  }

  # Optional claims
  dynamic "optional_claims" {
    for_each = var.optional_claims != null ? [var.optional_claims] : []
    content {
      dynamic "access_token" {
        for_each = optional_claims.value.access_token
        content {
          name                  = access_token.value.name
          source                = access_token.value.source
          essential             = access_token.value.essential
          additional_properties = access_token.value.additional_properties
        }
      }

      dynamic "id_token" {
        for_each = optional_claims.value.id_token
        content {
          name                  = id_token.value.name
          source                = id_token.value.source
          essential             = id_token.value.essential
          additional_properties = id_token.value.additional_properties
        }
      }

      dynamic "saml2_token" {
        for_each = optional_claims.value.saml2_token
        content {
          name                  = saml2_token.value.name
          source                = saml2_token.value.source
          essential             = saml2_token.value.essential
          additional_properties = saml2_token.value.additional_properties
        }
      }
    }
  }

  # Web application settings
  dynamic "web" {
    for_each = var.web_settings != null ? [var.web_settings] : []
    content {
      homepage_url  = web.value.homepage_url
      logout_url    = web.value.logout_url
      redirect_uris = web.value.redirect_uris

      dynamic "implicit_grant" {
        for_each = web.value.implicit_grant != null ? [web.value.implicit_grant] : []
        content {
          access_token_issuance_enabled = implicit_grant.value.access_token_issuance_enabled
          id_token_issuance_enabled     = implicit_grant.value.id_token_issuance_enabled
        }
      }
    }
  }

  # Single page application settings
  dynamic "single_page_application" {
    for_each = var.spa_settings != null ? [var.spa_settings] : []
    content {
      redirect_uris = single_page_application.value.redirect_uris
    }
  }

  # Public client settings
  dynamic "public_client" {
    for_each = var.public_client_settings != null ? [var.public_client_settings] : []
    content {
      redirect_uris = public_client.value.redirect_uris
    }
  }

  # Required resource access (API permissions)
  dynamic "required_resource_access" {
    for_each = var.required_resource_access
    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = required_resource_access.value.resource_access
        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }

  tags = var.tags
}

# Service Principal for the application
resource "azuread_service_principal" "main" {
  client_id                     = azuread_application.main.client_id
  app_role_assignment_required  = var.app_role_assignment_required
  description                   = var.service_principal_description
  notification_email_addresses = var.notification_email_addresses

  # SAML settings for enterprise applications
  dynamic "saml_single_sign_on" {
    for_each = var.saml_settings != null ? [var.saml_settings] : []
    content {
      relay_state = saml_single_sign_on.value.relay_state
    }
  }

  tags = var.tags
}

# Application password/secret
resource "azuread_application_password" "main" {
  count          = var.create_application_secret ? 1 : 0
  application_id = azuread_application.main.id
  display_name   = var.application_secret_display_name
  end_date       = var.application_secret_end_date
}

# Groups
resource "azuread_group" "main" {
  for_each = var.groups

  display_name            = each.value.display_name
  description             = each.value.description
  security_enabled        = each.value.security_enabled
  mail_enabled            = each.value.mail_enabled
  mail_nickname           = each.value.mail_nickname
  prevent_duplicate_names = each.value.prevent_duplicate_names
  assignable_to_role      = each.value.assignable_to_role

  dynamic "owners" {
    for_each = each.value.owners != null ? [each.value.owners] : []
    content {
      object_ids = owners.value
    }
  }

  dynamic "members" {
    for_each = each.value.members != null ? [each.value.members] : []
    content {
      object_ids = members.value
    }
  }
}

# App role assignments for groups
resource "azuread_app_role_assignment" "group_assignments" {
  for_each = var.group_app_role_assignments

  app_role_id         = each.value.app_role_id
  principal_object_id = azuread_group.main[each.value.group_key].object_id
  resource_object_id  = azuread_service_principal.main.object_id
}

# App role assignments for users
resource "azuread_app_role_assignment" "user_assignments" {
  for_each = var.user_app_role_assignments

  app_role_id         = each.value.app_role_id
  principal_object_id = each.value.user_object_id
  resource_object_id  = azuread_service_principal.main.object_id
}

# Users (optional - for demo/test purposes)
resource "azuread_user" "demo_users" {
  for_each = var.demo_users

  user_principal_name = each.value.user_principal_name
  display_name        = each.value.display_name
  given_name          = each.value.given_name
  surname             = each.value.surname
  mail_nickname       = each.value.mail_nickname
  password            = each.value.password
  force_password_change = each.value.force_password_change
  
  usage_location = each.value.usage_location
  job_title      = each.value.job_title
  department     = each.value.department
  company_name   = each.value.company_name
}

# Group memberships for demo users
resource "azuread_group_member" "demo_user_memberships" {
  for_each = var.demo_user_group_memberships

  group_object_id  = azuread_group.main[each.value.group_key].object_id
  member_object_id = azuread_user.demo_users[each.value.user_key].object_id
}

# Administrative unit (optional)
resource "azuread_administrative_unit" "main" {
  count = var.create_administrative_unit ? 1 : 0

  display_name = var.administrative_unit_name
  description  = var.administrative_unit_description

  hidden_membership_enabled = var.administrative_unit_hidden_membership
}

# Administrative unit members
resource "azuread_administrative_unit_member" "users" {
  for_each = var.create_administrative_unit ? var.administrative_unit_user_members : {}

  administrative_unit_object_id = azuread_administrative_unit.main[0].object_id
  member_object_id              = each.value
}

resource "azuread_administrative_unit_member" "groups" {
  for_each = var.create_administrative_unit ? var.administrative_unit_group_members : {}

  administrative_unit_object_id = azuread_administrative_unit.main[0].object_id
  member_object_id              = azuread_group.main[each.key].object_id
} 