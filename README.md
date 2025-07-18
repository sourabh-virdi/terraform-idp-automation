# Terraform IdP Automation

A comprehensive collection of Terraform modules for automated SSO/Identity Provider provisioning and configuration.

## Overview

This project provides Infrastructure as Code (IaC) solutions for provisioning and configuring popular identity providers including:

- **AWS Cognito** - User pools, identity pools, and SAML providers
- **Azure AD** - Applications, groups, roles, and enterprise applications
- **Okta** - Applications, users, groups, and policies
- **Keycloak** - Realms, clients, users, and roles

## Project Structure

```
├── modules/
│   ├── aws-cognito/          # AWS Cognito user pools and configurations
│   ├── azure-ad/             # Azure AD applications and enterprise setup
│   ├── okta/                 # Okta applications and user management
│   └── keycloak/             # Keycloak realm and client configurations
├── examples/
│   ├── aws-cognito-saml/     # Example AWS Cognito with SAML
│   ├── azure-ad-sso/         # Example Azure AD SSO setup
│   ├── okta-integration/     # Example Okta integration
│   ├── keycloak-setup/       # Example Keycloak configuration
│   └── multi-provider/       # Multi-provider SSO sandbox
├── docs/                     # Additional documentation
└── terraform.tf             # Provider configurations
```

## Prerequisites

- Terraform >= 1.0
- Appropriate cloud provider credentials
- Identity provider admin access

## Quick Start

1. Clone this repository
2. Choose a module or example to work with
3. Configure your provider credentials
4. Run terraform commands:

```bash
terraform init
terraform plan
terraform apply
```

## Modules

### AWS Cognito Module
Provisions AWS Cognito user pools with SAML integration and identity providers.

### Azure AD Module
Sets up Azure AD applications, service principals, and enterprise applications for SSO.

### Okta Module
Configures Okta applications, user assignments, and authentication policies.

### Keycloak Module
Deploys Keycloak realms, clients, and user federation configurations.

## Examples

Each example in the `examples/` directory demonstrates real-world usage patterns:

- Single provider setups
- Multi-provider environments
- SSO-enabled development sandboxes
- Production-ready configurations

## Contributing

Please read our contributing guidelines and submit pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 
