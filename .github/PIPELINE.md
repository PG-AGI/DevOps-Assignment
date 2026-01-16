Pipeline Reference
==================

CI (develop)
------------
- Workflow: `.github/workflows/ci-develop.yml`
- Stages: tests (backend pytest, frontend npm), Playwright E2E, build and push Docker images
- Outputs: Docker Hub images `pg-agi-backend` and `pg-agi-frontend` tagged with short SHA and `latest`

Deployment (main)
-----------------
- Workflows provided as `.disabled` templates: `deploy-main.yml.disabled`, `cd-main.yml.disabled`
- Intended for enabling after credentials and targets are set
- Supports adaptation for AWS ECS, GCP Cloud Run, or custom targets

Secrets
-------
- `DOCKERHUB_TOKEN` (required)
- `DOCKERHUB_USERNAME` (optional; defaults to repository owner)

Caching and tagging
-------------------
- Uses Buildx with GitHub Actions cache
- Tags: short Git SHA and `latest`

Testing steps
-------------
- Backend: `python -m pytest app/test_main.py`
- Frontend: `npm test` (placeholder), `npm run lint`, `npx playwright test`

Notes for enabling deployment
-----------------------------
- Uncomment or rename the deployment workflows
- Add cloud credentials and update registry references if not using Docker Hub
