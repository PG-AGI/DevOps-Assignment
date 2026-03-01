# Deployment Guide for GCP Cloud Shell

## Step 1: Navigate to your project directory

```
bash
cd DevOps-Assignment
```

## Step 2: Set the project

```
bash
gcloud config set project my-project-devops-488902
```

## Step 3: Enable required services

```
bash
gcloud services enable run.googleapis.com cloudbuild.googleapis.com artifactregistry.googleapis.com
```

## Step 4: Deploy the Backend

```
bash
gcloud run deploy devops-assignment-backend \
  --source ./backend \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 1 \
  --max-instances 10 \
  --set-env-vars ENVIRONMENT=prod
```

**Copy the backend URL** (it will look like: `https://devops-assignment-backend-xxx.a.run.app`)

## Step 5: Deploy the Frontend

Replace `YOUR_BACKEND_URL` with the URL from Step 4:

```
bash
gcloud run deploy devops-assignment-frontend \
  --source ./frontend \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 1 \
  --max-instances 10 \
  --set-env-vars NEXT_PUBLIC_API_URL=https://devops-assignment-backend-xxx.a.run.app
```

## Step 6: Get the URLs

```
bash
# Get backend URL
gcloud run services describe devops-assignment-backend --region us-central1 --format 'value(status.url)'

# Get frontend URL  
gcloud run services describe devops-assignment-frontend --region us-central1 --format 'value(status.url)'
```

## Step 7: Test the API

```
bash
curl https://devops-assignment-backend-xxx.a.run.app/api/health
curl https://devops-assignment-backend-xxx.a.run.app/api/message
```

## Expected Output

- Health: `{"status":"healthy","message":"Backend is running successfully"}`
- Message: `{"message":"You've successfully integrated the backend!"}`
