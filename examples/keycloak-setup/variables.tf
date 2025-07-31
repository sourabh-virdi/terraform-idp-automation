variable "keycloak_client_id" {
  description = "Keycloak admin client ID"
  type        = string
  default     = "admin-cli"
}

variable "keycloak_username" {
  description = "Keycloak admin username"
  type        = string
}

variable "keycloak_password" {
  description = "Keycloak admin password"
  type        = string
  sensitive   = true
}

variable "keycloak_url" {
  description = "Keycloak server URL"
  type        = string
  default     = "http://localhost:8080"
}

variable "realm_name" {
  description = "Name of the Keycloak realm"
  type        = string
  default     = "example-realm"
}

variable "realm_display_name" {
  description = "Display name of the Keycloak realm"
  type        = string
  default     = "Example Realm"
}

variable "realm_enabled" {
  description = "Whether the realm is enabled"
  type        = bool
  default     = true
}

variable "oidc_clients" {
  description = "OpenID Connect clients to create"
  type = map(object({
    client_id     = string
    name          = string
    description   = string
    enabled       = bool
    redirect_uris = list(string)
    web_origins   = list(string)
  }))
  default = {
    "webapp" = {
      client_id     = "example-webapp"
      name          = "Example Web Application"
      description   = "Example web application using OpenID Connect"
      enabled       = true
      redirect_uris = ["https://example.com/auth/callback", "https://localhost:3000/auth/callback"]
      web_origins   = ["https://example.com", "https://localhost:3000"]
    }
  }
}

variable "users" {
  description = "Users to create in the realm"
  type = map(object({
    username   = string
    email      = string
    first_name = string
    last_name  = string
    enabled    = bool
  }))
  default = {
    "testuser" = {
      username   = "testuser"
      email      = "test@example.com"
      first_name = "Test"
      last_name  = "User"
      enabled    = true
    }
  }
}

variable "groups" {
  description = "Groups to create in the realm"
  type = map(object({
    name = string
    path = string
  }))
  default = {
    "users" = {
      name = "Users"
      path = "/Users"
    }
    "admins" = {
      name = "Administrators"
      path = "/Administrators"
    }
  }
}

variable "realm_roles" {
  description = "Realm roles to create"
  type = map(object({
    name        = string
    description = string
  }))
  default = {
    "user" = {
      name        = "user"
      description = "Standard user role"
    }
    "admin" = {
      name        = "admin"
      description = "Administrator role"
    }
  }
}

variable "identity_providers" {
  description = "Identity providers to configure"
  type = map(object({
    provider_id   = string
    display_name  = string
    enabled       = bool
    client_id     = string
    client_secret = string
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "keycloak-setup"
    ManagedBy   = "terraform"
  }
} 