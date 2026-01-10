from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_message_endpoint():
    response = client.get("/api/message")
    assert response.status_code == 200
    assert "message" in response.json()

