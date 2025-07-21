# AWS Cognito Basic Example

This example demonstrates how to set up a basic AWS Cognito User Pool with essential features for web and mobile application authentication.

## What This Example Creates

- **Cognito User Pool** with customizable password policies
- **User Pool Client** configured for web/mobile applications
- **Hosted UI** for authentication flows
- **Multi-Factor Authentication** (MFA) configuration
- **Advanced Security Features** including risk detection
- **OAuth 2.0/OpenID Connect** endpoints
- **Optional Identity Pool** for AWS credential federation

## Features Demonstrated

### Authentication Features
- **Username/Email Authentication**: Users can sign in with username or email
- **OAuth 2.0 Flows**: Authorization code, implicit, and client credentials flows
- **Hosted UI**: Pre-built, customizable authentication pages
- **Password Policies**: Configurable complexity requirements
- **Account Recovery**: Email-based password reset

### Security Features
- **Multi-Factor Authentication**: TOTP (software tokens) and SMS options
- **Advanced Security**: Risk-based authentication and anomaly detection
- **Secure Token Handling**: JWT tokens with configurable expiration
- **Brute Force Protection**: Automatic account lockout on repeated failures

### Integration Features
- **CORS Configuration**: For web application integration
- **Custom Domains**: Optional custom authentication domains
- **Lambda Triggers**: Extensibility points for custom logic
- **CloudWatch Monitoring**: Built-in logging and metrics

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.0 installed
4. **IAM Permissions** for Cognito operations:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "cognito-idp:*",
           "cognito-identity:*"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

## Quick Start

### 1. Configure AWS Credentials

```bash
# Option 1: AWS CLI
aws configure

# Option 2: Environment Variables
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1
```

### 2. Clone and Navigate

```bash
git clone https://github.com/sourabh-virdi/terraform-idp-automation.git
cd terraform-idp-automation/examples/aws-cognito-basic
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

After deployment, you'll receive outputs including:

```bash
# View outputs
terraform output

# Example outputs:
user_pool_id = "us-east-1_XXXXXXXXX"
user_pool_client_id = "abcdef123456789"
hosted_ui_url = "https://my-app-users.auth.us-east-1.amazoncognito.com"
```

Visit the `hosted_ui_url` to test the authentication flow.

## Configuration Options

### Basic Configuration

```hcl
# Required settings
user_pool_name = "my-app-users"
client_name    = "my-app-client"
environment    = "dev"

# Application URLs
callback_urls = ["https://myapp.com/auth/callback"]
logout_urls   = ["https://myapp.com/logout"]
```

### Password Policy

```hcl
password_policy = {
  minimum_length    = 12        # 8-128 characters
  require_lowercase = true      # a-z required
  require_uppercase = true      # A-Z required
  require_numbers   = true      # 0-9 required
  require_symbols   = false     # Special characters
}
```

### Multi-Factor Authentication

```hcl
mfa_configuration          = "REQUIRED"  # OFF, OPTIONAL, REQUIRED
software_token_mfa_enabled = true        # TOTP apps like Authy
sms_mfa_enabled           = true         # SMS verification
```

### Advanced Security

```hcl
advanced_security_mode = "ENFORCED"  # OFF, AUDIT, ENFORCED

# AUDIT: Logs security events
# ENFORCED: Blocks suspicious activities
```

### Custom Domain (Optional)

```hcl
domain_name = "auth.mycompany.com"

# Requires:
# 1. Domain ownership verification
# 2. SSL certificate in ACM
# 3. DNS configuration
```

### Identity Pool Integration (Optional)

```hcl
create_identity_pool = true
identity_pool_name   = "my-app-identity"

# Enables:
# - AWS credential federation
# - Temporary AWS access for authenticated users
# - Integration with AWS services
```

## Testing Your Setup

### 1. Test Hosted UI

```bash
# Get the hosted UI URL
HOSTED_UI_URL=$(terraform output -raw hosted_ui_url)
echo "Open this URL to test: $HOSTED_UI_URL"
```

### 2. Test OAuth Endpoints

```bash
# Authorization endpoint
curl -I "$(terraform output -json oauth_endpoints | jq -r '.authorization_endpoint')"

# Token endpoint
curl -I "$(terraform output -json oauth_endpoints | jq -r '.token_endpoint')"
```

### 3. Create Test User (AWS CLI)

```bash
USER_POOL_ID=$(terraform output -raw user_pool_id)

# Create a test user
aws cognito-idp admin-create-user \
  --user-pool-id $USER_POOL_ID \
  --username testuser \
  --user-attributes Name=email,Value=test@example.com \
  --message-action SUPPRESS \
  --temporary-password TempPass123!

# Set permanent password
aws cognito-idp admin-set-user-password \
  --user-pool-id $USER_POOL_ID \
  --username testuser \
  --password Password123! \
  --permanent
```

## Integration Examples

### Web Application Integration

```javascript
// Example: React application integration
import { CognitoAuth } from 'amazon-cognito-auth-js';

const authConfig = {
  clientId: 'your-client-id',
  appWebDomain: 'your-domain.auth.region.amazoncognito.com',
  scope: 'openid email profile',
  redirectSignIn: 'https://yourapp.com/callback',
  redirectSignOut: 'https://yourapp.com/logout',
  responseType: 'code'
};

const auth = new CognitoAuth(authConfig);
```

### Mobile Application Integration

```swift
// Example: iOS Swift integration
import AWSCognito

let serviceConfiguration = AWSServiceConfiguration(
    region: .USEast1,
    credentialsProvider: nil
)

let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
    clientId: "your-client-id",
    clientSecret: nil,
    poolId: "your-pool-id"
)

AWSCognitoIdentityUserPool.register(
    with: serviceConfiguration,
    userPoolConfiguration: poolConfiguration,
    forKey: "UserPool"
)
```

## Monitoring and Troubleshooting

### CloudWatch Metrics

Monitor these key metrics in CloudWatch:

- `SignInSuccesses` - Successful sign-ins
- `SignInThrottles` - Throttled sign-in attempts
- `TokenRefreshSuccesses` - Token refresh operations
- `UserCreations` - New user registrations

### Common Issues

#### Issue: "User pool domain already exists"
```bash
# Solution: Use a unique domain prefix
domain_name = "my-unique-app-auth"
```

#### Issue: "Invalid redirect URI"
```bash
# Solution: Ensure callback URLs match exactly
callback_urls = [
  "https://yourapp.com/auth/callback"  # Must match your app
]
```

#### Issue: "Token validation failed"
```bash
# Solution: Check token expiration settings
# Tokens expire by default after 1 hour
```

### Debug Mode

Enable detailed logging:

```bash
export TF_LOG=DEBUG
terraform apply
```

## Advanced Customization

### Lambda Triggers

```hcl
lambda_triggers = {
  pre_sign_up               = "arn:aws:lambda:region:account:function:pre-signup"
  post_confirmation         = "arn:aws:lambda:region:account:function:post-confirm"
  pre_authentication        = "arn:aws:lambda:region:account:function:pre-auth"
  post_authentication       = "arn:aws:lambda:region:account:function:post-auth"
  pre_token_generation      = "arn:aws:lambda:region:account:function:pre-token"
  custom_message            = "arn:aws:lambda:region:account:function:custom-message"
  define_auth_challenge     = "arn:aws:lambda:region:account:function:define-auth"
  create_auth_challenge     = "arn:aws:lambda:region:account:function:create-auth"
  verify_auth_challenge     = "arn:aws:lambda:region:account:function:verify-auth"
}
```

### Custom Attributes

Add custom user attributes for your application needs.

### Branding and UI Customization

Customize the hosted UI with your brand colors, logo, and styling.

## Production Considerations

### Security Hardening

1. **Enable MFA**: Set `mfa_configuration = "REQUIRED"`
2. **Advanced Security**: Set `advanced_security_mode = "ENFORCED"`
3. **Strong Passwords**: Increase `minimum_length` to 12+
4. **Custom Domain**: Use your own domain for branding and security

### Scaling Considerations

1. **Rate Limits**: Plan for Cognito service limits
2. **Regional Deployment**: Consider multi-region setup
3. **Backup Strategy**: Export user data regularly
4. **Monitoring**: Set up CloudWatch alarms

### Cost Optimization

1. **Monthly Active Users**: Cognito charges per MAU
2. **SMS Costs**: MFA via SMS incurs additional charges
3. **Advanced Security**: Additional cost for risk detection

## Cleanup

```bash
terraform destroy
```

**Warning**: This will delete all users and authentication data. Ensure you have backups if needed.

## Next Steps

1. **Explore Multi-Provider**: Check the `multi-provider` example
2. **Add SAML Integration**: See the `aws-cognito-saml` example
3. **Lambda Customization**: Implement custom authentication flows
4. **Production Deployment**: Review the production checklist

## Support

- **Documentation**: [AWS Cognito Developer Guide](https://docs.aws.amazon.com/cognito/latest/developerguide/)
- **Issues**: [GitHub Issues](https://github.com/sourabh-virdi/terraform-idp-automation/issues)
- **Community**: [GitHub Discussions](https://github.com/sourabh-virdi/terraform-idp-automation/discussions) 