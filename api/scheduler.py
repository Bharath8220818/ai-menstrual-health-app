"""
api/scheduler.py
================
AI-based Automated Notification Engine for Femi-Friendly.

Schedule: every 6 hours (configurable via SCHEDULER_INTERVAL_HOURS env var)
Trigger: APScheduler BackgroundScheduler (runs in a background thread)
Push:    Firebase Admin SDK  (FCM)
Storage: MongoDB Atlas → notifications collection (JSON fallback)
Safety:  Per-user, per-type deduplication using last_notification_time

Notification types fired automatically:
  1. period_reminder      — 1 day before next_period_date
  2. water_reminder       — daily at runtime
  3. pregnancy_tip        — weekly, based on pregnancy_week
  4. irregular_cycle      — ML model flags irregularity
  5. stress_alert         — stress_level >= threshold (default 4)
  6. hydration_alert      — daily water intake below threshold
"""

from __future__ import annotations

import logging
import os
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)

# ── Optional dependency guards ─────────────────────────────────────────────────
try:
    from apscheduler.schedulers.background import BackgroundScheduler
    from apscheduler.triggers.interval import IntervalTrigger
    APSCHEDULER_AVAILABLE = True
except ImportError:
    APSCHEDULER_AVAILABLE = False
    logger.warning("APScheduler not installed — automated notifications disabled.")

try:
    import firebase_admin
    from firebase_admin import credentials as fb_credentials, messaging as fb_messaging
    FIREBASE_ADMIN_AVAILABLE = True
except ImportError:
    FIREBASE_ADMIN_AVAILABLE = False
    logger.warning("firebase_admin not installed — push notifications disabled.")

try:
    import joblib
    JOBLIB_AVAILABLE = True
except ImportError:
    JOBLIB_AVAILABLE = False

# ── Global scheduler singleton ─────────────────────────────────────────────────
_scheduler: Optional[Any] = None


# ══════════════════════════════════════════════════════════════════════════════
#  Firebase helpers
# ══════════════════════════════════════════════════════════════════════════════

def _ensure_firebase() -> bool:
    """Initialize Firebase Admin SDK once. Returns True if ready."""
    if not FIREBASE_ADMIN_AVAILABLE:
        return False
    if firebase_admin._apps:
        return True
    cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-adminsdk.json").strip()
    if not Path(cred_path).exists():
        logger.warning(f"Firebase service account not found at '{cred_path}'.")
        return False
    try:
        firebase_admin.initialize_app(fb_credentials.Certificate(cred_path))
        logger.info("Firebase Admin SDK initialized by scheduler.")
        return True
    except Exception as exc:
        logger.error(f"Firebase init error: {exc}")
        return False


def _send_fcm(token: str, title: str, body: str, data: Dict[str, str]) -> Optional[str]:
    """
    Send an FCM message to a device token.
    Returns the message_id on success, None on failure.
    """
    if not _ensure_firebase():
        logger.debug(f"[FCM-SIM] Would send to {token[:12]}… | {title}: {body}")
        return f"sim-{datetime.now(timezone.utc).timestamp()}"
    try:
        message = fb_messaging.Message(
            notification=fb_messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in data.items()},
            token=token,
            android=fb_messaging.AndroidConfig(
                priority="high",
                notification=fb_messaging.AndroidNotification(
                    channel_id=data.get("channel_id", "femi_general"),
                    sound="default",
                ),
            ),
        )
        msg_id = fb_messaging.send(message)
        logger.info(f"FCM sent to {token[:16]}… | id={msg_id}")
        return msg_id
    except Exception as exc:
        logger.error(f"FCM send failed: {exc}")
        return None


# ══════════════════════════════════════════════════════════════════════════════
#  MongoDB helpers
# ══════════════════════════════════════════════════════════════════════════════

def _get_all_users() -> List[Dict[str, Any]]:
    """Fetch all user documents from MongoDB (or JSON fallback)."""
    try:
        from api.database import get_collection
        col = get_collection(os.getenv("MONGO_USERS_COLLECTION", "users"))
        if col is not None:
            return list(col.find({}, {"_id": 0}))
    except Exception as exc:
        logger.warning(f"MongoDB user fetch failed: {exc}")

    # JSON fallback
    json_path = Path("data/users.json")
    if json_path.exists():
        import json
        try:
            data = json.loads(json_path.read_text())
            return list(data.values()) if isinstance(data, dict) else data
        except Exception:
            pass
    return []


def _get_fcm_token(email: str) -> Optional[str]:
    """Look up the stored FCM device token for a user."""
    try:
        from api.database import get_collection
        col = get_collection("fcm_tokens")
        if col is not None:
            doc = col.find_one({"email": email}, {"_id": 0, "token": 1})
            if doc:
                return doc.get("token")
    except Exception:
        pass

    # JSON fallback
    fcm_file = Path("data/fcm_tokens.json")
    if fcm_file.exists():
        import json
        try:
            tokens = json.loads(fcm_file.read_text())
            return tokens.get(email, {}).get("token")
        except Exception:
            pass
    return None


def _log_notification(
    email: str,
    notif_type: str,
    title: str,
    body: str,
    message_id: Optional[str],
    status: str,
) -> None:
    """Write a notification log record to MongoDB and JSON."""
    record = {
        "email": email,
        "type": notif_type,
        "title": title,
        "body": body,
        "message_id": message_id,
        "status": status,
        "created_at": datetime.now(timezone.utc).isoformat(),
        "source": "scheduler",
    }
    try:
        from api.database import insert_notification
        insert_notification(record)
    except Exception as exc:
        logger.warning(f"Notification log insert failed: {exc}")

    # JSON fallback
    import json
    notif_file = Path("data/notifications.json")
    notif_file.parent.mkdir(exist_ok=True)
    data: Dict[str, Any] = {}
    if notif_file.exists():
        try:
            data = json.loads(notif_file.read_text())
        except Exception:
            pass
    data.setdefault(email, []).append(record)
    try:
        notif_file.write_text(json.dumps(data, indent=2, default=str))
    except Exception:
        pass


def _update_last_notif_time(email: str, notif_type: str) -> None:
    """Stamp user's last_notification_time[type] to prevent duplicates."""
    key = f"last_notification_time.{notif_type}"
    now_iso = datetime.now(timezone.utc).isoformat()
    try:
        from api.database import get_collection
        col = get_collection(os.getenv("MONGO_USERS_COLLECTION", "users"))
        if col is not None:
            col.update_one({"email": email}, {"$set": {key: now_iso}})
    except Exception as exc:
        logger.warning(f"last_notification_time update failed: {exc}")


def _was_recently_notified(user: Dict[str, Any], notif_type: str, hours: int) -> bool:
    """Return True if this notification type was already sent within `hours` hours."""
    last_times: Dict[str, str] = user.get("last_notification_time", {})
    last_str = last_times.get(notif_type)
    if not last_str:
        return False
    try:
        last_dt = datetime.fromisoformat(last_str)
        if last_dt.tzinfo is None:
            last_dt = last_dt.replace(tzinfo=timezone.utc)
        return (datetime.now(timezone.utc) - last_dt) < timedelta(hours=hours)
    except Exception:
        return False


# ══════════════════════════════════════════════════════════════════════════════
#  ML model helper
# ══════════════════════════════════════════════════════════════════════════════

_ml_model: Optional[Any] = None


def _load_ml_model() -> Optional[Any]:
    global _ml_model
    if _ml_model is not None:
        return _ml_model
    if not JOBLIB_AVAILABLE:
        return None
    model_path = Path(os.getenv("MODEL_PATH", "ai_model/model.pkl"))
    if not model_path.exists():
        return None
    try:
        _ml_model = joblib.load(model_path)
        logger.info(f"ML model loaded from {model_path}")
    except Exception as exc:
        logger.warning(f"ML model load failed: {exc}")
    return _ml_model


def _predict_irregular_cycle(user: Dict[str, Any]) -> bool:
    """
    Use the trained RF model to flag irregular cycles.
    Falls back to a heuristic if model is unavailable.
    """
    model = _load_ml_model()
    cycle_length = user.get("cycle_length", 28)
    period_duration = user.get("period_duration", 5)
    age = user.get("age", 25)

    if model is not None:
        try:
            import numpy as np
            features = np.array([[cycle_length, period_duration, age]])
            result = model.predict(features)
            return bool(result[0])  # 1 = irregular
        except Exception as exc:
            logger.debug(f"ML predict failed, using heuristic: {exc}")

    # Heuristic fallback
    return cycle_length < 21 or cycle_length > 35 or period_duration > 7


# ══════════════════════════════════════════════════════════════════════════════
#  Pregnancy tips library
# ══════════════════════════════════════════════════════════════════════════════

_PREGNANCY_TIPS: Dict[int, str] = {
    4:  "Your baby is the size of a poppy seed! Stay hydrated and take your prenatal vitamins.",
    6:  "Morning sickness? Eat small, frequent meals and keep crackers nearby.",
    8:  "Your baby's heart is beating! Schedule your first prenatal checkup if you haven't.",
    10: "You're at the end of your first trimester — the risk of miscarriage drops significantly.",
    12: "First trimester complete! Many moms share their news now. Consider genetic testing.",
    14: "Second trimester begins! Energy often improves. Start gentle prenatal yoga.",
    16: "Your baby can hear sounds now. Talk and sing to them!",
    18: "Anatomy scan soon! Baby is about the size of a sweet potato.",
    20: "Halfway there! Your baby is moving — notice any kicks or flutters?",
    24: "Viability milestone reached. Baby's lungs are developing rapidly.",
    28: "Third trimester! Start thinking about your birth plan and hospital bag.",
    32: "Baby is head-down in most pregnancies now. Practice your breathing exercises.",
    36: "Baby is considered early-term. Have your hospital bag ready!",
    38: "Full term! Your baby could arrive any day. Rest as much as possible.",
    40: "Due date week! Stay calm — first-time pregnancies often run a little late.",
}

def _get_pregnancy_tip(week: int) -> str:
    """Return the closest pregnancy tip for the given week."""
    if week <= 0:
        return "Congratulations on your pregnancy! Take your prenatal vitamins daily."
    best_week = min(_PREGNANCY_TIPS.keys(), key=lambda w: abs(w - week))
    return _PREGNANCY_TIPS[best_week]


# ══════════════════════════════════════════════════════════════════════════════
#  Core notification dispatch functions
# ══════════════════════════════════════════════════════════════════════════════

def _dispatch(
    user: Dict[str, Any],
    notif_type: str,
    title: str,
    body: str,
    channel_id: str = "femi_general",
    dedupe_hours: int = 20,
) -> None:
    """
    Central dispatch: dedupe check → FCM send → log → update stamp.
    """
    email = user.get("email", "unknown")
    if _was_recently_notified(user, notif_type, hours=dedupe_hours):
        logger.debug(f"[SKIP] {email} | {notif_type} — sent within {dedupe_hours}h")
        return

    token = _get_fcm_token(email)
    status = "no_token"
    msg_id = None

    if token:
        msg_id = _send_fcm(
            token=token,
            title=title,
            body=body,
            data={"type": notif_type, "channel_id": channel_id, "email": email},
        )
        status = "sent" if msg_id else "failed"
    else:
        logger.debug(f"[NO TOKEN] {email} | {notif_type}")

    _log_notification(email, notif_type, title, body, msg_id, status)
    _update_last_notif_time(email, notif_type)


# ══════════════════════════════════════════════════════════════════════════════
#  Per-user notification checks
# ══════════════════════════════════════════════════════════════════════════════

def _check_period_reminder(user: Dict[str, Any]) -> None:
    """Fire if next_period_date is tomorrow."""
    next_period_str = user.get("next_period_date")
    if not next_period_str:
        return
    try:
        next_period = datetime.fromisoformat(str(next_period_str)).date()
    except Exception:
        return

    tomorrow = (datetime.now(timezone.utc) + timedelta(days=1)).date()
    if next_period != tomorrow:
        return

    _dispatch(
        user=user,
        notif_type="period_reminder",
        title="🌸 Period Reminder",
        body="Your period is expected tomorrow. Stock up on essentials and take it easy today.",
        channel_id="cycle_alerts",
        dedupe_hours=20,
    )


def _check_water_reminder(user: Dict[str, Any]) -> None:
    """Daily water intake reminder."""
    _dispatch(
        user=user,
        notif_type="water_reminder",
        title="💧 Time to Hydrate!",
        body="Staying hydrated supports your hormonal balance. Drink a glass of water now!",
        channel_id="water_reminders",
        dedupe_hours=6,
    )


def _check_pregnancy_tip(user: Dict[str, Any]) -> None:
    """Send weekly pregnancy tip if user is in pregnancy mode."""
    pregnancy_week = user.get("pregnancy_week")
    if not pregnancy_week or int(pregnancy_week) <= 0:
        return

    week = int(pregnancy_week)
    tip = _get_pregnancy_tip(week)
    _dispatch(
        user=user,
        notif_type="pregnancy_tip",
        title=f"🤱 Week {week} Pregnancy Tip",
        body=tip,
        channel_id="pregnancy_updates",
        dedupe_hours=24 * 7,   # once per week
    )


def _check_irregular_cycle(user: Dict[str, Any]) -> None:
    """Use ML model to flag irregular cycles."""
    # Skip if user is pregnant
    if user.get("pregnancy_week", 0):
        return

    if not _predict_irregular_cycle(user):
        return

    cycle_length = user.get("cycle_length", 28)
    _dispatch(
        user=user,
        notif_type="irregular_cycle",
        title="⚠️ Cycle Irregularity Detected",
        body=(
            f"Our AI noticed your cycle length ({cycle_length} days) may be irregular. "
            "Consider speaking with a healthcare provider."
        ),
        channel_id="cycle_alerts",
        dedupe_hours=24 * 3,   # at most every 3 days
    )


def _check_stress_alert(user: Dict[str, Any]) -> None:
    """Alert if stress_level is at or above threshold."""
    threshold = int(os.getenv("STRESS_ALERT_THRESHOLD", "4"))
    stress = user.get("stress_level", 0)
    if not stress or int(stress) < threshold:
        return

    _dispatch(
        user=user,
        notif_type="stress_alert",
        title="🧘 High Stress Detected",
        body=(
            f"Your reported stress level ({stress}/10) is elevated. "
            "Try a 5-minute breathing exercise or a short walk. You've got this! 💪"
        ),
        channel_id="femi_general",
        dedupe_hours=12,
    )


def _check_hydration_alert(user: Dict[str, Any]) -> None:
    """Alert if today's water intake is below the recommended threshold."""
    threshold_ml = int(os.getenv("HYDRATION_THRESHOLD_ML", "1500"))
    water_ml = user.get("water_intake_ml", 0) or user.get("water_intake", 0)
    if not water_ml or int(water_ml) >= threshold_ml:
        return

    deficit = threshold_ml - int(water_ml)
    _dispatch(
        user=user,
        notif_type="hydration_alert",
        title="🌊 Low Hydration Alert",
        body=(
            f"You've logged {water_ml} ml today — you need {deficit} ml more "
            f"to reach your {threshold_ml} ml goal. Drink up!"
        ),
        channel_id="water_reminders",
        dedupe_hours=8,
    )


# ══════════════════════════════════════════════════════════════════════════════
#  Main scheduler job
# ══════════════════════════════════════════════════════════════════════════════

def run_notification_job() -> None:
    """
    Entry-point called by APScheduler every N hours.
    Iterates all users and runs all notification checks.
    """
    logger.info("🔔 Notification job started — fetching users…")
    users = _get_all_users()
    if not users:
        logger.info("No users found — notification job skipped.")
        return

    logger.info(f"Processing {len(users)} user(s)…")
    sent_count = 0

    for user in users:
        email = user.get("email", "<unknown>")
        try:
            _check_period_reminder(user)
            _check_water_reminder(user)
            _check_pregnancy_tip(user)
            _check_irregular_cycle(user)
            _check_stress_alert(user)
            _check_hydration_alert(user)
            sent_count += 1
        except Exception as exc:
            logger.error(f"Notification job error for {email}: {exc}", exc_info=True)

    logger.info(f"Notification job complete — processed {sent_count}/{len(users)} users.")


# ══════════════════════════════════════════════════════════════════════════════
#  Scheduler lifecycle
# ══════════════════════════════════════════════════════════════════════════════

def start_scheduler() -> None:
    """
    Create and start the BackgroundScheduler.
    Called from FastAPI @app.on_event("startup").

    Interval is configurable via SCHEDULER_INTERVAL_HOURS (default: 6).
    Timezone is configurable via SCHEDULER_TIMEZONE (default: UTC).
    """
    global _scheduler

    if not APSCHEDULER_AVAILABLE:
        logger.warning("APScheduler not available — skipping automated notifications.")
        return

    if _scheduler and _scheduler.running:
        logger.info("Scheduler already running.")
        return

    interval_hours = float(os.getenv("SCHEDULER_INTERVAL_HOURS", "6"))
    tz_name = os.getenv("SCHEDULER_TIMEZONE", "UTC")

    try:
        from apscheduler.schedulers.background import BackgroundScheduler
        from apscheduler.triggers.interval import IntervalTrigger
        import pytz

        _scheduler = BackgroundScheduler(timezone=pytz.timezone(tz_name))
    except Exception:
        # pytz may not be installed — fall back to UTC string
        _scheduler = BackgroundScheduler(timezone="UTC")

    _scheduler.add_job(
        func=run_notification_job,
        trigger=IntervalTrigger(hours=interval_hours),
        id="femi_notification_engine",
        name="Femi-Friendly AI Notification Engine",
        replace_existing=True,
        misfire_grace_time=300,       # allow up to 5 min late execution
        coalesce=True,                # skip missed runs (don't pile up)
        max_instances=1,              # only one instance at a time
    )

    _scheduler.start()
    logger.info(
        f"Scheduler started — job fires every {interval_hours}h "
        f"(timezone: {tz_name}). Next run: "
        f"{_scheduler.get_job('femi_notification_engine').next_run_time}"
    )

    # Fire immediately on startup so we don't wait the first interval
    try:
        logger.info("Running initial notification sweep on startup…")
        run_notification_job()
    except Exception as exc:
        logger.error(f"Initial notification sweep error: {exc}")


def stop_scheduler() -> None:
    """Gracefully stop the scheduler. Called from FastAPI shutdown event."""
    global _scheduler
    if _scheduler and _scheduler.running:
        _scheduler.shutdown(wait=False)
        logger.info("Scheduler stopped.")
    _scheduler = None


def get_scheduler_status() -> Dict[str, Any]:
    """Return scheduler runtime status — exposed via /scheduler/status endpoint."""
    if not APSCHEDULER_AVAILABLE:
        return {"available": False, "reason": "apscheduler not installed"}
    if not _scheduler:
        return {"available": True, "running": False}

    jobs = []
    for job in _scheduler.get_jobs():
        jobs.append({
            "id": job.id,
            "name": job.name,
            "next_run": str(job.next_run_time) if job.next_run_time else None,
            "trigger": str(job.trigger),
        })

    return {
        "available": True,
        "running": _scheduler.running,
        "jobs": jobs,
        "firebase_ready": _ensure_firebase(),
    }
