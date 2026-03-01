#!/bin/bash
# AWS Credential Setup Script
# Run this script to create IAM user and generate access keys

set -e

echo "=== AWS Credential Setup ==="
echo "This script will create an IAM user with required permissions for deployment."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    echo "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS credentials not configured. Run 'aws configure' first."
    exit 1
fi

# Get current account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
echo "Current AWS Account: $ACCOUNT_ID"

# Create IAM user
IAM_USER="devops-deploy"
echo "Creating IAM user: $IAM_USER"

# Check if user exists
if aws iam get-user --user-name $IAM_USER 2>/dev/null; then
    echo "User $IAM_USER already exists."
else
    aws iam create-user --user-name $IAM_USER
    echo "User created successfully."
fi

# Create and attach IAM policy
POLICY_NAME="DevOpsAssignmentPolicy"
echo "Creating IAM policy: $POLICY_NAME"

# Read the policy file
POLICY_DOC=$(cat ../infrastructure/iam/aws-policy.json)

# Create policy
aws iam put-user-policy \
    --user-name $IAM_USER \
    --policy-name $POLICY_NAME \
    --policy-document "$POLICY_DOC"

echo "Policy attached successfully."

# Create access key
echo "Creating access key..."
ACCESS_KEY=$(aws iam create-access-key --user-name $IAM_USER --query 'AccessKey.AccessKeyId' --output text)
SECRET_KEY=$(aws iam create-access-key --user-name $IAM_USER --query 'AccessKey.SecretAccessKey' --output text)

echo ""
echo "=== Credentials Generated ==="
echo "AWS_ACCESS_KEY_ID: $ACCESS_KEY"
echo "AWS_SECRET_ACCESS_KEY: $SECRET_KEY"
echo ""
echo "IMPORTANT: Save these credentials now. The secret key will not be shown again!"
echo ""
echo "Next steps:"
echo "1. Add these to GitHub repository secrets"
echo "2. Run: aws configure --profile devops-deploy"
echo "   (use the credentials above)"
