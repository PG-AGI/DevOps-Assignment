# Infrastructure Architecture

## Multi-Cloud Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Users / Clients                                │
└─────────────────────┬───────────────────────────┬───────────────────────┘
                      │                           │
                      ▼                           ▼
        ┌─────────────────────────┐   ┌─────────────────────────┐
        │      AWS Region         │   │     GCP Region          │
        │      us-east-1          │   │    us-central1          │
        └─────────────────────────┘   └─────────────────────────┘
```

## AWS Architecture (Detailed)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Internet Gateway                                │
└────────────────────┬──────────────────────┬────────────────────────────┘
                     │                      │
         ┌───────────┴──────────┐  ┌───────┴─────────────┐
         │   Frontend ALB       │  │   Backend ALB       │
         │  Port 80/443         │  │  Port 80/443        │
         └───────────┬──────────┘  └───────┬─────────────┘
                     │                     │
┌────────────────────┴─────────────────────┴───────────────────────────────┐
│                          VPC (10.0.0.0/16)                                │
├───────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌─────────────────────────┐    ┌─────────────────────────┐            │
│  │ Public Subnet AZ-1      │    │ Public Subnet AZ-2      │            │
│  │ 10.0.0.0/24             │    │ 10.0.1.0/24             │            │
│  │  ┌──────────┐           │    │  ┌──────────┐           │            │
│  │  │ NAT GW 1 │           │    │  │ NAT GW 2 │           │            │
│  │  └──────────┘           │    │  └──────────┘           │            │
│  └─────────────────────────┘    └─────────────────────────┘            │
│                                                                           │
│  ┌─────────────────────────┐    ┌─────────────────────────┐            │
│  │ Private Subnet AZ-1     │    │ Private Subnet AZ-2     │            │
│  │ 10.0.100.0/24           │    │ 10.0.101.0/24           │            │
│  │  ┌──────────────────┐   │    │  ┌──────────────────┐   │            │
│  │  │ ECS Tasks        │   │    │  │ ECS Tasks        │   │            │
│  │  ├──────────────────┤   │    │  ├──────────────────┤   │            │
│  │  │ Frontend:3000    │   │    │  │ Frontend:3000    │   │            │
│  │  │ Backend:8000     │   │    │  │ Backend:8000     │   │            │
│  │  └──────────────────┘   │    │  └──────────────────┘   │            │
│  └─────────────────────────┘    └─────────────────────────┘            │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
         │                                      │
         ▼                                      ▼
┌──────────────────┐                  ┌──────────────────┐
│   ECR Repos      │                  │  CloudWatch      │
│  - Backend       │                  │   - Logs         │
│  - Frontend      │                  │   - Metrics      │
└──────────────────┘                  └──────────────────┘
```

### AWS Components

1. **VPC (Virtual Private Cloud)**
   - CIDR: 10.0.0.0/16
   - 2 Availability Zones for high availability
   - Public subnets: NAT Gateways, Load Balancers
   - Private subnets: ECS Tasks

2. **Application Load Balancers (ALB)**
   - Separate ALBs for frontend and backend
   - Health checks configured
   - Auto-scaling based on traffic

3. **ECS Fargate**
   - Serverless container orchestration
   - Task definitions for backend and frontend
   - Auto-scaling: 2-10 tasks
   - CPU-based scaling (target: 70%)

4. **ECR (Elastic Container Registry)**
   - Private Docker repositories
   - Image scanning enabled
   - Lifecycle policies (keep last 10 images)

5. **CloudWatch**
   - Centralized logging
   - Metrics and alarms
   - 7-day log retention

## GCP Architecture (Detailed)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      Global Load Balancer                                │
│                    (External IP: XX.XX.XX.XX)                           │
└────────────────┬───────────────────────────┬────────────────────────────┘
                 │                           │
         ┌───────┴──────────┐       ┌───────┴──────────┐
         │  Path: /         │       │  Path: /api/*    │
         │  Path: /home     │       │  Path: /health   │
         └───────┬──────────┘       └───────┬──────────┘
                 │                           │
         ┌───────▼──────────┐       ┌───────▼──────────┐
         │  Backend Service │       │  Backend Service │
         │   (Frontend)     │       │    (Backend)     │
         │   with CDN       │       │                  │
         └───────┬──────────┘       └───────┬──────────┘
                 │                           │
         ┌───────▼──────────┐       ┌───────▼──────────┐
         │  Network         │       │  Network         │
         │  Endpoint Group  │       │  Endpoint Group  │
         └───────┬──────────┘       └───────┬──────────┘
                 │                           │
┌────────────────┴───────────────────────────┴───────────────────────────┐
│                     VPC Network (Custom)                                │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │              VPC Access Connector                               │   │
│  │              10.8.0.0/28                                        │   │
│  └────────┬──────────────────────────────────┬────────────────────┘   │
│           │                                   │                         │
│  ┌────────▼────────────┐          ┌──────────▼──────────┐             │
│  │  Cloud Run          │          │  Cloud Run          │             │
│  │  Frontend Service   │          │  Backend Service    │             │
│  │                     │          │                     │             │
│  │  Min: 1 instance    │          │  Min: 1 instance    │             │
│  │  Max: 10 instances  │          │  Max: 10 instances  │             │
│  │  Port: 3000         │          │  Port: 8000         │             │
│  │  CPU: 1 vCPU        │          │  CPU: 1 vCPU        │             │
│  │  Memory: 512Mi      │          │  Memory: 512Mi      │             │
│  │                     │          │                     │             │
│  │  Auto-scale on:     │          │  Auto-scale on:     │             │
│  │  - CPU usage        │          │  - CPU usage        │             │
│  │  - Request count    │          │  - Request count    │             │
│  └─────────────────────┘          └─────────────────────┘             │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
         │                                      │
         ▼                                      ▼
┌──────────────────┐                  ┌──────────────────┐
│  Artifact        │                  │  Cloud           │
│  Registry /GCR   │                  │  Monitoring      │
│  - Backend       │                  │  - Uptime checks │
│  - Frontend      │                  │  - Metrics       │
└──────────────────┘                  └──────────────────┘
```

### GCP Components

1. **VPC Network**
   - Custom network configuration
   - Subnet: 10.0.0.0/24
   - Firewall rules for internal and external traffic

2. **Cloud Run**
   - Fully managed serverless platform
   - Automatic HTTPS
   - Built-in auto-scaling
   - Pay-per-use pricing

3. **Global Load Balancer**
   - Path-based routing
   - CDN enabled for frontend
   - SSL termination
   - Anycast IP for global reach

4. **Artifact Registry / GCR**
   - Docker image storage
   - Regional replication
   - Vulnerability scanning

5. **Cloud Monitoring**
   - Uptime checks
   - Custom metrics
   - Alerting policies

## Comparison: AWS vs GCP

| Feature | AWS | GCP |
|---------|-----|-----|
| **Compute** | ECS Fargate | Cloud Run |
| **Networking** | VPC with NAT | VPC with Access Connector |
| **Load Balancing** | ALB (2x) | Global LB (1x) |
| **Container Registry** | ECR | GCR/Artifact Registry |
| **Scaling** | Manual config (2-10) | Auto (1-10) |
| **HTTPS** | Requires ACM cert | Built-in |
| **Cost (monthly)** | ~$165 | ~$75 |
| **Deployment Time** | ~10 minutes | ~5 minutes |
| **Auto-scaling** | CPU-based | CPU + Request-based |

## Traffic Flow

### AWS Request Flow

```
User → Route 53 (DNS) → ALB → Target Group → ECS Task → Container
                          ↓
                    Health Checks
                          ↓
                    CloudWatch Logs
```

### GCP Request Flow

```
User → Cloud DNS → Global LB → Backend Service → NEG → Cloud Run → Container
                      ↓                                    ↓
                    CDN (Frontend)              Cloud Monitoring
```

## High Availability & Disaster Recovery

### AWS HA Strategy
- Multi-AZ deployment (2 AZs)
- Auto-scaling groups
- Health checks with automatic replacement
- ELB for traffic distribution
- Deployment circuit breaker with rollback

### GCP HA Strategy
- Multi-region capability (configured single region)
- Automatic instance management
- Built-in health checks
- Global load balancing
- Blue-green deployments

## Security Architecture

### Network Security

**AWS:**
```
Internet Gateway
    ↓
Security Group (ALB) - Allow 80/443 from 0.0.0.0/0
    ↓
Security Group (ECS) - Allow traffic only from ALB SG
    ↓
Private Subnets - No direct internet access
    ↓
NAT Gateway - Outbound internet for updates
```

**GCP:**
```
Internet
    ↓
Google Cloud Armor (optional)
    ↓
Cloud Run IAM - Public invoker role
    ↓
VPC Access Connector - Private network access
    ↓
Firewall Rules - Controlled access
```

### Identity & Access Management

**AWS:**
- IAM roles for ECS tasks
- Task execution role (pull images, logs)
- Task role (application permissions)
- ECR access policies

**GCP:**
- Service accounts for Cloud Run
- Artifact Registry permissions
- Cloud Run invoker permissions
- VPC access permissions

## Monitoring & Observability

### AWS Monitoring Stack

```
┌─────────────────────────────────────────┐
│         CloudWatch Logs                 │
│  /ecs/pg-agi-backend                   │
│  /ecs/pg-agi-frontend                  │
├─────────────────────────────────────────┤
│         CloudWatch Metrics              │
│  - CPUUtilization                       │
│  - MemoryUtilization                    │
│  - RequestCount                         │
│  - TargetResponseTime                   │
├─────────────────────────────────────────┤
│         CloudWatch Alarms               │
│  - High CPU (> 80%)                     │
│  - Service unhealthy                    │
└─────────────────────────────────────────┘
```

### GCP Monitoring Stack

```
┌─────────────────────────────────────────┐
│         Cloud Logging                   │
│  projects/PROJECT_ID/logs               │
├─────────────────────────────────────────┤
│         Cloud Monitoring                │
│  - Request count                        │
│  - Latency                              │
│  - Error rate                           │
│  - Instance count                       │
├─────────────────────────────────────────┤
│         Uptime Checks                   │
│  - Backend health                       │
│  - Frontend availability                │
└─────────────────────────────────────────┘
```

## Cost Optimization

### AWS Cost Breakdown
```
Component               Monthly Cost
────────────────────────────────────
NAT Gateway (2x)        $65
ECS Fargate (4 tasks)   $60
ALB (2x)                $30
CloudWatch              $10
Data Transfer           Free tier
────────────────────────────────────
Total                   ~$165/month
```

### GCP Cost Breakdown
```
Component               Monthly Cost
────────────────────────────────────
Cloud Run               $50
Load Balancer           $20
Artifact Registry       $5
VPC/Networking          $0
────────────────────────────────────
Total                   ~$75/month
```

### Cost Optimization Tips

1. **AWS:**
   - Use Fargate Spot for non-critical workloads
   - Single NAT Gateway for dev environments
   - Reduce log retention period
   - Use reserved capacity for stable workloads

2. **GCP:**
   - Set appropriate min/max instances
   - Use request-based scaling
   - Enable CDN for static content
   - Clean up unused images

## Scaling Patterns

### Horizontal Scaling

**AWS ECS:**
```python
Target Tracking Policy:
- Metric: CPUUtilization
- Target: 70%
- Scale out: Add 1 task every 60s
- Scale in: Remove 1 task every 300s
- Min: 2 tasks
- Max: 10 tasks
```

**GCP Cloud Run:**
```python
Auto-scaling:
- CPU utilization threshold
- Request concurrency (default: 80)
- Scale to zero when idle
- Min: 1 instance
- Max: 10 instances
- Scale out: Immediate
- Scale in: After cooldown
```

## Deployment Strategies

### Blue-Green Deployment

**AWS:**
```
1. Create new task definition (Green)
2. Update service with new task definition
3. ALB health checks validate new tasks
4. Gradually shift traffic (100% → 0% Blue, 0% → 100% Green)
5. Circuit breaker triggers rollback on failure
```

**GCP:**
```
1. Deploy new revision (Green)
2. Cloud Run validates new revision
3. Traffic split: 100% Blue, 0% Green
4. Gradually increase Green traffic
5. Monitor error rates
6. Rollback if needed (instant)
```

## Infrastructure as Code Benefits

1. **Version Control**: All infrastructure changes tracked in Git
2. **Reproducibility**: Identical environments across dev/staging/prod
3. **Consistency**: Standardized resource naming and tagging
4. **Documentation**: Code serves as documentation
5. **Testing**: Validate changes before applying
6. **Collaboration**: Team can review and approve changes
7. **Disaster Recovery**: Rebuild entire infrastructure from code

## References

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [GCP Architecture Framework](https://cloud.google.com/architecture/framework)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/)
- [12 Factor App](https://12factor.net/)
