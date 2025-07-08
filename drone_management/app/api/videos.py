"""Video file API endpoints."""

import math
from typing import Optional
from fastapi import APIRouter, Depends, UploadFile, File, Form, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.exceptions import (
    VideoFileNotFoundException,
    InvalidVideoFormatException,
    StorageException,
    OrganizationAccessException,
    FileSizeExceededException
)
from app.schemas.video_schemas import (
    VideoFileResponse,
    VideoFileSearchRequest,
    VideoFileSearchResponse,
    VideoFileUpdate
)
from app.services.video_service import VideoFileService
from app.utils.file_storage import storage_manager

router = APIRouter(prefix="/api/v1/videos", tags=["videos"])


@router.post("/upload", response_model=VideoFileResponse)
async def upload_video(
    file: UploadFile = File(...),
    organization_id: int = Form(...),
    uav_id: Optional[int] = Form(None),
    description: Optional[str] = Form(None),
    tags: Optional[str] = Form(None),
    location_latitude: Optional[float] = Form(None),
    location_longitude: Optional[float] = Form(None),
    altitude: Optional[float] = Form(None),
    db: Session = Depends(get_db)
):
    """Upload a video file."""
    try:
        # Create video data object
        from app.schemas.video_schemas import VideoFileCreate
        video_data = VideoFileCreate(
            filename=file.filename,
            organization_id=organization_id,
            uav_id=uav_id,
            description=description,
            tags=tags,
            location_latitude=location_latitude,
            location_longitude=location_longitude,
            altitude=altitude
        )
        
        # Create video file
        video_file = await VideoFileService.create_video_file(
            db, video_data, file.file, file.filename
        )
        
        return VideoFileResponse.from_orm(video_file)
    
    except FileSizeExceededException as e:
        raise HTTPException(status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE, detail=str(e))
    except InvalidVideoFormatException as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except OrganizationAccessException as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))
    except StorageException as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Upload failed")


@router.get("/{video_id}/download")
async def download_video(
    video_id: int,
    organization_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """Download a video file."""
    try:
        file_path, original_filename, mime_type = VideoFileService.get_file_download_info(
            db, video_id, organization_id
        )
        
        def iterfile(file_path: str):
            with open(file_path, mode="rb") as file_like:
                yield from file_like
        
        return StreamingResponse(
            iterfile(file_path),
            media_type=mime_type,
            headers={"Content-Disposition": f"attachment; filename={original_filename}"}
        )
    
    except VideoFileNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except StorageException as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.post("/search", response_model=VideoFileSearchResponse)
async def search_videos(
    search_request: VideoFileSearchRequest,
    db: Session = Depends(get_db)
):
    """Search videos with pagination and filtering."""
    try:
        items, total = VideoFileService.search_video_files(db, search_request)
        
        pages = math.ceil(total / search_request.size) if total > 0 else 0
        
        return VideoFileSearchResponse(
            items=[VideoFileResponse.from_orm(item) for item in items],
            total=total,
            page=search_request.page,
            size=search_request.size,
            pages=pages
        )
    
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Search failed")


@router.get("/{video_id}", response_model=VideoFileResponse)
async def get_video(
    video_id: int,
    organization_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """Get video metadata by ID."""
    try:
        video_file = VideoFileService.get_video_file(db, video_id, organization_id)
        return VideoFileResponse.from_orm(video_file)
    
    except VideoFileNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put("/{video_id}", response_model=VideoFileResponse)
async def update_video(
    video_id: int,
    video_data: VideoFileUpdate,
    organization_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """Update video metadata."""
    try:
        video_file = VideoFileService.update_video_file(db, video_id, video_data, organization_id)
        return VideoFileResponse.from_orm(video_file)
    
    except VideoFileNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Update failed")


@router.delete("/{video_id}")
async def delete_video(
    video_id: int,
    organization_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """Delete a video file (soft delete)."""
    try:
        success = VideoFileService.delete_video_file(db, video_id, organization_id)
        return {"message": "Video deleted successfully", "success": success}
    
    except VideoFileNotFoundException as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Delete failed")