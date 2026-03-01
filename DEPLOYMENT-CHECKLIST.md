# Deployment Checklist

Use this checklist to verify all mandatory deliverables are complete.

## ✅ Mandatory Deliverables

### 1. Forked GitHub Repository
- [ ] Repository is forked from original
- [ ] All changes committed to fork
- [ ] Git history preserved

### 2. External Architecture Documentation
- [ ] Google Docs link created
- [ ] All sections completed:
  - [ ] Cloud & region selection
  - [ ] Infrastructure architecture with diagrams
  - [ ] Compute and runtime decisions
  - [ ] Networking and security design
  - [ ] Environment separation (dev/staging/prod)
  - [ ] Scalability and availability strategy
  - [ ] Deployment and rollback behavior
  - [ ] Infrastructure state management
  - [ ] Failure scenarios and operational handling
  - [ ] Future growth and evolution strategy
  - [ ] "What we did NOT do" section

### 3. Hosted Application URLs

#### AWS Deployment
- [ ] Frontend URL: `https://devops-assignment-frontend-prod.xxx.amazonaws.com`
- [ ] Backend URL: `https://devops-assignment-backend-prod.xxx.amazonaws.com/api/health`
- [ ] API Message endpoint works: `/api/message`

#### GCP Deployment
- [ ] Frontend URL: `https://devops-assignment-frontend-prod-xxx.a.run.app`
- [ ] Backend URL: `https://devops-assignment-backend-prod-xxx.a.run.app/api/health`
- [ ] API Message endpoint works: `/api/message`

### 4. Demo Video (8-12 minutes)
- [ ] Link to unlisted YouTube/Loom/Google Drive
- [ ] Covers all required topics:
  - [ ] Architecture walkthrough
  - [ ] Cloud & region choices
  - [ ] Infrastructure decisions
  - [ ] Deployment flow
  - [ ] Scaling and failure handling
  - [ ] Tradeoffs and limitations
  - [ ] Future growth discussion

---

## 📋 Verification Commands

### Test Backend Health
```
bash
# AWS
curl https://YOUR-BACKEND-URL.amazonaws.com/api/health

# GCP
curl https://YOUR-BACKEND-URL.a.run.app/api/health
```

### Test Backend Message
```
bash
# AWS
curl https://YOUR-BACKEND-URL.amazonaws.com/api/message

# GCP
curl https://YOUR-BACKEND-URL.a.run.app/api/message
```

### Test Frontend
```
bash
# Open in browser
# AWS
open https://YOUR-FRONTEND-URL.amazonaws.com

# GCP
open https://YOUR-FRONTEND-URL.a.run.app
```

---

## 🎯 Grading Criteria Self-Check

| Category | Weight | Status |
|----------|--------|--------|
| Infrastructure Design & Cloud Decisions | 20% | [ ] |
| Scalability & Availability Thinking | 15% | [ ] |
| Networking, Security & Identity | 15% | [ ] |
| IaC Quality & State Management | 15% | [ ] |
| Failure Handling & Operational Readiness | 15% | [ ] |
| Future Growth & Evolution Strategy | 10% | [ ] |
| Documentation Quality | 5% | [ ] |
| Demo Video (Clarity & Depth) | 5% | [ ] |

---

## 🚀 Quick Start Commands

### Clone and Setup
```
bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/devops-assignment.git
cd devops-assignment

# Install dependencies
cd backend && pip install -r requirements.txt
cd ../frontend && npm install
```

### Local Development
```
bash
# Terminal 1 - Backend
cd backend
uvicorn app.main:app --reload --port 8000

# Terminal 2 - Frontend
cd frontend
npm run dev
```

### Build Docker Images
```
bash
# Backend
cd backend
docker build -t devops-backend:latest .

# Frontend
cd frontend
docker build -t devops-frontend:latest .
```

---

## 📝 Notes

- All environment variables should be set via secrets, never hardcoded
- Terraform state is stored in S3 (AWS) and GCS (GCP)
- Each environment (dev/staging/prod) has isolated state
- Auto-scaling is configured for both platforms
- Deployment is automated via GitHub Actions

---

*Last Updated: 2024*
