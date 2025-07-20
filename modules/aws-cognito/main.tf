# AWS Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name

  # Password policy
  password_policy {
    minimum_length    = var.password_policy.minimum_length
    require_lowercase = var.password_policy.require_lowercase
    require_numbers   = var.password_policy.require_numbers
    require_symbols   = var.password_policy.require_symbols
    require_uppercase = var.password_policy.require_uppercase
  }

  # Account recovery settings
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # Auto-verified attributes
  auto_verified_attributes = var.auto_verified_attributes

  # Schema
  dynamic "schema" {
    for_each = var.schema_attributes
    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      required            = schema.value.required
      mutable             = schema.value.mutable
    }
  }

  tags = var.tags
}

# User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  count           = var.domain_name != null ? 1 : 0
  domain          = var.domain_name
  certificate_arn = var.domain_certificate_arn
  user_pool_id    = aws_cognito_user_pool.main.id
}

# User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name         = var.client_name
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret                      = var.generate_client_secret
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  supported_identity_providers         = concat(["COGNITO"], [for provider in aws_cognito_identity_provider.saml : provider.provider_name])

  explicit_auth_flows = var.explicit_auth_flows

  # Token validity
  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = var.token_validity_units.access_token
    id_token      = var.token_validity_units.id_token
    refresh_token = var.token_validity_units.refresh_token
  }
}

# SAML Identity Providers
resource "aws_cognito_identity_provider" "saml" {
  for_each = var.saml_providers

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = each.value.provider_name
  provider_type = "SAML"

  provider_details = {
    MetadataURL           = each.value.metadata_url
    SSORedirectBindingURI = each.value.sso_redirect_binding_uri
    SLORedirectBindingURI = each.value.slo_redirect_binding_uri
  }

  attribute_mapping = each.value.attribute_mapping

  depends_on = [aws_cognito_user_pool.main]
}

# Identity Pool (for AWS credentials)
resource "aws_cognito_identity_pool" "main" {
  count                            = var.create_identity_pool ? 1 : 0
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.main.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = var.server_side_token_check
  }

  # SAML providers for identity pool
  dynamic "saml_provider_arns" {
    for_each = var.identity_pool_saml_providers
    content {
      saml_provider_arns = saml_provider_arns.value
    }
  }

  tags = var.tags
}

# IAM roles for identity pool
resource "aws_iam_role" "authenticated" {
  count = var.create_identity_pool ? 1 : 0
  name  = "${var.identity_pool_name}-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role" "unauthenticated" {
  count = var.create_identity_pool && var.allow_unauthenticated_identities ? 1 : 0
  name  = "${var.identity_pool_name}-unauthenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main[0].id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach roles to identity pool
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  count            = var.create_identity_pool ? 1 : 0
  identity_pool_id = aws_cognito_identity_pool.main[0].id

  roles = merge(
    {
      "authenticated" = aws_iam_role.authenticated[0].arn
    },
    var.allow_unauthenticated_identities ? {
      "unauthenticated" = aws_iam_role.unauthenticated[0].arn
    } : {}
  )

  dynamic "role_mapping" {
    for_each = var.role_mappings
    content {
      identity_provider         = role_mapping.value.identity_provider
      ambiguous_role_resolution = role_mapping.value.ambiguous_role_resolution
      type                      = role_mapping.value.type

      dynamic "mapping_rule" {
        for_each = role_mapping.value.mapping_rules
        content {
          claim      = mapping_rule.value.claim
          match_type = mapping_rule.value.match_type
          role_arn   = mapping_rule.value.role_arn
          value      = mapping_rule.value.value
        }
      }
    }
  }
} 