# Cloud Setup Guide

This guide walks you through setting up AWS and GCP credentials for the CI/CD pipelines.

## Prerequisites

- GitHub account with the repository forked
- AWS account with IAM user credentials
- GCP project with service account key

---

## AWS Setup

### Step 1: Create IAM User

1. Go to AWS Console → IAM → Users → Add users
2. Username: `github-actions-deploy`
3. Access type: Programmatic access
4. Attach policies:
   - `AmazonEC2ContainerRegistryFullAccess`
   - `AmazonECS_FullAccess`
   - `AmazonS3_FullAccess`
   - `SecretsManagerReadWrite`
   - `IAMFullAccess` (for creating roles)
5. Save the Access Key ID and Secret Access Key

### Step 2: Create S3 Bucket for Terraform State

```
bash
aws s3 mb s3://devops-tf-state-YOUR-ACCOUNT-ID --region us-east-1
aws s3api put-bucket-versioning --bucket devops-tf-state-YOUR-ACCOUNT-ID --versioning-configuration Status=Enabled
```

### Step 3: Create DynamoDB Table for State Locking

```
bash
aws dynamodb create-table \
  --table-name devops-assignment-tf-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 4: Create ECR Repositories

```
bash
aws ecr create-repository --repository-name devops-backend --region us-east-1
aws ecr create-repository --repository-name devops-frontend --region us-east-1
```

### Step 5: Add Secrets to GitHub

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your IAM user's Access Key ID
   - `AWS_SECRET_ACCESS_KEY`: Your IAM user's Secret Access Key
   - `AWS_ACCOUNT_ID`: Your AWS Account ID (12 digits)
   - `AWS_REGION`: us-east-1

---

## GCP Setup

### Step 1: Create GCP Project (if needed)

```
bash
gcloud projects create devops-assignment-XXXXX
gcloud config set project devops-assignment-XXXXX
```

### Step 2: Enable Required APIs

```
bash
gcloud services enable \
  cloudbuild.googleapis.com \
  run.googleapis.com \
  containerregistry.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com
```

### Step 3: Create Service Account

```
bash
gcloud iam service-accounts create github-deploy \
  --display-name="GitHub Deploy" \
  --project=YOUR-PROJECT-ID
```

### Step 4: Grant Permissions

```
bash
# Cloud Run Admin
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:github-deploy@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Storage Admin
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:github-deploy@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Secret Manager
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:github-deploy@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

# Cloud Build
gcloud projects add-iam-policy-binding YOUR-PROJECT-ID \
  --member="serviceAccount:github-deploy@YOUR-PROJECT-ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.builder"
```

### Step 5: Create Service Account Key

```
bash
gcloud iam service-accounts keys create github-deploy-key.json \
  --iam-account=github-deploy@YOUR-PROJECT-ID.iam.gserviceaccount.com
```

### Step 6: Add Secrets to GitHub

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add these secrets:
   - `GCP_PROJECT_ID`: Your GCP Project ID
   - `GCP_SA_KEY`: The contents of `github-deploy-key.json` (entire JSON file)

---

## Verify Setup

### Test AWS Credentials

```
bash
aws sts get-caller-identity
```

### Test GCP Credentials

```bash
gcloud auth activate-service-account --key-file=github-deploy-key.json
gcloud projects list
```

---

## Troubleshooting

### AWS Issues

- **"Invalid credentials"**: Check Access Key ID and Secret Access Key
- **"Bucket already exists"**: Use a unique bucket name
- **"Access denied"**: Verify IAM user has required permissions

### GCP Issues

- **"Permission denied"**: Verify service account has required roles
- **"Project not found"**: Verify project ID is correct
- **"API not enabled"**: Run the enable services command

---

## Security Notes

- Never commit credentials to Git
- Rotate keys regularly
- Use least-privilege IAM policies
- Enable MFA for human access to cloud consoles
