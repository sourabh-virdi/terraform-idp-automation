---
layout: default
title: Contributing
nav_order: 7
description: "How to contribute to the Terraform IdP Automation project"
---

# Contributing Guide
{: .no_toc }

Thank you for your interest in contributing to Terraform IdP Automation! This guide will help you get started.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## 🎯 Ways to Contribute

There are many ways to contribute to this project:

- **🐛 Report bugs**: Help us identify and fix issues
- **💡 Suggest features**: Propose new functionality or improvements
- **📝 Improve documentation**: Help make our docs clearer and more comprehensive
- **🔧 Write code**: Contribute to modules, examples, or tooling
- **🧪 Add tests**: Improve our test coverage and quality
- **📖 Write blog posts**: Share your experiences and insights
- **🤝 Help others**: Answer questions in discussions and issues

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Git** installed and configured
- **Terraform** >= 1.0 installed
- **Go** >= 1.19 (for running tests)
- Access to at least one identity provider for testing
- Familiarity with Infrastructure as Code principles

### Development Setup

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/terraform-idp-automation.git
   cd terraform-idp-automation
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/sourabh-virdi/terraform-idp-automation.git
   ```
4. **Install development dependencies**:
   ```bash
   # Install pre-commit hooks
   pip install pre-commit
   pre-commit install
   
   # Install Terraform tools
   go install github.com/terraform-linters/tflint@latest
   pip install checkov
   ```

### Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. **Make your changes** following our guidelines
3. **Test your changes** thoroughly
4. **Commit your changes** with clear messages
5. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```
6. **Create a pull request** on GitHub

## 📋 Contribution Guidelines

### Code Standards

#### Terraform Code Style

Follow these conventions for Terraform code:

```hcl
# Use descriptive resource names
resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name
  
  # Group related settings together
  password_policy {
    minimum_length    = var.password_policy.minimum_length
    require_lowercase = var.password_policy.require_lowercase
    require_uppercase = var.password_policy.require_uppercase
    require_numbers   = var.password_policy.require_numbers
    require_symbols   = var.password_policy.require_symbols
  }
  
  # Use consistent formatting
  tags = merge(var.tags, {
    Name = var.user_pool_name
    Type = "identity-infrastructure"
  })
}
```

**Best practices:**
- Use snake_case for all names
- Include meaningful descriptions for variables
- Group related configuration blocks
- Use consistent indentation (2 spaces)
- Sort arguments alphabetically within blocks
- Include appropriate tags on all resources

#### Variable Definitions

```hcl
variable "user_pool_name" {
  description = "Name of the Cognito User Pool"
  type        = string
  
  validation {
    condition     = length(var.user_pool_name) > 0 && length(var.user_pool_name) <= 128
    error_message = "User pool name must be between 1 and 128 characters."
  }
}

variable "password_policy" {
  description = "Password policy configuration for the user pool"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_uppercase = bool
    require_numbers   = bool
    require_symbols   = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}
```

#### Output Definitions

```hcl
output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_client_secret" {
  description = "Client secret for the Cognito User Pool client"
  value       = aws_cognito_user_pool_client.main.client_secret
  sensitive   = true
}
```

### Documentation Standards

#### Module Documentation

Each module must include:

1. **README.md** with:
   - Purpose and features
   - Usage examples
   - Input variables table
   - Output values table
   - Requirements and providers

2. **terraform-docs** compatible comments:
   ```hcl
   # Example comment format for terraform-docs
   variable "example" {
     description = "Description of the variable"
     type        = string
   }
   ```

#### Example Documentation

Each example must include:

1. **README.md** with:
   - What the example demonstrates
   - Prerequisites and setup
   - Step-by-step instructions
   - Expected outputs
   - Cleanup instructions

2. **terraform.tfvars.example**:
   ```hcl
   # Example configuration values
   user_pool_name = "example-pool"
   environment    = "dev"
   
   # Required tags
   tags = {
     Environment = "development"
     Project     = "example-project"
   }
   ```

### Testing Requirements

#### Unit Tests

All Terraform code must pass:

```bash
# Formatting check
terraform fmt -check -recursive

# Validation
terraform validate

# Security scanning
checkov --directory . --framework terraform

# Linting
tflint --recursive
```

#### Integration Tests

For modules that support it, add Go-based integration tests:

```go
func TestAWSCognitoModule(t *testing.T) {
    t.Parallel()
    
    uniqueID := random.UniqueId()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../modules/aws-cognito",
        Vars: map[string]interface{}{
            "user_pool_name": "test-pool-" + uniqueID,
            "client_name":    "test-client-" + uniqueID,
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate outputs
    userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
    assert.NotEmpty(t, userPoolID)
}
```

### Git Workflow

#### Commit Messages

Follow conventional commit format:

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(aws-cognito): add support for custom domains

Add support for custom domain configuration in AWS Cognito
user pools with automatic certificate management.

Closes #123
```

```
fix(azure-ad): resolve app registration permission issue

Fix issue where Microsoft Graph permissions were not being
properly assigned to the service principal.

Fixes #456
```

#### Branch Naming

Use descriptive branch names:

- `feature/add-keycloak-module`
- `fix/azure-ad-permissions`
- `docs/update-getting-started`
- `test/improve-cognito-tests`

## 🔍 Review Process

### Pull Request Guidelines

When submitting a pull request:

1. **Fill out the PR template** completely
2. **Include tests** for new functionality
3. **Update documentation** as needed
4. **Ensure all checks pass**
5. **Request appropriate reviewers**

### PR Template

```markdown
## Description
Brief description of the changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Criteria

Reviewers will check for:

- **Functionality**: Does the code work as expected?
- **Security**: Are there any security concerns?
- **Performance**: Will this impact performance?
- **Maintainability**: Is the code easy to understand and maintain?
- **Documentation**: Is the documentation clear and complete?
- **Testing**: Are there adequate tests?

## 🐛 Reporting Issues

### Bug Reports

When reporting bugs, include:

1. **Clear title** describing the issue
2. **Steps to reproduce** the problem
3. **Expected behavior**
4. **Actual behavior**
5. **Environment details**:
   - Terraform version
   - Provider versions
   - Operating system
   - Cloud provider/region

### Feature Requests

For feature requests, include:

1. **Clear description** of the proposed feature
2. **Use case** explaining why it's needed
3. **Proposed implementation** (if applicable)
4. **Alternatives considered**

### Issue Templates

Use our issue templates:

- **🐛 Bug Report**: For reporting bugs
- **💡 Feature Request**: For suggesting new features
- **📚 Documentation**: For documentation improvements
- **❓ Question**: For asking questions

## 📚 Documentation Contributions

### Writing Guidelines

- **Be clear and concise**: Use simple, direct language
- **Include examples**: Show real, working code examples
- **Consider the audience**: Write for different skill levels
- **Test instructions**: Verify that all steps work
- **Use consistent formatting**: Follow our style guide

### Blog Post Contributions

We welcome blog posts about:

- **Use cases**: Real-world implementation stories
- **Best practices**: Lessons learned from production deployments
- **Technical deep dives**: Detailed implementation explanations
- **Tutorials**: Step-by-step guides

#### Blog Post Guidelines

1. **Propose the topic** in an issue first
2. **Write in Markdown** format
3. **Include code examples** where relevant
4. **Add author bio** and contact information
5. **Submit via pull request**

## 🏆 Recognition

### Contributors

We recognize contributors through:

- **GitHub contributors page**
- **Release notes** mentioning significant contributions
- **Blog post bylines** for content contributors
- **Social media shoutouts** for major contributions

### Maintainer Path

Regular contributors may be invited to become maintainers with:

- **Commit access** to the repository
- **Release management** responsibilities
- **Community management** roles
- **Technical direction** input

## 📞 Getting Help

### Community Channels

- **GitHub Discussions**: For general questions and community interaction
- **GitHub Issues**: For bug reports and feature requests
- **Slack** (if applicable): For real-time chat with maintainers

### Maintainer Contact

- **Email**: platform-team@yourorg.com
- **Office Hours**: Wednesdays 2-3 PM UTC (Zoom link in discussions)

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the same MIT License that covers the project.

---

## 🙏 Thank You

Thank you for contributing to Terraform IdP Automation! Your contributions help make identity infrastructure management easier for everyone.

**Quick Links:**
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)
- [Development Setup](getting-started#development-setup)
- [Example Contributions](examples/#contributing-examples) 