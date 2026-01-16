Project Overview
=================

Purpose
-------
Full-stack application with FastAPI backend and Next.js frontend, automated CI/CD via GitHub Actions, and Docker image publication to Docker Hub.

What's Included
---------------
- Backend: FastAPI service with pytest tests
- Frontend: Next.js application with Playwright E2E tests
- CI: GitHub Actions workflow (develop branch)
- Docker: Multi-stage builds for backend and frontend; images pushed to Docker Hub
- Documentation: Setup, architecture, pipeline references, and infrastructure guides

Quick Links
-----------
- Getting started: [QUICKSTART.md](QUICKSTART.md)
- For engineers: [START-HERE.md](START-HERE.md)
- Full documentation map: [CI-CD-INDEX.md](CI-CD-INDEX.md)

Repository Structure
====================

Layout
------
```
.
├── backend/                      # FastAPI backend
│   ├── app/
│   │   ├── main.py              # FastAPI application
│   │   └── test_main.py         # pytest tests
│   ├── Dockerfile               # Backend container image
│   └── requirements.txt          # Python dependencies
├── frontend/                     # Next.js frontend
│   ├── pages/
│   │   └── index.js             # Main application page
│   ├── e2e/
│   │   └── frontend.spec.ts     # Playwright E2E tests
│   ├── Dockerfile               # Frontend container image
│   ├── package.json             # Node.js dependencies
│   └── playwright.package.json  # Playwright dependencies
├── .github/
│   └── workflows/
│       ├── ci-develop.yml       # CI pipeline (develop branch)
│       ├── deploy-main.yml.disabled    # Optional deployment (main)
│       └── cd-main.yml.disabled        # Optional deployment (main)
├── infra/                       # Infrastructure and deployment guides
│   ├── terraform/               # Terraform modules for cloud deployment
│   ├── aws-ecs-config.md        # ECS deployment template
│   ├── k8s-deployment.md        # Kubernetes template
│   └── DEPLOYMENT-CHECKLIST.md  # Pre-deployment checklist
└── docs/
    ├── START-HERE.md            # Engineer onboarding
    ├── QUICKSTART.md            # 5-minute setup
    ├── CI-CD-INDEX.md           # Documentation map
    └── ...                       # Reference guides
```

Local Development Setup
=======================

Prerequisites
-------------
- Python 3.12+
- Node.js 20+
- npm or yarn
- Git

Backend Setup (FastAPI)
-----------------------

**Step 1: Navigate to backend directory**
```bash
cd backend
```

**Step 2: Create and activate virtual environment**
```bash
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

**Step 3: Install dependencies**
```bash
pip install -r requirements.txt
```

**Step 4: Run tests (optional)**
```bash
python -m pytest app/test_main.py
```

**Step 5: Start the server**
```bash
uvicorn app.main:app --reload --port 8000
```

Backend is now available at `http://localhost:8000`

Frontend Setup (Next.js)
------------------------

**Step 1: Navigate to frontend directory**
```bash
cd frontend
```

**Step 2: Install dependencies**
```bash
npm ci
# or
npm install
```

**Step 3: Install Playwright browsers (for E2E tests)**
```bash
npx playwright install --with-deps
```

**Step 4: Run tests (optional)**
```bash
npm run lint
npx playwright test
```

**Step 5: Start development server**
```bash
npm run dev
```

Frontend is now available at `http://localhost:3000`

Configuration
=============

Backend URL Configuration
-------------------------

To change the backend URL that the frontend connects to:

**Step 1: Create .env.local in frontend directory**
```bash
# frontend/.env.local
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Step 2: For production deployment**
```bash
NEXT_PUBLIC_API_URL=https://your-api-domain.com
```

**Step 3: Restart the Next.js development server**
```bash
npm run dev
```

Docker Build (Local)
--------------------

**Backend image**
```bash
cd backend
docker build -t pg-agi-backend:local .
docker run -p 8000:8000 pg-agi-backend:local
```

**Frontend image**
```bash
cd frontend
docker build -t pg-agi-frontend:local .
docker run -p 3000:3000 pg-agi-frontend:local
```

CI/CD Pipeline
==============

Overview
--------
- Trigger: Push to `develop` branch
- Tests: Backend (pytest), Frontend (lint, npm test, Playwright E2E)
- Build: Docker images for backend and frontend
- Publish: Images pushed to Docker Hub with `latest` and short-SHA tags

See [.github/PIPELINE.md](.github/PIPELINE.md) for detailed pipeline information.

Secrets Required
----------------
- `DOCKERHUB_TOKEN`: Docker Hub access token (required)
- `DOCKERHUB_USERNAME`: Docker Hub username (optional; defaults to repository owner)

Setup instructions: [.github/SECRETS.md](.github/SECRETS.md)

Next Steps
==========

1. Review [QUICKSTART.md](QUICKSTART.md) for 5-minute setup
2. Read [START-HERE.md](START-HERE.md) for architecture overview
3. Consult [CI-CD-INDEX.md](CI-CD-INDEX.md) for complete documentation map
4. Enable deployment workflows when ready: [infra/DEPLOYMENT-CHECKLIST.md](infra/DEPLOYMENT-CHECKLIST.md)

   ```bash
   npm run start
   # or
   yarn start
   ```

   The frontend will be available at `http://localhost:3000`

## Testing the Integration

1. Ensure both backend and frontend servers are running
2. Open the frontend in your browser (default: http://localhost:3000)
3. If everything is working correctly, you should see:
   - A status message indicating the backend is connected
   - The message from the backend: "You've successfully integrated the backend!"
   - The current backend URL being used

## API Endpoints

- `GET /api/health`: Health check endpoint
  - Returns: `{"status": "healthy", "message": "Backend is running successfully"}`

- `GET /api/message`: Get the integration message
  - Returns: `{"message": "You've successfully integrated the backend!"}`
