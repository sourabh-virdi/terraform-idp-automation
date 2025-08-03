# Okta Module

This Terraform module creates and configures Okta applications (SAML and OAuth), users, groups, and authentication policies.

## Features

- **SAML 2.0 Applications**: Complete SAML application configuration
- **OAuth 2.0/OpenID Connect**: Modern OAuth and OIDC application setup
- **User Management**: User creation with profile attributes
- **Group Management**: Group creation and automatic assignments
- **Authentication Policies**: Sign-on policies with MFA requirements
- **Group Rules**: Dynamic group assignment based on user attributes
- **Application Assignments**: User and group assignments to applications
- **Attribute Mapping**: Flexible SAML attribute statements

## Usage

### Basic SAML Application

```hcl
module "okta_saml" {
  source = "../../modules/okta"

  app_name        = "enterprise-saml-app"
  app_description = "Enterprise SAML Application"

  # Create SAML application
  create_saml_app = true

  # SAML configuration
  sso_url     = "https://myapp.com/saml/acs"
  audience    = "https://myapp.com"
  recipient   = "https://myapp.com/saml/acs"
  destination = "https://myapp.com/saml/acs"

  # SAML signing
  response_signed  = true
  assertion_signed = true

  # Attribute statements
  attribute_statements = [
    {
      type      = "EXPRESSION"
      name      = "email"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
      values    = ["user.email"]
    },
    {
      type      = "EXPRESSION"
      name      = "firstName"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
      values    = ["user.firstName"]
    },
    {
      type      = "EXPRESSION"
      name      = "lastName"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
      values    = ["user.lastName"]
    }
  ]

  # Group attribute statements
  group_attribute_statements = [
    {
      type   = "GROUP"
      name   = "groups"
      filter = ".*"
    }
  ]
}
```

### OAuth/OIDC Application

```hcl
module "okta_oauth" {
  source = "../../modules/okta"

  app_name        = "web-application"
  app_description = "Web Application using OAuth 2.0"

  # Create OAuth application
  create_oauth_app = true
  oauth_org_url    = "dev-12345678"

  # OAuth configuration
  oauth_app_type = "web"
  response_types = ["code"]
  grant_types    = ["authorization_code", "refresh_token"]

  redirect_uris = [
    "https://myapp.com/auth/callback",
    "https://myapp.com/signin-oidc"
  ]
  post_logout_redirect_uris = [
    "https://myapp.com/logout",
    "https://myapp.com/signout-callback-oidc"
  ]

  # PKCE for additional security
  pkce_required = true

  # Custom scopes
  groups_claim = {
    type        = "FILTER"
    filter_type = "REGEX"
    name        = "groups"
    value       = ".*"
  }
}
```

### Complete Enterprise Setup

```hcl
module "okta_enterprise" {
  source = "../../modules/okta"

  app_name        = "enterprise-portal"
  app_description = "Enterprise Portal with SSO"

  # Create both SAML and OAuth apps
  create_saml_app  = true
  create_oauth_app = true
  oauth_org_url    = "mycompany"

  # SAML settings
  sso_url                  = "https://portal.mycompany.com/saml/acs"
  audience                 = "https://portal.mycompany.com"
  subject_name_id_template = "${user.userName}"
  subject_name_id_format   = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  # OAuth settings
  oauth_app_type    = "web"
  response_types    = ["code"]
  grant_types       = ["authorization_code", "refresh_token"]
  redirect_uris     = ["https://portal.mycompany.com/auth/callback"]
  post_logout_redirect_uris = ["https://portal.mycompany.com/logout"]

  # Groups
  groups = {
    "administrators" = {
      name        = "Portal Administrators"
      description = "Administrative users for the enterprise portal"
      skip_users  = false
    },
    "managers" = {
      name        = "Portal Managers"
      description = "Manager users for the enterprise portal"
      skip_users  = false
    },
    "employees" = {
      name        = "Portal Employees"
      description = "Employee users for the enterprise portal"
      skip_users  = false
    }
  }

  # Users
  users = {
    "admin" = {
      first_name     = "Admin"
      last_name      = "User"
      login          = "admin@mycompany.com"
      email          = "admin@mycompany.com"
      password       = "TempPassword123!"
      password_hash  = null
      old_password   = null
      recovery_question = "What is your favorite color?"
      recovery_answer   = "Blue"
      city           = "New York"
      cost_center    = "IT"
      country_code   = "US"
      department     = "Information Technology"
      display_name   = "Administrator"
      division       = "Technology"
      employee_number = "EMP001"
      honorific_prefix = "Mr."
      honorific_suffix = ""
      locale         = "en_US"
      manager        = ""
      manager_id     = ""
      middle_name    = ""
      mobile_phone   = "+1-555-123-4567"
      nick_name      = "Admin"
      organization   = "My Company"
      postal_address = "123 Main St"
      preferred_language = "en"
      primary_phone  = "+1-555-123-4567"
      profile_url    = ""
      second_email   = ""
      state          = "NY"
      street_address = "123 Main St"
      timezone       = "America/New_York"
      title          = "System Administrator"
      user_type      = "Employee"
      zip_code       = "10001"
      custom_profile_attributes = {
        department_code = "IT001"
        employee_level  = "L5"
      }
      password_policy_id = null
    }
  }

  # Group memberships
  group_memberships = {
    "admin_membership" = {
      group_key = "administrators"
      user_keys = ["admin"]
    }
  }

  # Group rules for automatic assignment
  group_rules = {
    "it_department_rule" = {
      name               = "IT Department Auto-Assignment"
      status             = "ACTIVE"
      group_assignments  = ["administrators"]
      expression_type    = "urn:okta:expression:1.0"
      expression_value   = "user.department==\"Information Technology\""
      users_excluded     = []
    }
  }

  # Authentication policies
  signon_policies = {
    "mfa_policy" = {
      name            = "Enterprise MFA Policy"
      status          = "ACTIVE"
      description     = "Multi-factor authentication policy for enterprise users"
      priority        = 1
      groups_included = []
      groups_excluded = []
    }
  }

  # Policy rules
  signon_policy_rules = {
    "mfa_rule" = {
      name                         = "Require MFA for All Users"
      policy_key                   = "mfa_policy"
      priority                     = 1
      status                       = "ACTIVE"
      access                       = "ALLOW"
      authtype                     = "ANY"
      mfa_required                 = true
      mfa_prompt                   = "ALWAYS"
      mfa_remember_device          = false
      mfa_lifetime                 = 0
      session_idle                 = 120
      session_lifetime             = 480
      session_persistent           = false
      users_excluded               = []
      network_includes             = []
      network_excludes             = []
      network_connection           = "ANYWHERE"
      risc_level                   = "ANY"
      factor_sequence = [
        {
          primary_criteria_factor_type = "PASSWORD"
          primary_criteria_provider    = "OKTA"
          secondary_criteria = [
            {
              factor_type = "token:software:totp"
              provider    = "OKTA"
            },
            {
              factor_type = "sms"
              provider    = "OKTA"
            }
          ]
        }
      ]
    }
  }

  # SAML group assignments
  saml_group_assignments = [
    {
      group_key = "administrators"
      priority  = 1
      profile   = {
        role = "admin"
      }
    },
    {
      group_key = "managers"
      priority  = 2
      profile   = {
        role = "manager"
      }
    }
  ]

  # OAuth group assignments
  oauth_group_assignments = [
    {
      group_key = "employees"
      priority  = 1
      profile   = {
        role = "user"
      }
    }
  ]
}
```

### Mobile Application

```hcl
module "okta_mobile" {
  source = "../../modules/okta"

  app_name        = "mobile-app"
  app_description = "Mobile Application"

  # OAuth for mobile (public client)
  create_oauth_app = true
  oauth_org_url    = "mycompany"

  oauth_app_type = "native"
  response_types = ["code"]
  grant_types    = ["authorization_code", "refresh_token"]

  # Mobile redirect URIs
  redirect_uris = [
    "com.mycompany.app://callback",
    "myapp://auth"
  ]

  # PKCE required for mobile apps
  pkce_required = true

  # Don't generate client secret for public clients
  omit_secret = true
}
```

### API Application

```hcl
module "okta_api" {
  source = "../../modules/okta"

  app_name        = "api-service"
  app_description = "Backend API Service"

  # OAuth for service-to-service
  create_oauth_app = true
  oauth_org_url    = "mycompany"

  oauth_app_type = "service"
  grant_types    = ["client_credentials"]

  # No redirect URIs needed for service apps
  redirect_uris = []

  # Custom scopes for API access
  groups_claim = {
    type        = "EXPRESSION"
    filter_type = "CONTAINS"
    name        = "scope"
    value       = "api.read api.write"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app_name | Name of the Okta application | `string` | n/a | yes |
| app_description | Description of the Okta application | `string` | `""` | no |
| create_saml_app | Whether to create a SAML application | `bool` | `false` | no |
| create_oauth_app | Whether to create an OAuth application | `bool` | `false` | no |
| oauth_org_url | Okta organization URL for OAuth endpoints | `string` | `""` | no |
| sso_url | Single Sign On URL for SAML | `string` | `""` | no |
| audience | Audience Restriction for SAML | `string` | `""` | no |
| oauth_app_type | The type of OAuth client application | `string` | `"web"` | no |
| response_types | List of OAuth 2.0 response type strings | `list(string)` | `["code"]` | no |
| grant_types | List of OAuth 2.0 grant type strings | `list(string)` | `["authorization_code"]` | no |
| redirect_uris | List of URIs for use in the redirect-based flow | `list(string)` | `[]` | no |
| groups | Map of Okta groups to create | `map(object)` | `{}` | no |
| users | Map of Okta users to create | `map(object)` | `{}` | no |
| signon_policies | Map of sign-on policies | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| saml_app_id | ID of the SAML application |
| oauth_app_id | ID of the OAuth application |
| oauth_client_id | OAuth client ID |
| oauth_client_secret | OAuth client secret (sensitive) |
| groups | Map of created Okta groups |
| users | Map of created Okta users |
| saml_metadata_url | SAML metadata URL for the application |
| oauth_app_urls | Important OAuth application URLs |

## Examples

See the `examples/` directory for complete working examples:

- `examples/okta-integration/` - Basic Okta integration
- `examples/multi-provider/` - Multi-provider SSO with Okta

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| okta | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| okta | ~> 4.0 |

## Configuration

### Okta Provider Setup

Configure the Okta provider with your organization details:

```hcl
provider "okta" {
  org_name  = "your-okta-org"
  base_url  = "okta.com"  # or "oktapreview.com" for preview
  api_token = "your-api-token"
}
```

### Environment Variables

Set these environment variables for the Okta provider:

```bash
export OKTA_ORG_NAME=your-okta-org
export OKTA_BASE_URL=okta.com
export OKTA_API_TOKEN=your-api-token
```

## Common Use Cases

### 1. Enterprise SAML Integration
Connect enterprise applications to Okta via SAML 2.0.

### 2. Modern OAuth Applications
Secure web and mobile applications with OAuth 2.0/OpenID Connect.

### 3. API Protection
Protect APIs with OAuth 2.0 client credentials flow.

### 4. User Lifecycle Management
Automate user provisioning and group assignments.

### 5. Multi-Factor Authentication
Implement organization-wide MFA policies.

## Best Practices

### Security
1. **Enable MFA**: Always require multi-factor authentication
2. **PKCE for Public Clients**: Use PKCE for mobile and SPA applications
3. **Principle of Least Privilege**: Grant minimal necessary permissions
4. **Regular Token Rotation**: Rotate API tokens and client secrets regularly
5. **Network Restrictions**: Use network zones to restrict access

### Application Configuration
1. **Appropriate Grant Types**: Choose correct OAuth grant types for your use case
2. **Secure Redirect URIs**: Use HTTPS and validate redirect URIs
3. **Session Management**: Configure appropriate session timeouts
4. **Attribute Mapping**: Map only necessary user attributes

### User Management
1. **Automated Provisioning**: Use group rules for automatic user assignment
2. **Profile Completeness**: Ensure user profiles have necessary attributes
3. **Lifecycle Policies**: Implement user lifecycle and access review policies

## Troubleshooting

### Common Issues

1. **Authentication Failures**: Check API token permissions and expiration
2. **SAML Configuration Errors**: Verify metadata and certificate configuration
3. **OAuth Redirect Issues**: Ensure redirect URIs are properly configured
4. **Group Assignment Problems**: Check group rules and membership logic

### Debug Commands

```bash
# Test API connectivity
curl -H "Authorization: SSWS $OKTA_API_TOKEN" \
  https://$OKTA_ORG_NAME.okta.com/api/v1/org

# List applications
curl -H "Authorization: SSWS $OKTA_API_TOKEN" \
  https://$OKTA_ORG_NAME.okta.com/api/v1/apps

# Check user details
curl -H "Authorization: SSWS $OKTA_API_TOKEN" \
  https://$OKTA_ORG_NAME.okta.com/api/v1/users/user@example.com
```

### Useful Okta Admin Tasks

```bash
# Reset user password
curl -X POST -H "Authorization: SSWS $OKTA_API_TOKEN" \
  https://$OKTA_ORG_NAME.okta.com/api/v1/users/{userId}/lifecycle/reset_password

# Activate user
curl -X POST -H "Authorization: SSWS $OKTA_API_TOKEN" \
  https://$OKTA_ORG_NAME.okta.com/api/v1/users/{userId}/lifecycle/activate
``` 