"""File storage utilities for video file management."""

import os
import uuid
import shutil
from pathlib import Path
from typing import Optional, BinaryIO
from datetime import datetime

from app.core.config import settings
from app.core.exceptions import StorageException, FileSizeExceededException, InvalidVideoFormatException


class FileStorageManager:
    """Manages local file storage operations."""
    
    def __init__(self, storage_path: str = None):
        self.storage_path = Path(storage_path or settings.storage_path)
        self.storage_path.mkdir(parents=True, exist_ok=True)
    
    def validate_file(self, filename: str, file_size: int) -> None:
        """Validate file format and size."""
        # Check file size
        if file_size > settings.max_upload_size:
            raise FileSizeExceededException(
                f"File size {file_size} exceeds maximum allowed size {settings.max_upload_size}"
            )
        
        # Check file extension
        file_ext = Path(filename).suffix.lower()
        if file_ext not in settings.allowed_video_extensions:
            raise InvalidVideoFormatException(
                f"File extension {file_ext} is not allowed. Allowed extensions: {settings.allowed_video_extensions}"
            )
    
    def generate_unique_filename(self, original_filename: str) -> str:
        """Generate a unique filename while preserving the extension."""
        file_ext = Path(original_filename).suffix
        unique_id = str(uuid.uuid4())
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        return f"{timestamp}_{unique_id}{file_ext}"
    
    def get_file_path(self, filename: str, organization_id: int) -> Path:
        """Get the full file path for storage."""
        org_folder = self.storage_path / f"org_{organization_id}"
        org_folder.mkdir(exist_ok=True)
        return org_folder / filename
    
    def save_file(self, file_content: BinaryIO, filename: str, organization_id: int) -> tuple[str, str]:
        """Save file to storage and return (unique_filename, file_path)."""
        try:
            # Generate unique filename
            unique_filename = self.generate_unique_filename(filename)
            file_path = self.get_file_path(unique_filename, organization_id)
            
            # Save file
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(file_content, buffer)
            
            return unique_filename, str(file_path)
        
        except Exception as e:
            raise StorageException(f"Failed to save file: {str(e)}")
    
    def delete_file(self, file_path: str) -> bool:
        """Delete file from storage."""
        try:
            if os.path.exists(file_path):
                os.remove(file_path)
                return True
            return False
        except Exception as e:
            raise StorageException(f"Failed to delete file: {str(e)}")
    
    def get_file_stream(self, file_path: str):
        """Get file stream for download."""
        if not os.path.exists(file_path):
            raise StorageException(f"File not found: {file_path}")
        
        return open(file_path, "rb")
    
    def get_file_size(self, file_path: str) -> int:
        """Get file size in bytes."""
        if not os.path.exists(file_path):
            raise StorageException(f"File not found: {file_path}")
        
        return os.path.getsize(file_path)


class VideoMetadataExtractor:
    """Extract metadata from video files."""
    
    @staticmethod
    def extract_metadata(file_path: str) -> dict:
        """Extract basic metadata from video file.
        
        Note: This is a basic implementation. In production, you would use
        libraries like ffmpeg-python or moviepy for proper metadata extraction.
        """
        try:
            file_size = os.path.getsize(file_path)
            file_ext = Path(file_path).suffix.lower()
            
            # Basic MIME type mapping
            mime_types = {
                '.mp4': 'video/mp4',
                '.avi': 'video/x-msvideo',
                '.mov': 'video/quicktime',
                '.mkv': 'video/x-matroska',
                '.webm': 'video/webm'
            }
            
            return {
                'file_size': file_size,
                'mime_type': mime_types.get(file_ext, 'video/unknown'),
                'duration': None,  # Would extract with ffmpeg
                'resolution_width': None,  # Would extract with ffmpeg
                'resolution_height': None,  # Would extract with ffmpeg
                'fps': None  # Would extract with ffmpeg
            }
        
        except Exception as e:
            raise StorageException(f"Failed to extract metadata: {str(e)}")


# Global storage manager instance
storage_manager = FileStorageManager()
metadata_extractor = VideoMetadataExtractor()