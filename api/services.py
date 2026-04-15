"""Service layer: calls into ai_model.predict and implements recommendation logic."""
from typing import Any, Dict, List, Optional

from ai_model import predict as predictor


def predict_cycle(data: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return predictor.predict_cycle_length(data)
    except Exception as exc:  # wrap errors for the API layer
        raise RuntimeError(f"Cycle prediction error: {exc}") from exc


def predict_irregular(data: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return predictor.predict_irregularity(data)
    except Exception as exc:
        raise RuntimeError(f"Irregularity prediction error: {exc}") from exc


def predict_fertility(data: Dict[str, Any]) -> Dict[str, Any]:
    try:
        return predictor.predict_pregnancy(data)
    except Exception as exc:
        raise RuntimeError(f"Fertility prediction error: {exc}") from exc


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
        model_out = predictor.predict(data)

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
