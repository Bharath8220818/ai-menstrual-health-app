"""
recommendation.py
-----------------
Simple recommendation engine returning food suggestions and tips
based on cycle phase, pregnancy status, stress and sleep.

Public API
  get_recommendations(phase, pregnancy_status, stress, sleep_hours, bmi, pcos, trying_to_conceive)

Returns
  dict { 'food': [...], 'tips': [...] }
"""
from typing import List, Dict


def _unique(seq: List[str]) -> List[str]:
    seen = set()
    out = []
    for s in seq:
        if s not in seen:
            seen.add(s)
            out.append(s)
    return out


def get_recommendations(phase: str,
                        pregnancy_status: str | None = None,
                        stress: str | None = None,
                        sleep_hours: float | None = None,
                        bmi: float | None = None,
                        pcos: str | None = None,
                        trying_to_conceive: bool = False) -> Dict[str, List[str]]:
    food = []
    tips = []

    phase = (phase or "").lower()
    stress = (stress or "").lower()

    # Phase-specific foods
    if phase == "menstrual":
        food += ["Spinach", "Lentils", "Dates", "Red meat (if non-vegetarian)", "Iron-rich cereals"]
        tips += ["Rest and avoid heavy exercise", "Use heat for cramps", "Stay hydrated"]
    elif phase == "follicular":
        food += ["Whole grains", "Leafy greens", "Berries", "Yogurt"]
        tips += ["Light-to-moderate exercise", "Focus on protein for recovery"]
    elif phase == "ovulation":
        food += ["Eggs", "Salmon", "Nuts", "Avocado", "Leafy greens"]
        tips += ["Maintain hydration", "Protein-rich meals support egg maturation"]
    elif phase == "luteal":
        food += ["Complex carbs", "Pumpkin seeds", "Dark chocolate (small amounts)", "Bananas"]
        tips += ["Manage bloating with light exercise", "Prioritise sleep"]
    else:
        food += ["Balanced diet: fruits, vegetables, whole grains, lean protein"]
        tips += ["Maintain balanced diet and regular sleep schedule"]

    # Pregnancy-specific
    if pregnancy_status and pregnancy_status.lower() in ("success", "pregnant", "pregnancy") or trying_to_conceive:
        food += ["Leafy greens", "Citrus fruits (vitamin C)", "Fortified cereals", "Eggs (folate)"]
        tips += ["Take folic acid supplement (400 µg daily)", "Avoid alcohol and limit caffeine"]

    # Stress and sleep adjustments
    if stress in ("high", "medium"):
        tips += ["Practice relaxation (breathing, yoga, meditation)", "Limit stimulants in the evening"]
    if sleep_hours is not None and sleep_hours < 6:
        tips += ["Aim for 7–9 hours sleep; establish regular bedtime"]

    # BMI / PCOS suggestions
    if bmi is not None:
        if bmi < 18.5:
            tips += ["Increase caloric intake with nutrient-dense foods"]
        elif bmi > 25:
            tips += ["Moderate calorie deficit + regular cardio can improve cycle regularity"]
    if pcos and str(pcos).lower() in ("yes", "true", "1"):
        tips += ["Low-glycaemic-index diet recommended for PCOS", "Regular resistance + aerobic exercise"]

    return {
        "food": _unique(food),
        "tips": _unique(tips),
    }
