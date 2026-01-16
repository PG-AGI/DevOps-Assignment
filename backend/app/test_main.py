from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "message": "Backend is running successfully"}

# Test /health endpoint
def test_health_root():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_api_message():
    response = client.get("/api/message")
    assert response.status_code == 200
    assert response.json() == {"message": "You've successfully integrated the backend!"}
