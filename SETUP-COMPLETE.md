Configuration and Setup Completion
====================================

Overview
--------
This guide walks through configuring GitHub secrets, verifying CI, and preparing for deployment.

Prerequisites
-------------
- GitHub repository with Actions enabled
- Docker Hub account with valid access token
- Code pushed to repository

Step 1: Create Docker Hub Token
--------------------------------

**On Docker Hub:**
1. Log in to [Docker Hub](https://hub.docker.com)
2. Navigate to Account Settings > Security
3. Click "New Access Token"
4. Name it (e.g., `pg-agi-ci`)
5. Set permissions to "Read, Write" (for image push)
6. Copy the token

Step 2: Configure GitHub Secrets
---------------------------------

**In your GitHub repository:**

1. Go to Settings > Secrets and variables > Actions
2. Click "New repository secret"
3. Add the following secrets:

   **Required:**
   - **Name:** `DOCKERHUB_TOKEN`
   - **Value:** Paste the Docker Hub token from Step 1

   **Optional:**
   - **Name:** `DOCKERHUB_USERNAME`
   - **Value:** Your Docker Hub username

Note: If `DOCKERHUB_USERNAME` is not set, the workflow uses the GitHub repository owner as the default.

Step 3: Verify Secrets Are Set
-------------------------------

**Check in GitHub UI:**
1. Go to Settings > Secrets and variables > Actions
2. Confirm `DOCKERHUB_TOKEN` is listed
3. Confirm `DOCKERHUB_USERNAME` is listed (if added)

Step 4: Trigger CI Pipeline
----------------------------

**Push code to develop branch:**
```bash
git push origin develop
```

**In GitHub:**
1. Navigate to Actions tab
2. Watch "CI (develop)" workflow run
3. Stages: checkout, tests, build, push to Docker Hub

Expected duration: 3-5 minutes

Step 5: Verify Docker Images
-----------------------------

**On Docker Hub:**
1. Log in to Docker Hub
2. Navigate to your repositories
3. Look for:
   - `pg-agi-backend` (tagged with `latest` and short SHA)
   - `pg-agi-frontend` (tagged with `latest` and short SHA)

Example image name:
```
<dockerhub-username>/pg-agi-backend:abc1234
<dockerhub-username>/pg-agi-backend:latest
```

Step 6: Review Test Results
----------------------------

**In GitHub Actions workflow run:**
1. Backend tests: pytest on `backend/app/test_main.py`
2. Frontend lint: npm eslint
3. Frontend tests: npm test
4. E2E tests: Playwright on frontend

All should show "PASSED" status.

Step 7: Optional - Enable Deployment Workflows
-----------------------------------------------

Deployment workflows are provided as disabled templates:
- `.github/workflows/deploy-main.yml.disabled`
- `.github/workflows/cd-main.yml.disabled`

To enable (optional):
1. Review workflow file
2. Add cloud provider credentials (AWS, GCP, etc.)
3. Rename from `.disabled` to `.yml`
4. Commit and push to `main` branch

See [infra/DEPLOYMENT-CHECKLIST.md](infra/DEPLOYMENT-CHECKLIST.md) for pre-deployment requirements.

Troubleshooting
---------------

**CI fails at Docker push:**
- Verify `DOCKERHUB_TOKEN` is valid and not expired
- Confirm `DOCKERHUB_USERNAME` matches Docker Hub account
- Check Docker Hub repository is public (or token has private repo access)

**Tests fail locally:**
- Backend: ensure `requirements.txt` is installed
- Frontend: run `npx playwright install --with-deps`
- Ensure ports 8000 (backend) and 3000 (frontend) are available

**Images not appearing on Docker Hub:**
- Check GitHub Actions logs for push errors
- Verify credentials are set correctly
- Ensure repository owner name matches Docker Hub username (if using default)

Next Steps
----------
- Read [START-HERE.md](START-HERE.md) for architecture overview
- Review [CI-CD-INDEX.md](CI-CD-INDEX.md) for documentation map
- Consult [.github/TROUBLESHOOTING.md](.github/TROUBLESHOOTING.md) for common issues
