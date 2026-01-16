#!/bin/bash

# CI/CD Pipeline Setup Script
# This script automates the creation of cloud resources needed for the CI/CD pipeline

set -e

echo "================================"
echo "CI/CD Pipeline Setup Script"
echo "================================"

# Check prerequisites
check_prerequisites() {
    echo ""
    echo "Checking prerequisites..."
    
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Please install it."
        exit 1
    fi
    
    if ! command -v gcloud &> /dev/null; then
        echo "Google Cloud SDK not found. Please install it."
        exit 1
    fi
    
    if ! command -v az &> /dev/null; then
        echo "Azure CLI not found. Please install it."
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        echo "Docker not found. Please install it."
        exit 1
    fi
    
    echo "✓ All prerequisites installed"
}

# Setup AWS resources
setup_aws() {
    echo ""
    echo "=== AWS Setup ==="
    
    read -p "Enter AWS Region (e.g., us-east-1): " AWS_REGION
    read -p "Enter ECR Repository Name for Backend (e.g., pg-agi-backend): " ECR_BACKEND
    read -p "Enter ECR Repository Name for Frontend (e.g., pg-agi-frontend): " ECR_FRONTEND
    read -p "Enter ECS Cluster Name (e.g., pg-agi-cluster): " ECS_CLUSTER
    
    # Configure AWS
    aws configure set region $AWS_REGION
    
    # Get Account ID
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    echo "✓ AWS Account ID: $ACCOUNT_ID"
    
    # Create ECR repositories
    echo "Creating ECR repositories..."
    aws ecr create-repository --repository-name $ECR_BACKEND --region $AWS_REGION 2>/dev/null || echo "  Repository $ECR_BACKEND already exists"
    aws ecr create-repository --repository-name $ECR_FRONTEND --region $AWS_REGION 2>/dev/null || echo "  Repository $ECR_FRONTEND already exists"
    
    # Create ECS Cluster
    echo "Creating ECS cluster..."
    aws ecs create-cluster --cluster-name $ECS_CLUSTER --region $AWS_REGION 2>/dev/null || echo "  Cluster $ECS_CLUSTER already exists"
    
    echo "✓ AWS resources created/verified"
    
    # Output secrets
    cat > aws-secrets.env <<EOF
AWS_ACCOUNT_ID=$ACCOUNT_ID
AWS_REGION=$AWS_REGION
AWS_ECS_CLUSTER=$ECS_CLUSTER
AWS_ECR_REPOSITORY_BACKEND=$ECR_BACKEND
AWS_ECR_REPOSITORY_FRONTEND=$ECR_FRONTEND
EOF
    
    echo "✓ AWS secrets saved to aws-secrets.env"
}

# Setup GCP resources
setup_gcp() {
    echo ""
    echo "=== GCP Setup ==="
    
    read -p "Enter GCP Project ID: " GCP_PROJECT
    read -p "Enter GCP Region (e.g., us-central1): " GCP_REGION
    
    # Set project
    gcloud config set project $GCP_PROJECT
    
    # Enable required APIs
    echo "Enabling required GCP APIs..."
    gcloud services enable \
        containerregistry.googleapis.com \
        run.googleapis.com \
        cloudresourcemanager.googleapis.com \
        iam.googleapis.com
    
    # Create service account
    echo "Creating service account for GitHub Actions..."
    SERVICE_ACCOUNT="github-actions"
    
    gcloud iam service-accounts create $SERVICE_ACCOUNT \
        --display-name="GitHub Actions" 2>/dev/null || echo "  Service account $SERVICE_ACCOUNT already exists"
    
    # Grant permissions
    gcloud projects add-iam-policy-binding $GCP_PROJECT \
        --member=serviceAccount:${SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com \
        --role=roles/run.admin \
        --quiet
    
    gcloud projects add-iam-policy-binding $GCP_PROJECT \
        --member=serviceAccount:${SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com \
        --role=roles/storage.admin \
        --quiet
    
    # Create and encode key
    echo "Creating service account key..."
    gcloud iam service-accounts keys create /tmp/gcp-key.json \
        --iam-account=${SERVICE_ACCOUNT}@${GCP_PROJECT}.iam.gserviceaccount.com
    
    GCP_SA_KEY=$(base64 -w 0 /tmp/gcp-key.json)
    
    # Output secrets
    cat > gcp-secrets.env <<EOF
GCP_PROJECT_ID=$GCP_PROJECT
GCP_REGION=$GCP_REGION
GCP_SA_KEY=$GCP_SA_KEY
EOF
    
    echo "✓ GCP resources created/verified"
    echo "✓ GCP secrets saved to gcp-secrets.env"
    rm -f /tmp/gcp-key.json
}

# Setup Azure resources
setup_azure() {
    echo ""
    echo "=== Azure Setup ==="
    
    read -p "Enter Azure Subscription ID: " SUBSCRIPTION_ID
    read -p "Enter Azure Resource Group Name: " RESOURCE_GROUP
    read -p "Enter Azure Region (e.g., eastus): " AZURE_REGION
    read -p "Enter ACR Name (e.g., pgagiregistry): " ACR_NAME
    
    # Set subscription
    az account set --subscription $SUBSCRIPTION_ID
    
    # Create resource group
    echo "Creating resource group..."
    az group create \
        --name $RESOURCE_GROUP \
        --location $AZURE_REGION 2>/dev/null || echo "  Resource group $RESOURCE_GROUP already exists"
    
    # Create ACR
    echo "Creating Azure Container Registry..."
    az acr create \
        --resource-group $RESOURCE_GROUP \
        --name $ACR_NAME \
        --sku Standard 2>/dev/null || echo "  ACR $ACR_NAME already exists"
    
    # Get credentials
    ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query username --output tsv)
    ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query 'passwords[0].value' --output tsv)
    
    # Output secrets
    cat > azure-secrets.env <<EOF
AZURE_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
AZURE_RESOURCE_GROUP=$RESOURCE_GROUP
AZURE_REGION=$AZURE_REGION
AZURE_REGISTRY_NAME=$ACR_NAME
AZURE_REGISTRY_USERNAME=$ACR_USERNAME
AZURE_REGISTRY_PASSWORD=$ACR_PASSWORD
EOF
    
    echo "✓ Azure resources created/verified"
    echo "✓ Azure secrets saved to azure-secrets.env"
}

# Setup GitHub secrets
setup_github_secrets() {
    echo ""
    echo "=== GitHub Secrets Setup ==="
    
    if ! command -v gh &> /dev/null; then
        echo "⚠ GitHub CLI (gh) not found. Please manually add secrets to GitHub."
        echo "Visit: https://github.com/YOUR_REPO/settings/secrets/actions"
        return
    fi
    
    read -p "Automatically upload secrets to GitHub? (y/n): " AUTO_SETUP
    
    if [ "$AUTO_SETUP" != "y" ]; then
        return
    fi
    
    # Load and set secrets
    if [ -f aws-secrets.env ]; then
        source aws-secrets.env
        echo "Setting AWS secrets..."
        gh secret set AWS_ACCOUNT_ID --body "$AWS_ACCOUNT_ID"
        gh secret set AWS_REGION --body "$AWS_REGION"
        gh secret set AWS_ECS_CLUSTER --body "$AWS_ECS_CLUSTER"
    fi
    
    if [ -f gcp-secrets.env ]; then
        source gcp-secrets.env
        echo "Setting GCP secrets..."
        gh secret set GCP_PROJECT_ID --body "$GCP_PROJECT_ID"
        gh secret set GCP_REGION --body "$GCP_REGION"
        gh secret set GCP_SA_KEY --body "$GCP_SA_KEY"
    fi
    
    if [ -f azure-secrets.env ]; then
        source azure-secrets.env
        echo "Setting Azure secrets..."
        gh secret set AZURE_REGISTRY_NAME --body "$AZURE_REGISTRY_NAME"
        gh secret set AZURE_REGISTRY_USERNAME --body "$AZURE_REGISTRY_USERNAME"
        gh secret set AZURE_REGISTRY_PASSWORD --body "$AZURE_REGISTRY_PASSWORD"
    fi
    
    echo "✓ GitHub secrets updated"
}

# Main setup flow
main() {
    check_prerequisites
    
    read -p "Setup AWS resources? (y/n): " SETUP_AWS
    if [ "$SETUP_AWS" = "y" ]; then
        setup_aws
    fi
    
    read -p "Setup GCP resources? (y/n): " SETUP_GCP
    if [ "$SETUP_GCP" = "y" ]; then
        setup_gcp
    fi
    
    read -p "Setup Azure resources? (y/n): " SETUP_AZURE
    if [ "$SETUP_AZURE" = "y" ]; then
        setup_azure
    fi
    
    setup_github_secrets
    
    echo ""
    echo "================================"
    echo "✓ Setup Complete!"
    echo "================================"
    echo ""
    echo "Next steps:"
    echo "1. Review the secret files created (aws-secrets.env, gcp-secrets.env, azure-secrets.env)"
    echo "2. Verify secrets are set in GitHub: gh secret list"
    echo "3. Push to develop branch to test the CI pipeline"
    echo "4. Merge to main branch to test deployments"
    echo ""
    echo "Documentation: .github/PIPELINE.md"
}

main
