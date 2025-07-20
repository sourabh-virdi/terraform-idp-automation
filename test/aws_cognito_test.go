package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAWSCognitoModule(t *testing.T) {
	t.Parallel()

	// Generate unique names for test resources
	uniqueID := random.UniqueId()
	userPoolName := "test-pool-" + uniqueID
	clientName := "test-client-" + uniqueID

	// Terraform options
	terraformOptions := &terraform.Options{
		// Path to the Terraform configuration
		TerraformDir: "../modules/aws-cognito",

		// Variables to pass to the Terraform code
		Vars: map[string]interface{}{
			"user_pool_name": userPoolName,
			"client_name":    clientName,
			"tags": map[string]string{
				"Environment": "test",
				"Purpose":     "terratest",
			},
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},

		// Retry up to 3 times, with 5 seconds between retries
		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	// Clean up resources after test
	defer terraform.Destroy(t, terraformOptions)

	// Run terraform init and apply
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	userPoolArn := terraform.Output(t, terraformOptions, "user_pool_arn")
	clientID := terraform.Output(t, terraformOptions, "user_pool_client_id")

	// Verify outputs are not empty
	assert.NotEmpty(t, userPoolID)
	assert.NotEmpty(t, userPoolArn)
	assert.NotEmpty(t, clientID)

	// Verify naming convention
	assert.Contains(t, userPoolID, "us-east-1_") // Cognito user pool ID format
}

func TestAWSCognitoWithSAML(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := "test-saml-pool-" + uniqueID
	clientName := "test-saml-client-" + uniqueID

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aws-cognito",

		Vars: map[string]interface{}{
			"user_pool_name": userPoolName,
			"client_name":    clientName,
			"saml_providers": map[string]interface{}{
				"TestSAML": map[string]interface{}{
					"provider_name":              "TestSAML",
					"metadata_url":              "https://example.com/metadata.xml",
					"sso_redirect_binding_uri":  "https://example.com/sso",
					"slo_redirect_binding_uri":  "https://example.com/slo",
					"attribute_mapping": map[string]string{
						"email": "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress",
					},
				},
			},
			"tags": map[string]string{
				"Environment": "test",
				"Purpose":     "terratest-saml",
			},
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},

		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate SAML provider configuration
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	samlProviders := terraform.OutputMap(t, terraformOptions, "saml_providers")

	assert.NotEmpty(t, userPoolID)
	assert.Contains(t, samlProviders, "TestSAML")
}

func TestAWSCognitoWithIdentityPool(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := "test-identity-pool-" + uniqueID
	clientName := "test-identity-client-" + uniqueID
	identityPoolName := "test-identity-pool-" + uniqueID

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aws-cognito",

		Vars: map[string]interface{}{
			"user_pool_name":        userPoolName,
			"client_name":           clientName,
			"create_identity_pool":  true,
			"identity_pool_name":    identityPoolName,
			"tags": map[string]string{
				"Environment": "test",
				"Purpose":     "terratest-identity",
			},
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},

		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate identity pool creation
	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	identityPoolID := terraform.Output(t, terraformOptions, "identity_pool_id")
	authenticatedRoleArn := terraform.Output(t, terraformOptions, "authenticated_role_arn")

	assert.NotEmpty(t, userPoolID)
	assert.NotEmpty(t, identityPoolID)
	assert.NotEmpty(t, authenticatedRoleArn)
	assert.Contains(t, authenticatedRoleArn, "arn:aws:iam::")
}

func TestAWSCognitoPasswordPolicy(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	userPoolName := "test-password-pool-" + uniqueID
	clientName := "test-password-client-" + uniqueID

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/aws-cognito",

		Vars: map[string]interface{}{
			"user_pool_name": userPoolName,
			"client_name":    clientName,
			"password_policy": map[string]interface{}{
				"minimum_length":    12,
				"require_lowercase": true,
				"require_numbers":   true,
				"require_symbols":   true,
				"require_uppercase": true,
			},
			"advanced_security_mode": "ENFORCED",
			"tags": map[string]string{
				"Environment": "test",
				"Purpose":     "terratest-security",
			},
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},

		MaxRetries:         3,
		TimeBetweenRetries: 5 * time.Second,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	userPoolID := terraform.Output(t, terraformOptions, "user_pool_id")
	assert.NotEmpty(t, userPoolID)

	// Additional validation could include AWS SDK calls to verify
	// the actual password policy configuration
} 