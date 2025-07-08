#!/usr/bin/env python3
"""Run the drone management API server."""

import uvicorn
from main import app

if __name__ == "__main__":
    print("🚁 Starting Drone Management API Server...")
    print("🌐 Server will be available at: http://localhost:8000")
    print("📖 API documentation: http://localhost:8000/docs")
    print("🔄 Health check: http://localhost:8000/health")
    print("=" * 50)
    
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=8000,
        reload=True,
        log_level="info"
    )