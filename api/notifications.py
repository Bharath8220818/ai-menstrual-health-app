from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime, timedelta
import json
from pathlib import Path

router = APIRouter()

# Data storage path
DATA_DIR = Path("data")
NOTIFICATIONS_FILE = DATA_DIR / "notifications.json"


class NotificationSchedule(BaseModel):
    """Model for notification schedule"""
    water_reminder: List[str]  # Times like ["10:00", "13:00", "16:00"]
    cycle_alert: Optional[str]  # Date of next period
    fertility_days: List[int]  # Days of month with high fertility
    pregnancy_week: Optional[int]  # Current pregnancy week


class NearbyPlace(BaseModel):
    """Model for nearby places"""
    name: str
    address: str
    latitude: float
    longitude: float
    distance: str
    rating: str
    phone: str
    place_type: str  # hospital, pharmacy, supermarket


class NearbyResponse(BaseModel):
    """Response model for nearby places"""
    data: List[NearbyPlace]
    status: str


def _load_notifications():
    """Load notifications from file"""
    if NOTIFICATIONS_FILE.exists():
        with open(NOTIFICATIONS_FILE, "r") as f:
            return json.load(f)
    return {}


def _save_notifications(data):
    """Save notifications to file"""
    DATA_DIR.mkdir(exist_ok=True)
    with open(NOTIFICATIONS_FILE, "w") as f:
        json.dump(data, f, indent=2, default=str)


@router.post("/notifications/schedule")
async def schedule_notifications(
    email: str = Query(..., description="User email"),
    cycle_length: int = Query(28, description="Average cycle length in days"),
    days_until_period: int = Query(14, description="Days until next period"),
    in_pregnancy: bool = Query(False, description="Is user pregnant"),
    pregnancy_week: Optional[int] = Query(None, description="Current pregnancy week"),
) -> NotificationSchedule:
    """
    Calculate and return notification schedule for user
    
    Returns:
        - Water reminder times (every 2-3 hours)
        - Cycle alert date (day before next period)
        - Fertility window dates
        - Pregnancy week updates
    """
    try:
        today = datetime.now()
        
        # Water reminders (every 2-3 hours, starting at 10:00)
        water_times = [
            "10:00",
            "13:00",
            "16:00",
            "19:00",
        ]
        
        # Cycle alert (day before next period)
        cycle_alert_date = None
        if not in_pregnancy:
            cycle_alert_date = (today + timedelta(days=days_until_period - 1)).strftime("%Y-%m-%d")
        
        # Fertility window (typically days 12-16 of 28-day cycle)
        fertile_start = max(1, 12 - (cycle_length - 28) // 2)
        fertile_end = fertile_start + 4
        
        days_until_fertile = fertile_start - today.day
        if days_until_fertile < 0:
            days_until_fertile += cycle_length
        
        fertility_days = []
        for i in range(5):
            fertile_day = ((today.day + days_until_fertile + i - 1) % cycle_length) + 1
            if 1 <= fertile_day <= cycle_length:
                fertility_days.append(fertile_day)
        
        # Pregnancy updates (weekly)
        pregnancy_week_value = pregnancy_week if pregnancy_week else None
        
        schedule = NotificationSchedule(
            water_reminder=water_times,
            cycle_alert=cycle_alert_date,
            fertility_days=fertility_days,
            pregnancy_week=pregnancy_week_value,
        )
        
        # Save to notification history
        notifications = _load_notifications()
        if email not in notifications:
            notifications[email] = []
        
        notifications[email].append({
            "timestamp": datetime.now().isoformat(),
            "schedule": schedule.dict(),
        })
        
        _save_notifications(notifications)
        
        return schedule
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error scheduling notifications: {str(e)}")


@router.get("/nearby", response_model=NearbyResponse)
async def get_nearby_places(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude"),
    type: str = Query("hospitals", description="Type: hospitals, pharmacies, supermarkets"),
    radius: int = Query(5, description="Search radius in km"),
) -> NearbyResponse:
    """
    Get nearby medical facilities, pharmacies, and supermarkets
    
    Returns list of nearby places with details:
        - name: Place name
        - address: Street address
        - latitude/longitude: Coordinates
        - distance: Distance from user
        - rating: User rating
        - phone: Contact number
    """
    try:
        # In production, integrate with Google Places API
        # For now, return mock data based on location and type
        
        places = _generate_nearby_places(lat, lng, type, radius)
        
        return NearbyResponse(
            data=places,
            status="success",
        )
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error fetching nearby places: {str(e)}")


def _generate_nearby_places(lat: float, lng: float, place_type: str, radius: int) -> List[NearbyPlace]:
    """Generate mock nearby places data"""
    
    # Mock hospitals
    hospitals = [
        NearbyPlace(
            name="City Medical Center",
            address="123 Main Street",
            latitude=lat + 0.01,
            longitude=lng + 0.01,
            distance="1.2 km",
            rating="4.8",
            phone="+1-555-0100",
            place_type="hospital",
        ),
        NearbyPlace(
            name="Women's Health Hospital",
            address="456 Oak Avenue",
            latitude=lat - 0.01,
            longitude=lng - 0.01,
            distance="2.5 km",
            rating="4.9",
            phone="+1-555-0101",
            place_type="hospital",
        ),
        NearbyPlace(
            name="Emergency Care Clinic",
            address="789 Elm Street",
            latitude=lat + 0.015,
            longitude=lng - 0.005,
            distance="1.8 km",
            rating="4.6",
            phone="+1-555-0102",
            place_type="hospital",
        ),
        NearbyPlace(
            name="Community Health Center",
            address="321 Pine Street",
            latitude=lat - 0.015,
            longitude=lng + 0.005,
            distance="2.1 km",
            rating="4.7",
            phone="+1-555-0103",
            place_type="hospital",
        ),
    ]
    
    # Mock pharmacies
    pharmacies = [
        NearbyPlace(
            name="Health Plus Pharmacy",
            address="321 Pine Street",
            latitude=lat + 0.005,
            longitude=lng + 0.005,
            distance="0.8 km",
            rating="4.7",
            phone="+1-555-0200",
            place_type="pharmacy",
        ),
        NearbyPlace(
            name="MediCare Drugs",
            address="654 Birch Avenue",
            latitude=lat - 0.008,
            longitude=lng + 0.008,
            distance="1.5 km",
            rating="4.5",
            phone="+1-555-0201",
            place_type="pharmacy",
        ),
        NearbyPlace(
            name="24-Hour Pharmacy Express",
            address="987 Maple Road",
            latitude=lat + 0.012,
            longitude=lng - 0.012,
            distance="2.3 km",
            rating="4.4",
            phone="+1-555-0202",
            place_type="pharmacy",
        ),
    ]
    
    # Mock supermarkets
    supermarkets = [
        NearbyPlace(
            name="Fresh Mart Supermarket",
            address="111 Produce Lane",
            latitude=lat + 0.008,
            longitude=lng - 0.008,
            distance="1.1 km",
            rating="4.6",
            phone="+1-555-0300",
            place_type="supermarket",
        ),
        NearbyPlace(
            name="Nutrition Store",
            address="222 Health Road",
            latitude=lat - 0.01,
            longitude=lng + 0.01,
            distance="2.0 km",
            rating="4.8",
            phone="+1-555-0301",
            place_type="supermarket",
        ),
        NearbyPlace(
            name="Organic Market",
            address="333 Garden Street",
            latitude=lat + 0.014,
            longitude=lng + 0.014,
            distance="2.7 km",
            rating="4.9",
            phone="+1-555-0302",
            place_type="supermarket",
        ),
    ]
    
    # Return based on type
    if place_type == "hospitals":
        return hospitals
    elif place_type == "pharmacies":
        return pharmacies
    else:
        return supermarkets


@router.get("/notifications/history")
async def get_notification_history(email: str = Query(..., description="User email")) -> dict:
    """Get notification history for a user"""
    try:
        notifications = _load_notifications()
        
        if email not in notifications:
            return {"data": [], "status": "success"}
        
        return {
            "data": notifications[email],
            "status": "success",
        }
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error fetching history: {str(e)}")


@router.delete("/notifications/clear")
async def clear_notifications(email: str = Query(..., description="User email")) -> dict:
    """Clear notification history for a user"""
    try:
        notifications = _load_notifications()
        
        if email in notifications:
            del notifications[email]
            _save_notifications(notifications)
        
        return {"status": "success", "message": "Notifications cleared"}
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Error clearing notifications: {str(e)}")
