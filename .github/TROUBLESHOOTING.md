Troubleshooting
===============

CI fails at npm install
-----------------------
- Ensure `package-lock.json` matches dependencies
- Verify `@playwright/test` is present; run `npx playwright install --with-deps`

Docker Hub push fails
---------------------
- Confirm `DOCKERHUB_TOKEN` is set and valid
- If username is missing, the workflow uses repository owner; set `DOCKERHUB_USERNAME` if needed

Playwright E2E fails locally
----------------------------
- Install browsers: `npx playwright install --with-deps`
- Ensure backend (port 8000) and frontend (port 3000) are running before tests

Deployment workflows do nothing
-------------------------------
- They are intentionally disabled (`.disabled` suffix). Rename to enable and add cloud credentials
