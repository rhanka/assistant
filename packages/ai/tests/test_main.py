import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_health_check():
    """Test the health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

def test_summarize_endpoint():
    """Test the summarize endpoint"""
    test_text = "This is a test text that should be summarized."
    
    response = client.post("/summarize", json={"text": test_text})
    assert response.status_code == 200
    
    data = response.json()
    assert "summary" in data
    assert "length" in data
    assert data["length"] == len(test_text)

def test_summarize_empty_text():
    """Test summarize endpoint with empty text"""
    response = client.post("/summarize", json={"text": ""})
    assert response.status_code == 400

def test_summarize_missing_text():
    """Test summarize endpoint with missing text field"""
    response = client.post("/summarize", json={})
    assert response.status_code == 422

def test_root_endpoint():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()
