# Terraform IdP Automation - Setup Guide

This guide will walk you through setting up the Terraform IdP Automation project from scratch to deployment.

## 📋 Prerequisites

### Required Tools
- **Terraform** >= 1.0 ([Download](https://terraform.io/downloads))
- **Git** ([Download](https://git-scm.com/downloads))
- **AWS CLI** ([Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **Azure CLI** ([Install Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))

### Required Accounts & Access
- **AWS Account** with IAM permissions for Cognito, Identity Pools, and IAM
- **Azure AD Tenant** with Global Administrator or Application Administrator role
- **Okta Organization** (Developer account sufficient) with Super Admin API access
- **Keycloak Server** (optional) with admin access

## 🚀 Quick Start (5 Minutes)

### Step 1: Clone the Repository
```bash
git clone https://github.com/sourabh-virdi/terraform-idp-automation.git
cd terraform-idp-automation
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Configure Your First Provider (AWS Cognito)
```bash
cd examples/aws-cognito-basic
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your settings
terraform init
terraform plan
terraform apply
```

## 🔧 Detailed Setup

### 1. Environment Preparation

#### Install Terraform
```bash
# macOS (using Homebrew)
brew install terraform

# Linux (using package manager)
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Windows (using Chocolatey)
choco install terraform
```

#### Verify Installation
```bash
terraform version
# Should output: Terraform v1.x.x
```

### 2. Provider-Specific Setup

#### AWS Cognito Setup

1. **Configure AWS CLI**
```bash
aws configure
# Enter your AWS Access Key ID, Secret, Region, and output format
```

2. **Set Environment Variables**
```bash
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
```

3. **Required IAM Permissions**
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
                "iam:DetachRolePolicy",
                "acm:DescribeCertificate"
            ],
            "Resource": "*"
        }
    ]
}
```

#### Azure AD Setup

1. **Login to Azure**
```bash
az login
```

2. **Set Environment Variables**
```bash
export AZURE_TENANT_ID=your-tenant-id
export AZURE_CLIENT_ID=your-client-id
export AZURE_CLIENT_SECRET=your-client-secret
```

3. **Create Service Principal** (if not using CLI auth)
```bash
az ad sp create-for-rbac --name "terraform-idp-automation" --role "Application Administrator"
```

4. **Required Azure AD Permissions**
- Application Administrator role
- Directory.ReadWrite.All (for creating apps)
- Group.ReadWrite.All (for managing groups)

### 3. Configuration Examples

#### Basic Single Provider Setup

**AWS Cognito Example:**
```bash
cd examples/aws-cognito-basic
```

Create `terraform.tfvars`:
```hcl
user_pool_name = "my-app-users"
client_name    = "my-app-client"
environment    = "dev"

callback_urls = ["https://myapp.com/callback"]
logout_urls   = ["https://myapp.com/logout"]

tags = {
  Environment = "development"
  Project     = "my-app"
}
```

**Deploy:**
```bash
terraform init
terraform plan
terraform apply
```

#### Multi-Provider Setup

```bash
cd examples/multi-provider
```

Create `terraform.tfvars`:
```hcl
# Environment
environment       = "dev"
organization_name = "MyCompany"
domain_name       = "mycompany.com"

# Okta
okta_org_name  = "mycompany-dev"
okta_api_token = "your-okta-api-token"

# Application URLs
app_homepage_url = "https://app-dev.mycompany.com"
callback_urls = [
  "https://app-dev.mycompany.com/auth/callback",
  "https://app-dev.mycompany.com/signin-oidc"
]

# Demo users for testing
create_demo_users  = true
demo_user_password = "TempPassword123!"

# AWS (optional custom domain)
# cognito_domain_name = "auth-dev.mycompany.com"
# cognito_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/your-cert"

tags = {
  Environment = "development"
  Project     = "sso-automation"
  Team        = "platform"
}
```

**Deploy:**
```bash
terraform init
terraform plan
terraform apply
```

### 4. Validation & Testing

#### Test Individual Providers

**AWS Cognito:**
```bash
# List user pools
aws cognito-idp list-user-pools --max-items 10

# Get user pool details
aws cognito-idp describe-user-pool --user-pool-id us-east-1_XXXXXXXXX
```

**Azure AD:**
```bash
# List applications
az ad app list --query "[?displayName=='your-app-name']"

# List groups
az ad group list --query "[?displayName=='your-group-name']"
```
#### Integration Testing

1. **SAML Federation Test**
   - Access application through each IdP
   - Verify attribute mapping
   - Test group-based access

2. **OAuth Flow Test**
   - Test authorization code flow
   - Verify token generation
   - Test refresh token

3. **Multi-Provider Test**
   - Login through different providers
   - Verify centralized identity
   - Test role-based access

### 5. Production Deployment

#### Security Hardening

1. **Use Backend State Storage**
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "idp-automation/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-locks"
  }
}
```

2. **Enable State Locking**
```bash
# Create DynamoDB table for locking
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

3. **Use Secrets Management**
```bash
# Store sensitive variables in AWS Secrets Manager
aws secretsmanager create-secret \
  --name "terraform-idp-automation/okta-api-token" \
  --secret-string "your-okta-api-token"
```

#### CI/CD Integration

1. **GitHub Actions Setup** (see `.github/workflows/` directory)
2. **Environment-specific Configurations**
3. **Automated Testing and Validation**

### 6. Troubleshooting

#### Common Issues

1. **Provider Authentication Errors**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check Azure login
az account show

# Test Okta API
curl -H "Authorization: SSWS $OKTA_API_TOKEN" \
  https://$OKTA_ORG_NAME.okta.com/api/v1/org
```

2. **Terraform State Issues**
```bash
# Refresh state
terraform refresh

# Import existing resources
terraform import module.aws_cognito.aws_cognito_user_pool.main us-east-1_XXXXXXXXX
```

3. **Permission Errors**
   - Verify IAM roles and policies
   - Check Azure AD roles
   - Validate Okta API token permissions

#### Debug Commands

```bash
# Enable Terraform debug logging
export TF_LOG=DEBUG
terraform apply

# Validate configuration
terraform validate

# Check formatting
terraform fmt -check
```

### 7. Next Steps

1. **Customize for Your Use Case**
   - Modify examples to match your requirements
   - Add custom attribute mappings
   - Configure additional security policies

2. **Scale the Deployment**
   - Add more identity providers
   - Implement environment-specific configurations
   - Set up monitoring and alerting

3. **Advanced Features**
   - Custom domain configuration
   - Advanced MFA policies
   - Identity federation workflows
   - Automated user provisioning

## 📚 Additional Resources

- [Module Documentation](./modules/)
- [Example Configurations](./examples/)

## 🤝 Support

- **Issues**: [GitHub Issues](https://github.com/sourabh-virdi/terraform-idp-automation/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sourabh-virdi/terraform-idp-automation/discussions)
- **Documentation**: [Project Wiki](https://github.com/sourabh-virdi/terraform-idp-automation/wiki) 