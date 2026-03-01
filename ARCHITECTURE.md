# DevOps Assignment - Architecture & Infrastructure Documentation

## Table of Contents
1. [Cloud & Region Selection](#1-cloud--region-selection)
2. [Compute & Runtime Decisions](#2-compute--runtime-decisions)
3. [Networking & Traffic Flow](#3-networking--traffic-flow)
4. [Environment Separation](#4-environment-separation)
5. [Scalability & Availability](#5-scalability--availability)
6. [Deployment Strategy](#6-deployment-strategy)
7. [Infrastructure as Code & State Management](#7-infrastructure-as-code--state-management)
8. [Security & Identity](#8-security--identity)
9. [Failure & Operational Thinking](#9-failure--operational-thinking)
10. [Future Growth Scenario](#10-future-growth-scenario)
11. [What We Did NOT Do](#11-what-we-did-not-do)

---

## 1. Cloud & Region Selection

### GCP (Google Cloud Platform)
- **Region**: us-central1 (Iowa)
- **Justification**:
  - Lowest cost region in US
  - Good free tier availability
  - Low latency for US-based users
  - All required services available (Cloud Run, Cloud Storage, Cloud Build)

### AWS (Amazon Web Services)
- **Region**: us-east-1 (N. Virginia)
- **Justification**:
  - Most mature region with all services
  - Lowest cost for compute
  - Best free tier coverage
  - Low latency for East Coast users

### Region Tradeoffs

| Factor | us-central1 (GCP) | us-east-1 (AWS) |
|--------|-------------------|-----------------|
| Latency (US East) | ~50ms | ~20ms |
| Cost | Lower | Higher |
| Free Tier | Good | Excellent |
| Service Availability | Good | Excellent |

---

## 2. Compute & Runtime Decisions

### GCP - Cloud Run (Serverless Containers)
- **Choice**: Cloud Run for both frontend and backend
- **Justification**:
  - Pay-per-use (only pay when requests are processed)
  - Automatic scaling from 0 to unlimited
  - No server management required
  - Built-in HTTPS
  - Free tier includes 2 million requests/month

### AWS - ECS Fargate (Containers)
- **Choice**: ECS Fargate for backend, S3 + CloudFront for frontend
- **Justification**:
  - Fargate: Serverless containers, no EC2 management
  - S3 + CloudFront: Optimized for static content delivery
  - Automatic scaling
  - Pay-per-use model

### Comparison

| Aspect | GCP Cloud Run | AWS ECS Fargate |
|--------|---------------|-----------------|
| Scaling | 0 to unlimited | Min to max instances |
| Cold Start | ~1 second | ~30 seconds |
| Cost | Per request | Per vCPU/hour |
| Management | Fully managed | Fully managed |
| Free Tier | 2M requests | 750 hours |

---

## 3. Networking & Traffic Flow

### Architecture Diagram (GCP)

```
Internet
    │
    ├─► Cloud CDN + Load Balancer
    │       │
    │       ├─► Frontend (Cloud Run)
    │       │
    │       └─► Backend (Cloud Run)
    │
    └─► Cloud CDN → Cloud Storage (Static)
```

### Public vs Private Components

| Component | Type | Access |
|-----------|------|--------|
| Frontend | Public | Anyone via URL |
| Backend API | Public | Frontend + authenticated users |
| Database | Private | Only via backend |

### Ingress Strategy
- **GCP**: Cloud Run + Cloud CDN + Global External Load Balancer
- **AWS**: CloudFront + API Gateway + ALB

### Security Rules
- HTTPS only (automatic with Cloud Run/ALB)
- CORS configured on backend
- No direct database access from internet

---

## 4. Environment Separation

### Three Environments: dev, staging, prod

| Environment | Scaling | Resources | Purpose |
|-------------|---------|-----------|---------|
| **dev** | 1-2 instances | 512MB, 1 CPU | Development testing |
| **staging** | 2-4 instances | 1GB, 2 CPU | Pre-production testing |
| **prod** | Auto (1-10) | 2GB, 2 CPU | Production traffic |

### Environment Differences

**Dev:**
- Minimal resources
- Manual scaling only
- Debug logging enabled

**Staging:**
- Production-like resources
- Auto-scaling enabled
- Standard logging

**Prod:**
- Full resources with auto-scaling
- Enhanced monitoring
- Cost optimization

---

## 5. Scalability & Availability

### What Scales Automatically

| Component | Auto-Scaling | Trigger |
|-----------|---------------|---------|
| Backend (Cloud Run) | Yes | CPU > 60%, concurrent requests |
| Backend (ECS Fargate) | Yes | CPU > 70%, request count |
| Frontend (Cloud Run) | Yes | CPU > 60% |
| CloudFront CDN | Yes | Always (edge locations) |

### What Does NOT Scale

- **Terraform State**: Manual backup
- **S3 Bucket**: Manual lifecycle policies

### Traffic Spike Handling
- Cloud Run: Instant scale-out based on requests
- CloudFront: Edge caching reduces origin requests
- Queue-based processing for async tasks

### Availability Guarantees
- **SLA**: 99.9% (Cloud Run)
- **RTO**: < 5 minutes (active deployments)
- **RPO**: Real-time (no data persistence)

---

## 6. Deployment Strategy

### CI/CD Pipeline

```
GitHub Push
    │
    ▼
GitHub Actions
    │
    ├─► Build Docker Image
    │
    ├─► Run Tests
    │
    ├─► Push to Registry
    │
    └─► Deploy to Environment
            │
            ├─► dev (automatic)
            ├─► staging (on merge to main)
            └─► prod (manual approval)
```

### Deployment Flow

1. **Code Push** → Trigger CI pipeline
2. **Build** → Create Docker image
3. **Test** → Run unit/integration tests
4. **Scan** → Security vulnerability scan
5. **Deploy** → Update Cloud Run/ECS service

### Zero-Downtime Deployment
- **Strategy**: Rolling update
- **Process**: New version receives traffic gradually
- **Rollback**: Automatic if health checks fail

### Failure Handling
- Health check failures → Rollback to previous version
- Deployment timeout → Cancel and keep previous version
- Rollback time: ~2-3 minutes

---

## 7. Infrastructure as Code & State Management

### Terraform Configuration

**GCP Structure:**
```
infrastructure/gcp/
├── backend.tf          # GCP provider + state backend
├── variables.tf        # Input variables
├── main.tf             # Main infrastructure
├── cloud_run.tf        # Cloud Run services
├── storage.tf           # Cloud Storage
├── cdn.tf              # Cloud CDN
└── secrets.tf          # Secret Manager
```

**AWS Structure:**
```
infrastructure/aws/
├── backend.tf          # AWS provider + S3 state
├── variables.tf        # Input variables
├── main.tf             # Main infrastructure
├── ecs.tf              # ECS Fargate services
├── s3.tf               # S3 buckets
├── cloudfront.tf       # CloudFront CDN
└── secrets.tf          # Secrets Manager
```

### State Management

| Aspect | Strategy |
|--------|----------|
| **State Storage** | S3 (AWS), GCS (GCP) |
| **Locking** | DynamoDB (AWS), GCS (GCP) |
| **Isolation** | Separate state file per environment |
| **Recovery** | Versioning enabled on state bucket |

### State Files
- `aws/dev/terraform.tfstate`
- `aws/staging/terraform.tfstate`
- `aws/prod/terraform.tfstate`
- `gcp/dev/terraform.tfstate`
- `gcp/staging/terraform.tfstate`
- `gcp/prod/terraform.tfstate`

---

## 8. Security & Identity

### Deployment Identity (CI/CD)

**GCP:**
- Service Account: `deploy@my-project.iam.gcloudaccount.com`
- Roles: Cloud Run Admin, Storage Admin, Secret Manager Secret Accessor

**AWS:**
- IAM User: `github-actions-deploy`
- Permissions: ECS Full Access, S3 Full Access, Secrets Manager

### Human Access Control

| Role | Access Level |
|------|--------------|
| Developers | Read-only to resources |
| DevOps | Full access to dev/staging |
| Admins | Full access including prod |

### Secret Storage

**Never in:**
- ❌ Git repositories
- ❌ Docker images
- ❌ CI/CD logs
- ❌ Code comments

**Always in:**
- ✅ GCP Secret Manager
- ✅ AWS Secrets Manager
- ✅ Environment variables (runtime)

### Secret Injection Flow
```
Secrets Manager
    │
    ▼ (runtime)
Container Environment
    │
    ▼
Application Code
```

### Least-Privilege Principles
- Service accounts have minimal permissions
- IAM roles scoped to specific resources
- No hardcoded credentials
- Secrets rotated automatically

---

## 9. Failure & Operational Thinking

### Smallest Failure Unit

| Component | Failure Unit | Impact |
|-----------|---------------|--------|
| Cloud Run Instance | Single container | Zero (auto-replace) |
| ECS Task | Single task | Zero (auto-replace) |
| Availability Zone | Entire AZ | Low (multi-AZ) |
| Region | Entire region | High (requires manual failover) |

### What Breaks First

1. **Health check failures** → Container restarted
2. **Memory exhaustion** → Container killed and restarted
3. **Rate limiting** → 429 errors returned
4. **Quota exceeded** → Deployment fails

### What Self-Recovers

- ✅ Container crashes (auto-restart)
- ✅ Failed health checks (auto-replace)
- ✅ Zone failures (multi-AZ deployment)
- ✅ Temporary load spikes (auto-scaling)

### What Requires Human Intervention

- ❌ Billing issues (account locked)
- ❌ Quota exceeded (request increase)
- ❌ Region outage (manual failover)
- ❌ Security incidents (investigation needed)

### Alerting Philosophy

| Alert Type | When | Action |
|------------|------|--------|
| Error Rate > 5% | Immediate | On-call paged |
| Latency > 2s | After 5 min | Investigate |
| Deployment Failed | Immediate | On-call paged |
| Cost Anomaly | Daily | Review |

---

## 10. Future Growth Scenario

### Traffic Increases 10x

**What Changes:**
- Increase max instances (10 → 100)
- Add Cloud CDN caching
- Implement caching layer (Redis)
- Database read replicas

**What Remains Unchanged:**
- Overall architecture
- API contracts
- Deployment process

### New Backend Service Added

**Infrastructure Changes:**
1. Add new Cloud Run service
2. Update load balancer
3. Add new secrets
4. Update CI/CD pipeline

**Early Decisions That Help:**
- Microservices architecture
- Environment parity
- IaC for all resources

### Client Demands Stricter Isolation

**Options:**
- Dedicated VPC per client
- Separate projects
- Multi-cloud deployment

### Region-Specific Data

**Implementation:**
- Data residency in target region
- CDN geo-routing
- Regional database replicas

---

## 11. What We Did NOT Do

### Intentionally Not Implemented

| Item | Reason |
|------|--------|
| **Kubernetes** | Overkill for simple app; managed services simpler |
| **Database** | Not required for stateless app; adds complexity |
| **Message Queue** | No async processing needed |
| **Monitoring Stack** | Basic logging sufficient for assignment |
| **VPN/Private Networking** | Public endpoints acceptable |
| **Multi-Region Active-Active** | Not cost-effective for demo |
| **Advanced CI/CD** | GitHub Actions sufficient |
| **Cost Alerts** | Not required for submission |
| **Disaster Recovery Plan** | Out of scope |

### Why These Decisions?

1. **No Kubernetes**: Adds operational complexity without benefit for a simple 2-service app
2. **No Database**: App is stateless; data not persisted
3. **No Monitoring Stack**: Cloud Logging sufficient
4. **No VPN**: Public endpoints with authentication sufficient

---

## Quick Start Guide

### Prerequisites
- Terraform installed
- gcloud CLI configured
- AWS CLI configured (optional)

### Deploy to GCP

```
bash
# 1. Set project
gcloud config set project my-project-devops-488902

# 2. Enable services
gcloud services enable run.googleapis.com cloudbuild.googleapis.com

# 3. Deploy backend
gcloud run deploy backend --source ./backend --region us-central1

# 4. Deploy frontend
gcloud run deploy frontend --source ./frontend --region us-central1 \
  --set-env-vars NEXT_PUBLIC_API_URL=https://backend-url
```

### Deploy to AWS

```
bash
# 1. Configure AWS
aws configure

# 2. Deploy using Terraform
cd infrastructure/aws
terraform init
terraform apply -var="environment=prod"
```

---

## Links

- **GitHub Repository**: (Your fork URL)
- **GCP Console**: https://console.cloud.google.com
- **AWS Console**: https://console.aws.amazon.com

---

*Document Version: 1.0*
*Last Updated: 2024*
