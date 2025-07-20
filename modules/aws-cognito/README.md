# AWS Cognito Module

This Terraform module creates and configures AWS Cognito User Pools and Identity Pools with SAML integration support.

## Features

- **User Pool**: Complete user pool configuration with customizable password policies
- **User Pool Client**: OAuth 2.0/OpenID Connect client configuration
- **SAML Integration**: Support for multiple SAML identity providers
- **Identity Pool**: AWS credential federation for authenticated users
- **IAM Roles**: Automatic creation of authenticated and unauthenticated roles
- **Domain Support**: Custom domain configuration for hosted UI
- **Security**: Advanced security features and token management

## Usage

### Basic User Pool

```hcl
module "cognito" {
  source = "../../modules/aws-cognito"

  user_pool_name = "my-app-users"
  client_name    = "my-app-client"

  callback_urls = ["https://myapp.com/callback"]
  logout_urls   = ["https://myapp.com/logout"]

  tags = {
    Environment = "production"
    Project     = "my-app"
  }
}
```

### User Pool with SAML Provider

```hcl
module "cognito_saml" {
  source = "../../modules/aws-cognito"

  user_pool_name = "enterprise-users"
  client_name    = "enterprise-client"

  # SAML configuration
  saml_providers = {
    "AzureAD" = {
      provider_name             = "AzureAD"
      metadata_url             = "https://login.microsoftonline.com/tenant-id/federationmetadata/2007-06/federationmetadata.xml"
      sso_redirect_binding_uri = "https://login.microsoftonline.com/tenant-id/saml2"
      slo_redirect_binding_uri = "https://login.microsoftonline.com/tenant-id/saml2"
      attribute_mapping = {
        email    = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        username = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      }
    }
  }

  callback_urls = ["https://myapp.com/callback"]
  logout_urls   = ["https://myapp.com/logout"]
}
```

### User Pool with Identity Pool

```hcl
module "cognito_with_identity" {
  source = "../../modules/aws-cognito"

  user_pool_name = "mobile-app-users"
  client_name    = "mobile-app-client"

  # Enable identity pool for AWS credentials
  create_identity_pool             = true
  identity_pool_name              = "mobile-app-identity"
  allow_unauthenticated_identities = false

  callback_urls = ["myapp://callback"]
  logout_urls   = ["myapp://logout"]
}
```

### Complete Configuration with Custom Domain

```hcl
module "cognito_complete" {
  source = "../../modules/aws-cognito"

  user_pool_name = "production-users"
  client_name    = "production-client"

  # Custom domain
  domain_name            = "auth.mycompany.com"
  domain_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/certificate-id"

  # Security settings
  advanced_security_mode = "ENFORCED"
  
  password_policy = {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # OAuth configuration
  allowed_oauth_flows  = ["code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]
  callback_urls        = ["https://myapp.com/callback"]
  logout_urls          = ["https://myapp.com/logout"]

  # Token configuration
  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 30

  # SAML providers
  saml_providers = {
    "CompanyAD" = {
      provider_name             = "CompanyAD"
      metadata_url             = "https://adfs.company.com/FederationMetadata/2007-06/FederationMetadata.xml"
      sso_redirect_binding_uri = "https://adfs.company.com/adfs/ls/"
      slo_redirect_binding_uri = "https://adfs.company.com/adfs/ls/"
      attribute_mapping = {
        email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        name  = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
      }
    }
  }

  # Identity pool
  create_identity_pool             = true
  identity_pool_name              = "production-identity"
  allow_unauthenticated_identities = false

  tags = {
    Environment = "production"
    Project     = "my-app"
    Team        = "platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| user_pool_name | Name of the Cognito User Pool | `string` | n/a | yes |
| client_name | Name of the Cognito User Pool Client | `string` | n/a | yes |
| password_policy | Password policy for the user pool | `object` | `{minimum_length=8, require_lowercase=true, require_numbers=true, require_symbols=true, require_uppercase=true}` | no |
| advanced_security_mode | Advanced security mode for the user pool | `string` | `"ENFORCED"` | no |
| auto_verified_attributes | Attributes to be auto-verified | `list(string)` | `["email"]` | no |
| domain_name | Domain name for the user pool | `string` | `null` | no |
| domain_certificate_arn | ACM certificate ARN for custom domain | `string` | `null` | no |
| saml_providers | Map of SAML identity providers | `map(object)` | `{}` | no |
| create_identity_pool | Whether to create a Cognito Identity Pool | `bool` | `false` | no |
| callback_urls | List of allowed callback URLs | `list(string)` | `[]` | no |
| logout_urls | List of allowed logout URLs | `list(string)` | `[]` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| user_pool_id | ID of the Cognito User Pool |
| user_pool_arn | ARN of the Cognito User Pool |
| user_pool_client_id | ID of the Cognito User Pool Client |
| user_pool_client_secret | Secret of the Cognito User Pool Client |
| identity_pool_id | ID of the Cognito Identity Pool |
| authenticated_role_arn | ARN of the authenticated IAM role |
| oauth_urls | OAuth-related URLs for the User Pool |

## Examples

See the `examples/` directory for complete working examples:

- `examples/aws-cognito-saml/` - Basic SAML integration
- `examples/multi-provider/` - Multi-provider SSO setup

## Providers

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |