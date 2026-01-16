Repository Structure and Pipeline Layout
==========================================

Directory Layout
================

Root Level
----------
```
.
├── README.md                    # Project overview and local setup
├── README-CICD.md               # CI/CD pipeline details
├── QUICKSTART.md                # 5-minute quick start guide
├── START-HERE.md                # Engineer onboarding
├── SETUP-COMPLETE.md            # Configuration and setup steps
├── CI-CD-INDEX.md               # Documentation navigation index
├── IMPLEMENTATION-COMPLETE.md   # Summary of implementation
├── PIPELINE-STRUCTURE.md        # This file
├── backend/
├── frontend/
├── .github/
└── infra/
```

Backend Directory
-----------------
```
backend/
├── app/
│   ├── main.py                  # FastAPI application entry point
│   └── test_main.py             # pytest unit tests
├── Dockerfile                   # Multi-stage backend container build
└── requirements.txt             # Python dependencies (pytest, fastapi, uvicorn, etc.)
```

Frontend Directory
------------------
```
frontend/
├── pages/
│   └── index.js                 # Next.js main application page
├── e2e/
│   └── frontend.spec.ts         # Playwright E2E test suite
├── Dockerfile                   # Multi-stage frontend container build
├── package.json                 # Node.js dependencies
└── playwright.package.json      # Playwright test dependencies
```

GitHub Actions and Workflows
-----------------------------
```
.github/
├── workflows/
│   ├── ci-develop.yml           # CI pipeline (active - runs on develop push)
│   ├── deploy-main.yml.disabled # Deployment template (disabled)
│   └── cd-main.yml.disabled     # CD template (disabled)
├── PIPELINE.md                  # Pipeline reference documentation
├── WORKFLOW_REFERENCE.md        # Workflow details and structure
├── ARCHITECTURE.md              # System architecture overview
├── QUICK-REFERENCE.md           # Quick lookup reference
├── SECRETS.md                   # Secrets configuration guide
└── TROUBLESHOOTING.md           # Common issues and solutions
```

Infrastructure and Deployment
------------------------------
```
infra/
├── DEPLOYMENT-CHECKLIST.md      # Pre-deployment verification steps
├── TERRAFORM-PROJECT-SUMMARY.md # Terraform project overview
├── TERRAFORM-SETUP-COMPLETE.md  # Terraform setup details
├── VALIDATION-REPORT.md         # Infrastructure validation results
├── aws-ecs-config.md            # AWS ECS deployment template
├── k8s-deployment.md            # Kubernetes deployment template
└── terraform/
    ├── INDEX.md                 # Terraform modules index
    ├── README.md                # Terraform setup guide
    ├── main.tf                  # Terraform main configuration
    ├── variables.tf             # Terraform input variables
    └── ...                       # Additional Terraform modules
```

CI/CD Pipeline Flow
===================

Trigger: Push to Develop
------------------------

```
Code Push to develop
      ↓
Checkout & Setup (Python 3.12, Node 20)
      ↓
Backend Tests (pytest)
      ├─→ Run: python -m pytest app/test_main.py
      └─→ Status: Pass/Fail
      ↓
Frontend Tests & Lint
      ├─→ Run: npm ci
      ├─→ Run: npm run lint
      ├─→ Run: npx playwright install --with-deps
      ├─→ Run: npm test
      └─→ Run: npx playwright test
      ↓
Build Docker Images
      ├─→ Backend: pg-agi-backend:{SHA|latest}
      └─→ Frontend: pg-agi-frontend:{SHA|latest}
      ↓
Push to Docker Hub
      ├─→ Authenticate with DOCKERHUB_TOKEN
      ├─→ Push backend image
      └─→ Push frontend image
      ↓
Workflow Complete
```

Key Files and Their Purposes
=============================

Workflow Configuration
----------------------
| File | Purpose | Status |
|---|---|---|
| `.github/workflows/ci-develop.yml` | Active CI pipeline | Enabled |
| `.github/workflows/deploy-main.yml.disabled` | AWS/GCP deployment | Disabled |
| `.github/workflows/cd-main.yml.disabled` | CD deployment example | Disabled |

Application Code
----------------
| File | Purpose | Language |
|---|---|---|
| `backend/app/main.py` | FastAPI application | Python |
| `backend/app/test_main.py` | Backend tests | Python |
| `frontend/pages/index.js` | Frontend application | JavaScript |
| `frontend/e2e/frontend.spec.ts` | E2E tests | TypeScript |

Container Configuration
-----------------------
| File | Purpose | Target |
|---|---|---|
| `backend/Dockerfile` | Backend image build | Python |
| `frontend/Dockerfile` | Frontend image build | Node.js |

Dependencies
------------
| File | Purpose | Type |
|---|---|---|
| `backend/requirements.txt` | Python dependencies | Backend |
| `frontend/package.json` | Node.js dependencies | Frontend |
| `frontend/playwright.package.json` | Playwright test deps | Frontend |

Documentation Map
=================

Getting Started
---------------
1. [README.md](README.md) - Project overview and local development
2. [QUICKSTART.md](QUICKSTART.md) - 5-minute setup
3. [START-HERE.md](START-HERE.md) - Engineer onboarding

Configuration and Setup
-----------------------
1. [SETUP-COMPLETE.md](SETUP-COMPLETE.md) - GitHub secrets and CI configuration
2. [README-CICD.md](README-CICD.md) - CI/CD pipeline details

References
----------
1. [CI-CD-INDEX.md](CI-CD-INDEX.md) - Complete documentation index
2. [.github/PIPELINE.md](.github/PIPELINE.md) - Pipeline details
3. [.github/QUICK-REFERENCE.md](.github/QUICK-REFERENCE.md) - Quick lookup
4. [.github/SECRETS.md](.github/SECRETS.md) - Secrets reference
5. [.github/TROUBLESHOOTING.md](.github/TROUBLESHOOTING.md) - Debugging guide

Infrastructure
---------------
1. [infra/DEPLOYMENT-CHECKLIST.md](infra/DEPLOYMENT-CHECKLIST.md) - Deployment verification
2. [infra/aws-ecs-config.md](infra/aws-ecs-config.md) - AWS ECS template
3. [infra/k8s-deployment.md](infra/k8s-deployment.md) - Kubernetes template
4. [infra/terraform/README.md](infra/terraform/README.md) - Terraform setup

Secrets and Credentials
=======================

Required for CI
---------------
- `DOCKERHUB_TOKEN`: Docker Hub personal access token (required)
- `DOCKERHUB_USERNAME`: Docker Hub username (optional; defaults to repo owner)

Optional for Deployment
-----------------------
- AWS credentials (if enabling ECS deployment)
- GCP credentials (if enabling GCP deployment)

Image Tagging
=============

Strategy
--------
- Uses short Git SHA and `latest` tag
- Both backend and frontend tagged identically

Format
------
```
<dockerhub-username>/<image-name>:<tag>

Examples:
myusername/pg-agi-backend:abc1234
myusername/pg-agi-backend:latest
myusername/pg-agi-frontend:abc1234
myusername/pg-agi-frontend:latest
```

Testing Coverage
================

Backend Tests
-------------
- Framework: pytest
- Location: `backend/app/test_main.py`
- Run in CI: `python -m pytest app/test_main.py`

Frontend Tests
--------------
- Linting: npm eslint
- Unit tests: npm test
- E2E tests: Playwright
- Location: `frontend/e2e/frontend.spec.ts`

Next Steps
==========

1. Review [README.md](README.md) for project setup
2. Follow [QUICKSTART.md](QUICKSTART.md) for 5-minute start
3. Configure secrets: [SETUP-COMPLETE.md](SETUP-COMPLETE.md)
4. Deep dive: [README-CICD.md](README-CICD.md)
5. Reference: [CI-CD-INDEX.md](CI-CD-INDEX.md) for full documentation map
