"""
Cycle History Management
MongoDB Atlas primary storage with JSON fallback.
"""

from __future__ import annotations

import json
import logging
import statistics
from datetime import datetime
from pathlib import Path

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/cycle-history", tags=["cycle tracking"])

# ── JSON fallback ──────────────────────────────────────────────────────────────
_CYCLES_FILE = Path(__file__).parent.parent / "data" / "cycles.json"
_CYCLES_FILE.parent.mkdir(parents=True, exist_ok=True)


# ── Pydantic models ────────────────────────────────────────────────────────────

class CycleEntry(BaseModel):
    email: str
    date: str = Field(..., description="YYYY-MM-DD")
    day_of_cycle: int = Field(..., ge=1, le=60)
    flow_intensity: int = Field(default=0, ge=0, le=5)
    symptoms: list[str] = Field(default_factory=list)
    notes: str = ""
    temperature: float | None = None
    cervical_mucus: str | None = None


class CycleResponse(BaseModel):
    success: bool
    message: str
    data: dict | None = None


# ── Storage helpers ────────────────────────────────────────────────────────────

def _load_json() -> dict:
    if _CYCLES_FILE.exists():
        try:
            with open(_CYCLES_FILE) as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def _save_json(data: dict) -> None:
    with open(_CYCLES_FILE, "w") as f:
        json.dump(data, f, indent=2, default=str)


def _db_insert(entry: dict) -> bool:
    try:
        from api.database import insert_cycle_entry
        return insert_cycle_entry(entry)
    except Exception as exc:
        logger.warning(f"MongoDB insert skipped: {exc}")
        return False


def _db_get_history(email: str, limit: int = 100) -> list[dict]:
    try:
        from api.database import get_cycle_history as _get
        results = _get(email, limit=limit)
        if results:
            return results
    except Exception as exc:
        logger.warning(f"MongoDB read skipped: {exc}")
    # JSON fallback
    data = _load_json()
    entries = data.get(email, [])
    return sorted(entries, key=lambda x: x.get("date", ""), reverse=True)[:limit]


# ── Endpoints ─────────────────────────────────────────────────────────────────

@router.post("/add", response_model=CycleResponse)
async def add_cycle_entry(entry: CycleEntry):
    """Add a new cycle entry."""
    record = entry.model_dump()
    record["created_at"] = datetime.utcnow().isoformat()

    # MongoDB primary
    mongo_ok = _db_insert(record)

    # JSON dual-write
    data = _load_json()
    data.setdefault(entry.email, [])
    data[entry.email].append(record)
    _save_json(data)

    return CycleResponse(success=True, message="Cycle entry added", data=record)


@router.get("/history/{email}")
async def get_cycle_history(
    email: str,
    limit: int = Query(12, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """Get paginated cycle history, newest first."""
    all_entries = _db_get_history(email, limit=limit + offset)
    total = len(all_entries)
    page = all_entries[offset: offset + limit]
    return {"success": True, "total": total, "offset": offset, "limit": limit, "entries": page}


@router.get("/stats/{email}")
async def get_cycle_stats(email: str):
    """Compute cycle statistics from stored history."""
    all_entries = _db_get_history(email, limit=200)

    if not all_entries:
        return {
            "success": True,
            "avg_cycle_length": 28,
            "avg_flow_duration": 5,
            "regularity_score": 0,
            "total_cycles": 0,
        }

    # Compute cycle lengths between day-1 entries
    cycle_lengths: list[float] = []
    flow_days: list[int] = []

    for i, entry in enumerate(all_entries):
        if i > 0 and entry.get("day_of_cycle") == 1:
            try:
                curr = datetime.fromisoformat(entry["date"])
                prev = datetime.fromisoformat(all_entries[i - 1]["date"])
                length = (prev - curr).days
                if 15 < length < 45:
                    cycle_lengths.append(length)
            except Exception:
                pass
        if entry.get("flow_intensity", 0) > 0:
            flow_days.append(entry["flow_intensity"])

    avg_cycle = sum(cycle_lengths) / len(cycle_lengths) if cycle_lengths else 28.0
    avg_flow = len(flow_days) or 5
    std_dev = statistics.stdev(cycle_lengths) if len(cycle_lengths) > 1 else 0
    regularity = max(0.0, 100.0 - std_dev * 5)

    return {
        "success": True,
        "total_cycles": len(all_entries),
        "avg_cycle_length": round(avg_cycle, 1),
        "avg_flow_duration": avg_flow,
        "regularity_score": round(regularity, 0),
        "last_cycle_date": all_entries[-1].get("date") if all_entries else None,
        "flow_intensities": [e.get("flow_intensity", 0) for e in all_entries[:30]],
        "symptoms_frequency": _symptom_freq(all_entries),
    }


def _symptom_freq(entries: list[dict]) -> dict:
    freq: dict[str, int] = {}
    for e in entries:
        for s in e.get("symptoms", []):
            freq[s] = freq.get(s, 0) + 1
    return dict(sorted(freq.items(), key=lambda x: x[1], reverse=True)[:10])


@router.put("/entry/{email}/{date}")
async def update_cycle_entry(email: str, date: str, entry: CycleEntry):
    """Update an existing cycle entry by date."""
    data = _load_json()
    if email not in data:
        raise HTTPException(status_code=404, detail="User has no cycle history")

    for i, cycle in enumerate(data[email]):
        if cycle.get("date") == date:
            updated = entry.model_dump()
            updated["created_at"] = cycle.get("created_at", datetime.utcnow().isoformat())
            updated["updated_at"] = datetime.utcnow().isoformat()
            data[email][i] = updated
            _save_json(data)
            return CycleResponse(success=True, message="Cycle entry updated", data=updated)

    raise HTTPException(status_code=404, detail="Cycle entry not found")


@router.delete("/entry/{email}/{date}")
async def delete_cycle_entry(email: str, date: str):
    """Delete a cycle entry by date."""
    data = _load_json()
    if email not in data:
        raise HTTPException(status_code=404, detail="User has no cycle history")

    before = len(data[email])
    data[email] = [c for c in data[email] if c.get("date") != date]
    if len(data[email]) < before:
        _save_json(data)
        return CycleResponse(success=True, message="Cycle entry deleted")

    raise HTTPException(status_code=404, detail="Cycle entry not found")
