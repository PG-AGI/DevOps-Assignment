from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_get_message():
    response = client.get("/api/message")
    assert response.status_code == 200
    assert "message" in response.json()

