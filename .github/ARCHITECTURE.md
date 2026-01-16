System Architecture Overview
============================

System Components
=================

**Application Tier**
```
   Frontend (Next.js)        Backend (FastAPI)
   - JavaScript/React        - Python 3.12
   - Port 3000              - Port 8000
   - Static assets          - REST API
   └─ E2E Tests            └─ Unit Tests (pytest)
```

**CI/CD Tier**
```
   GitHub Actions (CI)
   - Trigger: Push to develop
   - Environment: Python 3.12, Node 20
   - Caching: Docker Buildx cache
   └─ Outputs: Docker images to Docker Hub
```

**Registry**
```
   Docker Hub
   - Backend image: pg-agi-backend:{sha|latest}
   - Frontend image: pg-agi-frontend:{sha|latest}
   └─ Access: DOCKERHUB_TOKEN required
```

**Infrastructure (Optional)**
```
   Cloud Deployment Options
   - AWS ECS (template provided)
   - Kubernetes (template provided)
   - Terraform IaC (modules provided)
```

CI Pipeline Flow
================

**Detailed Pipeline Execution**

```
1. CODE PUSH TO DEVELOP BRANCH
   ↓
2. GITHUB ACTIONS TRIGGER
   ├─ Checkout repository
   ├─ Setup Python 3.12
   ├─ Setup Node.js 20
   └─ Configure Docker Buildx
   ↓
3. BACKEND TESTING
   ├─ Install dependencies: pip install -r requirements.txt
   ├─ Run tests: python -m pytest app/test_main.py
   └─ Verify: All tests pass
   ↓
4. FRONTEND TESTING & LINTING
   ├─ Install dependencies: npm ci
   ├─ Run linter: npm run lint
   ├─ Install Playwright: npx playwright install --with-deps
   ├─ Run unit tests: npm test
   ├─ Run E2E tests: npx playwright test
   └─ Verify: All tests pass
   ↓
5. BUILD DOCKER IMAGES
   ├─ Backend image
   │  ├─ Tag: short-sha and latest
   │  ├─ Dockerfile: multi-stage Python build
   │  └─ Cache: Docker Buildx cache
   ├─ Frontend image
   │  ├─ Tag: short-sha and latest
   │  ├─ Dockerfile: multi-stage Node.js build
   │  └─ Cache: Docker Buildx cache
   └─ Verify: Images built
   ↓
6. PUSH TO DOCKER HUB
   ├─ Authenticate: DOCKERHUB_TOKEN
   ├─ Backend: pg-agi-backend:{sha|latest}
   ├─ Frontend: pg-agi-frontend:{sha|latest}
   └─ Verify: Images in Docker Hub
   ↓
7. CI COMPLETE
   ├─ Duration: 3-5 minutes
   ├─ Status: Success/Failure
   └─ Next: Monitor logs, verify images
```

Data Flow
=========

**Application Communication**
```
Browser (Frontend)  ──HTTP──>  API (Backend)
     ↓                              ↓
  Next.js port 3000           FastAPI port 8000
  - Renders UI                - Handles requests
  - Makes API calls           - Returns responses
  - E2E tests verify          - Unit tests verify
```

**CI Artifact Flow**
```
Git Repository
     ↓
GitHub Actions (CI)
     ↓
Build & Test Pipeline
     ↓
Docker Images
     ↓
Docker Hub Registry
     ↓
(Ready for deployment)
```

Deployment Architecture
=======================

**Current Status**
- CI enabled on `develop` branch
- Deployment workflows disabled on `main` branch (by design)
- Prevents accidental cloud deployments before credentials are configured

**Deployment Options (Optional)**
- AWS ECS: Template in `infra/aws-ecs-config.md`
- Kubernetes: Template in `infra/k8s-deployment.md`
- Terraform IaC: Modules in `infra/terraform/`

**To Enable Deployment**
1. Configure cloud provider credentials
2. Rename `.disabled` to `.yml` in `.github/workflows/`
3. Update deployment target references
4. Commit and push to `main` branch

Testing and Validation
======================

**Backend Validation**
- Framework: pytest
- Location: `backend/app/test_main.py`
- Tests: API endpoints, health checks, business logic
- Coverage: Verified in CI on each commit

**Frontend Validation**
- Linting: ESLint (npm run lint)
- Unit tests: npm test
- E2E tests: Playwright on `frontend/e2e/frontend.spec.ts`
- Tests: Page rendering, API integration, user interactions
- Coverage: Verified in CI on each commit

**E2E Test Coverage**
- Verifies backend availability
- Validates frontend rendering
- Confirms API communication
- Tests basic user workflows

Security Considerations
=======================

**Secrets Management**
- `DOCKERHUB_TOKEN`: Never exposed in logs
- Scoped to: Docker Hub image push only
- Stored in: GitHub repository secrets
- Accessed in: CI workflow only

**Image Security**
- Multi-stage builds: Reduces image size and attack surface
- Docker Hub registry: Authentication required
- Tags: Immutable SHA + latest

**Workflow Security**
- CI workflows: Run on trusted GitHub runners
- No manual approvals needed (trusted develop branch)
- Deployment disabled by default (prevents accidents)

Performance Considerations
==========================

**Build Caching**
- Docker Buildx: Layer caching
- GitHub Actions: Dependency caching
- First build: ~5 minutes
- Subsequent builds: ~3 minutes (with warm cache)

**Test Optimization**
- Parallel: Backend and frontend tests
- Selective: Only changed code affected
- Playwright: Full browser automation for E2E

Monitoring and Observability
=============================

**CI Monitoring**
- GitHub Actions: View workflow runs in Actions tab
- Duration: Track build times
- Status: Pass/fail per stage
- Logs: Step-by-step execution details

**Application Health**
- Backend: pytest validates endpoints
- Frontend: Playwright E2E validates user experience
- Integration: Tests confirm backend-frontend communication

Next Steps
==========

1. Review [SECRETS.md](SECRETS.md) for credential setup
2. Follow [../../SETUP-COMPLETE.md](../../SETUP-COMPLETE.md) for configuration
3. Read [PIPELINE.md](PIPELINE.md) for detailed pipeline info
4. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for issue resolution
