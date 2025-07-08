"""Pydantic schemas for video file API."""

from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field


class VideoFileBase(BaseModel):
    """Base schema for video file."""
    filename: str
    description: Optional[str] = None
    tags: Optional[str] = None
    location_latitude: Optional[float] = None
    location_longitude: Optional[float] = None
    altitude: Optional[float] = None
    recorded_at: Optional[datetime] = None


class VideoFileCreate(VideoFileBase):
    """Schema for creating a video file."""
    organization_id: int
    uav_id: Optional[int] = None


class VideoFileUpdate(BaseModel):
    """Schema for updating a video file."""
    description: Optional[str] = None
    tags: Optional[str] = None
    location_latitude: Optional[float] = None
    location_longitude: Optional[float] = None
    altitude: Optional[float] = None
    recorded_at: Optional[datetime] = None


class VideoFileResponse(VideoFileBase):
    """Schema for video file response."""
    id: int
    original_filename: str
    file_size: int
    mime_type: Optional[str] = None
    duration: Optional[float] = None
    resolution_width: Optional[int] = None
    resolution_height: Optional[int] = None
    fps: Optional[float] = None
    organization_id: int
    uav_id: Optional[int] = None
    uploaded_at: datetime
    created_at: datetime
    updated_at: Optional[datetime] = None
    is_deleted: bool = False

    class Config:
        from_attributes = True


class VideoFileSearchRequest(BaseModel):
    """Schema for video file search request."""
    organization_id: Optional[int] = None
    uav_id: Optional[int] = None
    filename: Optional[str] = None
    tags: Optional[str] = None
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    page: int = Field(default=1, ge=1)
    size: int = Field(default=20, ge=1, le=100)


class VideoFileSearchResponse(BaseModel):
    """Schema for video file search response."""
    items: List[VideoFileResponse]
    total: int
    page: int
    size: int
    pages: int


class OrganizationBase(BaseModel):
    """Base schema for organization."""
    name: str
    code: str
    description: Optional[str] = None


class OrganizationResponse(OrganizationBase):
    """Schema for organization response."""
    id: int
    created_at: datetime
    is_active: bool = True

    class Config:
        from_attributes = True


class UAVBase(BaseModel):
    """Base schema for UAV."""
    name: str
    model: Optional[str] = None
    serial_number: str
    organization_id: int


class UAVResponse(UAVBase):
    """Schema for UAV response."""
    id: int
    created_at: datetime
    is_active: bool = True

    class Config:
        from_attributes = True