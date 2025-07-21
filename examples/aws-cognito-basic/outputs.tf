output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = module.cognito.user_pool_arn
}

output "user_pool_endpoint" {
  description = "Endpoint URL of the Cognito User Pool"
  value       = module.cognito.user_pool_endpoint
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool client"
  value       = module.cognito.user_pool_client_id
}

output "user_pool_client_secret" {
  description = "Client secret for the Cognito User Pool client"
  value       = module.cognito.user_pool_client_secret
  sensitive   = true
}

output "hosted_ui_url" {
  description = "URL of the hosted UI for authentication"
  value       = module.cognito.hosted_ui_url
}

output "oauth_endpoints" {
  description = "OAuth endpoint URLs"
  value       = module.cognito.oauth_endpoints
}

output "identity_pool_id" {
  description = "ID of the Cognito Identity Pool (if created)"
  value       = module.cognito.identity_pool_id
}

output "user_pool_domain" {
  description = "Domain prefix for the Cognito User Pool"
  value       = module.cognito.user_pool_domain
} 