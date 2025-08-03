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

func TestOktaIntegrationSAMLExample(t *testing.T) {
	t.Parallel()

	// Generate unique names to avoid conflicts
	uniqueID := random.UniqueId()
	appName := fmt.Sprintf("test-saml-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/okta-integration",
		Vars: map[string]interface{}{
			"okta_org_name":  getOktaOrgFromEnv(t),
			"okta_base_url":  "okta.com",
			"okta_api_token": getOktaTokenFromEnv(t),
			"app_name":       appName,
			"app_description": fmt.Sprintf("Test SAML application %s", uniqueID),
			"create_saml_app": true,
			"sso_url":         "https://test.example.com/saml/acs",
			"audience":        "https://test.example.com",
			"destination":     "https://test.example.com/saml/acs",
			"attribute_statements": []map[string]interface{}{
				{
					"type":      "EXPRESSION",
					"name":      "email",
					"namespace": "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
					"values":    []string{"user.email"},
				},
				{
					"type":      "EXPRESSION",
					"name":      "firstName",
					"namespace": "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
					"values":    []string{"user.firstName"},
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
	testOktaSAMLOutputs(t, terraformOptions)

	// Test SAML endpoints
	testOktaSAMLEndpoints(t, terraformOptions)

	// Test group creation
	testOktaGroups(t, terraformOptions)
}

func TestOktaIntegrationOAuthExample(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	appName := fmt.Sprintf("test-oauth-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/okta-integration",
		Vars: map[string]interface{}{
			"okta_org_name":      getOktaOrgFromEnv(t),
			"okta_base_url":      "okta.com",
			"okta_api_token":     getOktaTokenFromEnv(t),
			"app_name":           appName,
			"create_saml_app":    false,
			"create_oauth_app":   true,
			"oauth_app_type":     "web",
			"redirect_uris":      []string{"https://test.example.com/auth/callback"},
			"post_logout_redirect_uris": []string{"https://test.example.com/logout"},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Test OAuth outputs
	testOktaOAuthOutputs(t, terraformOptions)

	// Test OAuth endpoints
	testOktaOAuthEndpoints(t, terraformOptions)
}

func TestOktaIntegrationMobileApp(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	appName := fmt.Sprintf("test-mobile-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/okta-integration",
		Vars: map[string]interface{}{
			"okta_org_name":    getOktaOrgFromEnv(t),
			"okta_base_url":    "okta.com",
			"okta_api_token":   getOktaTokenFromEnv(t),
			"app_name":         appName,
			"create_saml_app":  false,
			"create_oauth_app": true,
			"oauth_app_type":   "native",
			"redirect_uris": []string{
				"com.example.app://auth/callback",
				"https://example.com/mobile/callback",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify native app configuration
	oauthAppID := terraform.Output(t, terraformOptions, "oauth_app_id")
	assert.NotEmpty(t, oauthAppID)
}

func TestOktaIntegrationWithGroups(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	appName := fmt.Sprintf("test-groups-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/okta-integration",
		Vars: map[string]interface{}{
			"okta_org_name":  getOktaOrgFromEnv(t),
			"okta_base_url":  "okta.com",
			"okta_api_token": getOktaTokenFromEnv(t),
			"app_name":       appName,
			"create_saml_app": true,
			"sso_url":        "https://test.example.com/saml/acs",
			"audience":       "https://test.example.com",
			"groups": map[string]interface{}{
				"test-users": map[string]interface{}{
					"name":        fmt.Sprintf("Test Users %s", uniqueID),
					"description": "Test users group",
					"type":        "OKTA_GROUP",
				},
				"test-admins": map[string]interface{}{
					"name":        fmt.Sprintf("Test Admins %s", uniqueID),
					"description": "Test administrators group",
					"type":        "OKTA_GROUP",
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify groups were created
	groupIDs := terraform.OutputMap(t, terraformOptions, "group_ids")
	assert.NotEmpty(t, groupIDs)
	assert.Contains(t, groupIDs, "test-users")
	assert.Contains(t, groupIDs, "test-admins")
}

func testOktaSAMLOutputs(t *testing.T, terraformOptions *terraform.Options) {
	// Test SAML app outputs
	samlAppID := terraform.Output(t, terraformOptions, "saml_app_id")
	assert.NotEmpty(t, samlAppID)

	samlMetadataURL := terraform.Output(t, terraformOptions, "saml_metadata_url")
	assert.NotEmpty(t, samlMetadataURL)
	assert.Contains(t, samlMetadataURL, "saml/metadata")

	samlSSOURL := terraform.Output(t, terraformOptions, "saml_sso_url")
	assert.NotEmpty(t, samlSSOURL)
	assert.Contains(t, samlSSOURL, "/sso/saml")

	// Test Okta URLs
	oktaSignOnURL := terraform.Output(t, terraformOptions, "okta_sign_on_url")
	assert.Contains(t, oktaSignOnURL, ".okta.com")
	assert.Contains(t, oktaSignOnURL, samlAppID)
}

func testOktaOAuthOutputs(t *testing.T, terraformOptions *terraform.Options) {
	// Test OAuth app outputs
	oauthAppID := terraform.Output(t, terraformOptions, "oauth_app_id")
	assert.NotEmpty(t, oauthAppID)

	oauthClientID := terraform.Output(t, terraformOptions, "oauth_client_id")
	assert.NotEmpty(t, oauthClientID)

	// Test OAuth endpoints
	authURL := terraform.Output(t, terraformOptions, "oauth_authorization_url")
	tokenURL := terraform.Output(t, terraformOptions, "oauth_token_url")
	userinfoURL := terraform.Output(t, terraformOptions, "oauth_userinfo_url")
	oidcConfigURL := terraform.Output(t, terraformOptions, "openid_configuration_url")

	assert.Contains(t, authURL, ".okta.com")
	assert.Contains(t, authURL, "/authorize")
	assert.Contains(t, tokenURL, "/token")
	assert.Contains(t, userinfoURL, "/userinfo")
	assert.Contains(t, oidcConfigURL, "/.well-known/openid_configuration")
}

func testOktaSAMLEndpoints(t *testing.T, terraformOptions *terraform.Options) {
	// Test SAML metadata endpoint
	metadataURL := terraform.Output(t, terraformOptions, "saml_metadata_url")
	
	client := &http.Client{Timeout: 30 * time.Second}
	resp, err := client.Get(metadataURL)
	assert.NoError(t, err)
	assert.Equal(t, http.StatusOK, resp.StatusCode)
	defer resp.Body.Close()

	// Verify content type is XML
	contentType := resp.Header.Get("Content-Type")
	assert.Contains(t, contentType, "xml")
}

func testOktaOAuthEndpoints(t *testing.T, terraformOptions *terraform.Options) {
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

	// Verify issuer matches expected pattern
	issuer, ok := oidcConfig["issuer"].(string)
	assert.True(t, ok)
	assert.Contains(t, issuer, ".okta.com")
}

func testOktaGroups(t *testing.T, terraformOptions *terraform.Options) {
	// Test that group IDs are returned
	groupIDs := terraform.OutputMap(t, terraformOptions, "group_ids")
	assert.NotEmpty(t, groupIDs)
}

func TestOktaValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/okta-integration",
		Vars: map[string]interface{}{
			"okta_org_name":    getOktaOrgFromEnv(t),
			"okta_base_url":    "okta.com",
			"okta_api_token":   getOktaTokenFromEnv(t),
			"app_name":         "test-validation",
			"oauth_app_type":   "invalid-type", // Invalid value
			"create_oauth_app": true,
		},
	}

	// This should fail due to validation
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "OAuth app type must be one of")
}

func TestOktaMinimalConfig(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	appName := fmt.Sprintf("test-minimal-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/okta-integration",
		Vars: map[string]interface{}{
			"okta_org_name":  getOktaOrgFromEnv(t),
			"okta_base_url":  "okta.com",
			"okta_api_token": getOktaTokenFromEnv(t),
			"app_name":       appName,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify minimal configuration works (defaults to SAML app)
	samlAppID := terraform.Output(t, terraformOptions, "saml_app_id")
	assert.NotEmpty(t, samlAppID)
}

func TestOktaAttributeMapping(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	appName := fmt.Sprintf("test-attributes-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/okta-integration",
		Vars: map[string]interface{}{
			"okta_org_name":  getOktaOrgFromEnv(t),
			"okta_base_url":  "okta.com",
			"okta_api_token": getOktaTokenFromEnv(t),
			"app_name":       appName,
			"create_saml_app": true,
			"sso_url":        "https://test.example.com/saml/acs",
			"audience":       "https://test.example.com",
			"attribute_statements": []map[string]interface{}{
				{
					"type":      "EXPRESSION",
					"name":      "email",
					"namespace": "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
					"values":    []string{"user.email"},
				},
				{
					"type":      "EXPRESSION",
					"name":      "roles",
					"namespace": "urn:oasis:names:tc:SAML:2.0:attrname-format:basic",
					"values":    []string{"isMemberOfGroupName(\"Administrators\") ? \"admin\" : \"user\""},
				},
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify SAML app was created with attribute mapping
	samlAppID := terraform.Output(t, terraformOptions, "saml_app_id")
	assert.NotEmpty(t, samlAppID)
}

// Helper functions
func getOktaOrgFromEnv(t *testing.T) string {
	oktaOrg := getEnvVar(t, "OKTA_ORG_NAME", "")
	if oktaOrg == "" {
		t.Skip("OKTA_ORG_NAME environment variable not set")
	}
	return oktaOrg
}

func getOktaTokenFromEnv(t *testing.T) string {
	token := getEnvVar(t, "OKTA_API_TOKEN", "")
	if token == "" {
		t.Skip("OKTA_API_TOKEN environment variable not set")
	}
	return token
} 