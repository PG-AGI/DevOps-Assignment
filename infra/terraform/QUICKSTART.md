# Terraform Quick Start Guide

## 🚀 5-Minute Setup

### Prerequisites Checklist
- [ ] Terraform installed
- [ ] AWS CLI configured (for AWS)
- [ ] gcloud CLI configured (for GCP)
- [ ] Docker images built and pushed

### Step 1: Configure Variables (2 minutes)

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
# REQUIRED: Set your GCP project ID
gcp_project_id = "your-gcp-project-id"

# OPTIONAL: Customize other settings
environment  = "production"
project_name = "pg-agi"
```

### Step 2: Deploy Infrastructure (3 minutes)

**Option A: Deploy Everything**
```bash
# Linux/macOS
chmod +x deploy.sh
./deploy.sh apply all

# Windows
.\deploy.ps1 -Action apply -Target all
```

**Option B: Deploy AWS Only**
```bash
./deploy.sh apply aws
```

**Option C: Deploy GCP Only**
```bash
./deploy.sh apply gcp
```

### Step 3: Get Your URLs

```bash
terraform output
```

Access your applications:
- **AWS Frontend**: `http://<aws_frontend_url>`
- **AWS Backend**: `http://<aws_backend_url>/health`
- **GCP Frontend**: `https://<gcp_frontend_url>`
- **GCP Backend**: `https://<gcp_backend_url>/health`

## 🔧 Common Commands

```bash
# Plan changes
./deploy.sh plan

# Apply changes
./deploy.sh apply

# View outputs
./deploy.sh output

# Destroy infrastructure
./deploy.sh destroy
```

## 📊 What Gets Created

### AWS Resources
- ✅ VPC with public/private subnets
- ✅ 2x Application Load Balancers
- ✅ ECS Fargate cluster
- ✅ ECR repositories
- ✅ Auto-scaling groups
- ✅ CloudWatch logging

### GCP Resources
- ✅ VPC Network
- ✅ Cloud Run services (backend + frontend)
- ✅ Global Load Balancer
- ✅ Artifact Registry
- ✅ Cloud Monitoring

## 🐛 Quick Troubleshooting

### "Terraform not found"
```bash
# Install Terraform
brew install terraform  # macOS
choco install terraform # Windows
```

### "AWS authentication failed"
```bash
aws configure
aws sts get-caller-identity
```

### "GCP authentication failed"
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### "Docker images not found"
Build and push images first:
```bash
# See README.md section "Build and Push Docker Images"
```

## 💰 Cost Estimate

- AWS: ~$165/month
- GCP: ~$75/month
- Total: ~$240/month

## 🧹 Cleanup

To destroy all infrastructure:
```bash
./deploy.sh destroy all
```

## 📚 Full Documentation

For detailed documentation, see [README.md](README.md)

## 🎯 Next Steps

1. ✅ Deploy infrastructure
2. 🔐 Set up custom domains
3. 🔒 Configure SSL certificates
4. 📊 Set up monitoring alerts
5. 🔄 Integrate with CI/CD pipeline
