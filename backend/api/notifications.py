"""
Notifications, Nearby Places, and Push Notification endpoints.
- Notifications: MongoDB primary + JSON fallback
- Nearby places: Google Places API primary + mock fallback
- Push: Firebase Admin SDK
"""

from __future__ import annotations

import json
import logging
import math
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any, Dict, List, Optional
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from uuid import uuid4

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, EmailStr

logger = logging.getLogger(__name__)

try:
    import firebase_admin
    from firebase_admin import credentials, messaging
except ImportError:
    firebase_admin = None
    credentials = None
    messaging = None

router = APIRouter()

# ── JSON fallbacks ─────────────────────────────────────────────────────────────
_DATA_DIR = Path("data")
_NOTIF_FILE = _DATA_DIR / "notifications.json"
_FCM_FILE = _DATA_DIR / "fcm_tokens.json"


# ── Pydantic models ────────────────────────────────────────────────────────────

class NotificationSchedule(BaseModel):
    water_reminder: List[str]
    cycle_alert: Optional[str]
    fertility_days: List[int]
    pregnancy_week: Optional[int]


class NearbyPlace(BaseModel):
    name: str
    address: str
    latitude: float
    longitude: float
    distance: str
    rating: str
    phone: str
    place_type: str


class NearbyResponse(BaseModel):
    data: List[NearbyPlace]
    status: str
    source: str = "mock"


class DeviceTokenRequest(BaseModel):
    email: EmailStr
    token: str
    platform: str = "android"


class PushRequest(BaseModel):
    title: str
    body: str
    email: Optional[EmailStr] = None
    token: Optional[str] = None
    data: Dict[str, str] = {}


class PushResult(BaseModel):
    status: str
    mode: str
    message_id: Optional[str] = None
    detail: str


# ── JSON helpers ───────────────────────────────────────────────────────────────

def _load_json(path: Path) -> dict:
    if path.exists():
        try:
            with open(path) as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def _save_json(path: Path, data: dict) -> None:
    path.parent.mkdir(exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=2, default=str)


# ── MongoDB helpers ────────────────────────────────────────────────────────────

def _store_notification(email: str, record: dict) -> None:
    """Write notification to MongoDB and JSON."""
    try:
        from api.database import insert_notification
        insert_notification({**record, "email": email})
    except Exception as exc:
        logger.warning(f"MongoDB notification insert failed: {exc}")
    data = _load_json(_NOTIF_FILE)
    data.setdefault(email, [])
    data[email].append(record)
    _save_json(_NOTIF_FILE, data)


def _fetch_notifications(email: str, limit: int = 30) -> list:
    try:
        from api.database import get_notifications
        results = get_notifications(email, limit=limit)
        if results:
            return results
    except Exception as exc:
        logger.warning(f"MongoDB notification fetch failed: {exc}")
    return _load_json(_NOTIF_FILE).get(email, [])


# ── Google Places API ──────────────────────────────────────────────────────────

_PLACE_TYPE_MAP = {
    "hospitals": "hospital",
    "pharmacies": "pharmacy",
    "markets": "supermarket",
    "supermarkets": "supermarket",
}

_EARTH_RADIUS_KM = 6371.0


def _haversine_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    dlat = math.radians(lat2 - lat1)
    dlng = math.radians(lng2 - lng1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(
        math.radians(lat2)
    ) * math.sin(dlng / 2) ** 2
    return _EARTH_RADIUS_KM * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def _http_get_json(url: str, headers: dict | None = None, timeout: int = 8) -> Any:
    try:
        req = Request(url, headers=headers or {})
        with urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8", errors="ignore"))
    except Exception as exc:
        logger.warning(f"HTTP request failed: {exc}")
        return {}


def _google_nearby(lat: float, lng: float, place_type: str, radius_m: int) -> list[NearbyPlace]:
    api_key = os.getenv("GOOGLE_MAPS_API_KEY", "").strip()
    if not api_key:
        return []

    params = {
        "location": f"{lat},{lng}",
        "radius": radius_m,
        "type": place_type,
        "key": api_key,
    }
    url = f"https://maps.googleapis.com/maps/api/place/nearbysearch/json?{urlencode(params)}"
    data = _http_get_json(url)

    results = data.get("results", [])
    places: list[NearbyPlace] = []
    for item in results[:8]:
        loc = item.get("geometry", {}).get("location", {})
        item_lat = loc.get("lat", lat)
        item_lng = loc.get("lng", lng)
        dist_km = _haversine_km(lat, lng, item_lat, item_lng)
        rating = str(item.get("rating", "N/A"))
        places.append(
            NearbyPlace(
                name=item.get("name", "Unknown"),
                address=item.get("vicinity", ""),
                latitude=item_lat,
                longitude=item_lng,
                distance=f"{dist_km:.1f} km",
                rating=rating,
                phone="",
                place_type=place_type,
            )
        )
    return places


def _mock_places(lat: float, lng: float, place_type: str) -> list[NearbyPlace]:
    """Deterministic mock data as fallback."""
    templates = {
        "hospital": [
            ("City Medical Center", "123 Main Street", 0.01, 0.01, "4.8"),
            ("Women's Health Hospital", "456 Oak Avenue", -0.01, -0.01, "4.9"),
            ("Emergency Care Clinic", "789 Elm Street", 0.015, -0.005, "4.6"),
            ("Community Health Centre", "321 Pine Street", -0.015, 0.005, "4.7"),
        ],
        "pharmacy": [
            ("Health Plus Pharmacy", "321 Pine Street", 0.005, 0.005, "4.7"),
            ("MediCare Drugs", "654 Birch Avenue", -0.008, 0.008, "4.5"),
            ("24-Hour Pharmacy Express", "987 Maple Road", 0.012, -0.012, "4.4"),
        ],
        "supermarket": [
            ("Fresh Mart Supermarket", "111 Produce Lane", 0.008, -0.008, "4.6"),
            ("Nutrition Store", "222 Health Road", -0.01, 0.01, "4.8"),
            ("Organic Market", "333 Garden Street", 0.014, 0.014, "4.9"),
        ],
    }
    rows = templates.get(place_type, templates["hospital"])
    places = []
    for name, addr, dlat, dlng, rating in rows:
        plat, plng = lat + dlat, lng + dlng
        dist = _haversine_km(lat, lng, plat, plng)
        places.append(
            NearbyPlace(
                name=name,
                address=addr,
                latitude=plat,
                longitude=plng,
                distance=f"{dist:.1f} km",
                rating=rating,
                phone="",
                place_type=place_type,
            )
        )
    return places


# ── Firebase ───────────────────────────────────────────────────────────────────

def _ensure_firebase() -> bool:
    if firebase_admin is None:
        return False
    if firebase_admin._apps:
        return True
    cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "").strip()
    if not cred_path or not Path(cred_path).exists():
        return False
    firebase_admin.initialize_app(credentials.Certificate(cred_path))
    return True


# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.post("/notifications/schedule")
async def schedule_notifications(
    email: str = Query(...),
    cycle_length: int = Query(28),
    days_until_period: int = Query(14),
    in_pregnancy: bool = Query(False),
    pregnancy_week: Optional[int] = Query(None),
) -> NotificationSchedule:
    today = datetime.now()
    water_times = ["08:00", "11:00", "14:00", "17:00", "20:00"]
    cycle_alert_date = (
        None
        if in_pregnancy
        else (today + timedelta(days=days_until_period - 1)).strftime("%Y-%m-%d")
    )
    fertile_start = max(1, 12 - (cycle_length - 28) // 2)
    days_until_fertile = (fertile_start - today.day) % cycle_length
    fertility_days = [
        ((today.day + days_until_fertile + i - 1) % cycle_length) + 1 for i in range(5)
    ]

    schedule = NotificationSchedule(
        water_reminder=water_times,
        cycle_alert=cycle_alert_date,
        fertility_days=fertility_days,
        pregnancy_week=pregnancy_week,
    )
    _store_notification(
        email,
        {"timestamp": today.isoformat(), "type": "schedule", "schedule": schedule.model_dump()},
    )
    return schedule


@router.get("/nearby", response_model=NearbyResponse)
async def get_nearby_places(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude"),
    type: str = Query("hospitals", description="hospitals | pharmacies | markets"),
    radius: int = Query(5, description="Search radius in km"),
) -> NearbyResponse:
    """Return nearby medical facilities using Google Places API (mock fallback)."""
    google_type = _PLACE_TYPE_MAP.get(type, "hospital")
    radius_m = radius * 1000

    places = _google_nearby(lat, lng, google_type, radius_m)
    source = "google_places"

    if not places:
        places = _mock_places(lat, lng, google_type)
        source = "mock"

    return NearbyResponse(data=places, status="success", source=source)


@router.post("/notifications/device-token")
async def upsert_device_token(payload: DeviceTokenRequest) -> dict:
    tokens = _load_json(_FCM_FILE)
    tokens[payload.email] = {
        "token": payload.token,
        "platform": payload.platform.lower(),
        "updated_at": datetime.utcnow().isoformat(),
    }
    _save_json(_FCM_FILE, tokens)
    return {"status": "success", "message": "Device token saved", "email": payload.email}


@router.get("/notifications/device-token/{email}")
async def get_device_token(email: EmailStr) -> dict:
    tokens = _load_json(_FCM_FILE)
    entry = tokens.get(email)
    if not entry:
        return {"status": "not_found", "message": "No token for this user"}
    tok = entry.get("token", "")
    masked = f"{tok[:8]}...{tok[-6:]}" if len(tok) > 16 else "***"
    return {
        "status": "success",
        "email": email,
        "platform": entry.get("platform"),
        "token_preview": masked,
        "updated_at": entry.get("updated_at"),
    }


@router.post("/notifications/push", response_model=PushResult)
async def send_push_notification(payload: PushRequest) -> PushResult:
    token = payload.token
    if not token and payload.email:
        token = _load_json(_FCM_FILE).get(payload.email, {}).get("token")

    if not token:
        raise HTTPException(
            status_code=404,
            detail="No device token. Register one first via /notifications/device-token.",
        )

    if _ensure_firebase() and messaging:
        msg = messaging.Message(
            notification=messaging.Notification(title=payload.title, body=payload.body),
            data=payload.data or {},
            token=token,
        )
        msg_id = messaging.send(msg)
        return PushResult(status="success", mode="firebase", message_id=msg_id, detail="Sent via Firebase")

    sim_id = f"sim-{uuid4().hex[:16]}"
    return PushResult(
        status="success",
        mode="simulated",
        message_id=sim_id,
        detail="Firebase not configured. Set FIREBASE_CREDENTIALS_PATH to enable real push.",
    )


@router.get("/notifications/history")
async def get_notification_history(email: str = Query(...)) -> dict:
    return {"data": _fetch_notifications(email), "status": "success"}


@router.delete("/notifications/clear")
async def clear_notifications(email: str = Query(...)) -> dict:
    data = _load_json(_NOTIF_FILE)
    data.pop(email, None)
    _save_json(_NOTIF_FILE, data)
    return {"status": "success", "message": "Notifications cleared"}
