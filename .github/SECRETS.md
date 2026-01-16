Secrets Guide
=============

Required
--------
- `DOCKERHUB_TOKEN`: Docker Hub access token used to push images

Optional
--------
- `DOCKERHUB_USERNAME`: Docker Hub username; if absent, the repository owner is used

Notes
-----
- Add secrets in GitHub: Settings → Secrets and variables → Actions
- Keep tokens scoped to the least privilege needed for image push
- If enabling cloud deployments, add provider-specific credentials as needed
