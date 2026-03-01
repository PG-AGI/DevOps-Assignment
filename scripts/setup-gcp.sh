#!/bin/bash
# GCP Service Account Setup Script
# Run this script to create a service account and generate a key

set -e

echo "=== GCP Service Account Setup ==="
echo "This script will create a service account with required permissions."

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed. Please install it first."
    echo "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "Error: gcloud not authenticated. Run 'gcloud auth login' first."
    exit 1
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "Error: No GCP project set. Run 'gcloud config set project YOUR_PROJECT_ID' first."
    exit 1
fi

echo "Current GCP Project: $PROJECT_ID"

# Service account details
SERVICE_ACCOUNT_NAME="devops-deploy"
SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Creating service account: $SERVICE_ACCOUNT_EMAIL"

# Check if service account exists
if gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL --project=$PROJECT_ID &> /dev/null; then
    echo "Service account already exists."
else
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
        --display-name="DevOps Deployment SA" \
        --description="Service account for DevOps assignment deployment"
    echo "Service account created successfully."
fi

# Grant roles to service account
echo "Granting roles to service account..."

ROLES=(
    "roles/cloudrun.admin"
    "roles/storage.admin"
    "roles/secretmanager.admin"
    "roles/compute.admin"
    "roles/iam.serviceAccountUser"
    "roles/logging.logWriter"
    "roles/monitoring.metricWriter"
)

for ROLE in "${ROLES[@]}"; do
    echo "  - Granting $ROLE"
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
        --role="$ROLE" --quiet
done

echo "Roles granted successfully."

# Create JSON key
KEY_FILE="${SERVICE_ACCOUNT_NAME}-key.json"
echo "Creating JSON key: $KEY_FILE"

gcloud iam service-accounts keys create $KEY_FILE \
    --iam-account=$SERVICE_ACCOUNT_EMAIL \
    --key-file-type=json

echo ""
echo "=== Credentials Generated ==="
echo "Key file created: $KEY_FILE"
echo ""
echo "Next steps:"
echo "1. Copy the content of $KEY_FILE"
echo "2. Add to GitHub secrets:"
echo "   - GCP_SA_KEY: <paste the JSON content>"
echo "   - GCP_PROJECT_ID: $PROJECT_ID"
echo ""
echo "IMPORTANT: Keep the key file secure and never commit it to git!"
