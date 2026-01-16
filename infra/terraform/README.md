# Terraform Infrastructure Documentation

## Overview

This Terraform configuration deploys the PG-AGI DevOps application to both AWS and GCP cloud platforms. It provides a complete, production-ready infrastructure with:

- **AWS**: VPC, ECS Fargate, ECR, Application Load Balancers, Auto Scaling
- **GCP**: VPC, Cloud Run, Artifact Registry, Global Load Balancer, Cloud Monitoring

## Architecture

### AWS Architecture

```
Internet
    │
    ├─── Application Load Balancer (Frontend)
    │         │
    │         └─── ECS Fargate Tasks (Frontend)
    │
    └─── Application Load Balancer (Backend)
              │
              └─── ECS Fargate Tasks (Backend)

VPC (10.0.0.0/16)
  ├─── Public Subnets (10.0.0.0/24, 10.0.1.0/24)
  │    └─── ALB, NAT Gateways
  └─── Private Subnets (10.0.100.0/24, 10.0.101.0/24)
       └─── ECS Tasks
```

**Components:**
- **VPC**: Isolated network with public and private subnets across 2 AZs
- **ECR**: Docker image repositories for backend and frontend
- **ECS Cluster**: Fargate launch type with container insights
- **ALB**: Separate load balancers for frontend and backend
- **Auto Scaling**: CPU-based scaling (target: 70%)
- **CloudWatch**: Centralized logging and monitoring

### GCP Architecture

```
Internet
    │
    └─── Global Load Balancer
              │
              ├─── Cloud Run (Frontend) - min: 1, max: 10
              └─── Cloud Run (Backend)  - min: 1, max: 10

VPC Network
  └─── VPC Access Connector
       └─── Private network access for Cloud Run
```

**Components:**
- **VPC Network**: Custom network with subnets
- **Artifact Registry**: Docker repository
- **Cloud Run**: Serverless container platform with auto-scaling
- **Global Load Balancer**: Path-based routing with CDN
- **Cloud Monitoring**: Uptime checks and monitoring

## Prerequisites

### Required Tools

1. **Terraform** >= 1.0
   ```bash
   # Install Terraform
   # macOS
   brew install terraform
   
   # Windows
   choco install terraform
   
   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

2. **AWS CLI** (for AWS deployment)
   ```bash
   # Install AWS CLI
   # macOS
   brew install awscli
   
   # Windows
   choco install awscli
   
   # Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

3. **gcloud CLI** (for GCP deployment)
   ```bash
   # Install gcloud
   # Visit: https://cloud.google.com/sdk/docs/install
   ```

### AWS Setup

1. **Configure AWS Credentials**
   ```bash
   aws configure
   # Enter:
   # - AWS Access Key ID
   # - AWS Secret Access Key
   # - Default region (e.g., us-east-1)
   # - Default output format (json)
   ```

2. **Verify AWS Access**
   ```bash
   aws sts get-caller-identity
   ```

### GCP Setup

1. **Authenticate with GCP**
   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Set GCP Project**
   ```bash
   gcloud config set project YOUR_PROJECT_ID
   ```

3. **Enable Required APIs**
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   gcloud services enable artifactregistry.googleapis.com
   gcloud services enable vpcaccess.googleapis.com
   ```

4. **Verify GCP Access**
   ```bash
   gcloud projects describe YOUR_PROJECT_ID
   ```

## Configuration

### 1. Copy and Edit Configuration File

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit terraform.tfvars

```hcl
# Global Configuration
environment  = "production"
project_name = "pg-agi"

# Deployment Targets
deploy_to_aws = true
deploy_to_gcp = true

# AWS Configuration
aws_region             = "us-east-1"
aws_vpc_cidr           = "10.0.0.0/16"
aws_availability_zones = ["us-east-1a", "us-east-1b"]

# GCP Configuration
gcp_project_id = "your-gcp-project-id"  # CHANGE THIS
gcp_region     = "us-central1"

# Application Configuration
backend_cpu      = 512
backend_memory   = 1024
frontend_cpu     = 512
frontend_memory  = 1024
desired_count    = 2
```

### 3. Build and Push Docker Images

Before deploying, you need to build and push your Docker images:

#### AWS ECR

```bash
# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION="us-east-1"

# Create ECR repositories (if not already created by Terraform)
aws ecr create-repository --repository-name pg-agi-backend --region $AWS_REGION
aws ecr create-repository --repository-name pg-agi-frontend --region $AWS_REGION

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push backend
cd backend
docker build -t pg-agi-backend .
docker tag pg-agi-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/pg-agi-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/pg-agi-backend:latest

# Build and push frontend
cd ../frontend
docker build -t pg-agi-frontend .
docker tag pg-agi-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/pg-agi-frontend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/pg-agi-frontend:latest
```

#### GCP GCR/Artifact Registry

```bash
# Set GCP project
gcloud config set project YOUR_PROJECT_ID

# Configure Docker for GCP
gcloud auth configure-docker
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build and push backend
cd backend
docker build -t gcr.io/YOUR_PROJECT_ID/pg-agi-backend:latest .
docker push gcr.io/YOUR_PROJECT_ID/pg-agi-backend:latest

# Build and push frontend
cd ../frontend
docker build -t gcr.io/YOUR_PROJECT_ID/pg-agi-frontend:latest .
docker push gcr.io/YOUR_PROJECT_ID/pg-agi-frontend:latest
```

### 4. Update Image URLs in terraform.tfvars

After pushing images, update these variables:

```hcl
# AWS Images
backend_image_aws  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend:latest"
frontend_image_aws = "123456789012.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend:latest"

# GCP Images
backend_image_gcp  = "gcr.io/your-project-id/pg-agi-backend:latest"
frontend_image_gcp = "gcr.io/your-project-id/pg-agi-frontend:latest"
```

## Deployment

### Method 1: Using Deployment Scripts (Recommended)

#### Linux/macOS
```bash
cd infra/terraform

# Make script executable
chmod +x deploy.sh

# Plan deployment
./deploy.sh plan all

# Deploy to both AWS and GCP
./deploy.sh apply all

# Deploy to AWS only
./deploy.sh apply aws

# Deploy to GCP only
./deploy.sh apply gcp

# Show outputs
./deploy.sh output

# Destroy infrastructure
./deploy.sh destroy all
```

#### Windows PowerShell
```powershell
cd infra\terraform

# Plan deployment
.\deploy.ps1 -Action plan -Target all

# Deploy to both AWS and GCP
.\deploy.ps1 -Action apply -Target all

# Deploy to AWS only
.\deploy.ps1 -Action apply -Target aws

# Deploy to GCP only
.\deploy.ps1 -Action apply -Target gcp

# Show outputs
.\deploy.ps1 -Action output

# Destroy infrastructure
.\deploy.ps1 -Action destroy -Target all
```

### Method 2: Manual Terraform Commands

```bash
cd infra/terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan deployment
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Show outputs
terraform output

# Destroy infrastructure (when needed)
terraform destroy
```

## Outputs

After successful deployment, Terraform will output:

```
aws_backend_url              = "http://pg-agi-production-backend-alb-123456.us-east-1.elb.amazonaws.com"
aws_frontend_url             = "http://pg-agi-production-frontend-alb-654321.us-east-1.elb.amazonaws.com"
aws_ecr_backend_repository   = "123456789012.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend"
aws_ecr_frontend_repository  = "123456789012.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend"
gcp_backend_url              = "https://pg-agi-production-backend-abc123-uc.a.run.app"
gcp_frontend_url             = "https://pg-agi-production-frontend-xyz789-uc.a.run.app"
gcp_load_balancer_ip         = "34.120.45.67"
```

## Testing the Deployment

### Test Backend

```bash
# AWS
curl http://<aws_backend_url>/health

# GCP
curl https://<gcp_backend_url>/health
```

### Test Frontend

```bash
# AWS
curl http://<aws_frontend_url>

# GCP
curl https://<gcp_frontend_url>
```

### Access Applications

Open the URLs in your browser:
- AWS Frontend: `http://<aws_frontend_url>`
- GCP Frontend: `https://<gcp_frontend_url>`

## Cost Estimation

### AWS (Monthly)
- VPC: $0 (free tier)
- NAT Gateway: ~$65 (2 NAT Gateways)
- ECS Fargate: ~$60 (4 tasks, 0.5 vCPU, 1GB RAM)
- ALB: ~$30 (2 load balancers)
- CloudWatch: ~$10
- **Total: ~$165/month**

### GCP (Monthly)
- Cloud Run: ~$50 (based on usage)
- VPC: $0 (free)
- Load Balancer: ~$20
- Artifact Registry: ~$5
- **Total: ~$75/month**

**Combined Total: ~$240/month**

## Scaling

### AWS Auto Scaling
- Configured to scale based on CPU utilization (target: 70%)
- Min instances: 2
- Max instances: 10

### GCP Auto Scaling
- Cloud Run automatically scales based on requests
- Min instances: 1
- Max instances: 10

## Security Best Practices

1. **Use Remote State Backend**
   ```hcl
   # Add to main.tf
   backend "s3" {
     bucket         = "your-terraform-state-bucket"
     key            = "pg-agi/terraform.tfstate"
     region         = "us-east-1"
     dynamodb_table = "terraform-state-lock"
     encrypt        = true
   }
   ```

2. **Enable HTTPS**
   - Add ACM certificate for AWS ALB
   - Cloud Run provides HTTPS by default

3. **Restrict Access**
   - Use security groups to limit access
   - Implement IAM roles with least privilege

4. **Enable Monitoring**
   - CloudWatch for AWS
   - Cloud Monitoring for GCP

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   # AWS
   aws configure
   aws sts get-caller-identity
   
   # GCP
   gcloud auth login
   gcloud auth application-default login
   ```

2. **Terraform State Lock**
   ```bash
   # Force unlock (use with caution)
   terraform force-unlock <LOCK_ID>
   ```

3. **Docker Image Not Found**
   - Ensure images are built and pushed before deployment
   - Verify image URLs in terraform.tfvars

4. **Resource Limits**
   - Check AWS service quotas
   - Verify GCP quota limits

### Viewing Logs

#### AWS
```bash
# View ECS logs
aws logs tail /ecs/pg-agi-production-backend --follow

# View service events
aws ecs describe-services --cluster pg-agi-production-cluster --services pg-agi-production-backend-service
```

#### GCP
```bash
# View Cloud Run logs
gcloud run services logs read pg-agi-production-backend --region us-central1

# Follow logs
gcloud run services logs tail pg-agi-production-backend --region us-central1
```

## Cleanup

To destroy all infrastructure:

```bash
# Using script
./deploy.sh destroy all

# Or manually
terraform destroy
```

**Warning**: This will delete all resources and data. Make sure to backup any important data before destroying.

## Advanced Configuration

### Custom Domain Setup

#### AWS
1. Add Route53 hosted zone
2. Create ACM certificate
3. Update ALB listener to use HTTPS
4. Add CNAME records

#### GCP
1. Map custom domain to Cloud Run
2. Verify domain ownership
3. Update load balancer with SSL certificate

### CI/CD Integration

Integrate with GitHub Actions:

```yaml
- name: Deploy to AWS
  run: |
    cd infra/terraform
    terraform init
    terraform apply -auto-approve -target=module.aws_infrastructure

- name: Deploy to GCP
  run: |
    cd infra/terraform
    terraform init
    terraform apply -auto-approve -target=module.gcp_infrastructure
```

## Support

For issues or questions:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review Terraform documentation
3. Check cloud provider documentation

## License

This infrastructure code is part of the PG-AGI DevOps Assignment.
