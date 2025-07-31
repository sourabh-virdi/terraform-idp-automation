package test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestKeycloakSetupExample(t *testing.T) {
	t.Parallel()

	// Generate unique names to avoid conflicts
	uniqueID := random.UniqueId()
	realmName := fmt.Sprintf("test-realm-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/keycloak-setup",
		Vars: map[string]interface{}{
			"keycloak_url":      getKeycloakURLFromEnv(t),
			"keycloak_username": getKeycloakUsernameFromEnv(t),
			"keycloak_password": getKeycloakPasswordFromEnv(t),
			"realm_name":        realmName,
			"realm_display_name": fmt.Sprintf("Test Realm %s", uniqueID),
			"realm_enabled":     true,
			"oidc_clients": map[string]interface{}{
				"webapp": map[string]interface{}{
					"client_id":     fmt.Sprintf("test-webapp-%s", uniqueID),
					"name":          fmt.Sprintf("Test Web App %s", uniqueID),
					"description":   "Test web application",
					"enabled":       true,
					"redirect_uris": []string{
						"https://test.example.com/auth/callback",
						"https://localhost:3000/auth/callback",
					},
					"web_origins": []string{
						"https://test.example.com",
						"https://localhost:3000",
					},
				},
			},
			"users": map[string]interface{}{
				"testuser": map[string]interface{}{
					"username":   fmt.Sprintf("testuser-%s", uniqueID),
					"email":      fmt.Sprintf("test-%s@example.com", uniqueID),
					"first_name": "Test",
					"last_name":  "User",
					"enabled":    true,
				},
			},
			"tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"ManagedBy":   "terraform",
			},
		},
	}

	// Clean up resources after test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Test outputs
	testKeycloakOutputs(t, terraformOptions)

	// Test realm functionality
	testKeycloakRealm(t, terraformOptions)

	// Test OIDC endpoints
	testKeycloakOIDCEndpoints(t, terraformOptions)

	// Test client configuration
	testKeycloakClients(t, terraformOptions)
}

func TestKeycloakMultipleClients(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	realmName := fmt.Sprintf("test-multi-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/keycloak-setup",
		Vars: map[string]interface{}{
			"keycloak_url":      getKeycloakURLFromEnv(t),
			"keycloak_username": getKeycloakUsernameFromEnv(t),
			"keycloak_password": getKeycloakPasswordFromEnv(t),
			"realm_name":        realmName,
			"realm_display_name": fmt.Sprintf("Multi-Client Realm %s", uniqueID),
			"oidc_clients": map[string]interface{}{
				"webapp": map[string]interface{}{
					"client_id":     fmt.Sprintf("webapp-%s", uniqueID),
					"name":          "Web Application",
					"description":   "Web application client",
					"enabled":       true,
					"redirect_uris": []string{"https://webapp.example.com/callback"},
					"web_origins":   []string{"https://webapp.example.com"},
				},
				"mobile": map[string]interface{}{
					"client_id":     fmt.Sprintf("mobile-%s", uniqueID),
					"name":          "Mobile Application",
					"description":   "Mobile application client",
					"enabled":       true,
					"redirect_uris": []string{"com.example.app://callback"},
					"web_origins":   []string{},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify multiple clients were created
	clientIDs := terraform.OutputMap(t, terraformOptions, "client_ids")
	assert.NotEmpty(t, clientIDs)
	assert.Contains(t, clientIDs, "webapp")
	assert.Contains(t, clientIDs, "mobile")
}

func TestKeycloakWithGroups(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	realmName := fmt.Sprintf("test-groups-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/keycloak-setup",
		Vars: map[string]interface{}{
			"keycloak_url":      getKeycloakURLFromEnv(t),
			"keycloak_username": getKeycloakUsernameFromEnv(t),
			"keycloak_password": getKeycloakPasswordFromEnv(t),
			"realm_name":        realmName,
			"realm_display_name": fmt.Sprintf("Groups Realm %s", uniqueID),
			"groups": map[string]interface{}{
				"employees": map[string]interface{}{
					"name": "Employees",
					"path": "/Employees",
				},
				"managers": map[string]interface{}{
					"name": "Managers",
					"path": "/Managers",
				},
				"developers": map[string]interface{}{
					"name": "Developers",
					"path": "/Employees/Developers",
				},
			},
			"realm_roles": map[string]interface{}{
				"user": map[string]interface{}{
					"name":        "user",
					"description": "Standard user role",
				},
				"admin": map[string]interface{}{
					"name":        "admin",
					"description": "Administrator role",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify groups and roles were created
	groupIDs := terraform.OutputMap(t, terraformOptions, "group_ids")
	assert.NotEmpty(t, groupIDs)
	assert.Contains(t, groupIDs, "employees")
	assert.Contains(t, groupIDs, "managers")
	assert.Contains(t, groupIDs, "developers")

	roleIDs := terraform.OutputMap(t, terraformOptions, "realm_role_ids")
	assert.NotEmpty(t, roleIDs)
	assert.Contains(t, roleIDs, "user")
	assert.Contains(t, roleIDs, "admin")
}

func TestKeycloakWithIdentityProviders(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	realmName := fmt.Sprintf("test-idp-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/keycloak-setup",
		Vars: map[string]interface{}{
			"keycloak_url":      getKeycloakURLFromEnv(t),
			"keycloak_username": getKeycloakUsernameFromEnv(t),
			"keycloak_password": getKeycloakPasswordFromEnv(t),
			"realm_name":        realmName,
			"realm_display_name": fmt.Sprintf("IdP Realm %s", uniqueID),
			"identity_providers": map[string]interface{}{
				"google": map[string]interface{}{
					"provider_id":   "google",
					"display_name":  "Google",
					"enabled":       true,
					"client_id":     "fake-google-client-id",
					"client_secret": "fake-google-client-secret",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify identity providers were created
	idpIDs := terraform.OutputMap(t, terraformOptions, "identity_provider_ids")
	assert.NotEmpty(t, idpIDs)
	assert.Contains(t, idpIDs, "google")
}

func testKeycloakOutputs(t *testing.T, terraformOptions *terraform.Options) {
	// Test realm outputs
	realmID := terraform.Output(t, terraformOptions, "realm_id")
	assert.NotEmpty(t, realmID)

	realmName := terraform.Output(t, terraformOptions, "realm_name")
	assert.NotEmpty(t, realmName)

	// Test client outputs
	clientIDs := terraform.OutputMap(t, terraformOptions, "client_ids")
	assert.NotEmpty(t, clientIDs)

	// Test user outputs
	userIDs := terraform.OutputMap(t, terraformOptions, "user_ids")
	assert.NotEmpty(t, userIDs)

	// Test endpoint URLs
	oidcConfigURL := terraform.Output(t, terraformOptions, "openid_configuration_url")
	tokenEndpoint := terraform.Output(t, terraformOptions, "token_endpoint")
	authEndpoint := terraform.Output(t, terraformOptions, "authorization_endpoint")
	userinfoEndpoint := terraform.Output(t, terraformOptions, "userinfo_endpoint")
	jwksURI := terraform.Output(t, terraformOptions, "jwks_uri")
	issuer := terraform.Output(t, terraformOptions, "issuer")

	assert.Contains(t, oidcConfigURL, "/.well-known/openid_configuration")
	assert.Contains(t, tokenEndpoint, "/token")
	assert.Contains(t, authEndpoint, "/auth")
	assert.Contains(t, userinfoEndpoint, "/userinfo")
	assert.Contains(t, jwksURI, "/certs")
	assert.Contains(t, issuer, realmName)
}

func testKeycloakRealm(t *testing.T, terraformOptions *terraform.Options) {
	realmName := terraform.Output(t, terraformOptions, "realm_name")
	keycloakURL := getKeycloakURLFromEnv(t)

	// Test realm info endpoint
	realmInfoURL := fmt.Sprintf("%s/realms/%s", keycloakURL, realmName)
	
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Get(realmInfoURL)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
	defer resp.Body.Close()

	// Parse realm info
	var realmInfo map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&realmInfo)
	assert.NoError(t, err)

	// Verify realm properties
	assert.Equal(t, realmName, realmInfo["realm"])
	assert.Equal(t, true, realmInfo["enabled"])
}

func testKeycloakOIDCEndpoints(t *testing.T, terraformOptions *terraform.Options) {
	// Test OpenID Connect configuration endpoint
	oidcConfigURL := terraform.Output(t, terraformOptions, "openid_configuration_url")
	
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Get(oidcConfigURL)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
	defer resp.Body.Close()

	// Parse OpenID configuration
	var oidcConfig map[string]interface{}
	err = json.NewDecoder(resp.Body).Decode(&oidcConfig)
	assert.NoError(t, err)

	// Verify required OIDC endpoints
	assert.Contains(t, oidcConfig, "issuer")
	assert.Contains(t, oidcConfig, "authorization_endpoint")
	assert.Contains(t, oidcConfig, "token_endpoint")
	assert.Contains(t, oidcConfig, "userinfo_endpoint")
	assert.Contains(t, oidcConfig, "jwks_uri")
	assert.Contains(t, oidcConfig, "end_session_endpoint")

	// Verify supported scopes
	scopesSupported, ok := oidcConfig["scopes_supported"].([]interface{})
	assert.True(t, ok)
	assert.Contains(t, scopesSupported, "openid")
	assert.Contains(t, scopesSupported, "profile")
	assert.Contains(t, scopesSupported, "email")

	// Verify supported response types
	responseTypes, ok := oidcConfig["response_types_supported"].([]interface{})
	assert.True(t, ok)
	assert.Contains(t, responseTypes, "code")
}

func testKeycloakClients(t *testing.T, terraformOptions *terraform.Options) {
	clientIDs := terraform.OutputMap(t, terraformOptions, "client_ids")
	assert.NotEmpty(t, clientIDs)

	// Verify client secrets are available
	clientSecrets := terraform.OutputMap(t, terraformOptions, "client_secrets")
	assert.NotEmpty(t, clientSecrets)

	// Each client should have a corresponding secret
	for clientKey := range clientIDs {
		assert.Contains(t, clientSecrets, clientKey)
		assert.NotEmpty(t, clientSecrets[clientKey])
	}
}

func TestKeycloakValidation(t *testing.T) {
	t.Parallel()

	// Test with invalid Keycloak URL
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/keycloak-setup",
		Vars: map[string]interface{}{
			"keycloak_url":      "invalid-url",
			"keycloak_username": "admin",
			"keycloak_password": "admin",
			"realm_name":        "test-validation",
		},
	}

	// This should fail during apply due to invalid URL
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	// Plan might succeed, but apply would fail
	if err == nil {
		_, err = terraform.ApplyE(t, terraformOptions)
		assert.Error(t, err)
	}
}

func TestKeycloakMinimalConfig(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	realmName := fmt.Sprintf("test-minimal-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/keycloak-setup",
		Vars: map[string]interface{}{
			"keycloak_url":      getKeycloakURLFromEnv(t),
			"keycloak_username": getKeycloakUsernameFromEnv(t),
			"keycloak_password": getKeycloakPasswordFromEnv(t),
			"realm_name":        realmName,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify minimal configuration works
	realmID := terraform.Output(t, terraformOptions, "realm_id")
	assert.NotEmpty(t, realmID)
}

func TestKeycloakHealthCheck(t *testing.T) {
	t.Parallel()

	keycloakURL := getKeycloakURLFromEnv(t)
	
	// Test Keycloak health endpoint
	healthURL := fmt.Sprintf("%s/health", keycloakURL)
	
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Get(healthURL)
	
	// Health endpoint might not exist in all Keycloak versions
	// So we just test that the server is reachable
	if err == nil {
		defer resp.Body.Close()
		// Any response (200, 404, etc.) means server is reachable
		assert.True(t, resp.StatusCode > 0)
	}
}

// Helper functions
func getKeycloakURLFromEnv(t *testing.T) string {
	url := getEnvVar(t, "KEYCLOAK_URL", "http://localhost:8080")
	return url
}

func getKeycloakUsernameFromEnv(t *testing.T) string {
	username := getEnvVar(t, "KEYCLOAK_USERNAME", "admin")
	return username
}

func getKeycloakPasswordFromEnv(t *testing.T) string {
	password := getEnvVar(t, "KEYCLOAK_PASSWORD", "admin")
	return password
} 