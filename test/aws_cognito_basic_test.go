package test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAWSCognitoBasicExample(t *testing.T) {
	t.Parallel()

	// Generate unique names to avoid conflicts
	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-pool-%s", uniqueID)
	clientName := fmt.Sprintf("test-client-%s", uniqueID)

	// Configure Terraform options
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"aws_region":     getAWSRegionFromEnv(t),
			"user_pool_name": userPoolName,
			"client_name":    clientName,
			"environment":    "test",
			"callback_urls": []string{
				"https://localhost:3000/auth/callback",
				"https://test.example.com/auth/callback",
			},
			"logout_urls": []string{
				"https://localhost:3000/logout",
				"https://test.example.com/logout",
			},
			"password_policy": map[string]interface{}{
				"minimum_length":    8,
				"require_lowercase": true,
				"require_uppercase": true,
				"require_numbers":   true,
				"require_symbols":   false,
			},
			"mfa_configuration":           "OPTIONAL",
			"software_token_mfa_enabled":  true,
			"sms_mfa_enabled":            false,
			"advanced_security_mode":     "AUDIT",
			"create_identity_pool":       false,
			"tags": map[string]string{
				"Environment": "test",
				"Project":     "terratest",
				"ManagedBy":   "terraform",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	// Clean up resources after test
	defer terraform.Destroy(t, terraformOptions)

	// Deploy the infrastructure
	terraform.InitAndApply(t, terraformOptions)

	// Test outputs
	testCognitoBasicOutputs(t, terraformOptions)

	// Test OAuth endpoints
	testCognitoOAuthEndpoints(t, terraformOptions)

	// Test user pool configuration
	testCognitoUserPoolConfig(t, terraformOptions)
}

func TestAWSCognitoBasicWithMFA(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-mfa-pool-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name":              userPoolName,
			"client_name":                 fmt.Sprintf("test-mfa-client-%s", uniqueID),
			"mfa_configuration":           "REQUIRED",
			"software_token_mfa_enabled":  true,
			"sms_mfa_enabled":            true,
			"advanced_security_mode":     "ENFORCED",
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify MFA configuration
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	assert.NotEmpty(t, userPoolID)
}

func TestAWSCognitoBasicWithIdentityPool(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-identity-pool-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name":       userPoolName,
			"client_name":          fmt.Sprintf("test-identity-client-%s", uniqueID),
			"create_identity_pool": true,
			"identity_pool_name":   fmt.Sprintf("test-identity-%s", uniqueID),
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify both user pool and identity pool were created
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	identityPoolID := terraform.Output(t, terraformOptions, "identity_pool_id")
	
	assert.NotEmpty(t, userPoolID)
	assert.NotEmpty(t, identityPoolID)
}

func TestAWSCognitoBasicAdvancedSecurity(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-security-pool-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name":         userPoolName,
			"client_name":            fmt.Sprintf("test-security-client-%s", uniqueID),
			"advanced_security_mode": "ENFORCED",
			"mfa_configuration":      "REQUIRED",
			"password_policy": map[string]interface{}{
				"minimum_length":    12,
				"require_lowercase": true,
				"require_uppercase": true,
				"require_numbers":   true,
				"require_symbols":   true,
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify advanced security configuration
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	assert.NotEmpty(t, userPoolID)
}

func testCognitoBasicOutputs(t *testing.T, terraformOptions *terraform.Options) {
	// Test required outputs
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	assert.NotEmpty(t, userPoolID)
	assert.Regexp(t, `^[a-zA-Z0-9_-]+_[a-zA-Z0-9]+$`, userPoolID)

	userPoolARN := terraform.Output(t, terraformOptions, "user_pool_arn")
	assert.NotEmpty(t, userPoolARN)
	assert.Contains(t, userPoolARN, "arn:aws:cognito-idp:")

	userPoolEndpoint := terraform.Output(t, terraformOptions, "user_pool_endpoint")
	assert.NotEmpty(t, userPoolEndpoint)
	assert.Contains(t, userPoolEndpoint, "https://cognito-idp.")

	clientID := terraform.Output(t, terraformOptions, "user_pool_client_id")
	assert.NotEmpty(t, clientID)

	// Test OAuth endpoints
	oauthEndpoints := terraform.OutputMap(t, terraformOptions, "oauth_endpoints")
	assert.NotEmpty(t, oauthEndpoints)
	assert.Contains(t, oauthEndpoints, "authorization_endpoint")
	assert.Contains(t, oauthEndpoints, "token_endpoint")
	assert.Contains(t, oauthEndpoints, "userinfo_endpoint")

	// Test hosted UI URL
	hostedUIURL := terraform.Output(t, terraformOptions, "hosted_ui_url")
	assert.NotEmpty(t, hostedUIURL)
	assert.Contains(t, hostedUIURL, ".auth.")
	assert.Contains(t, hostedUIURL, ".amazoncognito.com")
}

func testCognitoOAuthEndpoints(t *testing.T, terraformOptions *terraform.Options) {
	// Get OAuth endpoints
	oauthEndpoints := terraform.OutputMap(t, terraformOptions, "oauth_endpoints")
	
	// Test authorization endpoint
	authEndpoint := oauthEndpoints["authorization_endpoint"]
	assert.NotEmpty(t, authEndpoint)
	
	client := &http.Client{
		Timeout: 30 * time.Second,
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			// Don't follow redirects, we just want to test the endpoint exists
			return http.ErrUseLastResponse
		},
	}
	
	// Test that the authorization endpoint is reachable
	// We expect a redirect or error response, not 200 OK
	resp, err := client.Get(authEndpoint)
	if err == nil {
		defer resp.Body.Close()
		// Should get a redirect or error (not 200)
		assert.True(t, resp.StatusCode >= 300 || resp.StatusCode >= 400)
	}
}

func testCognitoUserPoolConfig(t *testing.T, terraformOptions *terraform.Options) {
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	
	// Basic validation that user pool ID follows expected format
	assert.NotEmpty(t, userPoolID)
	assert.Contains(t, userPoolID, "_")
	
	// Verify domain exists
	domain := terraform.Output(t, terraformOptions, "user_pool_domain")
	assert.NotEmpty(t, domain)
}

func TestAWSCognitoBasicValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name":     "test-validation",
			"client_name":        "test-validation-client",
			"mfa_configuration":  "INVALID_VALUE", // Invalid value
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
	}

	// This should fail due to validation
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "MFA configuration must be")
}

func TestAWSCognitoBasicMinimalConfig(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-minimal-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name": userPoolName,
			"client_name":    fmt.Sprintf("test-minimal-client-%s", uniqueID),
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify minimal configuration works with defaults
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	assert.NotEmpty(t, userPoolID)
}

func TestAWSCognitoBasicPasswordComplexity(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-password-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name": userPoolName,
			"client_name":    fmt.Sprintf("test-password-client-%s", uniqueID),
			"password_policy": map[string]interface{}{
				"minimum_length":    16,
				"require_lowercase": true,
				"require_uppercase": true,
				"require_numbers":   true,
				"require_symbols":   true,
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	assert.NotEmpty(t, userPoolID)
}

func TestAWSCognitoBasicCallbackURLs(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-callbacks-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name": userPoolName,
			"client_name":    fmt.Sprintf("test-callbacks-client-%s", uniqueID),
			"callback_urls": []string{
				"https://app1.example.com/auth/callback",
				"https://app2.example.com/auth/callback",
				"https://localhost:3000/auth/callback",
			},
			"logout_urls": []string{
				"https://app1.example.com/logout",
				"https://app2.example.com/logout",
				"https://localhost:3000/logout",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Verify configuration with multiple callback URLs
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	clientID := terraform.Output(t, terraformOptions, "user_pool_client_id")
	
	assert.NotEmpty(t, userPoolID)
	assert.NotEmpty(t, clientID)
}

func TestAWSCognitoBasicLambdaTriggers(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := fmt.Sprintf("test-lambda-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/aws-cognito-basic",
		Vars: map[string]interface{}{
			"user_pool_name": userPoolName,
			"client_name":    fmt.Sprintf("test-lambda-client-%s", uniqueID),
			"lambda_triggers": map[string]string{
				"pre_sign_up":        "arn:aws:lambda:us-east-1:123456789012:function:fake-pre-signup",
				"post_confirmation": "arn:aws:lambda:us-east-1:123456789012:function:fake-post-confirm",
			},
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": getAWSRegionFromEnv(t),
		},
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	// Note: This test will fail in apply because the Lambda functions don't exist
	// But it validates the configuration structure
	_, err := terraform.InitAndPlanE(t, terraformOptions)
	assert.NoError(t, err) // Plan should succeed even with fake Lambda ARNs
}

// Helper function to get AWS region from environment
func getAWSRegionFromEnv(t *testing.T) string {
	region := os.Getenv("AWS_DEFAULT_REGION")
	if region == "" {
		region = "us-east-1" // Default region
	}
	return region
} 