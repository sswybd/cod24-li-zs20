"""Demo script for video file management system."""

import asyncio
import os
import requests
import json
from pathlib import Path

BASE_URL = "http://localhost:8000"


def create_sample_video_file():
    """Create a sample video file for testing."""
    sample_video_path = Path("sample_video.mp4")
    if not sample_video_path.exists():
        # Create a dummy video file (just empty bytes for demo)
        with open(sample_video_path, "wb") as f:
            f.write(b"This is a demo video file content" * 1000)  # ~34KB
    return sample_video_path


def demo_create_test_data():
    """Create test organizations and UAVs."""
    print("Setting up test data...")
    
    # In a real implementation, these would be API calls to create organizations and UAVs
    # For this demo, we'll assume they exist with IDs 1 and 1
    print("✓ Using default organization_id=1 and uav_id=1 for demo")


def demo_upload_video():
    """Demo video upload functionality."""
    print("\n=== Video Upload Demo ===")
    
    sample_file = create_sample_video_file()
    
    url = f"{BASE_URL}/api/v1/videos/upload"
    
    with open(sample_file, "rb") as f:
        files = {"file": ("demo_video.mp4", f, "video/mp4")}
        data = {
            "organization_id": 1,
            "uav_id": 1,
            "description": "Demo video from drone flight",
            "tags": "demo,test,flight",
            "location_latitude": 40.7128,
            "location_longitude": -74.0060,
            "altitude": 100.5
        }
        
        try:
            response = requests.post(url, files=files, data=data)
            if response.status_code == 200:
                video_data = response.json()
                print(f"✓ Video uploaded successfully!")
                print(f"  Video ID: {video_data['id']}")
                print(f"  Filename: {video_data['filename']}")
                print(f"  Size: {video_data['file_size']} bytes")
                return video_data['id']
            else:
                print(f"✗ Upload failed: {response.status_code}")
                print(f"  Error: {response.text}")
                return None
        except requests.exceptions.ConnectionError:
            print("✗ Could not connect to server. Make sure the server is running.")
            return None
        finally:
            # Clean up sample file
            if sample_file.exists():
                sample_file.unlink()


def demo_search_videos():
    """Demo video search functionality."""
    print("\n=== Video Search Demo ===")
    
    url = f"{BASE_URL}/api/v1/videos/search"
    search_data = {
        "organization_id": 1,
        "page": 1,
        "size": 10
    }
    
    try:
        response = requests.post(url, json=search_data)
        if response.status_code == 200:
            search_results = response.json()
            print(f"✓ Search completed!")
            print(f"  Total videos: {search_results['total']}")
            print(f"  Page: {search_results['page']}/{search_results['pages']}")
            
            for video in search_results['items']:
                print(f"  - Video {video['id']}: {video['original_filename']}")
                print(f"    Size: {video['file_size']} bytes")
                print(f"    Description: {video.get('description', 'N/A')}")
            
            return search_results['items']
        else:
            print(f"✗ Search failed: {response.status_code}")
            print(f"  Error: {response.text}")
            return []
    except requests.exceptions.ConnectionError:
        print("✗ Could not connect to server. Make sure the server is running.")
        return []


def demo_get_video(video_id: int):
    """Demo get video metadata functionality."""
    print(f"\n=== Get Video {video_id} Demo ===")
    
    url = f"{BASE_URL}/api/v1/videos/{video_id}"
    
    try:
        response = requests.get(url)
        if response.status_code == 200:
            video_data = response.json()
            print(f"✓ Video metadata retrieved!")
            print(f"  ID: {video_data['id']}")
            print(f"  Original filename: {video_data['original_filename']}")
            print(f"  Size: {video_data['file_size']} bytes")
            print(f"  MIME type: {video_data.get('mime_type', 'N/A')}")
            print(f"  Uploaded: {video_data['uploaded_at']}")
            return video_data
        else:
            print(f"✗ Get video failed: {response.status_code}")
            print(f"  Error: {response.text}")
            return None
    except requests.exceptions.ConnectionError:
        print("✗ Could not connect to server. Make sure the server is running.")
        return None


def demo_download_video(video_id: int):
    """Demo video download functionality."""
    print(f"\n=== Download Video {video_id} Demo ===")
    
    url = f"{BASE_URL}/api/v1/videos/{video_id}/download"
    
    try:
        response = requests.get(url, stream=True)
        if response.status_code == 200:
            # Save to downloads folder
            filename = response.headers.get('Content-Disposition', '').split('filename=')[-1]
            if not filename:
                filename = f"downloaded_video_{video_id}.mp4"
            
            download_path = Path(f"downloads/{filename}")
            download_path.parent.mkdir(exist_ok=True)
            
            with open(download_path, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            print(f"✓ Video downloaded successfully!")
            print(f"  Saved to: {download_path}")
            print(f"  Size: {download_path.stat().st_size} bytes")
            return str(download_path)
        else:
            print(f"✗ Download failed: {response.status_code}")
            print(f"  Error: {response.text}")
            return None
    except requests.exceptions.ConnectionError:
        print("✗ Could not connect to server. Make sure the server is running.")
        return None


def demo_update_video(video_id: int):
    """Demo video update functionality."""
    print(f"\n=== Update Video {video_id} Demo ===")
    
    url = f"{BASE_URL}/api/v1/videos/{video_id}"
    update_data = {
        "description": "Updated demo video with new description",
        "tags": "demo,test,flight,updated",
        "altitude": 150.0
    }
    
    try:
        response = requests.put(url, json=update_data)
        if response.status_code == 200:
            video_data = response.json()
            print(f"✓ Video updated successfully!")
            print(f"  New description: {video_data['description']}")
            print(f"  New tags: {video_data['tags']}")
            print(f"  New altitude: {video_data['altitude']}")
            return video_data
        else:
            print(f"✗ Update failed: {response.status_code}")
            print(f"  Error: {response.text}")
            return None
    except requests.exceptions.ConnectionError:
        print("✗ Could not connect to server. Make sure the server is running.")
        return None


def demo_delete_video(video_id: int):
    """Demo video delete functionality."""
    print(f"\n=== Delete Video {video_id} Demo ===")
    
    url = f"{BASE_URL}/api/v1/videos/{video_id}"
    
    try:
        response = requests.delete(url)
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Video deleted successfully!")
            print(f"  Message: {result['message']}")
            return True
        else:
            print(f"✗ Delete failed: {response.status_code}")
            print(f"  Error: {response.text}")
            return False
    except requests.exceptions.ConnectionError:
        print("✗ Could not connect to server. Make sure the server is running.")
        return False


def main():
    """Run all demo functions."""
    print("🚁 Drone Management Video File System Demo")
    print("=" * 50)
    
    # Check if server is running
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code != 200:
            print("❌ Server health check failed. Please start the server first.")
            print("   Run: python main.py")
            return
    except requests.exceptions.ConnectionError:
        print("❌ Could not connect to server. Please start the server first.")
        print("   Run: python main.py")
        return
    
    print("✅ Server is running!")
    
    # Run demo sequence
    demo_create_test_data()
    
    # Upload a video
    video_id = demo_upload_video()
    if not video_id:
        print("Demo stopped due to upload failure.")
        return
    
    # Search videos
    videos = demo_search_videos()
    
    # Get video metadata
    demo_get_video(video_id)
    
    # Download video
    demo_download_video(video_id)
    
    # Update video
    demo_update_video(video_id)
    
    # Search again to see updates
    print("\n=== Search After Update ===")
    demo_search_videos()
    
    # Delete video
    demo_delete_video(video_id)
    
    print("\n🎉 Demo completed successfully!")
    print("Check the 'downloads' folder for downloaded files.")


if __name__ == "__main__":
    main()