# Drone Management Backend

A comprehensive video file management system for drone operations backend.

## Features

- ✅ Video file upload and download
- ✅ Metadata management and extraction  
- ✅ Organization and UAV relationship management
- ✅ REST API endpoints with FastAPI
- ✅ Local file storage with future minio support
- ✅ Demo functionality and comprehensive testing
- ✅ Soft delete capability
- ✅ File validation and error handling
- ✅ Transaction management
- ✅ Organization-level access control

## Project Structure

```
drone_management/
├── app/
│   ├── api/                 # API endpoints
│   │   └── videos.py        # Video management endpoints
│   ├── core/                # Core configuration
│   │   ├── config.py        # Application settings
│   │   ├── database.py      # Database configuration
│   │   └── exceptions.py    # Custom exceptions
│   ├── models/              # Database models
│   │   └── video_file.py    # VideoFile, Organization, UAV models
│   ├── schemas/             # Pydantic schemas
│   │   └── video_schemas.py # Request/response schemas
│   ├── services/            # Business logic
│   │   └── video_service.py # Video file service layer
│   └── utils/               # Utility functions
│       └── file_storage.py  # File storage management
├── tests/                   # Test files
│   └── test_videos.py       # API tests
├── storage/                 # Local file storage (excluded from git)
├── main.py                  # FastAPI application
├── demo.py                  # Demo script
├── seed_data.py            # Sample data creation
├── run_server.py           # Server runner script
└── requirements.txt        # Python dependencies
```

## Quick Start

### 1. Installation

```bash
cd drone_management
pip install -r requirements.txt
```

### 2. Setup Database and Sample Data

```bash
python seed_data.py
```

### 3. Run the Server

```bash
python run_server.py
```

The server will be available at:
- API: http://localhost:8000
- Documentation: http://localhost:8000/docs
- Health Check: http://localhost:8000/health

### 4. Run Demo

```bash
python demo.py
```

### 5. Run Tests

```bash
python -m pytest tests/ -v
```

## API Endpoints

### Video Management

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/videos/upload` | Upload video files |
| GET | `/api/v1/videos/{video_id}/download` | Download video files |
| POST | `/api/v1/videos/search` | List videos with pagination and filtering |
| GET | `/api/v1/videos/{video_id}` | Get video metadata |
| PUT | `/api/v1/videos/{video_id}` | Update video metadata |
| DELETE | `/api/v1/videos/{video_id}` | Delete videos (soft delete) |

### General

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Root endpoint |
| GET | `/health` | Health check |

## Usage Examples

### Upload a Video

```bash
curl -X POST "http://localhost:8000/api/v1/videos/upload" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@video.mp4" \
  -F "organization_id=1" \
  -F "uav_id=1" \
  -F "description=Test video" \
  -F "tags=test,demo"
```

### Search Videos

```bash
curl -X POST "http://localhost:8000/api/v1/videos/search" \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": 1,
    "page": 1,
    "size": 10
  }'
```

### Download a Video

```bash
curl -X GET "http://localhost:8000/api/v1/videos/1/download" \
  -H "accept: application/json" \
  --output downloaded_video.mp4
```

## Database Models

### Organization
- Organization management with code and description
- One-to-many relationship with UAVs and VideoFiles

### UAV (Unmanned Aerial Vehicle)
- UAV information including model and serial number
- Belongs to an organization
- One-to-many relationship with VideoFiles

### VideoFile
- Complete video metadata including file information
- Relationships to Organization and UAV
- Soft delete capability
- Location and altitude tracking
- Upload and recording timestamps

## Technical Features

### File Storage
- Local file storage with organized directory structure
- Unique filename generation with timestamps and UUIDs
- File validation for size and format
- Metadata extraction (extensible for ffmpeg integration)

### Database Management
- SQLAlchemy ORM with SQLite (easily configurable for PostgreSQL/MySQL)
- Transaction management with decorators
- Soft delete implementation
- Migration-ready models

### API Design
- FastAPI with automatic OpenAPI documentation
- Pydantic schemas for request/response validation
- Comprehensive error handling
- CORS configuration for frontend integration

### Security & Validation
- File type validation
- File size limits
- Organization-level access control
- Input validation with Pydantic

## Future Enhancements

1. **Minio Integration**: The storage system is designed to easily integrate with Minio for scalable object storage.

2. **Advanced Metadata**: Integration with ffmpeg for comprehensive video metadata extraction (duration, resolution, fps).

3. **Authentication**: JWT-based authentication system for user management.

4. **Streaming**: Video streaming capabilities for large files.

5. **Search Enhancement**: Full-text search and advanced filtering options.

6. **Monitoring**: Logging and monitoring integration.

## Development

### Adding New Endpoints
1. Create endpoint in `app/api/`
2. Add business logic to `app/services/`
3. Update schemas in `app/schemas/`
4. Add tests in `tests/`

### Database Changes
1. Update models in `app/models/`
2. Create migration scripts (when using Alembic)
3. Update seed data if needed

### Testing
- Unit tests with pytest
- FastAPI TestClient for API testing
- Separate test database configuration

## Configuration

The application uses `app/core/config.py` for configuration:

- `app_name`: Application name
- `debug`: Debug mode
- `database_url`: Database connection string
- `storage_path`: File storage path
- `max_upload_size`: Maximum file upload size
- `allowed_video_extensions`: Allowed video file extensions