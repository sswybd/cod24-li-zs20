"""Seed script to create sample data for testing."""

from app.core.database import SessionLocal
from app.models.video_file import Organization, UAV


def create_sample_data():
    """Create sample organizations and UAVs for testing."""
    db = SessionLocal()
    try:
        # Check if data already exists
        existing_org = db.query(Organization).first()
        if existing_org:
            print("Sample data already exists. Skipping...")
            return
        
        # Create sample organizations
        org1 = Organization(
            name="AerialTech Solutions",
            code="AERIAL_TECH",
            description="Professional drone services company"
        )
        
        org2 = Organization(
            name="SkyView Industries",
            code="SKYVIEW",
            description="Commercial aerial photography and surveying"
        )
        
        db.add(org1)
        db.add(org2)
        db.flush()  # Get IDs
        
        # Create sample UAVs
        uav1 = UAV(
            name="DJI Mavic Pro",
            model="Mavic Pro",
            serial_number="MVP001",
            organization_id=org1.id
        )
        
        uav2 = UAV(
            name="DJI Phantom 4",
            model="Phantom 4 Pro",
            serial_number="P4P001",
            organization_id=org1.id
        )
        
        uav3 = UAV(
            name="Autel EVO",
            model="EVO II Pro",
            serial_number="EVO001",
            organization_id=org2.id
        )
        
        db.add(uav1)
        db.add(uav2)
        db.add(uav3)
        
        db.commit()
        
        print("✓ Sample data created successfully!")
        print(f"  Organizations: {org1.name} (ID: {org1.id}), {org2.name} (ID: {org2.id})")
        print(f"  UAVs: {uav1.name} (ID: {uav1.id}), {uav2.name} (ID: {uav2.id}), {uav3.name} (ID: {uav3.id})")
        
    except Exception as e:
        print(f"Error creating sample data: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    create_sample_data()