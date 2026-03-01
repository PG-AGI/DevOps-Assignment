# GCP Service Account Setup Script (PowerShell)
# Run this script to create a service account and generate a key

Write-Host "=== GCP Service Account Setup ===" -ForegroundColor Cyan
Write-Host "This script will create a service account with required permissions."

# Check if gcloud CLI is installed
$gcloudCmd = Get-Command gcloud -ErrorAction SilentlyContinue
if (-not $gcloudCmd) {
    Write-Host "Error: gcloud CLI is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit: https://cloud.google.com/sdk/docs/install"
    exit 1
}

# Check if gcloud is authenticated
try {
    $account = gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>$null
    if (-not $account) {
        Write-Host "Error: gcloud not authenticated. Run 'gcloud auth login' first." -ForegroundColor Red
        exit 1
    }
    Write-Host "Authenticated as: $account" -ForegroundColor Green
} catch {
    Write-Host "Error: gcloud not authenticated. Run 'gcloud auth login' first." -ForegroundColor Red
    exit 1
}

# Get current project
$PROJECT_ID = gcloud config get-value project 2>$null
if (-not $PROJECT_ID) {
    Write-Host "Error: No GCP project set. Run 'gcloud config set project YOUR_PROJECT_ID' first." -ForegroundColor Red
    exit 1
}

Write-Host "Current GCP Project: $PROJECT_ID" -ForegroundColor Green

$SERVICE_ACCOUNT_NAME = "devops-deploy"
$SERVICE_ACCOUNT_EMAIL = "${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

Write-Host "Creating service account: $SERVICE_ACCOUNT_EMAIL"

# Check if service account exists
$saExists = gcloud iam service-accounts describe $SERVICE_ACCOUNT_EMAIL --project=$PROJECT_ID 2>$null
if ($saExists) {
    Write-Host "Service account already exists." -ForegroundColor Yellow
} else {
    gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME `
        --display-name="DevOps Deployment SA" `
        --description="Service account for DevOps assignment deployment"
    Write-Host "Service account created successfully." -ForegroundColor Green
}

# Grant roles to service account
Write-Host "Granting roles to service account..."

$roles = @(
    "roles/cloudrun.admin",
    "roles/storage.admin",
    "roles/secretmanager.admin",
    "roles/compute.admin",
    "roles/iam.serviceAccountUser",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
)

foreach ($role in $roles) {
    Write-Host "  - Granting $role"
    gcloud projects add-iam-policy-binding $PROJECT_ID `
        --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" `
        --role="$role" --quiet 2>$null
}

Write-Host "Roles granted successfully." -ForegroundColor Green

# Create JSON key
$KEY_FILE = "${SERVICE_ACCOUNT_NAME}-key.json"
Write-Host "Creating JSON key: $KEY_FILE"

gcloud iam service-accounts keys create $KEY_FILE `
    --iam-account=$SERVICE_ACCOUNT_EMAIL `
    --key-file-type=json

$keyContent = Get-Content $KEY_FILE -Raw

Write-Host ""
Write-Host "=== Credentials Generated ===" -ForegroundColor Cyan
Write-Host "Key file created: $KEY_FILE"
Write-Host ""
Write-Host "GCP_PROJECT_ID: $PROJECT_ID"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Copy the content of $KEY_FILE"
Write-Host "2. Add to GitHub secrets:"
Write-Host "   - GCP_SA_KEY: <paste the JSON content>"
Write-Host "   - GCP_PROJECT_ID: $PROJECT_ID"
Write-Host ""
Write-Host "IMPORTANT: Keep the key file secure!" -ForegroundColor Yellow
