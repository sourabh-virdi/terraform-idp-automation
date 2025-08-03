#!/bin/bash

# Terraform IdP Automation Test Runner
# This script runs comprehensive tests for all identity provider modules

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_TIMEOUT="30m"
DEFAULT_PARALLEL="4"
DEFAULT_PROVIDERS="aws-cognito,azure-ad,okta,keycloak"

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

usage() {
    cat << EOF
Terraform IdP Automation Test Runner

USAGE:
    $0 [OPTIONS] [COMMAND]

COMMANDS:
    all             Run all tests (default)
    aws-cognito     Run AWS Cognito tests only
    azure-ad        Run Azure AD tests only
    okta            Run Okta tests only
    keycloak        Run Keycloak tests only
    unit            Run unit tests only
    integration     Run integration tests only
    validation      Run validation tests only
    setup           Setup test environment
    clean           Clean up test resources
    coverage        Generate test coverage report

OPTIONS:
    -t, --timeout DURATION    Test timeout (default: ${DEFAULT_TIMEOUT})
    -p, --parallel NUMBER     Number of parallel tests (default: ${DEFAULT_PARALLEL})
    -v, --verbose             Enable verbose output
    -d, --debug               Enable debug mode
    -h, --help                Show this help message

ENVIRONMENT VARIABLES:
    AWS_ACCESS_KEY_ID         AWS access key
    AWS_SECRET_ACCESS_KEY     AWS secret key
    AWS_DEFAULT_REGION        AWS region (default: us-east-1)
    
    ARM_TENANT_ID             Azure tenant ID
    ARM_CLIENT_ID             Azure client ID
    ARM_CLIENT_SECRET         Azure client secret
    ARM_SUBSCRIPTION_ID       Azure subscription ID
    
    OKTA_ORG_NAME            Okta organization name
    OKTA_BASE_URL            Okta base URL (default: okta.com)
    OKTA_API_TOKEN           Okta API token
    
    KEYCLOAK_URL             Keycloak server URL (default: http://localhost:8080)
    KEYCLOAK_USERNAME        Keycloak admin username (default: admin)
    KEYCLOAK_PASSWORD        Keycloak admin password (default: admin)

EXAMPLES:
    # Run all tests
    $0 all

    # Run AWS Cognito tests with verbose output
    $0 -v aws-cognito

    # Run tests with custom timeout and debug mode
    $0 -t 45m -d all

    # Generate coverage report
    $0 coverage

    # Setup environment and run Azure AD tests
    $0 setup && $0 azure-ad

EOF
}

check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check Go installation
    if ! command -v go &> /dev/null; then
        print_error "Go is not installed. Please install Go 1.19 or later."
        exit 1
    fi
    
    go_version=$(go version | grep -oE 'go[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+')
    print_success "Go version: $go_version"
    
    # Check Terraform installation
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform 1.0 or later."
        exit 1
    fi
    
    terraform_version=$(terraform version | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
    print_success "Terraform version: $terraform_version"
    
    # Check if we're in the right directory
    if [[ ! -f "go.mod" ]]; then
        print_error "Please run this script from the test directory."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

setup_environment() {
    print_header "Setting Up Test Environment"
    
    # Initialize Go module
    print_info "Initializing Go module..."
    go mod tidy
    
    # Download dependencies
    print_info "Downloading dependencies..."
    go mod download
    
    # Verify module integrity
    print_info "Verifying module integrity..."
    go mod verify
    
    print_success "Environment setup completed"
}

check_credentials() {
    local provider=$1
    
    case $provider in
        "aws-cognito")
            if [[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
                print_warning "AWS credentials not set. Some tests may be skipped."
                return 1
            fi
            print_success "AWS credentials configured"
            ;;
        "azure-ad")
            if [[ -z "$ARM_TENANT_ID" ]]; then
                print_warning "Azure credentials not set. Some tests may be skipped."
                return 1
            fi
            print_success "Azure credentials configured"
            ;;
        "okta")
            if [[ -z "$OKTA_ORG_NAME" ]] || [[ -z "$OKTA_API_TOKEN" ]]; then
                print_warning "Okta credentials not set. Some tests may be skipped."
                return 1
            fi
            print_success "Okta credentials configured"
            ;;
        "keycloak")
            if [[ -z "$KEYCLOAK_URL" ]]; then
                export KEYCLOAK_URL="http://localhost:8080"
                print_info "Using default Keycloak URL: $KEYCLOAK_URL"
            fi
            if [[ -z "$KEYCLOAK_USERNAME" ]]; then
                export KEYCLOAK_USERNAME="admin"
            fi
            if [[ -z "$KEYCLOAK_PASSWORD" ]]; then
                export KEYCLOAK_PASSWORD="admin"
            fi
            print_success "Keycloak credentials configured"
            ;;
    esac
    return 0
}

run_tests() {
    local provider=$1
    local timeout=$2
    local parallel=$3
    local verbose=$4
    local debug=$5
    
    # Convert provider name to test pattern
    local test_pattern=""
    case $provider in
        "aws-cognito")
            test_pattern="TestAWSCognito"
            ;;
        "azure-ad")
            test_pattern="TestAzureAD"
            ;;
        "okta")
            test_pattern="TestOkta"
            ;;
        "keycloak")
            test_pattern="TestKeycloak"
            ;;
        "unit")
            test_pattern="TestUnit"
            ;;
        "integration")
            test_pattern="TestIntegration"
            ;;
        "validation")
            test_pattern="Validation"
            ;;
        "all")
            test_pattern=""
            ;;
    esac
    
    # Build test command
    local cmd="go test"
    
    if [[ $verbose == "true" ]]; then
        cmd="$cmd -v"
    fi
    
    cmd="$cmd -timeout $timeout"
    cmd="$cmd -parallel $parallel"
    
    if [[ -n $test_pattern ]]; then
        cmd="$cmd -run $test_pattern"
    fi
    
    # Set environment variables for debug mode
    if [[ $debug == "true" ]]; then
        export TF_LOG=DEBUG
        export TERRATEST_LOG_PARSER=false
    fi
    
    print_header "Running Tests: $provider"
    print_info "Command: $cmd"
    
    # Check credentials for specific provider
    if [[ $provider != "all" ]] && [[ $provider != "unit" ]] && [[ $provider != "validation" ]]; then
        check_credentials $provider
    fi
    
    # Run tests
    if eval $cmd; then
        print_success "Tests passed for $provider"
        return 0
    else
        print_error "Tests failed for $provider"
        return 1
    fi
}

run_coverage() {
    print_header "Generating Test Coverage Report"
    
    local coverage_file="coverage.out"
    local coverage_html="coverage.html"
    
    print_info "Running tests with coverage..."
    go test -v -timeout 30m -coverprofile=$coverage_file ./...
    
    if [[ -f $coverage_file ]]; then
        print_info "Generating HTML coverage report..."
        go tool cover -html=$coverage_file -o $coverage_html
        
        print_info "Coverage summary:"
        go tool cover -func=$coverage_file
        
        print_success "Coverage report generated: $coverage_html"
    else
        print_error "Coverage file not generated"
        return 1
    fi
}

cleanup_resources() {
    print_header "Cleaning Up Test Resources"
    
    # This would ideally scan for any leftover Terraform state files
    # and run terraform destroy on them
    
    local cleanup_dirs=(
        "../examples/aws-cognito-basic"
        "../examples/azure-ad-sso"
        "../examples/okta-integration"
        "../examples/keycloak-setup"
        "../examples/multi-provider"
    )
    
    for dir in "${cleanup_dirs[@]}"; do
        if [[ -d "$dir" ]] && [[ -f "$dir/.terraform/terraform.tfstate" ]]; then
            print_info "Cleaning up resources in $dir..."
            (cd "$dir" && terraform destroy -auto-approve) || true
        fi
    done
    
    print_success "Cleanup completed"
}

validate_environment() {
    print_header "Validating Test Environment"
    
    # Check network connectivity
    print_info "Checking network connectivity..."
    
    # AWS
    if curl -f -s https://cognito-idp.us-east-1.amazonaws.com/ > /dev/null; then
        print_success "AWS Cognito service reachable"
    else
        print_warning "AWS Cognito service not reachable"
    fi
    
    # Azure
    if curl -f -s https://login.microsoftonline.com/ > /dev/null; then
        print_success "Azure AD service reachable"
    else
        print_warning "Azure AD service not reachable"
    fi
    
    # Okta (if configured)
    if [[ -n "$OKTA_ORG_NAME" ]]; then
        if curl -f -s "https://$OKTA_ORG_NAME.okta.com/" > /dev/null; then
            print_success "Okta service reachable"
        else
            print_warning "Okta service not reachable"
        fi
    fi
    
    # Keycloak
    if curl -f -s "${KEYCLOAK_URL:-http://localhost:8080}/" > /dev/null; then
        print_success "Keycloak service reachable"
    else
        print_warning "Keycloak service not reachable"
    fi
    
    print_success "Environment validation completed"
}

# Parse command line arguments
TIMEOUT=$DEFAULT_TIMEOUT
PARALLEL=$DEFAULT_PARALLEL
VERBOSE="false"
DEBUG="false"
COMMAND=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -p|--parallel)
            PARALLEL="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="true"
            shift
            ;;
        -d|--debug)
            DEBUG="true"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        all|aws-cognito|azure-ad|okta|keycloak|unit|integration|validation|setup|clean|coverage)
            COMMAND="$1"
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Default command
if [[ -z "$COMMAND" ]]; then
    COMMAND="all"
fi

# Main execution
print_header "Terraform IdP Automation Test Runner"
print_info "Command: $COMMAND"
print_info "Timeout: $TIMEOUT"
print_info "Parallel: $PARALLEL"
print_info "Verbose: $VERBOSE"
print_info "Debug: $DEBUG"

# Execute command
case $COMMAND in
    "setup")
        check_prerequisites
        setup_environment
        validate_environment
        ;;
    "clean")
        cleanup_resources
        ;;
    "coverage")
        check_prerequisites
        setup_environment
        run_coverage
        ;;
    "all")
        check_prerequisites
        setup_environment
        
        # Run tests for each provider
        providers=("aws-cognito" "azure-ad" "okta" "keycloak")
        failed_providers=()
        
        for provider in "${providers[@]}"; do
            if ! run_tests "$provider" "$TIMEOUT" "$PARALLEL" "$VERBOSE" "$DEBUG"; then
                failed_providers+=("$provider")
            fi
        done
        
        if [[ ${#failed_providers[@]} -eq 0 ]]; then
            print_success "All tests passed!"
            exit 0
        else
            print_error "Tests failed for: ${failed_providers[*]}"
            exit 1
        fi
        ;;
    *)
        check_prerequisites
        setup_environment
        run_tests "$COMMAND" "$TIMEOUT" "$PARALLEL" "$VERBOSE" "$DEBUG"
        ;;
esac 