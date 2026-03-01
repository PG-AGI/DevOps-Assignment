# DevOps Assignment - Cloud Infrastructure Deployment

## Overview

This project demonstrates production-grade cloud infrastructure deployment for a simple FastAPI backend and Next.js frontend application. The infrastructure is deployed across **two cloud platforms**: AWS and Google Cloud Platform (GCP).

## Application Architecture

```
┌─────────────────┐     ┌─────────────────┐
│   Frontend     │────▶│    Backend      │
│  (Next.js)     │     │   (FastAPI)     │
│   Port: 3000   │     │   Port: 8000    │
└─────────────────┘     └─────────────────┘
```

### API Endpoints

- **GET /api/health**: Health check endpoint
  - Returns: `{"status": "healthy", "message": "Backend is running successfully"}`
  
- **GET /api/message**: Get integration message
  - Returns: `{"message": "You've successfully integrated the backend!"}`

---

## Cloud & Region Selection

### AWS Deployment

| Aspect | Selection | Justification |
|--------|-----------|---------------|
| **Region** | us-east-1 (N. Virginia) | Lowest cost among AWS regions, high availability, excellent latency for US East coast users |
| **Compute** | ECS Fargate | Serverless containers - no server management, auto-scaling, pay-per-use |
| **CDN** | CloudFront + S3 | Global CDN for frontend, low latency delivery |

**Tradeoffs:**
- Cost-effective but higher latency for EU/Asia users
- Excellent ecosystem integration with other AWS services

### GCP Deployment

| Aspect | Selection | Justification |
|--------|-----------|---------------|
| **Region** | us-central1 (Iowa) | Lowest cost GCP region, good availability, strong SLA |
| **Compute** | Cloud Run | Fully managed serverless containers, automatic scaling to zero, per-request pricing |
| **CDN** | Cloud CDN | Global edge caching, integrated with Cloud Load Balancing |

**Tradeoffs:**
- More aggressive auto-scaling (including scale-to-zero in dev)
- Simple pricing model based on resource consumption

---

## Infrastructure Architecture

### AWS Architecture Diagram

```
                              ┌──────────────────────────────────────┐
                              │         Internet                     │
                              └──────────────┬───────────────────────┘
                                             │
                                             ▼
                                  ┌─────────────────────┐
                                  │   CloudFront CDN    │
                                  │   (S3 for static)   │
                                  └──────────┬──────────┘
                                             │
                                             ▼
                                  ┌─────────────────────┐
                                  │  Application Load   │
                                  │      Balancer       │
                                  └──────────┬──────────┘
                                             │
                        ┌────────────────────┬┴────────────────────┐
                        │                    │                     │
                        ▼                    ▼                     ▼
              ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
              │  ECS Fargate    │  │  ECS Fargate    │  │  ECS Fargate    │
              │   (Frontend)    │  │   (Backend)     │  │   (Backend)     │
              │   Private Subnet│  │  Private Subnet │  │  Private Subnet │
              └─────────────────┘  └─────────────────┘  └─────────────────┘
```

### GCP Architecture Diagram

```
                              ┌──────────────────────────────────────┐
                              │         Internet                     │
                              └──────────────┬───────────────────────┘
                                             │
                                             ▼
                                  ┌─────────────────────┐
                                  │   Cloud CDN         │
                                  │   + Cloud Storage   │
                                  └──────────┬──────────┘
                                             │
                                             ▼
                                  ┌─────────────────────┐
                                  │  Cloud Load         │
                                  │   Balancer          │
                                  └──────────┬──────────┘
                                             │
                        ┌────────────────────┴┐
                        │                     │
                        ▼                     ▼
              ┌─────────────────┐  ┌─────────────────┐
              │    Cloud Run    │  │    Cloud Run    │
              │   (Frontend)    │  │   (Backend)     │
              │   Private       │  │   Private       │
              └─────────────────┘  └─────────────────┘
```

---

## Environment Separation

### Dev Environment

| Component | AWS | GCP |
|-----------|-----|-----|
| **Min Instances** | 1 | 0 (scale to zero) |
| **Max Instances** | 2 | 2 |
| **Resources** | 256 CPU, 512MB | 1 CPU, 512MB |
| **Cost Protection** | Budget alerts enabled | Budget alerts enabled |

### Staging Environment

| Component | AWS | GCP |
|-----------|-----|-----|
| **Min Instances** | 1 | 1 |
| **Max Instances** | 3 | 5 |
| **Resources** | 512 CPU, 1GB | 1 CPU, 512MB |
| **Purpose** | Pre-production testing | Integration testing |

### Production Environment

| Component | AWS | GCP |
|-----------|-----|-----|
| **Min Instances** | 2 | 2 |
| **Max Instances** | 10 | 20 |
| **Resources** | 512 CPU, 1GB | 1 CPU, 1GB |
| **HA Features** | Multi-AZ enabled | Multi-region ready |
| **Protection** | Deletion protection | - |

---

## Scalability & Availability

### What Scales Automatically

| Component | AWS | GCP |
|-----------|-----|-----|
| **Backend** | ECS Auto Scaling (CPU/Request based) | Cloud Run (CPU/Request based) |
| **Frontend** | ECS Auto Scaling (CPU/Request based) | Cloud Run (CPU/Request based) |
| **Static Content** | CloudFront (edge caching) | Cloud CDN (edge caching) |

### Scaling Metrics

- **CPU Utilization Target**: 70%
- **Request Count Target**: 1000 requests per target (ALB)
- **Cooldown Period**: 300 seconds between scaling actions

### What Does NOT Scale Automatically

| Component | Reason |
|-----------|--------|
| **Database** | Not needed for this stateless app |
| **NAT Gateway** | Not cost-effective for this scale |
| **Static S3 Bucket** | Not needed - served via CloudFront |

### Traffic Spike Handling

1. **Request Queuing**: Load balancer queues requests during scaling
2. **Connection Draining**: 30-second grace period for in-flight requests
3. **Circuit Breaker**: Automatic rollback on failed deployments

---

## Deployment Strategy

### CI/CD Pipeline Flow

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Commit  │───▶│  Build   │───▶│  Test    │───▶│ Deploy   │
│          │    │ Docker   │    │          │    │          │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                                                      │
                         ┌────────────────────────────┤
                         │                            │
                         ▼                            ▼
                  ┌─────────────┐            ┌─────────────┐
                  │    Dev      │            │   Staging    │
                  │  (auto)     │            │  (manual)    │
                  └─────────────┘            └─────────────┘
                                                 │
                                                 ▼
                                          ┌─────────────┐
                                          │   Prod      │
                                          │  (manual)   │
                                          └─────────────┘
```

### Deployment Behavior

1. **Zero-Downtime Deployment**: New tasks start before old ones stop
2. **Health Check Integration**: Traffic shifted only after health checks pass
3. **Automatic Rollback**: Circuit breaker triggers rollback on failures
4. **Blue/Green**: Traffic gradually shifted to new version

### Rollback Strategy

- **AWS**: ECS deployment circuit breaker automatically rolls back
- **GCP**: Traffic can be instantly shifted back to previous revision

---

## Infrastructure as Code

### State Management

#### AWS
- **Backend**: S3 bucket with DynamoDB for locking
- **State File**: `s3://devops-assignment-tf-state/aws/{environment}/terraform.tfstate`
- **Locking**: DynamoDB table prevents concurrent modifications

#### GCP
- **Backend**: GCS bucket with versioning
- **State File**: `gs://devops-assignment-tf-state/gcp/{environment}/terraform.tfstate`
- **Locking**: GCS object versioning for conflict prevention

### State Isolation

Each environment (dev/staging/prod) has separate state files:
- Dev: Independent state, can be freely modified
- Staging: Isolated, tested before production
- Production: Locked down, requires approval

---

## Security & Identity

### Deployment Identity (CI/CD)

| Platform | Identity | Permissions |
|----------|----------|-------------|
| **AWS** | IAM User (GitHub Actions) | ECS, ECR, S3, CloudFront, Secrets Manager |
| **GCP** | Service Account | Cloud Run, Container Registry, Storage |

### Human Access Control

- **AWS**: MFA required for console, IAM roles for CLI
- **GCP**: 2FA enabled, Organization policies enforced

### Secret Storage

| Secret | AWS | GCP |
|--------|-----|-----|
| **API Keys** | Secrets Manager | Secret Manager |
| **Database** | Secrets Manager | Secret Manager |
| **Credentials** | Never in code/logs | Never in code/logs |

### Security Groups / Firewall Rules

| Component | Rule | Justification |
|-----------|------|---------------|
| **ALB** | 0.0.0.0:80,443 | Public access needed |
| **ECS Tasks** | ALB security group only | Private network |
| **Cloud Run** | allUsers:invoker | Public API |

---

## Failure & Operational Thinking

### Failure Analysis

| Component | Failure Unit | Recovery | Human Intervention |
|-----------|--------------|----------|-------------------|
| **Backend Container** | Single ECS task | Auto-restart by ECS | No |
| **Frontend Container** | Single ECS task | Auto-restart by ECS | No |
| **ALB** | AZ-level failure | Multi-AZ automatic | No |
| **Cloud Run** | Instance failure | New instance starts | No |
| **Database** | N/A (stateless) | N/A | N/A |

### What Breaks First

1. **Backend Health Check Failure** → ALB removes unhealthy targets
2. **Container OOM** → ECS restarts container
3. **Scaling Lag** → Request queuing during spike

### Alerting Philosophy

- **Critical**: Service down, error rate > 5%
- **Warning**: High latency > 2s, CPU > 80%
- **Info**: Deployment completed, scaling events

---

## Future Growth Scenario

### Traffic Increases 10x

| Component | Change Required | Status |
|-----------|-----------------|--------|
| **Max Instances** | Increase from 10→100 | Easy config change |
| **Database** | Add RDS if state needed | New component |
| **CDN** | Already handling static | No change |

### New Backend Service

| Platform | Action |
|----------|--------|
| **AWS** | New ECS service, ALB target group |
| **GCP** | New Cloud Run service, Load balancer backend |

### Client Demands

| Requirement | Implementation |
|-------------|----------------|
| **Stricter Isolation** | Dedicated VPC, privateLink |
| **Region-specific Data** | Multi-region deployment |

---

## What We Did NOT Do

| Item | Reason |
|------|--------|
| **Kubernetes** | Overkill for simple app - ECS/Cloud Run simpler |
| **Database** | Stateless app, not needed |
| **Message Queue** | Synchronous processing sufficient |
| **VPC Peering** | Not needed for 2-service architecture |
| **PrivateLink** | Not needed for public API |
| **WAF** | Not required for this simple app |
| **Multi-Region Active-Active** | Cost-prohibitive for assignment |
| **Observability Stack** | Basic logging sufficient |
| **Chaos Engineering** | Not in scope |

---

## Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- GCP Account with appropriate permissions
- Terraform >= 1.0 installed
- Docker installed

### Deploy to AWS

```
bash
cd infrastructure/aws

# Initialize Terraform
terraform init -backend-config="bucket=YOUR_STATE_BUCKET"

# Deploy dev environment
terraform apply -var-file=dev.tfvars

# Deploy staging (after testing dev)
terraform apply -var-file=staging.tfvars

# Deploy production (with approval)
terraform apply -var-file=prod.tfvars
```

### Deploy to GCP

```
bash
cd infrastructure/gcp

# Initialize Terraform
terraform init -backend-config="bucket=YOUR_STATE_BUCKET"

# Deploy dev environment
terraform apply -var-file=dev.tfvars

# Deploy staging
terraform apply -var-file=staging.tfvars

# Deploy production
terraform apply -var-file=prod.tfvars
```

### GitHub Actions (Automatic Deployment)

1. Set up GitHub secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_ACCOUNT_ID`
   - `GCP_SA_KEY` (Base64 encoded)
   - `GCP_PROJECT_ID`

2. Push to main branch triggers deployment

---

## Live URLs

> **Note**: Replace with actual deployed URLs after infrastructure deployment

- **AWS Frontend**: https://devops-assignment-{environment}.cloudfront.net
- **AWS Backend**: https://devops-assignment-{environment}.cloudfront.net/api
- **GCP Frontend**: https://devops-frontend-{environment}-uc.a.run.app
- **GCP Backend**: https://devops-backend-{environment}-uc.a.run.app

---

## Documentation

- [External Architecture Documentation](https://docs.google.com) - Comprehensive cloud architecture guide

---

## Demo Video

[Link to demo video] - 8-12 minute walkthrough of architecture, deployment, and operations

---

## Project Structure

```
.
├── backend/                    # FastAPI backend
│   ├── app/
│   │   └── main.py            # Main application
│   ├── requirements.txt       # Python dependencies
│   └── Dockerfile            # Container image
├── frontend/                   # Next.js frontend
│   ├── pages/
│   │   └── index.js          # Main page
│   ├── package.json          # Node dependencies
│   └── Dockerfile            # Container image
├── infrastructure/
│   ├── aws/                  # AWS Terraform
│   │   ├── main.tf           # Main infrastructure
│   │   ├── variables.tf      # Variables
│   │   ├── dev.tfvars        # Dev environment
│   │   ├── staging.tfvars    # Staging environment
│   │   └── prod.tfvars       # Production environment
│   └── gcp/                  # GCP Terraform
│       ├── main.tf           # Main infrastructure
│       ├── variables.tf      # Variables
│       ├── dev.tfvars        # Dev environment
│       ├── staging.tfvars    # Staging environment
│       └── prod.tfvars       # Production environment
├── .github/
│   └── workflows/
│       ├── aws-deploy.yml    # AWS CI/CD
│       └── gcp-deploy.yml    # GCP CI/CD
├── TODO.md                   # Task tracker
└── README.md                 # This file
```

---

## License

MIT License - See LICENSE file for details
