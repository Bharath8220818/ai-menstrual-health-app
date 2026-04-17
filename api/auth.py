"""
Authentication & User Management
Handles user registration, login, profile management
"""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime, timedelta
import json
from pathlib import Path

router = APIRouter(prefix="/auth", tags=["authentication"])

# Simple JSON-based user storage (replace with DB in production)
USERS_FILE = Path(__file__).parent.parent / "data" / "users.json"
USERS_FILE.parent.mkdir(parents=True, exist_ok=True)


class UserRegister(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    name: str = Field(..., min_length=2)
    age: int = Field(default=28, ge=13, le=100)
    weight: float = Field(default=60, gt=30, lt=300)
    height: float = Field(default=165, gt=100, lt=250)


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


def _load_users() -> dict:
    """Load users from JSON file."""
    if USERS_FILE.exists():
        try:
            with open(USERS_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def _save_users(users: dict):
    """Save users to JSON file."""
    with open(USERS_FILE, "w") as f:
        json.dump(users, f, indent=2)


def _hash_password(password: str) -> str:
    """Simple password hashing (use bcrypt in production)."""
    import hashlib
    return hashlib.sha256(password.encode()).hexdigest()


def _generate_token(email: str) -> str:
    """Generate simple auth token (use JWT in production)."""
    import hashlib
    import time
    data = f"{email}:{int(time.time())}"
    return hashlib.sha256(data.encode()).hexdigest()[:32]


@router.post("/register", response_model=AuthResponse)
async def register(data: UserRegister):
    """Register a new user."""
    users = _load_users()
    
    if data.email in users:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    user_profile = {
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
        "created_at": datetime.now().isoformat(),
    }
    
    users[data.email] = user_profile
    _save_users(users)
    
    token = _generate_token(data.email)
    
    return AuthResponse(
        success=True,
        message="Registration successful",
        user=UserProfile(**user_profile),
        token=token,
    )


@router.post("/login", response_model=AuthResponse)
async def login(data: UserLogin):
    """Login an existing user."""
    users = _load_users()
    
    if data.email not in users:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    user = users[data.email]
    if user["password"] != _hash_password(data.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    token = _generate_token(data.email)
    
    return AuthResponse(
        success=True,
        message="Login successful",
        user=UserProfile(**user),
        token=token,
    )


@router.get("/verify/{email}")
async def verify_user(email: str):
    """Verify if user exists."""
    users = _load_users()
    
    if email in users:
        return {
            "exists": True,
            "name": users[email].get("name"),
            "created_at": users[email].get("created_at"),
        }
    
    return {"exists": False}


@router.get("/profile/{email}")
async def get_profile(email: str):
    """Get user profile."""
    users = _load_users()
    
    if email not in users:
        raise HTTPException(status_code=404, detail="User not found")
    
    user = users[email]
    return UserProfile(**user)


@router.put("/profile/{email}")
async def update_profile(email: str, profile: UserProfile):
    """Update user profile."""
    users = _load_users()
    
    if email not in users:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Update profile while keeping password
    old_password = users[email].get("password")
    updated = profile.dict()
    updated["password"] = old_password
    updated["created_at"] = users[email].get("created_at", datetime.now().isoformat())
    
    users[email] = updated
    _save_users(users)
    
    return {
        "success": True,
        "message": "Profile updated",
        "user": UserProfile(**updated),
    }


@router.post("/logout")
async def logout(email: str):
    """Logout user (token invalidation in production)."""
    return {
        "success": True,
        "message": "Logged out successfully",
    }
