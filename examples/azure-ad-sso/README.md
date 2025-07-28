# Azure AD SSO Example

This example demonstrates how to set up Azure Active Directory application registration for enterprise Single Sign-On (SSO) with OpenID Connect/OAuth 2.0.

## What This Example Creates

- **Azure AD Application Registration** with web application configuration
- **Service Principal** for the application
- **Application Roles** for role-based access control
- **Security Groups** for user organization
- **API Permissions** for Microsoft Graph access
- **OAuth 2.0/OpenID Connect** endpoints for authentication

## Features Demonstrated

### Application Registration
- **Web Application Configuration**: Redirect URIs, logout URLs, home page
- **Multi-Tenant Support**: Configurable sign-in audience
- **Application Roles**: Custom roles for RBAC
- **Branding**: Application logo and display names

### Security Features
- **OAuth 2.0 Flows**: Authorization code flow with PKCE support
- **Token Configuration**: Access tokens and ID tokens
- **API Permissions**: Microsoft Graph delegated permissions
- **Conditional Access**: Integration with Azure AD conditional access policies

### Group Management
- **Security Groups**: Organized user access control
- **Group Assignments**: Automatic role assignments
- **Nested Groups**: Hierarchical group structures

## Prerequisites

1. **Azure Subscription** with Global Administrator or Application Administrator role
2. **Azure CLI** installed and configured
3. **Terraform** >= 1.0 installed
4. **Azure AD Tenant** with appropriate permissions

### Required Azure AD Permissions

Your account needs these Azure AD roles:
- **Application Administrator** or **Global Administrator**
- **Groups Administrator** (for group management)

## Quick Start

### 1. Login to Azure

```bash
az login
```

### 2. Get Tenant Information

```bash
# Get your tenant ID
az account show --query tenantId -o tsv

# Verify permissions
az ad signed-in-user show --query '{displayName:displayName, userPrincipalName:userPrincipalName}'
```

### 3. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your tenant ID and settings
```

### 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 5. Test the Setup

```bash
# Get application details
terraform output application_id
terraform output oauth2_authorization_url

# Test OpenID Connect configuration
curl $(terraform output -raw openid_configuration_url)
```

## Configuration Examples

### Basic Web Application

```hcl
application_name = "my-enterprise-app"
sign_in_audience = "AzureADMyOrg"

web_settings = {
  redirect_uris = [
    "https://myapp.com/auth/callback",
    "https://myapp.com/signin-oidc"
  ]
  logout_url    = "https://myapp.com/signout-oidc"
  home_page_url = "https://myapp.com"
}
```

### Multi-Tenant Application

```hcl
sign_in_audience = "AzureADMultipleOrgs"  # Support multiple Azure AD tenants

required_resource_access = [
  {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access = [
      {
        id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
        type = "Scope"
      }
    ]
  }
]
```

### Role-Based Access Control

```hcl
app_roles = [
  {
    display_name = "Global Administrator"
    description  = "Global administrators with full system access"
    value        = "GlobalAdmin"
    allowed_member_types = ["User"]
  },
  {
    display_name = "Department Manager"
    description  = "Managers with departmental access"
    value        = "DeptManager"
    allowed_member_types = ["User"]
  }
]
```

## Integration Examples

### ASP.NET Core Integration

```csharp
// Startup.cs
services.AddAuthentication(OpenIdConnectDefaults.AuthenticationScheme)
    .AddMicrosoftIdentityWebApp(options =>
    {
        options.ClientId = "your-application-id";
        options.TenantId = "your-tenant-id";
        options.Instance = "https://login.microsoftonline.com/";
    });
```

### Node.js Integration

```javascript
// Using passport-azure-ad
const BearerStrategy = require('passport-azure-ad').BearerStrategy;

const options = {
    identityMetadata: 'https://login.microsoftonline.com/your-tenant-id/v2.0/.well-known/openid_configuration',
    clientID: 'your-application-id',
    validateIssuer: true,
    audience: 'your-application-id'
};

passport.use(new BearerStrategy(options, (token, done) => {
    // Token validation logic
    return done(null, token);
}));
```

### React SPA Integration

```javascript
// Using @azure/msal-react
import { PublicClientApplication } from "@azure/msal-browser";

const msalConfig = {
    auth: {
        clientId: "your-application-id",
        authority: "https://login.microsoftonline.com/your-tenant-id",
        redirectUri: "https://yourapp.com/auth/callback"
    }
};

const msalInstance = new PublicClientApplication(msalConfig);
```

## Testing Your Setup

### 1. Test Authentication Flow

```bash
# Get authorization URL
AUTH_URL=$(terraform output -raw oauth2_authorization_url)
echo "Visit: $AUTH_URL?client_id=$(terraform output -raw application_id)&response_type=code&redirect_uri=https://yourapp.com/callback&scope=openid"
```

### 2. Test API Permissions

```bash
# Get access token (requires additional setup)
az account get-access-token --resource=https://graph.microsoft.com --query accessToken -o tsv
```

### 3. Verify Group Membership

```bash
# List created groups
az ad group list --query "[?displayName=='Enterprise App Users'].{Name:displayName,ObjectId:objectId}" -o table
```

## Common Configurations

### Single Page Application (SPA)

```hcl
# Additional configuration for SPA
web_settings = {
  redirect_uris = [
    "https://yourapp.com",
    "https://localhost:3000"
  ]
}

# Enable implicit flow for SPA
oauth2_allow_implicit_flow = true
```

### API Application

```hcl
# For API protection
required_resource_access = [
  {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access = [
      {
        id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Directory.Read.All
        type = "Role"
      }
    ]
  }
]
```

## Troubleshooting

### Common Issues

#### Issue: "Insufficient privileges"
```bash
# Solution: Ensure you have Application Administrator role
az role assignment list --assignee $(az ad signed-in-user show --query objectId -o tsv)
```

#### Issue: "Reply URL mismatch"
```bash
# Solution: Ensure redirect URIs match exactly
# Check your application's redirect URI configuration
```

#### Issue: "Invalid client"
```bash
# Solution: Verify application ID and ensure app is enabled
terraform output application_id
```

### Debug Commands

```bash
# List all app registrations
az ad app list --query "[].{DisplayName:displayName,AppId:appId}" -o table

# Show specific application details
az ad app show --id $(terraform output -raw application_id)

# Check service principal
az ad sp show --id $(terraform output -raw service_principal_id)
```

## Production Considerations

### Security Hardening

1. **Certificate Authentication**: Use certificate-based authentication for production
2. **Conditional Access**: Implement conditional access policies
3. **Privileged Identity Management**: Use PIM for admin roles
4. **Regular Access Reviews**: Implement periodic access reviews

### Compliance

1. **Audit Logging**: Enable Azure AD audit logs
2. **Data Residency**: Configure appropriate data residency settings
3. **Backup Strategy**: Implement configuration backup procedures

## Cleanup

```bash
terraform destroy
```

**Note**: This will remove all created applications, service principals, and groups.

## Next Steps

1. **Multi-Provider Integration**: Check the `multi-provider` example
2. **Advanced Security**: Implement conditional access policies
3. **B2B Collaboration**: Set up external partner access
4. **Graph API Integration**: Build custom applications using Microsoft Graph

## Support

- **Azure AD Documentation**: [Microsoft Identity Platform](https://docs.microsoft.com/en-us/azure/active-directory/develop/)
- **Issues**: [GitHub Issues](https://github.com/sourabh-virdi/terraform-idp-automation/issues)
- **Community**: [GitHub Discussions](https://github.com/sourabh-virdi/terraform-idp-automation/discussions) 