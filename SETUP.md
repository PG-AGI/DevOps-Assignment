# DevOps Assignment - Setup Guide

This guide walks you through setting up the cloud infrastructure and deploying the application.

## Prerequisites

Before you begin, ensure you have:

- [ ] AWS Account
- [ ] GCP Account
- [ ] GitHub Account
- [ ] AWS CLI installed and configured
- [ ] gcloud CLI installed (see below)

### Install gcloud CLI

**Windows:**
1. Download the Google Cloud SDK installer: https://cloud.google.com/sdk/docs/install#windows
2. Run the installer
3. After installation, run: `gcloud auth login`

**Or using PowerShell (if you have winget):**
```
powershell
winget install GoogleCloudSDK
```

---

## Step 1: Fork the Repository

Already completed ✅

---

## Step 2: Configure GitHub Secrets

You need to add the following secrets to your GitHub repository:

### For AWS Deployment:
1. Go to your forked repository → Settings → Secrets and variables → Actions
2. Add these secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS Access Key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Key
   - `TF_API_TOKEN`: Terraform Cloud API token (optional, for state locking)

### For GCP Deployment:
1. Create a Service Account in GCP with these roles:
   - Cloud Run Admin
   - Storage Admin
   - Secret Manager Admin
   - Compute Admin
   - Service Account User

2. Download the JSON key file

3. Add these secrets to GitHub:
   - `GCP_SA_KEY`: The JSON content from your service account key
   - `GCP_PROJECT_ID`: Your GCP project ID

---

## Step 3: Create State Storage (AWS)

### Option A: Using Terraform (Recommended)

```
bash
cd infrastructure/bootstrap
terraform init
terraform apply
```

### Option B: Manual Setup

1. **Create S3 Bucket:**
   
```
bash
   aws s3 mb s3://devops-assignment-tf-state --region us-east-1
   aws s3api put-bucket-versioning --bucket devops-assignment-tf-state --versioning-configuration Status=Enabled
   aws s3api put-bucket-encryption --bucket devops-assignment-tf-state --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
   
```

2. **Create DynamoDB Table:**
   
```
bash
   aws dynamodb create-table \
     --table-name devops-assignment-tf-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   
```

---

## Step 4: Create State Storage (GCP)

### Option A: Using Console

1. Go to Cloud Storage → Create Bucket
2. Name: `devops-assignment-tf-state`
3. Location: us-central1
4. Click Create

### Option B: Using gcloud

```
bash
gsutil mb -l us-central1 gs://devops-assignment-tf-state
gsutil versioning set on gs://devops-assignment-tf-state
```

---

## Step 5: Deploy via GitHub Actions

### Deploy to AWS:
1. Go to your repository → Actions
2. Click on "Deploy to AWS"
3. Click "Run workflow"
4. Select environment: `dev`
5. Click "Run workflow"

### Deploy to GCP:
1. Go to your repository → Actions
2. Click on "Deploy to GCP"
3. Click "Run workflow"
4. Select environment: `dev`
5. Click "Run workflow"

---

## Step 6: Verify Deployment

After deployment completes:

### AWS:
- Get ALB DNS name from Terraform output
- Visit: `http://<alb-dns-name>`

### GCP:
- Get Cloud Run service URLs from Terraform output
- Visit the frontend URL

---

## Manual Deployment (Alternative)

If you prefer to deploy manually:

### AWS:
```
bash
cd infrastructure/aws
terraform init -backend-config="bucket=devops-assignment-tf-state" -backend-config="key=aws/dev/terraform.tfstate" -backend-config="region=us-east-1" -backend-config="dynamodb_table=devops-assignment-tf-lock" -backend-config="encrypt=true"
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
```

### GCP:
```
bash
cd infrastructure/gcp
terraform init -backend-config="bucket=devops-assignment-tf-state" -backend-config="prefix=gcp/dev/terraform.tfstate"
terraform plan -var-file=dev.tfvars -var="project_id=your-project-id"
terraform apply -var-file=dev.tfvars -var="project_id=your-project-id"
```

---

## Troubleshooting

### Common Issues:

1. **Terraform state not found**: Ensure S3/GCS buckets are created first
2. **Permission denied**: Check AWS/GCP credentials in GitHub secrets
3. **Container image not found**: Ensure ECR/GCR repositories exist
4. **Service unavailable**: Check security group/network ACLs

### Check Logs:

**AWS:**
```
bash
aws logs get-log-events --log-group-name /ecs/devops-assignment-backend-dev
```

**GCP:**
```
bash
gcloud logging read "resource.type=cloud_run_revision" --limit 50
```

---

## Next Steps After Deployment

1. **Update Documentation**: Create Google Docs with architecture details
2. **Record Demo**: Create 8-12 minute demo video
3. **Test Integration**: Verify frontend connects to backend

---

## Cleanup (When Done)

To avoid ongoing charges:

**AWS:**
```
bash
cd infrastructure/aws
terraform destroy -var-file=prod.tfvars
```

**GCP:**
```
bash
cd infrastructure/gcp
terraform destroy -var-file=prod.tfvars -var="project_id=your-project-id"
