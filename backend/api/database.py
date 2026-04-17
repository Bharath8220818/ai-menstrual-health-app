"""
MongoDB Atlas database connection and collection helpers for Femi-Friendly.
Falls back to JSON files gracefully if MongoDB is unavailable.
"""

from __future__ import annotations

import os
import json
import logging
from pathlib import Path
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)

# ── Try to import motor (async) or pymongo (sync) ─────────────────────────────
try:
    from pymongo import MongoClient
    from pymongo.collection import Collection
    from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
    PYMONGO_AVAILABLE = True
except ImportError:
    PYMONGO_AVAILABLE = False
    logger.warning("pymongo not installed — running in JSON-file-only mode.")

# ── Connection singleton ───────────────────────────────────────────────────────
_client: Optional[Any] = None
_db: Optional[Any] = None


def _get_client():
    """Return a cached MongoClient, creating it on first call."""
    global _client
    if not PYMONGO_AVAILABLE:
        return None
    if _client is not None:
        return _client

    mongo_uri = os.getenv(
        "MONGO_URI",
        "mongodb+srv://<USER>:<PASSWORD>@<CLUSTER>/",
    )
    try:
        _client = MongoClient(mongo_uri, serverSelectionTimeoutMS=5000)
        # Verify connectivity
        _client.admin.command("ping")
        logger.info("✅ MongoDB Atlas connected successfully.")
    except Exception as exc:
        logger.warning(f"⚠️  MongoDB connection failed ({exc}). Using JSON fallback.")
        _client = None
    return _client


def get_db():
    """Return the MongoDB database object, or None if unavailable."""
    global _db
    client = _get_client()
    if client is None:
        return None
    if _db is None:
        db_name = os.getenv("MONGO_DB_NAME", "femi_friendly")
        _db = client[db_name]
    return _db


def get_collection(name: str) -> Optional[Any]:
    """Return a MongoDB collection by name, or None if unavailable."""
    db = get_db()
    if db is None:
        return None
    return db[name]


# ── High-level helpers ─────────────────────────────────────────────────────────

def upsert_user(email: str, data: Dict[str, Any]) -> bool:
    """Insert or update a user document by email. Returns True on success."""
    col = get_collection(os.getenv("MONGO_USERS_COLLECTION", "users"))
    if col is None:
        return False
    try:
        col.update_one({"email": email}, {"$set": data}, upsert=True)
        return True
    except Exception as exc:
        logger.error(f"upsert_user error: {exc}")
        return False


def find_user(email: str) -> Optional[Dict[str, Any]]:
    """Find a user by email. Returns the document or None."""
    col = get_collection(os.getenv("MONGO_USERS_COLLECTION", "users"))
    if col is None:
        return None
    try:
        doc = col.find_one({"email": email}, {"_id": 0})
        return doc
    except Exception as exc:
        logger.error(f"find_user error: {exc}")
        return None


def insert_cycle_entry(entry: Dict[str, Any]) -> bool:
    """Insert a cycle history entry. Returns True on success."""
    col = get_collection(os.getenv("MONGO_CYCLES_COLLECTION", "cycles"))
    if col is None:
        return False
    try:
        col.insert_one(entry)
        return True
    except Exception as exc:
        logger.error(f"insert_cycle_entry error: {exc}")
        return False


def get_cycle_history(email: str, limit: int = 50) -> List[Dict[str, Any]]:
    """Retrieve cycle entries for a user, newest first."""
    col = get_collection(os.getenv("MONGO_CYCLES_COLLECTION", "cycles"))
    if col is None:
        return []
    try:
        cursor = col.find(
            {"email": email},
            {"_id": 0},
        ).sort("date", -1).limit(limit)
        return list(cursor)
    except Exception as exc:
        logger.error(f"get_cycle_history error: {exc}")
        return []


def insert_notification(notification: Dict[str, Any]) -> bool:
    """Store a notification record. Returns True on success."""
    col = get_collection(os.getenv("MONGO_NOTIFICATIONS_COLLECTION", "notifications"))
    if col is None:
        return False
    try:
        col.insert_one(notification)
        return True
    except Exception as exc:
        logger.error(f"insert_notification error: {exc}")
        return False


def get_notifications(email: str, limit: int = 30) -> List[Dict[str, Any]]:
    """Retrieve notifications for a user, newest first."""
    col = get_collection(os.getenv("MONGO_NOTIFICATIONS_COLLECTION", "notifications"))
    if col is None:
        return []
    try:
        cursor = col.find(
            {"email": email},
            {"_id": 0},
        ).sort("created_at", -1).limit(limit)
        return list(cursor)
    except Exception as exc:
        logger.error(f"get_notifications error: {exc}")
        return []


def is_mongo_connected() -> bool:
    """Check if MongoDB is currently reachable."""
    return get_db() is not None
