# AWS Credential Setup Script (PowerShell)
# Run this script to create IAM user and generate access keys

Write-Host "=== AWS Credential Setup ===" -ForegroundColor Cyan
Write-Host "This script will create an IAM user with required permissions for deployment."

# Check if AWS CLI is installed
$awsCmd = Get-Command aws -ErrorAction SilentlyContinue
if (-not $awsCmd) {
    Write-Host "Error: AWS CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit: https://aws.amazon.com/cli/"
    exit 1
}

# Check if AWS credentials are configured
try {
    $identity = aws sts get-caller-identity 2>$null | ConvertFrom-Json
    Write-Host "Current AWS Account: $($identity.Account)" -ForegroundColor Green
} catch {
    Write-Host "Error: AWS credentials not configured. Run 'aws configure' first." -ForegroundColor Red
    exit 1
}

$IAM_USER = "devops-deploy"
Write-Host "Creating IAM user: $IAM_USER"

# Check if user exists
$userExists = aws iam get-user --user-name $IAM_USER 2>$null
if ($userExists) {
    Write-Host "User $IAM_USER already exists." -ForegroundColor Yellow
} else {
    aws iam create-user --user-name $IAM_USER
    Write-Host "User created successfully." -ForegroundColor Green
}

# Create and attach IAM policy
$POLICY_NAME = "DevOpsAssignmentPolicy"
Write-Host "Creating IAM policy: $POLICY_NAME"

# Read the policy file
$policyPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$policyPath = Join-Path $policyPath "..\infrastructure\iam\aws-policy.json"
$POLICY_DOC = Get-Content $policyPath -Raw

# Create policy
aws iam put-user-policy `
    --user-name $IAM_USER `
    --policy-name $POLICY_NAME `
    --policy-document "$POLICY_DOC"

Write-Host "Policy attached successfully." -ForegroundColor Green

# Create access key
Write-Host "Creating access key..."
$accessKeyOutput = aws iam create-access-key --user-name $IAM_USER | ConvertFrom-Json
$ACCESS_KEY = $accessKeyOutput.AccessKey.AccessKeyId
$SECRET_KEY = $accessKeyOutput.AccessKey.SecretAccessKey

Write-Host ""
Write-Host "=== Credentials Generated ===" -ForegroundColor Cyan
Write-Host "AWS_ACCESS_KEY_ID: $ACCESS_KEY"
Write-Host "AWS_SECRET_ACCESS_KEY: $SECRET_KEY"
Write-Host ""
Write-Host "IMPORTANT: Save these credentials now!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Add these to GitHub repository secrets"
