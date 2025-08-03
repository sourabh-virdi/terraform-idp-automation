# Okta Integration Example

This example demonstrates how to set up Okta for SAML 2.0 and OAuth/OIDC integration with enterprise applications.

## What This Example Creates

- **SAML 2.0 Application** for enterprise SSO
- **OAuth/OIDC Application** for modern web/mobile apps
- **Okta Groups** for user organization and access control
- **User Assignments** and group memberships
- **Attribute Mapping** for SAML assertions
- **Authentication Policies** for security controls

## Features Demonstrated

### SAML 2.0 Integration
- **SAML Application Configuration**: SSO URL, audience, destination
- **Attribute Statements**: Custom attribute mapping
- **Metadata Generation**: Automatic SAML metadata
- **Group-Based Access**: Role assignments through groups

### OAuth/OIDC Integration
- **Multiple App Types**: Web, native, browser, service applications
- **PKCE Support**: Proof Key for Code Exchange for security
- **Custom Scopes**: Application-specific permissions
- **Token Management**: Access and refresh token configuration

### User Management
- **Group Organization**: Hierarchical group structures
- **Automatic Assignments**: Rule-based user assignments
- **Lifecycle Management**: User provisioning and deprovisioning

## Prerequisites

1. **Okta Organization** with Super Admin access
2. **Okta API Token** with appropriate scopes
3. **Terraform** >= 1.0 installed
4. **Application Domain** for callback URLs

### Required Okta Permissions

Your API token needs these permissions:
- **Super Admin** (recommended) or specific admin roles:
  - **Application Administrator**
  - **Group Administrator**
  - **User Administrator**

## Quick Start

### 1. Get Okta API Token

```bash
# Login to Okta Admin Console
# Go to Security → API → Tokens
# Create new token with Super Admin permissions
```

### 2. Configure Environment Variables

```bash
export OKTA_ORG_NAME="sourabh-virdi-name"
export OKTA_BASE_URL="okta.com"
export OKTA_API_TOKEN="your-api-token"
```

### 3. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
```

### 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 5. Test the Setup

```bash
# Get SAML metadata
curl $(terraform output -raw saml_metadata_url)

# Test OAuth endpoints
curl $(terraform output -raw openid_configuration_url)
```

## Configuration Examples

### SAML 2.0 Application

```hcl
create_saml_app = true
app_name        = "enterprise-portal"
sso_url         = "https://portal.company.com/saml/acs"
audience        = "https://portal.company.com"
destination     = "https://portal.company.com/saml/acs"

attribute_statements = [
  {
    type      = "EXPRESSION"
    name      = "email"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.email"]
  },
  {
    type      = "EXPRESSION"
    name      = "roles"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["Arrays.contains(user.groups, \"Administrators\") ? \"admin\" : \"user\""]
  }
]
```

### OAuth/OIDC Application

```hcl
create_oauth_app = true
oauth_app_type   = "web"
redirect_uris = [
  "https://app.company.com/auth/callback"
]
post_logout_redirect_uris = [
  "https://app.company.com/logout"
]
```

### Mobile Application

```hcl
create_oauth_app = true
oauth_app_type   = "native"
redirect_uris = [
  "com.company.app://callback",
  "https://app.company.com/mobile/callback"
]
```

## Integration Examples

### Java Spring Boot Integration

```java
// application.yml
spring:
  security:
    oauth2:
      client:
        registration:
          okta:
            client-id: ${OKTA_CLIENT_ID}
            client-secret: ${OKTA_CLIENT_SECRET}
            scope: openid,profile,email
        provider:
          okta:
            issuer-uri: https://sourabh-virdi.okta.com/oauth2/default
```

### Node.js Express Integration

```javascript
// Using passport-saml
const SamlStrategy = require('passport-saml').Strategy;

passport.use(new SamlStrategy({
    entryPoint: 'https://sourabh-virdi.okta.com/app/your-app-id/sso/saml',
    issuer: 'https://your-app.com',
    cert: fs.readFileSync('path/to/cert.pem', 'utf8')
}, (profile, done) => {
    // Process SAML assertion
    return done(null, profile);
}));
```

### React SPA Integration

```javascript
// Using @okta/okta-react
import { OktaAuth } from '@okta/okta-auth-js';
import { Security } from '@okta/okta-react';

const oktaAuth = new OktaAuth({
    issuer: 'https://sourabh-virdi.okta.com/oauth2/default',
    clientId: 'your-client-id',
    redirectUri: window.location.origin + '/callback'
});

function App() {
    return (
        <Security oktaAuth={oktaAuth}>
            {/* Your app components */}
        </Security>
    );
}
```

### .NET Core Integration

```csharp
// Startup.cs
services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://sourabh-virdi.okta.com/oauth2/default";
        options.Audience = "api://your-api-identifier";
    });
```

## Testing Your Setup

### 1. Test SAML Application

```bash
# Get SAML metadata
METADATA_URL=$(terraform output -raw saml_metadata_url)
curl -s $METADATA_URL | xmllint --format -

# Test SSO URL
SSO_URL=$(terraform output -raw saml_sso_url)
echo "SAML SSO URL: $SSO_URL"
```

### 2. Test OAuth Application

```bash
# Get OAuth endpoints
terraform output oauth_authorization_url
terraform output oauth_token_url

# Test OpenID configuration
curl $(terraform output -raw openid_configuration_url) | jq
```

### 3. Test User Assignment

```bash
# Check group memberships (requires Okta CLI or API calls)
# okta groups list-users --groupId $(terraform output -json group_ids | jq -r '.["app-users"]')
```

## Advanced Configuration

### Conditional Authentication

```hcl
signon_policies = {
  "mfa-policy" = {
    name        = "MFA Required Policy"
    description = "Require MFA for all users"
    priority    = 1
    type        = "OKTA_SIGN_ON"
  }
}
```

### Dynamic Group Rules

```hcl
# In Okta console or via API
# Create group rules for automatic user assignment
```

### Custom Attribute Mapping

```hcl
attribute_statements = [
  {
    type      = "EXPRESSION"
    name      = "department"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    values    = ["user.department"]
  },
  {
    type      = "EXPRESSION"
    name      = "customRole"
    namespace = "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"
    values    = ["user.customAttribute"]
  }
]
```

## Security Best Practices

### SAML Security

1. **Certificate Management**: Regularly rotate signing certificates
2. **Assertion Encryption**: Enable assertion encryption for sensitive data
3. **Audience Validation**: Ensure proper audience validation
4. **Time-based Controls**: Configure appropriate assertion timeouts

### OAuth Security

1. **PKCE**: Always use PKCE for public clients
2. **State Parameter**: Implement CSRF protection
3. **Token Validation**: Properly validate all tokens
4. **Scope Limitation**: Use minimal necessary scopes

## Troubleshooting

### Common Issues

#### Issue: "SAML assertion failed"
```bash
# Check SAML configuration
curl -s $(terraform output -raw saml_metadata_url) | grep -E "(entityID|Location)"

# Verify application configuration matches metadata
```

#### Issue: "OAuth redirect_uri mismatch"
```bash
# Ensure redirect URIs match exactly
terraform output oauth_app_id
# Check in Okta console: Applications → Your App → General → Login
```

#### Issue: "Token validation failed"
```bash
# Verify issuer and audience
curl $(terraform output -raw openid_configuration_url) | jq '.issuer'
```

### Debug Commands

```bash
# List all applications
# okta apps list

# Get specific application details
# okta apps get $(terraform output -raw saml_app_id)

# List groups
# okta groups list
```

## Monitoring and Maintenance

### Health Checks

```bash
# Test SAML metadata availability
curl -f $(terraform output -raw saml_metadata_url) > /dev/null && echo "SAML metadata OK"

# Test OAuth configuration
curl -f $(terraform output -raw openid_configuration_url) > /dev/null && echo "OAuth config OK"
```

### Certificate Rotation

```bash
# Monitor certificate expiration
# Set up alerts for certificate expiration (90 days before)
```

## Production Considerations

### High Availability

1. **Multiple Applications**: Deploy in multiple Okta orgs for redundancy
2. **Certificate Backup**: Maintain secure certificate backups
3. **Configuration Backup**: Regular configuration exports

### Compliance

1. **Audit Logging**: Enable comprehensive audit logging
2. **Access Reviews**: Regular access certification
3. **Policy Enforcement**: Implement strong authentication policies

### Performance

1. **Connection Pooling**: Optimize API connections
2. **Caching**: Cache SAML metadata and OAuth configuration
3. **Rate Limiting**: Respect Okta rate limits

## Cleanup

```bash
terraform destroy
```

**Note**: This will remove all applications, groups, and user assignments.

## Next Steps

1. **Multi-Provider Integration**: Check the `multi-provider` example
2. **Advanced Policies**: Implement adaptive authentication
3. **API Integration**: Build custom workflows with Okta APIs
4. **Mobile Apps**: Configure mobile application integration

## Support

- **Okta Documentation**: [Okta Developer Docs](https://developer.okta.com/)
- **SAML Toolkit**: [SAML Developer Tools](https://www.samltool.com/)
- **Issues**: [GitHub Issues](https://github.com/sourabh-virdi/terraform-idp-automation/issues)
- **Community**: [GitHub Discussions](https://github.com/sourabh-virdi/terraform-idp-automation/discussions) 