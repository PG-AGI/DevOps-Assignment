Start Here
==========

Audience
--------
- Engineers reviewing the CI/CD implementation
- DevOps practitioners integrating or extending the pipeline

What you will find
-------------------
- Overview of the pipeline and file map
- Required secrets and prerequisites
- Typical workflow from code push to artifact publication

Required secrets
----------------
- `DOCKERHUB_TOKEN`: Docker Hub access token
- `DOCKERHUB_USERNAME` (optional): Docker Hub username; defaults to repository owner when absent

Workflow summary
----------------
1. Push to `develop`
	- Run backend tests (pytest)
	- Run frontend lint/tests (npm) and Playwright E2E
	- Build backend and frontend images
	- Push images to Docker Hub with `latest` and short-SHA tags
2. (Optional) Merge to `main`
	- Deployment workflows are present but disabled; enable or adapt to target environment

File structure (selected)
-------------------------
- CI: `.github/workflows/ci-develop.yml`
- Disabled deployment: `.github/workflows/deploy-main.yml.disabled`, `.github/workflows/cd-main.yml.disabled`
- Docs index: `CI-CD-INDEX.md`, `PIPELINE-STRUCTURE.md`
- Infra: `infra/` (checklists, cloud templates), `infra/terraform/` (IaC docs)

Next steps
----------
- Read [QUICKSTART.md](QUICKSTART.md) for a five-minute setup
- Review [CI-CD-INDEX.md](CI-CD-INDEX.md) for documentation map
- Consult [PIPELINE-STRUCTURE.md](PIPELINE-STRUCTURE.md) for repository layout
