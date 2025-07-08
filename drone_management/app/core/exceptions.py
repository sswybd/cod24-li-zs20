"""Custom exception classes."""

class DroneManagementException(Exception):
    """Base exception for drone management operations."""
    pass


class VideoFileNotFoundException(DroneManagementException):
    """Raised when video file is not found."""
    pass


class InvalidVideoFormatException(DroneManagementException):
    """Raised when video format is not supported."""
    pass


class StorageException(DroneManagementException):
    """Raised when storage operations fail."""
    pass


class OrganizationAccessException(DroneManagementException):
    """Raised when organization access is denied."""
    pass


class FileSizeExceededException(DroneManagementException):
    """Raised when file size exceeds allowed limit."""
    pass