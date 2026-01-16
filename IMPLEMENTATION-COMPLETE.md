Implementation Summary
======================

Scope delivered
---------------
- CI on `develop`: backend tests (pytest), frontend lint/tests, Playwright E2E, Docker image builds, push to Docker Hub
- Image tagging: short Git SHA and `latest`
- Deployment workflows: provided as disabled stubs for main branch
- Documentation: onboarding, references, infra guides, Terraform references

Key decisions
-------------
- Docker Hub chosen over multi-cloud registries; multi-cloud steps commented/disabled
- Repository owner used as Docker Hub username if `DOCKERHUB_USERNAME` is absent
- Deployment workflows left disabled to avoid unintended cloud usage; enable after configuring credentials

What to configure
-----------------
- GitHub secret `DOCKERHUB_TOKEN` (required)
- Optional `DOCKERHUB_USERNAME`
- If enabling deployments, supply cloud credentials and adjust targets

Recommended reading
-------------------
- [START-HERE.md](START-HERE.md)
- [QUICKSTART.md](QUICKSTART.md)
- [.github/PIPELINE.md](.github/PIPELINE.md)
- [.github/SECRETS.md](.github/SECRETS.md)
