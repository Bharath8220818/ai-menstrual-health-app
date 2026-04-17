"""
Cycle History Management
Track and retrieve user's menstrual cycle data
"""

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field
from datetime import datetime
import json
from pathlib import Path

router = APIRouter(prefix="/cycle-history", tags=["cycle tracking"])

# Simple JSON-based storage (replace with DB in production)
CYCLES_FILE = Path(__file__).parent.parent / "data" / "cycles.json"
CYCLES_FILE.parent.mkdir(parents=True, exist_ok=True)


class CycleEntry(BaseModel):
    email: str
    date: str = Field(..., description="YYYY-MM-DD format")
    day_of_cycle: int = Field(..., ge=1, le=60)
    flow_intensity: int = Field(default=0, ge=0, le=5)  # 0=none, 5=heavy
    symptoms: list[str] = Field(default_factory=list)
    notes: str = ""
    temperature: float | None = None
    cervical_mucus: str | None = None


class CycleResponse(BaseModel):
    success: bool
    message: str
    data: dict | None = None


def _load_cycles() -> dict:
    """Load cycles from JSON."""
    if CYCLES_FILE.exists():
        try:
            with open(CYCLES_FILE, "r") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def _save_cycles(cycles: dict):
    """Save cycles to JSON."""
    with open(CYCLES_FILE, "w") as f:
        json.dump(cycles, f, indent=2, default=str)


@router.post("/add", response_model=CycleResponse)
async def add_cycle_entry(entry: CycleEntry):
    """Add a new cycle entry."""
    cycles = _load_cycles()
    
    if entry.email not in cycles:
        cycles[entry.email] = []
    
    cycle_data = entry.dict()
    cycle_data["created_at"] = datetime.now().isoformat()
    
    cycles[entry.email].append(cycle_data)
    _save_cycles(cycles)
    
    return CycleResponse(
        success=True,
        message="Cycle entry added",
        data=cycle_data,
    )


@router.get("/history/{email}")
async def get_cycle_history(
    email: str,
    limit: int = Query(12, ge=1, le=100),
    offset: int = Query(0, ge=0),
):
    """Get user's cycle history."""
    cycles = _load_cycles()
    
    if email not in cycles:
        return {
            "success": True,
            "total": 0,
            "entries": [],
        }
    
    user_cycles = cycles[email]
    # Sort by date (newest first)
    user_cycles = sorted(user_cycles, key=lambda x: x["date"], reverse=True)
    
    total = len(user_cycles)
    entries = user_cycles[offset : offset + limit]
    
    return {
        "success": True,
        "total": total,
        "offset": offset,
        "limit": limit,
        "entries": entries,
    }


@router.get("/stats/{email}")
async def get_cycle_stats(email: str):
    """Get cycle statistics for analysis."""
    cycles = _load_cycles()
    
    if email not in cycles or not cycles[email]:
        return {
            "success": True,
            "avg_cycle_length": 28,
            "avg_flow_duration": 5,
            "regularity_score": 0,
            "total_cycles": 0,
        }
    
    user_cycles = cycles[email]
    
    # Calculate cycle lengths (in production, group by cycles properly)
    cycle_lengths = []
    flow_durations = []
    
    for i, cycle in enumerate(user_cycles):
        if i > 0 and cycle["day_of_cycle"] == 1:
            prev_cycle = user_cycles[i - 1]
            # Calculate days between cycles
            from datetime import datetime as dt
            curr_date = dt.fromisoformat(cycle["date"])
            prev_date = dt.fromisoformat(prev_cycle["date"])
            length = (prev_date - curr_date).days
            if 15 < length < 45:  # Physiological range
                cycle_lengths.append(length)
        
        # Count flow days
        if cycle["flow_intensity"] > 0:
            flow_durations.append(cycle["flow_intensity"])
    
    avg_cycle = sum(cycle_lengths) / len(cycle_lengths) if cycle_lengths else 28
    avg_flow = len(flow_durations) or 5
    
    # Simple regularity score (0-100)
    if cycle_lengths:
        import statistics
        std_dev = statistics.stdev(cycle_lengths) if len(cycle_lengths) > 1 else 0
        regularity = max(0, 100 - (std_dev * 5))
    else:
        regularity = 0
    
    return {
        "success": True,
        "total_cycles": len(user_cycles),
        "avg_cycle_length": round(avg_cycle, 1),
        "avg_flow_duration": avg_flow,
        "regularity_score": round(regularity, 0),
        "last_cycle_date": user_cycles[-1]["date"] if user_cycles else None,
        "flow_intensities": [c["flow_intensity"] for c in user_cycles[:30]],
        "symptoms_frequency": _get_symptom_frequency(user_cycles),
    }


def _get_symptom_frequency(cycles: list) -> dict:
    """Get frequency of symptoms."""
    freq = {}
    for cycle in cycles:
        for symptom in cycle.get("symptoms", []):
            freq[symptom] = freq.get(symptom, 0) + 1
    
    # Sort by frequency
    return dict(sorted(freq.items(), key=lambda x: x[1], reverse=True)[:10])


@router.put("/entry/{email}/{date}")
async def update_cycle_entry(email: str, date: str, entry: CycleEntry):
    """Update an existing cycle entry."""
    cycles = _load_cycles()
    
    if email not in cycles:
        raise HTTPException(status_code=404, detail="User has no cycle history")
    
    # Find and update entry
    for i, cycle in enumerate(cycles[email]):
        if cycle["date"] == date:
            updated = entry.dict()
            updated["created_at"] = cycle.get("created_at", datetime.now().isoformat())
            updated["updated_at"] = datetime.now().isoformat()
            cycles[email][i] = updated
            _save_cycles(cycles)
            return CycleResponse(
                success=True,
                message="Cycle entry updated",
                data=updated,
            )
    
    raise HTTPException(status_code=404, detail="Cycle entry not found")


@router.delete("/entry/{email}/{date}")
async def delete_cycle_entry(email: str, date: str):
    """Delete a cycle entry."""
    cycles = _load_cycles()
    
    if email not in cycles:
        raise HTTPException(status_code=404, detail="User has no cycle history")
    
    original_len = len(cycles[email])
    cycles[email] = [c for c in cycles[email] if c["date"] != date]
    
    if len(cycles[email]) < original_len:
        _save_cycles(cycles)
        return CycleResponse(success=True, message="Cycle entry deleted")
    
    raise HTTPException(status_code=404, detail="Cycle entry not found")
