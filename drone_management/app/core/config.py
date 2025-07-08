"""Core application configuration and settings."""

from typing import Optional
from pydantic import BaseModel


class Settings(BaseModel):
    """Application settings."""
    
    app_name: str = "Drone Management API"
    debug: bool = True
    database_url: str = "sqlite:///./drone_management.db"
    storage_path: str = "./storage/videos"
    max_upload_size: int = 100 * 1024 * 1024  # 100MB
    allowed_video_extensions: list = [".mp4", ".avi", ".mov", ".mkv", ".webm"]


settings = Settings()