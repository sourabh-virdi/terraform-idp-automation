# Keycloak Module

This Terraform module creates and configures Keycloak realms, clients, users, groups, and identity providers.

## Features

- **Realm Management**: Complete realm configuration with customizable settings
- **OpenID Connect Clients**: OAuth 2.0/OpenID Connect client configuration
- **SAML Clients**: SAML 2.0 client configuration
- **User Management**: User creation and group assignments
- **Group Management**: Group hierarchy and role assignments
- **Identity Providers**: SAML and OIDC identity provider integration
- **Role Management**: Realm and client role configuration
- **Protocol Mappers**: Custom attribute mapping for claims

## Usage

### Basic Realm Setup

```hcl
module "keycloak" {
  source = "../../modules/keycloak"

  realm_name         = "my-company"
  realm_display_name = "My Company"
  keycloak_base_url  = "https://auth.mycompany.com"

  # OpenID Connect client
  openid_clients = {
    "web-app" = {
      client_id   = "web-application"
      name        = "Web Application"
      description = "Main web application client"
      enabled     = true
      access_type = "CONFIDENTIAL"
      valid_redirect_uris = ["https://app.mycompany.com/*"]
      valid_post_logout_redirect_uris = ["https://app.mycompany.com/logout"]
      web_origins = ["https://app.mycompany.com"]
      admin_url   = "https://app.mycompany.com/admin"
      base_url    = "https://app.mycompany.com"
      root_url    = "https://app.mycompany.com"
      standard_flow_enabled = true
      implicit_flow_enabled = false
      direct_access_grants_enabled = true
      service_accounts_enabled = false
      pkce_code_challenge_method = "S256"
      client_authenticator_type = "client-secret"
      client_secret = "your-client-secret"
      access_token_lifespan = 300
      extra_config = {}
    }
  }
}
```

### Realm with Users and Groups

```hcl
module "keycloak_with_users" {
  source = "../../modules/keycloak"

  realm_name = "enterprise"
  keycloak_base_url = "https://keycloak.example.com"

  # Create groups
  groups = {
    "admins" = {
      name      = "Administrators"
      parent_id = null
      attributes = {
        department = ["IT"]
      }
    }
    "users" = {
      name      = "Regular Users"
      parent_id = null
      attributes = {
        department = ["General"]
      }
    }
  }

  # Create users
  users = {
    "admin" = {
      username       = "admin"
      enabled        = true
      email          = "admin@example.com"
      first_name     = "Admin"
      last_name      = "User"
      email_verified = true
      attributes     = {}
      initial_password   = "admin123"
      temporary_password = true
    }
    "user1" = {
      username       = "john.doe"
      enabled        = true
      email          = "john.doe@example.com"
      first_name     = "John"
      last_name      = "Doe"
      email_verified = true
      attributes     = {}
      initial_password   = "password123"
      temporary_password = true
    }
  }

  # Group memberships
  user_group_memberships = {
    "admin_membership" = {
      user_key   = "admin"
      group_keys = ["admins"]
    }
    "user1_membership" = {
      user_key   = "user1"
      group_keys = ["users"]
    }
  }
}
```

### SAML Integration

```hcl
module "keycloak_saml" {
  source = "../../modules/keycloak"

  realm_name = "saml-realm"
  keycloak_base_url = "https://keycloak.example.com"

  # SAML client
  saml_clients = {
    "saml-app" = {
      client_id = "saml-application"
      name      = "SAML Application"
      sign_documents = true
      sign_assertions = true
      encrypt_assertions = false
      client_signature_required = true
      valid_redirect_uris = ["https://app.example.com/saml/acs"]
      base_url = "https://app.example.com"
      master_saml_processing_url = "https://app.example.com/saml/acs"
      name_id_format = "email"
      root_url = "https://app.example.com"
      signing_certificate = ""
      signing_private_key = ""
      encryption_certificate = ""
      idp_initiated_sso_url_name = "saml-app"
      idp_initiated_sso_relay_state = ""
      assertion_consumer_post_url = "https://app.example.com/saml/acs"
      assertion_consumer_redirect_url = ""
      logout_service_post_binding_url = "https://app.example.com/saml/sls"
      logout_service_redirect_binding_url = ""
      extra_config = {}
    }
  }

  # SAML Identity Provider
  saml_identity_providers = {
    "external-saml" = {
      alias = "external-saml-idp"
      display_name = "External SAML Provider"
      enabled = true
      store_token = false
      add_read_token_role_on_create = false
      trust_email = true
      link_only = false
      first_broker_login_flow_alias = "first broker login"
      single_sign_on_service_url = "https://external-idp.com/saml/sso"
      single_logout_service_url = "https://external-idp.com/saml/sls"
      backchannel_supported = false
      name_id_policy_format = "Persistent"
      post_binding_response = true
      post_binding_authn_request = true
      post_binding_logout = true
      want_assertions_signed = true
      want_assertions_encrypted = false
      force_authn = false
      validate_signature = true
      signing_certificate = "-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"
      signature_algorithm = "RSA_SHA256"
      extra_config = {}
    }
  }
}
```

### Complete Enterprise Setup

```hcl
module "keycloak_enterprise" {
  source = "../../modules/keycloak"

  realm_name         = "enterprise"
  realm_display_name = "Enterprise Realm"
  keycloak_base_url  = "https://auth.enterprise.com"

  # Realm settings
  login_with_email_allowed = true
  registration_allowed     = false
  reset_password_allowed   = true
  verify_email            = true
  ssl_required            = "external"

  # Session settings
  sso_session_idle_timeout = "30m"
  sso_session_max_lifespan = "10h"
  
  # Password policy
  password_policy = "length(12) and digits(2) and lowerCase(1) and upperCase(1) and specialChars(1)"

  # OpenID Connect clients
  openid_clients = {
    "web-portal" = {
      client_id   = "enterprise-portal"
      name        = "Enterprise Portal"
      description = "Main enterprise web portal"
      enabled     = true
      access_type = "CONFIDENTIAL"
      valid_redirect_uris = ["https://portal.enterprise.com/*"]
      valid_post_logout_redirect_uris = ["https://portal.enterprise.com/logout"]
      web_origins = ["https://portal.enterprise.com"]
      admin_url   = ""
      base_url    = "https://portal.enterprise.com"
      root_url    = "https://portal.enterprise.com"
      standard_flow_enabled = true
      implicit_flow_enabled = false
      direct_access_grants_enabled = false
      service_accounts_enabled = true
      pkce_code_challenge_method = "S256"
      client_authenticator_type = "client-secret"
      client_secret = var.portal_client_secret
      access_token_lifespan = 300
      extra_config = {}
    }
  }

  # Realm roles
  realm_roles = {
    "admin" = {
      name        = "admin"
      description = "Administrator role"
      attributes  = {}
    }
    "user" = {
      name        = "user"
      description = "Regular user role"
      attributes  = {}
    }
  }

  # Groups
  groups = {
    "it-admins" = {
      name      = "IT Administrators"
      parent_id = null
      attributes = {
        department = ["IT"]
        level      = ["admin"]
      }
    }
    "business-users" = {
      name      = "Business Users"
      parent_id = null
      attributes = {
        department = ["Business"]
        level      = ["user"]
      }
    }
  }

  # Protocol mappers for custom claims
  user_attribute_mappers = {
    "department-mapper" = {
      client_key = "web-portal"
      name = "department"
      user_attribute = "department"
      claim_name = "department"
      claim_value_type = "String"
      add_to_id_token = true
      add_to_access_token = true
      add_to_userinfo = true
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| realm_name | Name of the Keycloak realm | `string` | n/a | yes |
| keycloak_base_url | Base URL of the Keycloak server | `string` | `"http://localhost:8080"` | no |
| realm_display_name | Display name of the realm | `string` | `null` | no |
| login_with_email_allowed | Whether login with email is allowed | `bool` | `true` | no |
| registration_allowed | Whether user registration is allowed | `bool` | `false` | no |
| ssl_required | SSL requirement level | `string` | `"external"` | no |
| password_policy | Password policy string | `string` | Complex default | no |
| openid_clients | Map of OpenID Connect clients | `map(object)` | `{}` | no |
| saml_clients | Map of SAML clients | `map(object)` | `{}` | no |
| groups | Map of groups to create | `map(object)` | `{}` | no |
| users | Map of users to create | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| realm_id | ID of the Keycloak realm |
| realm_name | Name of the Keycloak realm |
| openid_client_ids | Map of OpenID Connect client IDs |
| saml_client_ids | Map of SAML client IDs |
| group_ids | Map of group IDs |
| user_ids | Map of user IDs |
| realm_urls | Important realm URLs |

## Examples

See the `examples/` directory for complete working examples:

- `examples/keycloak-setup/` - Basic Keycloak realm setup
- `examples/multi-provider/` - Multi-provider SSO with Keycloak

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| keycloak | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| keycloak | ~> 4.0 |

## Configuration

### Keycloak Provider Setup

Configure the Keycloak provider with your server details:

```hcl
provider "keycloak" {
  client_id     = "admin-cli"
  username      = "admin"
  password      = "admin"
  url           = "http://localhost:8080"
  initial_login = false
}
```

### Environment Variables

Set these environment variables for the Keycloak provider:

```bash
export KEYCLOAK_CLIENT_ID=admin-cli
export KEYCLOAK_USERNAME=admin
export KEYCLOAK_PASSWORD=admin
export KEYCLOAK_URL=http://localhost:8080
```

## Security Considerations

1. **Password Policies**: Configure strong password policies
2. **SSL/TLS**: Always use HTTPS in production
3. **Client Secrets**: Store client secrets securely
4. **Session Management**: Configure appropriate session timeouts
5. **Regular Updates**: Keep Keycloak updated to latest version 