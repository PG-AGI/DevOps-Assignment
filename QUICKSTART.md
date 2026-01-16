Quickstart (5 Minutes)
======================

Prerequisites
-------------
- Docker Hub account and token (`DOCKERHUB_TOKEN` secret)
- Node.js 20 and Python 3.12 locally if you run tests
- GitHub Actions enabled on this repository

Configure secrets
-----------------
- Add `DOCKERHUB_TOKEN` in GitHub repository secrets
- (Optional) Add `DOCKERHUB_USERNAME`; otherwise the repository owner is used

Run locally (optional)
----------------------
Backend
- `cd backend`
- `pip install -r requirements.txt`
- `python -m pytest app/test_main.py`

Frontend
- `cd frontend`
- `npm ci`
- `npm run lint`
- `npx playwright install --with-deps`
- `npx playwright test`

CI flow on push to develop
--------------------------
1. Checkout code
2. Backend tests (pytest)
3. Frontend lint/tests and Playwright E2E
4. Build backend and frontend Docker images
5. Push images to Docker Hub with `latest` and short-SHA tags

Next
----
- Push to `develop` to exercise CI
- Review deployment templates in `.github/workflows/*.disabled` before enabling
