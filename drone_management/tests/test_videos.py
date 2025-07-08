"""Tests for video file management system."""

import pytest
import tempfile
import os
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from io import BytesIO

from main import app
from app.core.database import Base, get_db
from app.models.video_file import Organization, UAV

# Test database
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)


def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()


app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)


@pytest.fixture
def setup_test_data():
    """Set up test organizations and UAVs."""
    db = TestingSessionLocal()
    try:
        # Create test organization
        org = Organization(
            name="Test Organization",
            code="TEST_ORG",
            description="Test organization for video management"
        )
        db.add(org)
        db.flush()
        
        # Create test UAV
        uav = UAV(
            name="Test Drone",
            model="DJI Mavic",
            serial_number="TEST_001",
            organization_id=org.id
        )
        db.add(uav)
        db.commit()
        
        return {"org_id": org.id, "uav_id": uav.id}
    finally:
        db.close()


def test_root_endpoint():
    """Test root endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "version" in data


def test_health_check():
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"


def test_upload_video(setup_test_data):
    """Test video upload functionality."""
    test_data = setup_test_data
    
    # Create a test video file
    video_content = b"fake video content" * 100
    video_file = BytesIO(video_content)
    
    files = {"file": ("test_video.mp4", video_file, "video/mp4")}
    data = {
        "organization_id": test_data["org_id"],
        "uav_id": test_data["uav_id"],
        "description": "Test video upload",
        "tags": "test,demo"
    }
    
    response = client.post("/api/v1/videos/upload", files=files, data=data)
    assert response.status_code == 200
    
    video_data = response.json()
    assert "id" in video_data
    assert video_data["original_filename"] == "test_video.mp4"
    assert video_data["organization_id"] == test_data["org_id"]
    assert video_data["description"] == "Test video upload"
    
    return video_data["id"]


def test_get_video(setup_test_data):
    """Test get video metadata."""
    test_data = setup_test_data
    video_id = test_upload_video(setup_test_data)
    
    response = client.get(f"/api/v1/videos/{video_id}")
    assert response.status_code == 200
    
    video_data = response.json()
    assert video_data["id"] == video_id
    assert video_data["original_filename"] == "test_video.mp4"


def test_search_videos(setup_test_data):
    """Test video search functionality."""
    test_data = setup_test_data
    test_upload_video(setup_test_data)
    
    search_data = {
        "organization_id": test_data["org_id"],
        "page": 1,
        "size": 10
    }
    
    response = client.post("/api/v1/videos/search", json=search_data)
    assert response.status_code == 200
    
    search_results = response.json()
    assert "items" in search_results
    assert "total" in search_results
    assert search_results["total"] > 0
    assert len(search_results["items"]) > 0


def test_update_video(setup_test_data):
    """Test video update functionality."""
    test_data = setup_test_data
    video_id = test_upload_video(setup_test_data)
    
    update_data = {
        "description": "Updated test video",
        "tags": "test,demo,updated"
    }
    
    response = client.put(f"/api/v1/videos/{video_id}", json=update_data)
    assert response.status_code == 200
    
    video_data = response.json()
    assert video_data["description"] == "Updated test video"
    assert video_data["tags"] == "test,demo,updated"


def test_delete_video(setup_test_data):
    """Test video delete functionality."""
    test_data = setup_test_data
    video_id = test_upload_video(setup_test_data)
    
    response = client.delete(f"/api/v1/videos/{video_id}")
    assert response.status_code == 200
    
    result = response.json()
    assert result["success"] is True
    
    # Verify video is soft deleted
    response = client.get(f"/api/v1/videos/{video_id}")
    assert response.status_code == 404


def test_upload_invalid_file_format(setup_test_data):
    """Test upload with invalid file format."""
    test_data = setup_test_data
    
    # Create a test file with invalid extension
    file_content = b"fake content"
    files = {"file": ("test_file.txt", BytesIO(file_content), "text/plain")}
    data = {
        "organization_id": test_data["org_id"],
        "description": "Test invalid upload"
    }
    
    response = client.post("/api/v1/videos/upload", files=files, data=data)
    assert response.status_code == 400


def test_get_nonexistent_video():
    """Test getting a video that doesn't exist."""
    response = client.get("/api/v1/videos/99999")
    assert response.status_code == 404


if __name__ == "__main__":
    pytest.main([__file__])