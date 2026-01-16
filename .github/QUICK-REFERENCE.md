Quick Reference Guide
=====================

Git Branches
============

| Branch | Purpose | Trigger |
|--------|---------|---------|
| `develop` | CI pipeline | Any push |
| `main` | Deployment templates | Disabled |

GitHub Secrets
==============

**Required:**
- `DOCKERHUB_TOKEN` - Docker Hub personal access token

**Optional:**
- `DOCKERHUB_USERNAME` - Docker Hub username (defaults to repo owner)

**Where to add:**
Settings > Secrets and variables > Actions > New repository secret

Docker Image Tags
=================

**Format:**
```
<dockerhub-username>/<image-name>:<tag>
```

**Backend:**
- Image: `pg-agi-backend`
- Tags: `latest`, `{short-sha}`
- Example: `myuser/pg-agi-backend:latest`, `myuser/pg-agi-backend:abc1234`

**Frontend:**
- Image: `pg-agi-frontend`
- Tags: `latest`, `{short-sha}`
- Example: `myuser/pg-agi-frontend:latest`, `myuser/pg-agi-frontend:abc1234`

Common Commands
===============

**Backend (Local Testing)**
```bash
cd backend
pip install -r requirements.txt
python -m pytest app/test_main.py
```

**Frontend (Local Testing)**
```bash
cd frontend
npm ci
npm run lint
npx playwright install --with-deps
npx playwright test
```

**Docker Build (Backend)**
```bash
cd backend
docker build -t pg-agi-backend:local .
docker run -p 8000:8000 pg-agi-backend:local
```

**Docker Build (Frontend)**
```bash
cd frontend
docker build -t pg-agi-frontend:local .
docker run -p 3000:3000 pg-agi-frontend:local
```

**Push to develop (trigger CI)**
```bash
git push origin develop
```

CI Workflow Status
==================

**View in GitHub:**
1. Navigate to Actions tab
2. Click "CI (develop)" workflow
3. View recent runs and status

**Expected stages:**
- Checkout & Setup
- Backend Tests
- Frontend Tests & Lint
- Build Docker Images
- Push to Docker Hub

**Expected duration:** 3-5 minutes

File Locations
==============

**Workflow files:**
- CI: `.github/workflows/ci-develop.yml` (active)
- Deployment: `.github/workflows/deploy-main.yml.disabled` (disabled)
- Deployment: `.github/workflows/cd-main.yml.disabled` (disabled)

**Application code:**
- Backend: `backend/app/main.py`
- Backend tests: `backend/app/test_main.py`
- Frontend: `frontend/pages/index.js`
- E2E tests: `frontend/e2e/frontend.spec.ts`

**Dependencies:**
- Backend: `backend/requirements.txt`
- Frontend: `frontend/package.json`
- Playwright: `frontend/playwright.package.json`

Documentation Map
=================

**Getting started:**
- [../../README.md](../../README.md)
- [../../QUICKSTART.md](../../QUICKSTART.md)
- [../../START-HERE.md](../../START-HERE.md)

**Configuration:**
- [../../SETUP-COMPLETE.md](../../SETUP-COMPLETE.md)
- [SECRETS.md](SECRETS.md)

**Reference:**
- [PIPELINE.md](PIPELINE.md)
- [WORKFLOW_REFERENCE.md](WORKFLOW_REFERENCE.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

Useful Links
============

- Docker Hub: https://hub.docker.com
- GitHub Actions: Actions tab in repository
- FastAPI docs: http://localhost:8000/docs (local)
- Next.js app: http://localhost:3000 (local)
