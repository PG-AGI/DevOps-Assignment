# PGAGI Project – Dockerized Backend & Frontend

## 📌 Overview
This project demonstrates a **containerized FastAPI backend** with a **Next.js frontend**, following DevOps best practices such as multi-stage Docker builds, non-root containers, environment-based configuration, and Docker Compose orchestration.

The project was initially built to satisfy a backend containerization assignment and was later extended with a frontend and full end-to-end integration.

---

## 🏗️ Architecture

```
Browser
  │
  │  http://localhost:3000
  ▼
Frontend (Next.js container)
  │
  │  http://localhost:5000 (via browser)
  ▼
Backend (FastAPI container)
```

- The frontend is served on **port 3000**
- The backend API is exposed on **port 5000**
- Docker port mapping forwards host traffic to containers

---

## 🔧 Backend Details

### API Endpoints

| Method | Endpoint        | Description              |
|------|----------------|--------------------------|
| GET  | /api/health    | Health check endpoint     |
| GET  | /api/message   | Returns a sample message  |

### Tech Stack
- Python 3
- FastAPI
- Pytest
- Docker (multi-stage build)

### Testing
- Unit tests written using **pytest**
- Tests are executed locally and during Docker build

---

## 🎨 Frontend Details

### Tech Stack
- Next.js
- React
- Axios
- Docker (multi-stage build)

### Functionality
- Displays backend health status
- Fetches and displays message from backend
- Uses environment-based API configuration

---

## 🐳 Docker & DevOps Practices

### Backend Dockerfile
- Multi-stage build
- Small runtime image
- Runs as non-root user
- Environment-based configuration

### Frontend Dockerfile
- Multi-stage build
- Build-time environment variables (`NEXT_PUBLIC_API_URL`)
- Optimized production image

### Docker Compose
- Orchestrates frontend and backend
- Uses Docker Hub images
- Exposes required ports

---

## ▶️ How to Run the Project

### Prerequisites
- Docker
- Docker Compose

### Run using Docker Compose

```bash
docker compose pull
docker compose up -d
```

### Access the Application
- Frontend: http://localhost:3000
- Backend Health: http://localhost:5000/api/health

---

## 🧪 Local Development (Optional)

### Backend
```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pytest
uvicorn app.main:app --reload
```

### Frontend
```bash
npm install
npm run dev
```

---

## 📦 Docker Hub Images

- Backend: `<dockerhub-username>/pgagi-backend:latest`
- Frontend: `<dockerhub-username>/pgagi-frontend:latest`

---

## ✨ Key Learnings

- Difference between build-time and runtime environment variables
- Docker multi-stage build scoping
- Docker DNS vs browser networking
- Secure container practices
- End-to-end containerized application setup

---

## 🏁 Conclusion

This project demonstrates a production-style containerized application with clear separation of concerns, best practices, and real-world debugging experience.
