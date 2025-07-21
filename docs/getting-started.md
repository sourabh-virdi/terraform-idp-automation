---
layout: default
title: Getting Started
nav_order: 2
description: "Complete guide to get started with Terraform IdP Automation"
---

# Getting Started
{: .no_toc }

This guide will help you get up and running with Terraform IdP Automation in minutes.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 🎯 Overview

Terraform IdP Automation enables you to manage identity providers using Infrastructure as Code. Whether you're setting up AWS Cognito for a web application, Azure AD for enterprise SSO, or building a complete multi-provider identity federation, this platform has you covered.

## 📋 Prerequisites

Before you begin, ensure you have the following tools and access:

### Required Tools

- **[Terraform](https://terraform.io/downloads)** >= 1.0
- **[Git](https://git-scm.com/downloads)**
- **[AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** (for AWS Cognito)
- **[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)** (for Azure AD)

### Account Access

You'll need access to at least one of the following:

- **AWS Account** with IAM permissions for Cognito and Identity Pools
- **Azure AD Tenant** with Global Administrator or Application Administrator role
- **Okta Organization** with Super Admin API access
- **Keycloak Server** with admin access

## 🚀 Quick Start (5 Minutes)

### Step 1: Clone the Repository

```bash
git clone https://github.com/sourabh-virdi/terraform-idp-automation.git
cd terraform-idp-automation
```

### Step 2: Choose Your Starting Point

We recommend starting with AWS Cognito as it's the most straightforward:

```bash
cd examples/aws-cognito-basic
```

### Step 3: Configure Your Environment

Copy the example configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your settings:

```hcl
# Basic AWS Cognito configuration
user_pool_name = "my-app-users"
client_name    = "my-app-client"
environment    = "dev"

# Application URLs
callback_urls = ["https://localhost:3000/callback"]
logout_urls   = ["https://localhost:3000/logout"]

# Tags
tags = {
  Environment = "development"
  Project     = "my-app"
  Team        = "engineering"
}
```

### Step 4: Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

🎉 **Congratulations!** You now have a fully configured AWS Cognito User Pool.

### Step 5: Test Your Setup

After deployment, Terraform will output important information:

```bash
terraform output
```

You'll see outputs like:

```
user_pool_id = "us-east-1_ABC123DEF"
user_pool_client_id = "abcdef123456789"
hosted_ui_url = "https://my-app-users.auth.us-east-1.amazoncognito.com"
```

## 🔧 Detailed Setup

### AWS Cognito Setup

#### 1. Configure AWS Credentials

```bash
# Option 1: AWS CLI
aws configure

# Option 2: Environment Variables
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1
```

#### 2. Required IAM Permissions

Create an IAM policy with these permissions:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:*",
                "cognito-identity:*",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:GetRole",
                "iam:DeleteRole",
                "iam:DetachRolePolicy"
            ],
            "Resource": "*"
        }
    ]
}
```

#### 3. Example Configuration

```hcl
module "cognito" {
  source = "../../modules/aws-cognito"

  user_pool_name = "my-application-users"
  client_name    = "my-application-client"

  # Password policy
  password_policy = {
    minimum_length    = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }

  # Advanced security
  advanced_security_mode = "ENFORCED"

  # MFA configuration
  mfa_configuration = "OPTIONAL"
  software_token_mfa_enabled = true
  sms_mfa_enabled = true

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### Azure AD Setup

#### 1. Login to Azure

```bash
az login
```

#### 2. Set Environment Variables

```bash
export AZURE_TENANT_ID=your-tenant-id
export AZURE_CLIENT_ID=your-client-id
export AZURE_CLIENT_SECRET=your-client-secret
```

#### 3. Example Configuration

```hcl
module "azure_ad" {
  source = "../../modules/azure-ad"

  application_name = "my-enterprise-app"
  sign_in_audience = "AzureADMyOrg"

  # Web application settings
  web_settings = {
    redirect_uris = [
      "https://myapp.com/auth/callback",
      "https://myapp.com/signin-oidc"
    ]
    logout_url = "https://myapp.com/signout-oidc"
  }

  # Required permissions
  required_resource_access = [
    {
      resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
      resource_access = [
        {
          id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
          type = "Scope"
        }
      ]
    }
  ]
}
```

### Okta Setup

#### 1. Get API Token

1. Login to Okta Admin Console
2. Go to Security → API → Tokens
3. Create new token with Super Admin permissions

#### 2. Set Environment Variables

```bash
export OKTA_ORG_NAME=your-okta-org
export OKTA_BASE_URL=okta.com
export OKTA_API_TOKEN=your-api-token
```

#### 3. Example Configuration

```hcl
module "okta" {
  source = "../../modules/okta"

  app_name        = "my-saml-app"
  app_description = "My SAML Application"

  # SAML configuration
  create_saml_app = true
  sso_url         = "https://myapp.com/saml/acs"
  audience        = "https://myapp.com"

  # Attribute mapping
  attribute_statements = [
    {
      type      = "EXPRESSION"
      name      = "email"
      namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
      values    = ["user.email"]
    }
  ]
}
```

## 🔗 Multi-Provider Integration

One of the most powerful features is the ability to integrate multiple identity providers:

```bash
cd examples/multi-provider
```

Configure multiple providers:

```hcl
# Multi-provider configuration
module "multi_provider_sso" {
  source = "../../examples/multi-provider"

  # Environment settings
  environment       = "dev"
  organization_name = "MyCompany"
  domain_name      = "mycompany.com"

  # Provider settings
  okta_org_name = "mycompany-dev"
  
  # Application URLs
  app_homepage_url = "https://app-dev.mycompany.com"
  callback_urls = [
    "https://app-dev.mycompany.com/auth/callback"
  ]

  # Enable providers
  enable_cognito_integration = true
  enable_azure_ad_integration = true
  enable_okta_integration = true
}
```

This creates:
- AWS Cognito as the central authentication hub
- Azure AD SAML integration
- Okta SAML integration
- Cross-provider user attribute mapping

## 📚 Next Steps

### 1. Explore Examples

Check out our comprehensive examples:

```bash
# Basic single-provider examples
ls examples/

# Try different configurations
cd examples/okta-oauth
terraform init && terraform plan
```

### 2. Read Module Documentation

Each module has detailed documentation:

- [AWS Cognito Module](modules/aws-cognito)
- [Azure AD Module](modules/azure-ad)
- [Okta Module](modules/okta)
- [Keycloak Module](modules/keycloak)

### 3. Production Deployment

For production deployments:

1. **Use Remote State**: Configure S3 backend with DynamoDB locking
2. **Environment Separation**: Separate dev/staging/prod configurations
3. **Security Hardening**: Enable advanced security features
4. **Monitoring**: Set up CloudWatch dashboards and alerts

```hcl
# Production backend configuration
terraform {
  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "idp-automation/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 4. CI/CD Integration

Set up automated deployments:

```yaml
# .github/workflows/deploy.yml
name: Deploy IdP Infrastructure

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
      - name: Terraform Apply
        run: |
          terraform init
          terraform apply -auto-approve
```

## 🛠️ Customization

### Custom Domains

```hcl
# Custom domain for Cognito
module "cognito" {
  source = "../../modules/aws-cognito"
  
  # ... other configuration
  
  domain_name = "auth.mycompany.com"
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."
}
```

### Custom Themes

```hcl
# Custom Keycloak theme
module "keycloak" {
  source = "../../modules/keycloak"
  
  # ... other configuration
  
  themes = {
    login_theme = "my-custom-theme"
    admin_theme = "my-admin-theme"
  }
}
```

### Advanced Security

```hcl
# Advanced security configuration
module "cognito" {
  source = "../../modules/aws-cognito"
  
  # ... other configuration
  
  # Risk configuration
  risk_configuration = {
    compromised_credentials_risk_configuration = {
      actions = {
        event_action = "BLOCK"
      }
    }
    account_takeover_risk_configuration = {
      actions = {
        high_action = {
          event_action = "MFA_IF_CONFIGURED"
          notify       = true
        }
      }
    }
  }
}
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Authentication Errors

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Azure login
az account show

# Test Okta API
curl -H "Authorization: SSWS $OKTA_API_TOKEN" \
  https://$OKTA_ORG_NAME.okta.com/api/v1/org
```

#### 2. Terraform State Issues

```bash
# Refresh state
terraform refresh

# Import existing resources
terraform import module.cognito.aws_cognito_user_pool.main us-east-1_XXXXXXXXX
```

#### 3. Permission Errors

- Verify IAM roles and policies for AWS
- Check Azure AD roles and permissions
- Validate Okta API token scope

### Getting Help

- **Documentation**: Check our [comprehensive docs](/)
- **Examples**: Browse [working examples](examples/)
- **Issues**: Report bugs on [GitHub Issues](https://github.com/sourabh-virdi/terraform-idp-automation/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/sourabh-virdi/terraform-idp-automation/discussions)

## 🎉 Success!

You're now ready to build production-grade identity infrastructure with Terraform IdP Automation. Start with a simple configuration and gradually add complexity as your needs evolve.

**Next recommended reading**:
- [Module Documentation](modules/)
- [Best Practices Blog](blog/)
- [API Reference](api/)

---

*Need help? [Open an issue](https://github.com/sourabh-virdi/terraform-idp-automation/issues) or start a [discussion](https://github.com/sourabh-virdi/terraform-idp-automation/discussions).* 