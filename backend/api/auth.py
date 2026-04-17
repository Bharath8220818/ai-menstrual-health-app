"""
Authentication & User Management
MongoDB Atlas primary storage with JSON fallback.
Passwords hashed with bcrypt; tokens are signed JWTs.
"""

from __future__ import annotations

import hashlib
import json
import logging
import os
import time
from datetime import datetime, timedelta
from pathlib import Path

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr, Field

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/auth", tags=["authentication"])

# ── JSON fallback paths ────────────────────────────────────────────────────────
_USERS_FILE = Path(__file__).parent.parent / "data" / "users.json"
_USERS_FILE.parent.mkdir(parents=True, exist_ok=True)

# ── Optional dependencies (bcrypt / jose) ─────────────────────────────────────
try:
    import bcrypt as _bcrypt
    _BCRYPT_OK = True
except ImportError:
    _BCRYPT_OK = False
    logger.warning("bcrypt not installed — using SHA-256 fallback (install bcrypt for production)")

try:
    from jose import jwt as _jwt
    _JWT_SECRET = os.getenv("JWT_SECRET_KEY", "YOUR_SECURE_JWT_SECRET_KEY")
    _JWT_ALGO = "HS256"
    _JWT_EXPIRE_HOURS = int(os.getenv("JWT_EXPIRATION_HOURS", "24"))
    _JWT_OK = True
except ImportError:
    _JWT_OK = False
    logger.warning("python-jose not installed — using simple token fallback")


# ── Pydantic models ────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    name: str = Field(..., min_length=2)
    age: int = Field(default=28, ge=13, le=100)
    weight: float = Field(default=60.0, gt=30, lt=300)
    height: float = Field(default=165.0, gt=100, lt=250)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserProfile(BaseModel):
    email: str
    name: str
    age: int
    weight: float
    height: float
    cycle_length: int = 28
    period_length: int = 5
    notifications_enabled: bool = True
    last_period_date: str | None = None


class AuthResponse(BaseModel):
    success: bool
    message: str
    user: UserProfile | None = None
    token: str | None = None


# ── Password helpers ───────────────────────────────────────────────────────────

def _hash_password(password: str) -> str:
    if _BCRYPT_OK:
        return _bcrypt.hashpw(password.encode(), _bcrypt.gensalt()).decode()
    return hashlib.sha256(password.encode()).hexdigest()


def _verify_password(plain: str, hashed: str) -> bool:
    if _BCRYPT_OK and hashed.startswith("$2"):
        return _bcrypt.checkpw(plain.encode(), hashed.encode())
    return hashlib.sha256(plain.encode()).hexdigest() == hashed


def _generate_token(email: str) -> str:
    if _JWT_OK:
        payload = {
            "sub": email,
            "iat": int(time.time()),
            "exp": int((datetime.utcnow() + timedelta(hours=_JWT_EXPIRE_HOURS)).timestamp()),
        }
        return _jwt.encode(payload, _JWT_SECRET, algorithm=_JWT_ALGO)
    data = f"{email}:{int(time.time())}"
    return hashlib.sha256(data.encode()).hexdigest()[:32]


# ── Storage helpers (MongoDB primary, JSON fallback) ──────────────────────────

def _load_users_json() -> dict:
    if _USERS_FILE.exists():
        try:
            with open(_USERS_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def _save_users_json(users: dict) -> None:
    with open(_USERS_FILE, "w") as f:
        json.dump(users, f, indent=2)


def _get_user(email: str) -> dict | None:
    """Read user from MongoDB if available, else JSON."""
    try:
        from api.database import find_user
        doc = find_user(email)
        if doc is not None:
            return doc
    except Exception:
        pass
    users = _load_users_json()
    return users.get(email)


def _save_user(email: str, data: dict) -> None:
    """Write user to MongoDB AND JSON (dual-write for safety)."""
    try:
        from api.database import upsert_user
        upsert_user(email, data)
    except Exception as exc:
        logger.warning(f"MongoDB write skipped: {exc}")
    users = _load_users_json()
    users[email] = data
    _save_users_json(users)


# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.post("/register", response_model=AuthResponse)
async def register(data: UserRegister):
    """Register a new user."""
    if _get_user(data.email) is not None:
        raise HTTPException(status_code=400, detail="Email already registered")

    user_doc = {
        "email": data.email,
        "password": _hash_password(data.password),
        "name": data.name,
        "age": data.age,
        "weight": data.weight,
        "height": data.height,
        "cycle_length": 28,
        "period_length": 5,
        "notifications_enabled": True,
        "last_period_date": None,
        "created_at": datetime.utcnow().isoformat(),
    }
    _save_user(data.email, user_doc)

    return AuthResponse(
        success=True,
        message="Registration successful",
        user=UserProfile(**user_doc),
        token=_generate_token(data.email),
    )


@router.post("/login", response_model=AuthResponse)
async def login(data: UserLogin):
    """Login an existing user."""
    user = _get_user(data.email)
    if user is None or not _verify_password(data.password, user.get("password", "")):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    return AuthResponse(
        success=True,
        message="Login successful",
        user=UserProfile(**user),
        token=_generate_token(data.email),
    )


@router.get("/verify/{email}")
async def verify_user(email: str):
    """Check if a user account exists."""
    user = _get_user(email)
    if user:
        return {"exists": True, "name": user.get("name"), "created_at": user.get("created_at")}
    return {"exists": False}


@router.get("/profile/{email}")
async def get_profile(email: str):
    """Return user profile."""
    user = _get_user(email)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return UserProfile(**user)


@router.put("/profile/{email}")
async def update_profile(email: str, profile: UserProfile):
    """Update user profile fields."""
    existing = _get_user(email)
    if existing is None:
        raise HTTPException(status_code=404, detail="User not found")

    updated = profile.model_dump()
    updated["password"] = existing.get("password", "")
    updated["created_at"] = existing.get("created_at", datetime.utcnow().isoformat())
    updated["updated_at"] = datetime.utcnow().isoformat()

    _save_user(email, updated)
    return {"success": True, "message": "Profile updated", "user": UserProfile(**updated)}


@router.post("/logout")
async def logout():
    """Logout (token invalidation happens client-side for stateless JWT)."""
    return {"success": True, "message": "Logged out successfully"}
