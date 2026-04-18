"""Service layer: calls into ai_model.predict and implements recommendation logic."""
from typing import Any, Dict, List, Optional

from ai_model.predict import (
    predict as run_predict,
    predict_all as run_predict_all,
    predict_cycle_length,
    predict_irregularity,
    predict_pregnancy,
)
from ai_model.advanced_models import (
    CycleIntelligenceEngine,
    PersonalizationEngine,
    PregnancyHealthSystem,
    MentalHealthModule,
)
from ai_model.nutrition_engine import NutritionIntelligenceEngine
from ai_model.alert_notification_system import SmartAlertSystem, NotificationScheduler
from ai_model.daily_health_engine import DailyHealthEngine


def predict_cycle(data: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return predict_cycle_length(data)
    except Exception as exc:  # wrap errors for the API layer
        raise RuntimeError(f"Cycle prediction error: {exc}") from exc


def predict_irregular(data: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return predict_irregularity(data)
    except Exception as exc:
        raise RuntimeError(f"Irregularity prediction error: {exc}") from exc


def predict_fertility(data: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return predict_pregnancy(data)
    except Exception as exc:
        raise RuntimeError(f"Fertility prediction error: {exc}") from exc


def predict_all(data: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return run_predict_all(data)
    except Exception as exc:
        raise RuntimeError(f"Unified prediction error: {exc}") from exc


def _calculate_water_intake(weight_kg: Optional[float], exercise_min: Optional[float]) -> Optional[float]:
    """Estimate daily water intake in litres.

    - Base: 35 ml per kg body weight
    - Add ~0.35 L per 30 minutes of moderate exercise
    """
    if weight_kg is None:
        return None
    try:
        base_l = float(weight_kg) * 35.0 / 1000.0
        extra = 0.0
        if exercise_min:
            extra = 0.35 * (float(exercise_min) / 30.0)
        total = round(base_l + extra, 2)
        return total
    except Exception:
        return None


def _food_recommendations_from_symptoms(symptoms: List[str]) -> List[str]:
    recs: List[str] = []
    s_lower = [s.lower() for s in (symptoms or [])]
    if any("cramp" in s or "pain" in s for s in s_lower):
        recs.extend(["Banana", "Ginger", "Yogurt"])
    if any("bloat" in s or "bloating" in s for s in s_lower):
        recs.extend(["Fennel", "Peppermint Tea", "Asparagus"])
    if any("fatigue" in s or "tired" in s for s in s_lower):
        recs.extend(["Spinach", "Oats", "Almonds"])
    if any(
        keyword in s
        for s in s_lower
        for keyword in (
            "pcod",
            "pcos",
            "irregular cycle",
            "acne",
            "weight gain",
            "facial hair",
            "hair thinning",
            "dark neck",
            "sugar craving",
        )
    ):
        recs.extend([
            "Eggs",
            "Greek Yogurt",
            "Lentils",
            "Leafy Greens",
            "Nuts and Seeds",
        ])
    if not recs:
        recs = ["Banana", "Spinach"]
    # de-duplicate while preserving order
    seen = set()
    out = []
    for r in recs:
        if r not in seen:
            seen.add(r)
            out.append(r)
    return out


def _health_tips_from_context(stress: Optional[str], sleep_hours: Optional[float]) -> List[str]:
    tips: List[str] = []
    st = (stress or "").lower()
    if st in ("high", "medium"):
        tips.append("Reduce stress: try mindfulness, short walks, or breathing exercises")
    if sleep_hours is None or (isinstance(sleep_hours, (int, float)) and sleep_hours < 7):
        tips.append("Improve sleep: aim for 7–9 hours and keep a consistent schedule")
    if not tips:
        tips.append("Maintain a balanced diet, regular exercise, and hydration")
    return tips


def _pcod_tips_from_symptoms(symptoms: List[str]) -> List[str]:
    s_lower = [s.lower() for s in (symptoms or [])]
    has_pcod_pattern = any(
        keyword in symptom
        for symptom in s_lower
        for keyword in (
            "pcod",
            "pcos",
            "irregular cycle",
            "acne",
            "weight gain",
            "facial hair",
            "hair thinning",
            "dark neck",
            "pelvic pain",
        )
    )
    if not has_pcod_pattern:
        return []

    return [
        "Possible PCOD-related symptoms logged: track cycle length, acne, hair changes, and weight shifts every month",
        "Exercise most days with a mix of walking, strength training, or yoga to support insulin sensitivity",
        "Choose high-fiber, high-protein meals and reduce sugary drinks or refined snacks",
        "Discuss persistent irregular periods, severe pain, or very heavy bleeding with a gynecologist",
    ]


def recommend(data: Dict[str, Any]) -> Dict[str, Any]:
    """Produce combined prediction + recommendation payload used by the frontend.

    Returns the concrete JSON shape requested by the app:
    {
      "cycle_length": 28,
      "status": "Normal",
      "water_intake": 2.4,
      "food_recommendations": [...],
      "health_tips": [...]
    }
    """
    try:
        model_out = run_predict(data)

        cycle_length = model_out.get("predicted_cycle_length")
        status = model_out.get("cycle_status")

        water = _calculate_water_intake(
            weight_kg=data.get("weight_kg"),
            exercise_min=data.get("exercise_minutes_per_day", 0),
        )

        foods = _food_recommendations_from_symptoms(data.get("symptoms", []))

        tips = _health_tips_from_context(
            stress=data.get("stress_level"),
            sleep_hours=data.get("sleep_hours"),
        )
        tips.extend(_pcod_tips_from_symptoms(data.get("symptoms", [])))
        tips = list(dict.fromkeys(tips))

        return {
            "cycle_length": cycle_length,
            "status": status,
            "water_intake": water,
            "food_recommendations": foods,
            "health_tips": tips,
        }

    except Exception as exc:
        raise RuntimeError(f"Recommendation generation failed: {exc}") from exc


def recommend_products(data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate product recommendations from cycle and pregnancy context."""
    try:
        from api.product_recommendation_service import recommend_products as run_product_recommendation

        return run_product_recommendation(data)
    except Exception as exc:
        raise RuntimeError(f"Product recommendation failed: {exc}") from exc


def _chat_reply_from_prediction(query: str, prediction: Dict[str, Any]) -> Optional[str]:
    q = (query or "").lower()
    if not q:
        return None

    if any(k in q for k in ("pregnan", "fertil", "ovulat", "conceive", "chance")):
        phase = prediction.get("cycle_phase", "Unknown")
        chance = prediction.get("pregnancy_chance", "N/A")
        window = prediction.get("fertility_window", [])
        if isinstance(window, list) and window:
            window_text = f"{window[0]}–{window[-1]}"
        else:
            window_text = "N/A"
        return (
            f"Based on your latest profile, your current phase is {phase}. "
            f"Pregnancy chance is {chance}. Estimated fertile window days: {window_text}. "
            "Track symptoms daily to improve prediction quality."
        )

    if any(k in q for k in ("period", "cycle", "late", "irregular")):
        phase = prediction.get("cycle_phase", "Unknown")
        fertility_prob = prediction.get("fertility_probability")
        prob_text = f"{round(float(fertility_prob) * 100)}%" if fertility_prob is not None else "N/A"
        return (
            f"Current cycle phase: {phase}. Estimated fertility score: {prob_text}. "
            "If your cycle stays irregular for more than 2 consecutive cycles, consult a clinician."
        )

    tips = prediction.get("tips", [])
    if isinstance(tips, list) and tips:
        return f"Here is a personalized tip: {tips[0]}"
    return None


def chat(data: Dict[str, Any]) -> Dict[str, Any]:
    """Return a chat response for the app chatbot."""
    message = str(data.get("message", "")).strip()
    if not message:
        return {"reply": "Please share your question so I can help.", "source": "rule-based"}

    profile = data.get("profile") or {}
    cycle = data.get("cycle") or {}
    merged_payload = {**profile, **cycle}
    prediction = None

    if merged_payload:
        try:
            prediction = run_predict_all(merged_payload)
        except Exception:
            prediction = None

    if prediction:
        reply = _chat_reply_from_prediction(message, prediction)
        if reply:
            return {
                "reply": reply,
                "source": "model-assisted",
                "prediction": prediction,
            }

    q = message.lower()
    if any(k in q for k in ("cramp", "pain")):
        return {
            "reply": (
                "For period cramps: use gentle heat, stay hydrated, and try light stretching. "
                "If pain is severe or unusual, consult a doctor."
            ),
            "source": "rule-based",
        }
    if any(k in q for k in ("food", "diet", "eat")):
        return {
            "reply": (
                "Prioritize iron-rich and anti-inflammatory foods: spinach, lentils, yogurt, "
                "berries, and ginger tea."
            ),
            "source": "rule-based",
        }
    if any(k in q for k in ("sleep", "stress")):
        return {
            "reply": (
                "Aim for 7–9 hours sleep, reduce late caffeine, and use short breathing sessions "
                "to lower stress-related cycle disruption."
            ),
            "source": "rule-based",
        }

    return {
        "reply": (
            "I can help with cycle health, fertility window, pregnancy chance, food, hydration, and cramps. "
            "Tell me your current concern."
        ),
        "source": "rule-based",
    }


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ADVANCED FEATURES: Cycle Intelligence, Nutrition, Pregnancy, Alerts, Notifications
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


def get_cycle_intelligence(data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate intelligent cycle analysis with trend detection and anomaly detection"""
    try:
        engine = CycleIntelligenceEngine()
        cycle_history = data.get("cycle_history", [28])

        irregularity = engine.predict_irregular_patterns(cycle_history)
        hormonal_risk = engine.detect_hormonal_imbalance_risk(data)
        pcos_risk = engine.detect_pcos_risk(data)

        return {
            "irregularity_analysis": irregularity,
            "hormonal_imbalance_risk": hormonal_risk,
            "pcos_risk_assessment": pcos_risk,
            "next_predicted_cycle": engine.time_series.predict_next_cycle()
        }
    except Exception as exc:
        raise RuntimeError(f"Cycle intelligence error: {exc}") from exc


def get_nutrition_plan(data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate personalized daily nutrition plan"""
    try:
        engine = NutritionIntelligenceEngine()

        plan = engine.generate_daily_meal_plan(
            cycle_phase=data.get("cycle_phase"),
            pregnancy_week=data.get("pregnancy_week", 0),
            calories_target=data.get("calories_target", 2000),
            diet_type=data.get("diet_type", "balanced")
        )

        return plan
    except Exception as exc:
        raise RuntimeError(f"Nutrition planning error: {exc}") from exc


def get_fertility_insights(data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate advanced fertility prediction and insights"""
    try:
        engine = PersonalizationEngine(data.get("user_id", "default"))
        engine.build_profile(data)

        fertility_score = engine.estimate_fertility_score(
            data.get("ovulation_day", 14),
            data.get("cycle_length", 28)
        )

        personalized_baseline = engine.calculate_personalized_baseline()

        return {
            "fertility_score": fertility_score,
            "personalized_baseline": personalized_baseline,
            "personalized_recommendations": engine.get_personalized_recommendations(
                data.get("cycle_phase", "follicular")
            ),
            "fertility_window": _calculate_fertility_window(
                data.get("cycle_length", 28),
                data.get("last_period_date")
            ) if "last_period_date" in data else None
        }
    except Exception as exc:
        raise RuntimeError(f"Fertility insights error: {exc}") from exc


def get_pregnancy_insights(data: Dict[str, Any]) -> Dict[str, Any]:
    """Get comprehensive pregnancy health tracking and information"""
    try:
        health_system = PregnancyHealthSystem()
        last_period_date = data.get("last_period_date")

        if last_period_date:
            pregnancy_week = health_system.estimate_pregnancy_week(last_period_date)
        else:
            pregnancy_week = data.get("pregnancy_week", 0)

        trimester_info = health_system.get_trimester_info(pregnancy_week)
        risk_assessment = health_system.detect_pregnancy_risks(data)
        weekly_tips = health_system.get_weekly_pregnancy_tips(pregnancy_week)

        return {
            "pregnancy_week": pregnancy_week,
            "trimester_info": trimester_info,
            "risk_assessment": risk_assessment,
            "weekly_pregnancy_tips": weekly_tips
        }
    except Exception as exc:
        raise RuntimeError(f"Pregnancy insights error: {exc}") from exc


def get_mental_health_status(data: Dict[str, Any]) -> Dict[str, Any]:
    """Track mental health metrics and get wellness suggestions"""
    try:
        module = MentalHealthModule()

        if "mood" in data:
            module.track_mental_health(
                mood=data.get("mood", 5),
                stress=data.get("stress", 5),
                sleep_hours=data.get("sleep_hours", 7)
            )

        wellness_suggestions = module.get_wellness_suggestions(
            mood=data.get("mood", 5),
            stress=data.get("stress", 5)
        )

        health_summary = module.get_mental_health_summary()

        return {
            "current_mood": data.get("mood", 5),
            "current_stress": data.get("stress", 5),
            "current_sleep_hours": data.get("sleep_hours", 7),
            "health_summary": health_summary,
            "wellness_suggestions": wellness_suggestions
        }
    except Exception as exc:
        raise RuntimeError(f"Mental health tracking error: {exc}") from exc


def get_health_alerts(data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate smart health alerts based on user data"""
    try:
        alert_system = SmartAlertSystem()
        alerts = alert_system.generate_all_alerts(data)

        return {
            "alerts": alerts,
            "critical_alerts": [a for a in alerts if a.get("type") == "critical"],
            "warning_alerts": [a for a in alerts if a.get("type") == "warning"],
            "info_alerts": [a for a in alerts if a.get("type") == "info"]
        }
    except Exception as exc:
        raise RuntimeError(f"Alert generation error: {exc}") from exc


def get_notifications(data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate personalized notifications"""
    try:
        scheduler = NotificationScheduler()
        notifications = []

        # Water reminders
        water_notif = scheduler.generate_water_reminders(
            activity_level=data.get("activity_level", "moderate"),
            pregnancy_week=data.get("pregnancy_week", 0),
            time_last_water=data.get("time_last_water_mins", 120)
        )
        if water_notif:
            notifications.append(water_notif)

        # Period reminders
        period_notif = scheduler.generate_period_reminder(
            days_until_period=data.get("days_until_period", 5)
        )
        if period_notif:
            notifications.append(period_notif)

        # Fertility alerts
        fertility_notif = scheduler.generate_fertility_alert(
            days_until_ovulation=data.get("days_until_ovulation", 10),
            fertility_score=data.get("fertility_score", 50),
            trying_to_conceive=data.get("trying_to_conceive", False)
        )
        if fertility_notif:
            notifications.append(fertility_notif)

        # Pregnancy updates
        if data.get("pregnancy_week", 0) > 0:
            preg_notif = scheduler.generate_pregnancy_update(data.get("pregnancy_week", 0))
            if preg_notif:
                notifications.append(preg_notif)

        # Mental health check-in
        if data.get("show_mental_health_checkin", False):
            mh_notif = scheduler.generate_mental_health_check_in()
            notifications.append(mh_notif)

        return {
            "notifications": notifications,
            "total_count": len(notifications)
        }
    except Exception as exc:
        raise RuntimeError(f"Notification generation error: {exc}") from exc


def get_daily_health_recommendations(data: Dict[str, Any]) -> Dict[str, Any]:
    """Generate comprehensive daily health recommendations"""
    try:
        engine = DailyHealthEngine()

        recommendations = engine.generate_daily_recommendations(
            cycle_phase=data.get("cycle_phase"),
            pregnancy_week=data.get("pregnancy_week", 0),
            stress_level=data.get("stress_level", "Medium"),
            sleep_hours=data.get("sleep_hours", 7),
            bmi=data.get("bmi", 22.5),
            activity_level=data.get("activity_level", "Moderate"),
            mood_score=data.get("mood_score", 7)
        )

        return recommendations
    except Exception as exc:
        raise RuntimeError(f"Daily health recommendations error: {exc}") from exc


def _calculate_fertility_window(cycle_length: int, last_period_date: str) -> Optional[List[int]]:
    """Calculate fertility window relative to cycle start"""
    from datetime import datetime, timedelta
    try:
        if not last_period_date:
            return None
        lmp = datetime.strptime(last_period_date, "%Y-%m-%d")
        ovulation_day = cycle_length // 2
        fertile_start = ovulation_day - 5
        fertile_end = ovulation_day + 1
        return list(range(fertile_start, fertile_end + 1))
    except:
        return None


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HEALTH CALCULATOR  (water + nutrition + BMI + pregnancy stage)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def calculate_health(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    One-shot health calculator.

    Water logic:  base = weight_kg × 0.033 L
                  if pregnant: base += 0.7 L
                  if exercise == Heavy:  base += 0.5 L
                  if exercise == Moderate: base += 0.25 L

    Nutrition AI: BMI-based calories + protein/iron/calcium targets,
                  boosted for pregnancy.

    Returns a single flat JSON consumed by the Flutter AI Insights screen.
    """
    try:
        weight = float(data.get("weight_kg", 60))
        height = data.get("height_cm")
        pregnant = bool(data.get("pregnant", False))
        preg_week = int(data.get("pregnancy_week") or 0)
        exercise = str(data.get("exercise") or "Moderate").strip().lower()
        bmi_input = data.get("bmi")

        # ── BMI ──────────────────────────────────────────────────────────────
        if bmi_input:
            bmi = round(float(bmi_input), 1)
        elif height:
            h_m = float(height) / 100.0
            bmi = round(weight / (h_m ** 2), 1)
        else:
            bmi = None

        bmi_label = "N/A"
        if bmi is not None:
            if bmi < 18.5:
                bmi_label = "Underweight"
            elif bmi < 25:
                bmi_label = "Normal"
            elif bmi < 30:
                bmi_label = "Overweight"
            else:
                bmi_label = "Obese"

        # ── Water intake (Litres) ─────────────────────────────────────────────
        water = weight * 0.033
        if pregnant:
            water += 0.7
        if "heavy" in exercise or "intense" in exercise:
            water += 0.5
        elif "moderate" in exercise:
            water += 0.25
        water = round(water, 2)

        # ── Nutrition AI ──────────────────────────────────────────────────────
        if pregnant:
            calories = 2200
            protein_g = 75
            iron_mg = 27
            calcium_mg = 1000
            nutrition_note = "Pregnancy nutrition — boosted for baby growth & maternal health."
        elif bmi is not None and bmi < 18.5:
            calories = 2000
            protein_g = 60
            iron_mg = 18
            calcium_mg = 1000
            nutrition_note = "Underweight — focus on calorie-dense, nutrient-rich foods."
        elif bmi is not None and bmi >= 30:
            calories = 1600
            protein_g = 55
            iron_mg = 18
            calcium_mg = 1000
            nutrition_note = "Aim for a slight caloric deficit with high protein to preserve muscle."
        else:
            calories = 1800
            protein_g = 50
            iron_mg = 18
            calcium_mg = 1000
            nutrition_note = "Balanced daily intake for a healthy woman."

        # Adjust for exercise level
        if "heavy" in exercise or "intense" in exercise:
            calories += 300
            protein_g += 15
        elif "moderate" in exercise:
            calories += 150

        # ── Pregnancy stage ───────────────────────────────────────────────────
        if pregnant and preg_week > 0:
            if preg_week <= 12:
                pregnancy_stage = "First Trimester"
            elif preg_week <= 27:
                pregnancy_stage = "Second Trimester"
            else:
                pregnancy_stage = "Third Trimester"
            days_remaining = max(0, (40 - preg_week) * 7)
        else:
            pregnancy_stage = None
            days_remaining = None

        # ── Phase tips ────────────────────────────────────────────────────────
        cycle_phase = str(data.get("cycle_phase") or "").lower()
        if "men" in cycle_phase or "period" in cycle_phase:
            phase_tip = "Rest, use warmth for cramps, and eat iron-rich foods like leafy greens."
        elif "fol" in cycle_phase:
            phase_tip = "Great time for cardio and trying new activities — energy is building!"
        elif "ovu" in cycle_phase or "fertil" in cycle_phase:
            phase_tip = "Peak fertility & energy — stay active and track your ovulation."
        elif "lut" in cycle_phase:
            phase_tip = "Wind down, prioritise sleep and magnesium-rich foods."
        else:
            phase_tip = "Track your symptoms daily for more personalised advice."

        return {
            "water_liters": water,
            "water_cups": round(water / 0.25),
            "nutrition": {
                "calories": f"{calories} kcal",
                "protein": f"{protein_g}g",
                "iron": f"{iron_mg}mg",
                "calcium": f"{calcium_mg}mg",
                "note": nutrition_note,
            },
            "bmi": bmi,
            "bmi_label": bmi_label,
            "pregnancy_stage": pregnancy_stage,
            "days_remaining": days_remaining,
            "phase_tip": phase_tip,
            "advice": phase_tip,  # alias for frontend compatibility
        }
    except Exception as exc:
        raise RuntimeError(f"Health calculation error: {exc}") from exc

