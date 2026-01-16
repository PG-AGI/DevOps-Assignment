Workflow Reference and Details
==============================

CI Workflow: ci-develop.yml
===========================

**Trigger Condition**
- Branch: `develop`
- Event: Any push
- Status: Active and enabled

**Step 1: Setup and Environment**
```yaml
- Checkout code from repository
- Setup Python 3.12 runtime
- Setup Node.js 20 runtime
- Configure Docker Buildx for multi-platform builds
```

**Step 2: Backend Testing**
```yaml
- Name: Install Python Dependencies
  Command: pip install -r requirements.txt
  Duration: 30-60 seconds (cached on subsequent runs)

- Name: Run Backend Tests
  Command: python -m pytest app/test_main.py -v
  Expected: All tests pass
  Duration: 10-20 seconds
```

**Step 3: Frontend Testing and Linting**
```yaml
- Name: Install Node Dependencies
  Command: npm ci
  Duration: 60-120 seconds (cached on subsequent runs)

- Name: Run ESLint
  Command: npm run lint
  Expected: No linting errors
  Duration: 5-10 seconds

- Name: Install Playwright Browsers
  Command: npx playwright install --with-deps
  Duration: 60-90 seconds (cached on subsequent runs)

- Name: Run Unit Tests
  Command: npm test
  Expected: All tests pass
  Duration: 10-20 seconds

- Name: Run E2E Tests
  Command: npx playwright test
  Expected: All tests pass
  Duration: 30-60 seconds
```

**Step 4: Build Docker Images**
```yaml
- Name: Build Backend Image
  Command: docker buildx build --tag <user>/pg-agi-backend:{sha|latest}
  Context: ./backend/
  Dockerfile: backend/Dockerfile
  Cache: GitHub Actions cache + Docker layer cache
  Duration: 2-3 minutes (first run), 30-60 seconds (cached)

- Name: Build Frontend Image
  Command: docker buildx build --tag <user>/pg-agi-frontend:{sha|latest}
  Context: ./frontend/
  Dockerfile: frontend/Dockerfile
  Cache: GitHub Actions cache + Docker layer cache
  Duration: 2-3 minutes (first run), 30-60 seconds (cached)
```

**Step 5: Push to Docker Hub**
```yaml
- Name: Authenticate to Docker Hub
  Secret: DOCKERHUB_TOKEN
  Username: DOCKERHUB_USERNAME (or repo owner)

- Name: Push Backend Image
  Image: <username>/pg-agi-backend
  Tags: {short-sha}, latest
  Duration: 30-60 seconds

- Name: Push Frontend Image
  Image: <username>/pg-agi-frontend
  Tags: {short-sha}, latest
  Duration: 30-60 seconds
```

**Overall Duration:** 3-5 minutes per run

Deployment Workflows (Disabled)
================================

**deploy-main.yml.disabled**

**Purpose**
- Template for AWS ECS or GCP Cloud Run deployment
- Intentionally disabled to prevent accidental deployments

**To Enable**
1. Rename file: `deploy-main.yml.disabled` → `deploy-main.yml`
2. Add credentials: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
3. Update target: ECS cluster and service names
4. Commit and push to `main` branch

**Trigger**
- Branch: `main` only
- Event: Push after merge

**Intended Stages**
- Pull Docker images from Docker Hub
- Deploy to ECS or Cloud Run
- Run smoke tests
- Report deployment status

**cd-main.yml.disabled**

**Purpose**
- Template for continuous deployment workflow
- Similar to deploy-main but with different orchestration

**To Enable**
1. Rename file: `cd-main.yml.disabled` → `cd-main.yml`
2. Configure cloud provider credentials
3. Update deployment parameters
4. Commit and push to `main` branch

Caching Strategy
=================

**GitHub Actions Cache**
- Dependencies: Python packages and npm modules
- Key: OS + Python version + requirements.txt hash
- Hit rate improves after first run
- Automatically managed by GitHub

**Docker Buildx Cache**
- Layers: Each build layer cached
- Mode: inline (stored in image) and registry (external)
- Improves subsequent build speed
- Automatically managed per build

**Impact on Build Time**
```
First build:  5 minutes (all dependencies, fresh cache)
Second build: 3 minutes (warm cache, minimal dependencies)
Typical build: 3-4 minutes (most dependencies cached)
```

Image Tagging and Naming
========================

**Naming Convention**
```
<registry>/<namespace>/<image>:<tag>

Examples:
- myusername/pg-agi-backend:abc1234
- myusername/pg-agi-backend:latest
- myusername/pg-agi-frontend:abc1234
- myusername/pg-agi-frontend:latest
```

**Tag Strategy**
- `latest`: Always points to most recent commit on develop
- `{short-sha}`: Immutable commit-specific tag (7-char SHA)
- Both tags applied simultaneously
- Allows rollback: Pull specific SHA tag when needed

**Image IDs**
- Backend: `pg-agi-backend`
- Frontend: `pg-agi-frontend`
- Registry: Docker Hub (default)
- Username: `DOCKERHUB_USERNAME` or repository owner

Environment Variables and Secrets
==================================

**Required Secrets**
| Secret | Purpose | Where Used |
|--------|---------|------------|
| `DOCKERHUB_TOKEN` | Docker Hub authentication | Push step |

**Optional Secrets**
| Secret | Purpose | Default |
|--------|---------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub username | Repository owner |

**Workflow Access**
- Secrets available in all steps
- Masked in logs (never visible)
- Scoped to: CI workflow only

**Adding Secrets**
1. Go to repository Settings
2. Secrets and variables > Actions
3. Click "New repository secret"
4. Add name and value
5. Available in next workflow run

Debugging and Troubleshooting
=============================

**View Workflow Logs**
1. Navigate to Actions tab
2. Click workflow name ("CI (develop)")
3. Click specific run
4. Expand steps to see details

**Common Issues**
| Issue | Cause | Solution |
|-------|-------|----------|
| Docker push fails | Invalid token | Verify DOCKERHUB_TOKEN |
| npm install fails | Stale cache | Clear cache, retry |
| Tests fail | Environment issue | Review test logs, reproduce locally |
| Build times slow | Warm cache not available | Typical on first run, improves after |

**Enable Debug Logging**
1. Repository Settings > Secrets and variables > Actions
2. Create secret: `ACTIONS_STEP_DEBUG` = `true`
3. Re-run workflow
4. View detailed step output in logs

Workflow Status and Metrics
===========================

**Monitoring**
- GitHub Actions tab: Visual status per workflow
- Badges: Can be added to README
- Notifications: Email on failure

**Metrics to Track**
- Success rate: Should be >95%
- Duration: Typical 3-5 minutes
- Cache hit rate: Improves over time
- Image sizes: Monitor for optimization

**Performance Optimization**
- Parallel jobs: Backend and frontend tests in parallel
- Caching: Reuse dependencies
- Layer caching: Docker Buildx
- Selective testing: Only changed files (future improvement)

Next Steps
==========

1. Review [SECRETS.md](SECRETS.md) to setup credentials
2. Read [PIPELINE.md](PIPELINE.md) for overview
3. Check [../../SETUP-COMPLETE.md](../../SETUP-COMPLETE.md) for step-by-step
4. Consult [TROUBLESHOOTING.md](TROUBLESHOOTING.md) if issues arise
