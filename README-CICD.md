CI/CD Pipeline Overview
=======================

Purpose
-------
Automate testing, building, and publishing of Docker images to Docker Hub on each code push.

Pipelines Summary
=================

Continuous Integration (Develop Branch)
----------------------------------------

**Trigger:** Any push to `develop` branch

**Workflow file:** `.github/workflows/ci-develop.yml`

**Stages:**

1. **Setup**
   - Checkout code
   - Set up Python 3.12
   - Set up Node.js 20

2. **Backend Testing**
   - Install Python dependencies: `pip install -r requirements.txt`
   - Run pytest: `python -m pytest app/test_main.py`

3. **Frontend Testing**
   - Install Node dependencies: `npm ci`
   - Run linter: `npm run lint`
   - Install Playwright browsers: `npx playwright install --with-deps`
   - Run unit tests: `npm test`
   - Run E2E tests: `npx playwright test`

4. **Build Docker Images**
   - Backend image: tagged with short Git SHA and `latest`
   - Frontend image: tagged with short Git SHA and `latest`
   - Uses Docker Buildx with GitHub Actions cache

5. **Push to Docker Hub**
   - Authenticate with `DOCKERHUB_TOKEN`
   - Push backend: `<username>/pg-agi-backend:{sha|latest}`
   - Push frontend: `<username>/pg-agi-frontend:{sha|latest}`

**Expected duration:** 3-5 minutes

Deployment (Main Branch - Disabled)
-----------------------------------

**Workflow files:**
- `.github/workflows/deploy-main.yml.disabled`
- `.github/workflows/cd-main.yml.disabled`

**Status:** Intentionally disabled to prevent accidental cloud deployments

**To enable:**
1. Rename `.disabled` to `.yml`
2. Add cloud provider credentials (AWS, GCP, etc.)
3. Update deployment targets
4. Commit and push to `main` branch

See [infra/DEPLOYMENT-CHECKLIST.md](infra/DEPLOYMENT-CHECKLIST.md) for full deployment guide.

Configuration
=============

Required Secrets
----------------

Add in GitHub repository: Settings > Secrets and variables > Actions

| Secret Name | Required | Description |
|---|---|---|
| `DOCKERHUB_TOKEN` | Yes | Docker Hub personal access token for image push |
| `DOCKERHUB_USERNAME` | No | Docker Hub username; defaults to repository owner if absent |

How to create Docker Hub token:
1. Log in to Docker Hub
2. Account Settings > Security
3. Create New Access Token
4. Set permissions to "Read, Write"
5. Copy token to GitHub secrets

Image Naming and Tagging
------------------------

**Format:**
```
<dockerhub-username>/<image-name>:<tag>
```

**Backend image:**
- Name: `pg-agi-backend`
- Tags: `{short-sha}` and `latest`
- Example: `username/pg-agi-backend:abc1234`, `username/pg-agi-backend:latest`

**Frontend image:**
- Name: `pg-agi-frontend`
- Tags: `{short-sha}` and `latest`
- Example: `username/pg-agi-frontend:abc1234`, `username/pg-agi-frontend:latest`

Caching Strategy
----------------

- Uses Docker Buildx with GitHub Actions cache
- Layers cached per image
- Speeds up subsequent builds
- Cache is automatically managed by GitHub Actions

Testing Coverage
================

Backend Tests
-------------
- Framework: pytest
- Location: `backend/app/test_main.py`
- Covers: API endpoints, health checks, message functionality

Frontend Tests
--------------
- Unit tests: npm test
- Linting: npm run lint
- E2E tests: Playwright
- Location: `frontend/e2e/frontend.spec.ts`
- Covers: Page rendering, API communication, user interactions

Monitoring and Troubleshooting
==============================

View Workflow Runs
------------------

**In GitHub:**
1. Navigate to Actions tab
2. Click "CI (develop)" workflow
3. View recent runs with status (passing/failing)
4. Click individual run to see details

Common Issues
-------------

**Docker Hub push fails:**
- Verify `DOCKERHUB_TOKEN` is valid and not expired
- Check token has "Read, Write" permissions
- Ensure Docker Hub repository exists (auto-created on first push)

**Tests fail:**
- Review test logs in GitHub Actions
- Ensure all dependencies are in `requirements.txt` (backend) or `package.json` (frontend)
- Run tests locally to reproduce: see [README.md](README.md)

**Images not tagged correctly:**
- Check Git SHA is being calculated correctly
- Verify Docker Buildx is using correct tag parameters

**Slow builds:**
- Builds may be slow on first run (fresh cache)
- Subsequent builds benefit from Docker layer caching
- GitHub Actions cache may take 1-2 runs to fully warm up

Debugging Workflows
-------------------

**Enable debug logging:**
1. Go to repository Settings > Secrets and variables > Actions
2. Create new secret: `ACTIONS_STEP_DEBUG` = `true`
3. Re-run workflow to see detailed logs

**View specific step logs:**
1. Open workflow run
2. Click failed step to expand
3. Review error messages and stack traces

Next Steps
==========

1. Ensure `DOCKERHUB_TOKEN` is configured: [SETUP-COMPLETE.md](SETUP-COMPLETE.md)
2. Push code to `develop` to trigger CI
3. Verify images appear on Docker Hub
4. Review [CI-CD-INDEX.md](CI-CD-INDEX.md) for full documentation map
5. When ready, enable deployment workflows: [infra/DEPLOYMENT-CHECKLIST.md](infra/DEPLOYMENT-CHECKLIST.md)
