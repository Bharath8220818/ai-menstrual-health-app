"""Femi-Friendly FastAPI application entry-point."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Load .env before anything else
from dotenv import load_dotenv
load_dotenv()

from api.routes import router
from api.auth import router as auth_router
from api.cycle_history import router as cycle_router
from api.notifications import router as notifications_router

app = FastAPI(
    title="Menstrual Health AI API",
    version="2.0.0",
    description=(
        "Predictive endpoints and recommendations for women's menstrual "
        "and reproductive health — powered by Femi-Friendly AI."
    ),
)

# ── CORS ──────────────────────────────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(router)
app.include_router(auth_router)
app.include_router(cycle_router)
app.include_router(notifications_router)


# ── DB status endpoint ────────────────────────────────────────────────────────
@app.get("/db-status", tags=["health"])
def db_status():
    """Return MongoDB Atlas connectivity status."""
    from api.database import is_mongo_connected
    connected = is_mongo_connected()
    return {
        "mongodb": "connected" if connected else "fallback (JSON files)",
        "status": "ok",
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("api.main:app", host="0.0.0.0", port=8000, reload=True)
