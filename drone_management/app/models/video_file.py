"""Database models for drone management system."""

from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean, Float, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class Organization(Base):
    """Organization model."""
    __tablename__ = "organizations"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    is_active = Column(Boolean, default=True)

    # Relationships
    uavs = relationship("UAV", back_populates="organization")
    video_files = relationship("VideoFile", back_populates="organization")


class UAV(Base):
    """UAV (Unmanned Aerial Vehicle) model."""
    __tablename__ = "uavs"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    model = Column(String(100))
    serial_number = Column(String(100), unique=True, index=True)
    organization_id = Column(Integer, ForeignKey("organizations.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    is_active = Column(Boolean, default=True)

    # Relationships
    organization = relationship("Organization", back_populates="uavs")
    video_files = relationship("VideoFile", back_populates="uav")


class VideoFile(Base):
    """Video file model with metadata and relationships."""
    __tablename__ = "video_files"

    id = Column(Integer, primary_key=True, index=True)
    filename = Column(String(255), nullable=False, index=True)
    original_filename = Column(String(255), nullable=False)
    file_path = Column(String(500), nullable=False)
    file_size = Column(Integer, nullable=False)  # in bytes
    mime_type = Column(String(100))
    duration = Column(Float)  # in seconds
    resolution_width = Column(Integer)
    resolution_height = Column(Integer)
    fps = Column(Float)  # frames per second
    
    # Relationships
    organization_id = Column(Integer, ForeignKey("organizations.id"), nullable=False)
    uav_id = Column(Integer, ForeignKey("uavs.id"), nullable=True)
    
    # Metadata
    description = Column(Text)
    tags = Column(Text)  # JSON string of tags
    location_latitude = Column(Float)
    location_longitude = Column(Float)
    altitude = Column(Float)
    
    # Timestamps
    recorded_at = Column(DateTime(timezone=True))
    uploaded_at = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    # Soft delete
    is_deleted = Column(Boolean, default=False)
    deleted_at = Column(DateTime(timezone=True))

    # Relationships
    organization = relationship("Organization", back_populates="video_files")
    uav = relationship("UAV", back_populates="video_files")