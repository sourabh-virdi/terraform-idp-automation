# User Pool Outputs
output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Endpoint name of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

output "user_pool_domain" {
  description = "Domain name of the Cognito User Pool"
  value       = var.domain_name != null ? aws_cognito_user_pool_domain.main[0].domain : null
}

output "user_pool_hosted_ui_url" {
  description = "Hosted UI URL of the Cognito User Pool"
  value       = var.domain_name != null ? "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com" : null
}

# User Pool Client Outputs
output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.main.id
}

output "user_pool_client_secret" {
  description = "Secret of the Cognito User Pool Client"
  value       = var.generate_client_secret ? aws_cognito_user_pool_client.main.client_secret : null
  sensitive   = true
}

# Identity Pool Outputs
output "identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = var.create_identity_pool ? aws_cognito_identity_pool.main[0].id : null
}

output "identity_pool_arn" {
  description = "ARN of the Cognito Identity Pool"
  value       = var.create_identity_pool ? aws_cognito_identity_pool.main[0].arn : null
}

# IAM Role Outputs
output "authenticated_role_arn" {
  description = "ARN of the authenticated IAM role"
  value       = var.create_identity_pool ? aws_iam_role.authenticated[0].arn : null
}

output "unauthenticated_role_arn" {
  description = "ARN of the unauthenticated IAM role"
  value       = var.create_identity_pool && var.allow_unauthenticated_identities ? aws_iam_role.unauthenticated[0].arn : null
}

# SAML Provider Outputs
output "saml_providers" {
  description = "Map of SAML identity provider details"
  value = {
    for k, v in aws_cognito_identity_provider.saml : k => {
      provider_name = v.provider_name
      provider_type = v.provider_type
    }
  }
}

# OAuth URLs
output "oauth_urls" {
  description = "OAuth-related URLs for the User Pool"
  value = var.domain_name != null ? {
    authorization_endpoint = "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/authorize"
    token_endpoint        = "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/token"
    userinfo_endpoint     = "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/userInfo"
    jwks_uri              = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json"
  } : null
}

# Data source for current AWS region
data "aws_region" "current" {} 