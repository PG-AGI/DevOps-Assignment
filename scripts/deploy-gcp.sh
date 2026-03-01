#!/bin/bash
# GCP Deployment Script for DevOps Assignment
# Run this in GCP Cloud Shell

set -e

echo "=== GCP Deployment Script ==="

# Configuration
PROJECT_ID="my-project-devops-488902"
REGION="us-central1"
BACKEND_SERVICE="devops-assignment-backend"
FRONTEND_SERVICE="devops-assignment-frontend"

echo "Project: $PROJECT_ID"
echo "Region: $REGION"

# Set project
echo "Setting project..."
gcloud config set project $PROJECT_ID

# Enable services
echo "Enabling services..."
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com

# Deploy backend
echo "Deploying backend..."
BACKEND_URL=$(gcloud run deploy $BACKEND_SERVICE \
    --source ./backend \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 1 \
    --max-instances 10 \
    --set-env-vars ENVIRONMENT=prod \
    --format 'value(status.url)')

echo "Backend deployed to: $BACKEND_URL"

# Deploy frontend
echo "Deploying frontend..."
gcloud run deploy $FRONTEND_SERVICE \
    --source ./frontend \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 1 \
    --max-instances 10 \
    --set-env-vars NEXT_PUBLIC_API_URL="$BACKEND_URL"

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe $FRONTEND_SERVICE --region $REGION --format 'value(status.url)')

echo "=== Deployment Complete ==="
echo "Backend: $BACKEND_URL"
echo "Frontend: $FRONTEND_URL"

# Test endpoints
echo ""
echo "Testing endpoints..."
curl -f "${BACKEND_URL}/api/health" && echo " - Health OK"
curl -f "${BACKEND_URL}/api/message" && echo " - Message OK"
