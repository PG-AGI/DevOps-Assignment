#  Terraform Infrastructure - Pre-Deployment Checklist

Use this checklist before deploying your infrastructure to ensure everything is properly configured.

---

##  Phase 1: Prerequisites (5 minutes)

### Tools Installation
- [ ] **Terraform** installed (>= 1.0)
  ```bash
  terraform version
  # Should show: Terraform v1.x.x or higher
  ```

- [ ] **AWS CLI** installed and configured (if deploying to AWS)
  ```bash
  aws --version
  aws sts get-caller-identity
  # Should show your AWS account details
  ```

- [ ] **gcloud CLI** installed and configured (if deploying to GCP)
  ```bash
  gcloud --version
  gcloud projects describe YOUR_PROJECT_ID
  # Should show your GCP project details
  ```

- [ ] **Docker** installed (for building images)
  ```bash
  docker --version
  # Should show: Docker version 20.x.x or higher
  ```

---

##  Phase 2: AWS Configuration (10 minutes)

### AWS Account Setup
- [ ] AWS account created and active
- [ ] IAM user with appropriate permissions
- [ ] AWS CLI configured with credentials
  ```bash
  aws configure list
  ```

### AWS Permissions Required
- [ ] VPC management (create VPC, subnets, route tables)
- [ ] ECS management (create clusters, services, tasks)
- [ ] ECR management (create repositories, push images)
- [ ] ELB management (create load balancers, target groups)
- [ ] IAM management (create roles, policies)
- [ ] CloudWatch management (create log groups)

### AWS Resources Check
- [ ] No conflicting VPC CIDR ranges
- [ ] Sufficient EIP quota (need 2)
- [ ] Sufficient service quotas for ECS
- [ ] Region selected: `us-east-1` (or customize in terraform.tfvars)

---

##  Phase 3: GCP Configuration (10 minutes)

### GCP Project Setup
- [ ] GCP project created
- [ ] Billing enabled on the project
- [ ] gcloud authenticated
  ```bash
  gcloud auth list
  gcloud auth application-default login
  ```

### GCP APIs to Enable
- [ ] Compute Engine API
  ```bash
  gcloud services enable compute.googleapis.com
  ```
- [ ] Cloud Run API
  ```bash
  gcloud services enable run.googleapis.com
  ```
- [ ] Container Registry API
  ```bash
  gcloud services enable containerregistry.googleapis.com
  ```
- [ ] Artifact Registry API
  ```bash
  gcloud services enable artifactregistry.googleapis.com
  ```
- [ ] VPC Access API
  ```bash
  gcloud services enable vpcaccess.googleapis.com
  ```

### GCP Permissions Required
- [ ] Owner or Editor role on the project
- [ ] Cloud Run Admin
- [ ] Compute Admin
- [ ] Service Account Admin
- [ ] VPC Admin

---

##  Phase 4: Docker Images (20 minutes)

### Build Backend Image
- [ ] Navigate to backend directory
- [ ] Build Docker image
  ```bash
  cd backend
  docker build -t pg-agi-backend .
  ```
- [ ] Test image locally (optional)
  ```bash
  docker run -p 8000:8000 pg-agi-backend
  # Visit http://localhost:8000/health
  ```

### Build Frontend Image
- [ ] Navigate to frontend directory
- [ ] Build Docker image
  ```bash
  cd frontend
  docker build -t pg-agi-frontend .
  ```
- [ ] Test image locally (optional)
  ```bash
  docker run -p 3000:3000 pg-agi-frontend
  # Visit http://localhost:3000
  ```

### Push Images to AWS ECR
- [ ] Get AWS account ID
  ```bash
  AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
  ```
- [ ] Create ECR repositories (or let Terraform create them)
  ```bash
  aws ecr create-repository --repository-name pg-agi-backend --region us-east-1
  aws ecr create-repository --repository-name pg-agi-frontend --region us-east-1
  ```
- [ ] Login to ECR
  ```bash
  aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
  ```
- [ ] Tag and push backend
  ```bash
  docker tag pg-agi-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend:latest
  docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend:latest
  ```
- [ ] Tag and push frontend
  ```bash
  docker tag pg-agi-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend:latest
  docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend:latest
  ```

### Push Images to GCP GCR
- [ ] Set GCP project
  ```bash
  gcloud config set project YOUR_PROJECT_ID
  ```
- [ ] Configure Docker for GCP
  ```bash
  gcloud auth configure-docker
  ```
- [ ] Tag and push backend
  ```bash
  docker tag pg-agi-backend:latest gcr.io/YOUR_PROJECT_ID/pg-agi-backend:latest
  docker push gcr.io/YOUR_PROJECT_ID/pg-agi-backend:latest
  ```
- [ ] Tag and push frontend
  ```bash
  docker tag pg-agi-frontend:latest gcr.io/YOUR_PROJECT_ID/pg-agi-frontend:latest
  docker push gcr.io/YOUR_PROJECT_ID/pg-agi-frontend:latest
  ```

---

##  Phase 5: Terraform Configuration (5 minutes)

### Create terraform.tfvars
- [ ] Navigate to terraform directory
  ```bash
  cd infra/terraform
  ```
- [ ] Copy example file
  ```bash
  cp terraform.tfvars.example terraform.tfvars
  ```
- [ ] Edit terraform.tfvars with your values

### Required Variables to Set
- [ ] `gcp_project_id` = "your-actual-project-id"
- [ ] `backend_image_aws` = "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/pg-agi-backend:latest"
- [ ] `frontend_image_aws` = "ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/pg-agi-frontend:latest"
- [ ] `backend_image_gcp` = "gcr.io/YOUR_PROJECT_ID/pg-agi-backend:latest"
- [ ] `frontend_image_gcp` = "gcr.io/YOUR_PROJECT_ID/pg-agi-frontend:latest"

### Optional Variables to Customize
- [ ] `environment` (default: "production")
- [ ] `project_name` (default: "pg-agi")
- [ ] `aws_region` (default: "us-east-1")
- [ ] `gcp_region` (default: "us-central1")
- [ ] `desired_count` (default: 2)
- [ ] `backend_cpu` / `backend_memory`
- [ ] `frontend_cpu` / `frontend_memory`

### Deployment Targets
- [ ] `deploy_to_aws` = true/false
- [ ] `deploy_to_gcp` = true/false

---

##  Phase 6: Pre-Deployment Validation (5 minutes)

### Terraform Validation
- [ ] Initialize Terraform
  ```bash
  terraform init
  ```
- [ ] Validate configuration
  ```bash
  terraform validate
  # Should show: "Success! The configuration is valid."
  ```
- [ ] Check formatting
  ```bash
  terraform fmt -check -recursive
  # Should show no output (all files formatted)
  ```

### Review Planned Changes
- [ ] Run terraform plan
  ```bash
  terraform plan -out=tfplan
  ```
- [ ] Review the plan output
  - [ ] Correct number of resources (AWS: ~40, GCP: ~20)
  - [ ] No unexpected changes
  - [ ] Image URLs are correct
  - [ ] Resource naming is correct

### Cost Estimation
- [ ] Review estimated costs
  - AWS: ~$165/month
  - GCP: ~$75/month
  - Total: ~$240/month
- [ ] Budget approved
- [ ] Cost alerts configured (optional)

---

##  Phase 7: Deployment (10 minutes)

### Deploy Infrastructure
- [ ] Choose deployment method:

  **Option A: Using deployment script (Recommended)**
  ```bash
  # Linux/macOS
  chmod +x deploy.sh
  ./deploy.sh apply all

  # Windows
  .\deploy.ps1 -Action apply -Target all
  ```

  **Option B: Manual Terraform commands**
  ```bash
  terraform apply tfplan
  ```

### Monitor Deployment
- [ ] Watch for errors during apply
- [ ] Deployment takes ~10-15 minutes
- [ ] Note any failed resources

### Capture Outputs
- [ ] Save output values
  ```bash
  terraform output > deployment-outputs.txt
  ```
- [ ] Record URLs:
  - [ ] AWS Backend URL: _________________
  - [ ] AWS Frontend URL: _________________
  - [ ] GCP Backend URL: _________________
  - [ ] GCP Frontend URL: _________________

---

##  Phase 8: Post-Deployment Testing (10 minutes)

### Test AWS Deployment
- [ ] Test backend health
  ```bash
  curl http://<aws_backend_url>/health
  # Should return 200 OK
  ```
- [ ] Test frontend
  ```bash
  curl http://<aws_frontend_url>
  # Should return HTML
  ```
- [ ] Open frontend in browser
  - [ ] Page loads successfully
  - [ ] Backend connectivity works

### Test GCP Deployment
- [ ] Test backend health
  ```bash
  curl https://<gcp_backend_url>/health
  # Should return 200 OK
  ```
- [ ] Test frontend
  ```bash
  curl https://<gcp_frontend_url>
  # Should return HTML
  ```
- [ ] Open frontend in browser
  - [ ] Page loads successfully
  - [ ] Backend connectivity works
  - [ ] HTTPS works automatically

### Verify Auto-Scaling
- [ ] AWS: Check ECS service has 2 tasks running
  ```bash
  aws ecs describe-services --cluster pg-agi-production-cluster --services pg-agi-production-backend-service
  ```
- [ ] GCP: Check Cloud Run instances
  ```bash
  gcloud run services describe pg-agi-production-backend --region us-central1
  ```

### Verify Monitoring
- [ ] AWS CloudWatch logs show data
  ```bash
  aws logs tail /ecs/pg-agi-production-backend --follow
  ```
- [ ] GCP Cloud Logging shows data
  ```bash
  gcloud logging read "resource.type=cloud_run_revision"
  ```

---

##  Phase 9: Documentation (5 minutes)

### Document Your Deployment
- [ ] Record all URLs in a secure location
- [ ] Document any customizations made
- [ ] Note any issues encountered
- [ ] Update team wiki/documentation
- [ ] Share access credentials securely

### Create Runbook
- [ ] How to deploy updates
- [ ] How to scale services
- [ ] How to view logs
- [ ] How to rollback changes
- [ ] Emergency contacts

---

##  Phase 10: Optional Enhancements

### Security Enhancements
- [ ] Set up custom domain with SSL
- [ ] Configure AWS Certificate Manager
- [ ] Set up WAF rules
- [ ] Enable AWS GuardDuty
- [ ] Enable GCP Security Command Center
- [ ] Implement secrets management
- [ ] Set up VPN or bastion hosts

### Monitoring Enhancements
- [ ] Create CloudWatch dashboards
- [ ] Set up GCP monitoring dashboards
- [ ] Configure alerting policies
- [ ] Set up PagerDuty/OpsGenie integration
- [ ] Configure log aggregation
- [ ] Set up APM (Application Performance Monitoring)

### CI/CD Setup
- [ ] Set up GitHub Actions workflow
- [ ] Configure GitLab CI or Jenkins
- [ ] Implement automated testing
- [ ] Set up deployment approvals
- [ ] Configure automatic rollback
- [ ] Document CI/CD process

### Backup & DR
- [ ] Set up Terraform state backup
- [ ] Configure infrastructure snapshots
- [ ] Document disaster recovery procedures
- [ ] Test recovery process
- [ ] Set up cross-region replication (if needed)

---

##  Deployment Status Tracker

### AWS Infrastructure
| Component | Status | Notes |
|-----------|--------|-------|
| VPC | ⬜ | |
| Subnets | ⬜ | |
| NAT Gateways | ⬜ | |
| Security Groups | ⬜ | |
| ECR Repositories | ⬜ | |
| ECS Cluster | ⬜ | |
| Load Balancers | ⬜ | |
| ECS Services | ⬜ | |
| Auto Scaling | ⬜ | |
| CloudWatch | ⬜ | |

### GCP Infrastructure
| Component | Status | Notes |
|-----------|--------|-------|
| VPC Network | ⬜ | |
| Firewall Rules | ⬜ | |
| Service Account | ⬜ | |
| Cloud Run Backend | ⬜ | |
| Cloud Run Frontend | ⬜ | |
| Load Balancer | ⬜ | |
| Monitoring | ⬜ | |

**Legend**:  Not Started |  In Progress |  Complete |  Failed

---

##  Troubleshooting Quick Reference

### Terraform Errors
```bash
# Re-initialize
terraform init -upgrade

# Validate
terraform validate

# Format
terraform fmt -recursive
```

### AWS Authentication
```bash
aws configure
aws sts get-caller-identity
```

### GCP Authentication
```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### Docker Issues
```bash
# AWS ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# GCP GCR login
gcloud auth configure-docker
```

---

##  Support Resources

- **Documentation**: `infra/terraform/README.md`
- **Quick Start**: `infra/terraform/QUICKSTART.md`
- **Architecture**: `infra/terraform/ARCHITECTURE.md`
- **Validation Report**: `infra/VALIDATION-REPORT.md`

---

##  Final Sign-Off

Before marking this deployment complete, ensure:

- [ ] All phases completed successfully
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Team notified
- [ ] Monitoring configured
- [ ] Costs within budget
- [ ] Rollback procedure documented

---

**Ready to deploy?** Start with Phase 1 and work through each section systematically!
