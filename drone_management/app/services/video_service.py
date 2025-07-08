"""Video file service layer with CRUD operations."""

import os
from datetime import datetime
from typing import Optional, List, BinaryIO
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_

from app.models.video_file import VideoFile, Organization, UAV
from app.schemas.video_schemas import VideoFileCreate, VideoFileUpdate, VideoFileSearchRequest
from app.core.database import with_transaction
from app.core.exceptions import (
    VideoFileNotFoundException, 
    OrganizationAccessException,
    StorageException
)
from app.utils.file_storage import storage_manager, metadata_extractor


class VideoFileService:
    """Service class for video file operations."""
    
    @staticmethod
    def get_video_file(db: Session, video_id: int, organization_id: Optional[int] = None) -> VideoFile:
        """Get video file by ID with optional organization access control."""
        query = db.query(VideoFile).filter(
            VideoFile.id == video_id,
            VideoFile.is_deleted == False
        )
        
        if organization_id:
            query = query.filter(VideoFile.organization_id == organization_id)
        
        video_file = query.first()
        if not video_file:
            raise VideoFileNotFoundException(f"Video file with ID {video_id} not found")
        
        return video_file
    
    @staticmethod
    async def create_video_file(
        db: Session,
        video_data: VideoFileCreate,
        file_content: BinaryIO,
        original_filename: str
    ) -> VideoFile:
        """Create a new video file with upload."""
        
        # Validate organization exists
        organization = db.query(Organization).filter(
            Organization.id == video_data.organization_id,
            Organization.is_active == True
        ).first()
        
        if not organization:
            raise OrganizationAccessException(f"Organization {video_data.organization_id} not found")
        
        # Validate UAV if provided
        if video_data.uav_id:
            uav = db.query(UAV).filter(
                UAV.id == video_data.uav_id,
                UAV.organization_id == video_data.organization_id,
                UAV.is_active == True
            ).first()
            
            if not uav:
                raise OrganizationAccessException(f"UAV {video_data.uav_id} not found in organization")
        
        # Get file size for validation
        file_content.seek(0, 2)  # Seek to end
        file_size = file_content.tell()
        file_content.seek(0)  # Reset to beginning
        
        # Validate file
        storage_manager.validate_file(original_filename, file_size)
        
        # Save file to storage
        unique_filename, file_path = storage_manager.save_file(
            file_content, original_filename, video_data.organization_id
        )
        
        try:
            # Extract metadata
            metadata = metadata_extractor.extract_metadata(file_path)
            
            # Create video file record
            video_file = VideoFile(
                filename=unique_filename,
                original_filename=original_filename,
                file_path=file_path,
                file_size=metadata['file_size'],
                mime_type=metadata['mime_type'],
                duration=metadata.get('duration'),
                resolution_width=metadata.get('resolution_width'),
                resolution_height=metadata.get('resolution_height'),
                fps=metadata.get('fps'),
                organization_id=video_data.organization_id,
                uav_id=video_data.uav_id,
                description=video_data.description,
                tags=video_data.tags,
                location_latitude=video_data.location_latitude,
                location_longitude=video_data.location_longitude,
                altitude=video_data.altitude,
                recorded_at=video_data.recorded_at
            )
            
            db.add(video_file)
            db.commit()
            db.refresh(video_file)
            return video_file
            
        except Exception as e:
            # Clean up file if database operation fails
            storage_manager.delete_file(file_path)
            db.rollback()
            raise e
    
    @staticmethod
    def update_video_file(
        db: Session,
        video_id: int,
        video_data: VideoFileUpdate,
        organization_id: Optional[int] = None
    ) -> VideoFile:
        """Update video file metadata."""
        video_file = VideoFileService.get_video_file(db, video_id, organization_id)
        
        update_data = video_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(video_file, field, value)
        
        video_file.updated_at = datetime.utcnow()
        db.commit()
        return video_file
    
    @staticmethod
    def delete_video_file(
        db: Session,
        video_id: int,
        organization_id: Optional[int] = None
    ) -> bool:
        """Soft delete video file."""
        video_file = VideoFileService.get_video_file(db, video_id, organization_id)
        
        # Soft delete
        video_file.is_deleted = True
        video_file.deleted_at = datetime.utcnow()
        
        # Optionally delete physical file
        try:
            storage_manager.delete_file(video_file.file_path)
        except StorageException:
            # Log error but don't fail the operation
            pass
        
        db.commit()
        return True
    
    @staticmethod
    def search_video_files(
        db: Session,
        search_request: VideoFileSearchRequest
    ) -> tuple[List[VideoFile], int]:
        """Search video files with filtering and pagination."""
        query = db.query(VideoFile).filter(VideoFile.is_deleted == False)
        
        # Apply filters
        if search_request.organization_id:
            query = query.filter(VideoFile.organization_id == search_request.organization_id)
        
        if search_request.uav_id:
            query = query.filter(VideoFile.uav_id == search_request.uav_id)
        
        if search_request.filename:
            query = query.filter(
                or_(
                    VideoFile.filename.contains(search_request.filename),
                    VideoFile.original_filename.contains(search_request.filename)
                )
            )
        
        if search_request.tags:
            query = query.filter(VideoFile.tags.contains(search_request.tags))
        
        if search_request.start_date:
            query = query.filter(VideoFile.recorded_at >= search_request.start_date)
        
        if search_request.end_date:
            query = query.filter(VideoFile.recorded_at <= search_request.end_date)
        
        # Get total count
        total = query.count()
        
        # Apply pagination
        offset = (search_request.page - 1) * search_request.size
        items = query.offset(offset).limit(search_request.size).all()
        
        return items, total
    
    @staticmethod
    def get_file_download_info(
        db: Session,
        video_id: int,
        organization_id: Optional[int] = None
    ) -> tuple[str, str, str]:
        """Get file download information."""
        video_file = VideoFileService.get_video_file(db, video_id, organization_id)
        
        if not os.path.exists(video_file.file_path):
            raise StorageException(f"Physical file not found: {video_file.file_path}")
        
        return video_file.file_path, video_file.original_filename, video_file.mime_type or "application/octet-stream"