# Azure AD Module

This Terraform module creates and configures Azure AD applications, service principals, groups, and enterprise SSO integrations.

## Features

- **Application Registration**: Complete Azure AD application setup
- **Service Principal**: Automatic service principal creation and configuration
- **Enterprise SSO**: SAML and OAuth integration capabilities
- **Group Management**: Security groups with role assignments
- **User Management**: Demo users for testing (optional)
- **API Permissions**: Microsoft Graph and custom API permissions
- **Administrative Units**: Organizational structure management
- **Role-Based Access**: App roles and group assignments

## Usage

### Basic Application Registration

```hcl
module "azure_ad_basic" {
  source = "../../modules/azure-ad"

  application_name        = "my-web-app"
  application_description = "My Web Application"
  sign_in_audience       = "AzureADMyOrg"

  # Basic web application settings
  web_settings = {
    homepage_url  = "https://myapp.com"
    logout_url    = "https://myapp.com/logout"
    redirect_uris = ["https://myapp.com/auth/callback"]
    implicit_grant = {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  # Create application secret
  create_application_secret = true

  tags = ["web-app", "production"]
}
```

### Enterprise Application with Groups

```hcl
module "azure_ad_enterprise" {
  source = "../../modules/azure-ad"

  application_name        = "enterprise-portal"
  application_description = "Enterprise Portal Application"
  sign_in_audience       = "AzureADMyOrg"

  # Web application configuration
  web_settings = {
    homepage_url  = "https://portal.enterprise.com"
    logout_url    = "https://portal.enterprise.com/logout"
    redirect_uris = [
      "https://portal.enterprise.com/auth/callback",
      "https://portal.enterprise.com/signin-oidc"
    ]
    implicit_grant = {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  # App roles for RBAC
  app_roles = [
    {
      allowed_member_types = ["User"]
      description          = "Administrator role with full access"
      display_name         = "Administrator"
      enabled              = true
      id                   = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
      value                = "Admin"
    },
    {
      allowed_member_types = ["User", "Application"]
      description          = "Manager role with limited access"
      display_name         = "Manager"
      enabled              = true
      id                   = "b2c3d4e5-f6g7-8901-bcde-f23456789012"
      value                = "Manager"
    },
    {
      allowed_member_types = ["User"]
      description          = "Regular user with basic access"
      display_name         = "User"
      enabled              = true
      id                   = "c3d4e5f6-g7h8-9012-cdef-345678901234"
      value                = "User"
    }
  ]

  # Required API permissions
  required_resource_access = [
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      resource_access = [
        {
          id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
          type = "Scope"
        },
        {
          id   = "b340eb25-3456-403f-be2f-af7a0d370277" # User.ReadBasic.All
          type = "Scope"
        },
        {
          id   = "06da0dbc-49e2-44d2-8312-53746be5bb00" # Directory.Read.All
          type = "Role"
        }
      ]
    }
  ]

  # Security groups
  groups = {
    "admins" = {
      display_name            = "Portal Administrators"
      description             = "Administrative access to the enterprise portal"
      security_enabled        = true
      mail_enabled            = false
      mail_nickname           = "portal-admins"
      prevent_duplicate_names = true
      assignable_to_role      = true
      owners                  = []
      members                 = []
    },
    "managers" = {
      display_name            = "Portal Managers"
      description             = "Manager access to the enterprise portal"
      security_enabled        = true
      mail_enabled            = false
      mail_nickname           = "portal-managers"
      prevent_duplicate_names = true
      assignable_to_role      = true
      owners                  = []
      members                 = []
    },
    "users" = {
      display_name            = "Portal Users"
      description             = "Standard user access to the enterprise portal"
      security_enabled        = true
      mail_enabled            = false
      mail_nickname           = "portal-users"
      prevent_duplicate_names = true
      assignable_to_role      = false
      owners                  = []
      members                 = []
    }
  }

  # Group role assignments
  group_app_role_assignments = {
    "admin-assignment" = {
      app_role_id = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
      group_key   = "admins"
    },
    "manager-assignment" = {
      app_role_id = "b2c3d4e5-f6g7-8901-bcde-f23456789012"
      group_key   = "managers"
    },
    "user-assignment" = {
      app_role_id = "c3d4e5f6-g7h8-9012-cdef-345678901234"
      group_key   = "users"
    }
  }

  # Service principal settings
  app_role_assignment_required = true
  create_application_secret   = true

  tags = ["enterprise", "production", "sso"]
}
```

### Single Page Application (SPA)

```hcl
module "azure_ad_spa" {
  source = "../../modules/azure-ad"

  application_name        = "react-spa"
  application_description = "React Single Page Application"
  sign_in_audience       = "AzureADMyOrg"

  # SPA configuration
  spa_settings = {
    redirect_uris = [
      "http://localhost:3000",
      "https://myapp.com",
      "https://myapp.com/auth/callback"
    ]
  }

  # Required permissions for SPA
  required_resource_access = [
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      resource_access = [
        {
          id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
          type = "Scope"
        },
        {
          id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
          type = "Scope"
        },
        {
          id   = "14dad69e-099b-42c9-810b-d002981feec1" # profile
          type = "Scope"
        }
      ]
    }
  ]

  tags = ["spa", "react", "development"]
}
```

### API Application with Service Principal

```hcl
module "azure_ad_api" {
  source = "../../modules/azure-ad"

  application_name        = "api-backend"
  application_description = "Backend API Application"
  sign_in_audience       = "AzureADMyOrg"

  # API permissions and scopes
  api_permissions = {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
    oauth2_permission_scopes = [
      {
        admin_consent_description  = "Allow the application to read user data"
        admin_consent_display_name = "Read user data"
        enabled                    = true
        id                         = "user.read"
        type                       = "User"
        user_consent_description   = "Allow the application to read your user data"
        user_consent_display_name  = "Read your user data"
        value                      = "user.read"
      },
      {
        admin_consent_description  = "Allow the application to write user data"
        admin_consent_display_name = "Write user data"
        enabled                    = true
        id                         = "user.write"
        type                       = "Admin"
        user_consent_description   = "Allow the application to write your user data"
        user_consent_display_name  = "Write your user data"
        value                      = "user.write"
      }
    ]
  }

  # Service accounts enabled for API
  create_application_secret = true
  
  tags = ["api", "backend", "service"]
}
```

### Demo Environment with Users

```hcl
module "azure_ad_demo" {
  source = "../../modules/azure-ad"

  application_name        = "demo-app"
  application_description = "Demo Application for Testing"
  sign_in_audience       = "AzureADMyOrg"

  # Basic web app settings
  web_settings = {
    homepage_url  = "https://demo.mycompany.com"
    logout_url    = "https://demo.mycompany.com/logout"
    redirect_uris = ["https://demo.mycompany.com/auth/callback"]
    implicit_grant = {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }

  # Groups
  groups = {
    "demo-users" = {
      display_name            = "Demo Users"
      description             = "Demo users for testing"
      security_enabled        = true
      mail_enabled            = false
      mail_nickname           = "demo-users"
      prevent_duplicate_names = true
      assignable_to_role      = false
      owners                  = []
      members                 = []
    }
  }

  # Demo users
  demo_users = {
    "test-user-1" = {
      user_principal_name   = "testuser1@yourdomain.onmicrosoft.com"
      display_name          = "Test User 1"
      given_name            = "Test"
      surname               = "User1"
      mail_nickname         = "testuser1"
      password              = "TempPassword123!"
      force_password_change = true
      usage_location        = "US"
      job_title             = "Test User"
      department            = "IT"
      company_name          = "Demo Company"
    },
    "test-user-2" = {
      user_principal_name   = "testuser2@yourdomain.onmicrosoft.com"
      display_name          = "Test User 2"
      given_name            = "Test"
      surname               = "User2"
      mail_nickname         = "testuser2"
      password              = "TempPassword123!"
      force_password_change = true
      usage_location        = "US"
      job_title             = "Test User"
      department            = "IT"
      company_name          = "Demo Company"
    }
  }

  # User group memberships
  demo_user_group_memberships = {
    "user1-membership" = {
      group_key = "demo-users"
      user_key  = "test-user-1"
    },
    "user2-membership" = {
      group_key = "demo-users"
      user_key  = "test-user-2"
    }
  }

  create_application_secret = true
  tags = ["demo", "testing"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_name | Display name for the Azure AD application | `string` | n/a | yes |
| application_description | Description for the Azure AD application | `string` | `""` | no |
| sign_in_audience | Sign-in audience for the application | `string` | `"AzureADMyOrg"` | no |
| web_settings | Web application settings | `object` | `null` | no |
| spa_settings | Single page application settings | `object` | `null` | no |
| public_client_settings | Public client settings | `object` | `null` | no |
| app_roles | List of app roles for the application | `list(object)` | `[]` | no |
| required_resource_access | Required resource access (API permissions) | `list(object)` | `[]` | no |
| groups | Map of Azure AD groups to create | `map(object)` | `{}` | no |
| demo_users | Demo users to create (for testing) | `map(object)` | `{}` | no |
| create_application_secret | Whether to create an application secret | `bool` | `false` | no |
| app_role_assignment_required | Whether app role assignment is required | `bool` | `false` | no |
| tags | Tags to assign to the resources | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| application_id | The Application (Client) ID of the Azure AD application |
| application_object_id | The Object ID of the Azure AD application |
| service_principal_id | The Object ID of the service principal |
| application_secret_value | The value of the application secret (sensitive) |
| groups | Map of created Azure AD groups |
| demo_users | Map of created demo users |
| tenant_id | The Tenant ID |
| oauth_endpoints | OAuth endpoints for the Azure AD tenant |

## Examples

See the `examples/` directory for complete working examples:

- `examples/azure-ad-sso/` - Basic Azure AD SSO setup
- `examples/multi-provider/` - Multi-provider SSO with Azure AD

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azuread | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| azuread | ~> 2.0 |

## Configuration

### Azure AD Provider Setup

Configure the Azure AD provider with your tenant details:

```hcl
provider "azuread" {
  tenant_id = "your-tenant-id"
}
```

### Environment Variables

Set these environment variables for the Azure AD provider:

```bash
export AZURE_TENANT_ID=your-tenant-id
export AZURE_CLIENT_ID=your-client-id
export AZURE_CLIENT_SECRET=your-client-secret
```

Or use Azure CLI authentication:

```bash
az login
```

## Common Use Cases

### 1. Web Application SSO
Perfect for traditional web applications requiring server-side authentication.

### 2. Single Page Applications
Ideal for React, Angular, Vue.js applications with client-side authentication.

### 3. API Protection
Secure APIs with OAuth 2.0 and role-based access control.

### 4. Enterprise Integration
Connect existing enterprise applications to Azure AD for SSO.

### 5. Multi-Tenant Applications
Support multiple Azure AD tenants with appropriate audience configuration.

## Security Best Practices

1. **Least Privilege**: Only request necessary API permissions
2. **App Role Assignment**: Enable role assignment for sensitive applications
3. **Certificate Authentication**: Use certificates instead of secrets for production
4. **Conditional Access**: Implement conditional access policies
5. **Regular Review**: Regularly review and rotate application secrets
6. **Monitoring**: Enable audit logging and monitor sign-in activities

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure you have Application Administrator or Global Administrator role
2. **API Permission Errors**: Check that required permissions are granted and admin consented
3. **Token Issues**: Verify token endpoint configuration and audience settings
4. **Group Assignment Failures**: Ensure groups exist before assigning app roles

### Debug Commands

```bash
# List applications
az ad app list --display-name "your-app-name"

# Check service principal
az ad sp list --display-name "your-app-name"

# Verify group memberships
az ad group member list --group "group-name"
``` 