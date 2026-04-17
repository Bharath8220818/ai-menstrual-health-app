"""
predict.py
==========
Menstrual Health AI Pipeline — Prediction & Recommendation Engine

This module loads the pre-trained model bundle (model.pkl) and exposes:

  predict(user_input: dict) → dict
      Primary public function. Accepts raw user data and returns:
        - predicted_cycle_length   : float  (days)
        - cycle_status             : str    ("Regular" | "Irregular")
        - irregularity_probability : float  (0–1)
        - pregnancy_likelihood     : str    ("Success" | "Failure" | "N/A")
        - pregnancy_probability    : float  (0–1, if applicable)
        - recommendations          : list[str]

Usage (standalone)
------------------
    python ai_model/predict.py

Usage (from API / Flutter backend)
-----------------------------------
    from ai_model.predict import predict
    result = predict({
        "age"          : 28,
        "bmi"          : 22.5,
        "cycle_length" : 28,        # most recent cycle length in days
        "menses_length": 5,         # period duration
        "total_high_days": 6,       # high-fertility days
        "luteal_phase" : 13,
        "intercourse_fertile": 1,   # 0 or 1
        "unusual_bleeding": 0,      # 0 or 1
        "num_pregnancies": 0,
        "miscarriages" : 0,
        # Optional fertility-related fields (used only if trying_to_conceive=True)
        "trying_to_conceive": False,
        "pcos"         : "No",      # "Yes" / "No"
        "stress_level" : "Low",     # "Low" / "Medium" / "High"
        "smoking"      : "No",
        "alcohol"      : "Never",   # "Never" / "Occasionally" / "Regularly"
        "trying_months": 0,
    })
"""

import os
import sys
import warnings
import numpy as np
import joblib

warnings.filterwarnings("ignore")

# ── ensure project root is on the path ────────────────────────────────────────
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# ──────────────────────────────────────────────────────────────────────────────
# MODEL PATH
# ──────────────────────────────────────────────────────────────────────────────
MODEL_PKL = os.path.join(os.path.dirname(os.path.abspath(__file__)), "model.pkl")

# ── Lazy-loaded bundle (loaded once per process) ──────────────────────────────
_BUNDLE: dict | None = None

# recommendation engine (separate module)
from ai_model.recommendation import get_recommendations


def _load_bundle() -> dict:
    """Load model.pkl once and cache in module-level variable."""
    global _BUNDLE
    if _BUNDLE is None:
        if not os.path.exists(MODEL_PKL):
            raise FileNotFoundError(
                f"model.pkl not found at {MODEL_PKL}.\n"
                "Run `python ai_model/train.py` first."
            )
        _BUNDLE = joblib.load(MODEL_PKL)
        # Some Windows environments restrict multiprocessing handles.
        # Force single-thread inference to keep prediction endpoints stable.
        for key in ("cycle_length_model", "irregularity_model", "pregnancy_model"):
            model = _BUNDLE.get(key)
            if model is not None and hasattr(model, "n_jobs"):
                try:
                    model.n_jobs = 1
                except Exception:
                    pass
        print("[predict] Model bundle loaded successfully.")
    return _BUNDLE


# ──────────────────────────────────────────────────────────────────────────────
# INPUT DEFAULTS & VALIDATION
# ──────────────────────────────────────────────────────────────────────────────
_DEFAULTS = {
    "age"                 : 28,
    "bmi"                 : 22.5,
    "cycle_length"        : 28,
    "menses_length"       : 5,
    "mean_cycle_length"   : 28,
    "mean_menses_length"  : 5,
    "mean_bleeding"       : 2,
    "total_menses_score"  : 10,
    "luteal_phase"        : 13,
    "estimated_ovulation" : 15,
    "total_high_days"     : 5,
    "total_peak_days"     : 2,
    "total_fertility_days": 7,
    "num_intercourse"     : 4,
    "intercourse_fertile" : 1,
    "unusual_bleeding"    : 0,
    "cycle_with_peak"     : 1,
    "reproductive_cat"    : 1,
    "num_pregnancies"     : 0,
    "miscarriages"        : 0,
    "abortions"           : 0,
    # Fertility-specific
    "trying_to_conceive"  : False,
    "male_age"            : 30,
    "menstrual_regularity": "Regular",
    "pcos"                : "No",
    "stress_level"        : "Low",
    "smoking"             : "No",
    "alcohol"             : "Never",
    "sperm_count"         : 20.0,
    "motility"            : 50.0,
    "trying_months"       : 0,
    "treatment_type"      : "Unknown",
}

# Maps user-friendly input keys → FedCycle feature names (Model 1 & 2)
_CYCLE_COL_MAP = {
    "age"                 : "Age",
    "bmi"                 : "BMI",
    "cycle_length"        : "LengthofCycle",
    "menses_length"       : "LengthofMenses",
    "mean_cycle_length"   : "MeanCycleLength",
    "mean_menses_length"  : "MeanMensesLength",
    "mean_bleeding"       : "MeanBleedingIntensity",
    "total_menses_score"  : "TotalMensesScore",
    "luteal_phase"        : "LengthofLutealPhase",
    "estimated_ovulation" : "EstimatedDayofOvulation",
    "total_high_days"     : "TotalNumberofHighDays",
    "total_peak_days"     : "TotalNumberofPeakDays",
    "total_fertility_days": "TotalDaysofFertility",
    "num_intercourse"     : "NumberofDaysofIntercourse",
    "intercourse_fertile" : "IntercourseInFertileWindow",
    "unusual_bleeding"    : "UnusualBleeding",
    "cycle_with_peak"     : "CycleWithPeakorNot",
    "reproductive_cat"    : "ReproductiveCategory",
    "num_pregnancies"     : "Numberpreg",
    "miscarriages"        : "Miscarriages",
    "abortions"           : "Abortions",
}

# Maps user-friendly input keys → Fertility dataset feature names (Model 3)
_FERTILITY_COL_MAP = {
    "age"                 : "Female_Age",
    "male_age"            : "Male_Age",
    "bmi"                 : "BMI",
    "menstrual_regularity": "Menstrual_Regularity",
    "pcos"                : "PCOS",
    "stress_level"        : "Stress_Level",
    "smoking"             : "Smoking",
    "alcohol"             : "Alcohol_Intake",
    "sperm_count"         : "Sperm_Count_Million_per_ml",
    "motility"            : "Motility_%",
    "trying_months"       : "Trying_Duration_Months",
    "treatment_type"      : "Treatment_Type",
}


# ──────────────────────────────────────────────────────────────────────────────
# FEATURE VECTOR BUILDERS
# ──────────────────────────────────────────────────────────────────────────────
def _build_cycle_vector(inp: dict, feature_names: list[str]) -> np.ndarray:
    """
    Build a 1-D feature array for the cycle length / irregularity models.
    feature_names is the ordered list stored in the bundle.
    """
    # Map from FedCycle column name → value
    col_to_val: dict[str, float] = {}
    for user_key, fed_col in _CYCLE_COL_MAP.items():
        col_to_val[fed_col] = float(inp.get(user_key, _DEFAULTS[user_key]))

    vec = np.array([col_to_val.get(col, 0.0) for col in feature_names],
                   dtype=np.float32)
    return vec.reshape(1, -1)


def _build_fertility_vector(inp: dict, bundle: dict) -> np.ndarray | None:
    """
    Build a 1-D feature array for the pregnancy outcome model.
    Returns None if fertility data is not applicable.
    """
    fc         = bundle["feature_cols"]["pregnancy_outcome"]
    feat_names = fc["features"]
    le_dict    = bundle["label_encoders"]
    scaler     = bundle["scalers"].get("fertility_scaler")

    # Build a raw row dict
    raw: dict[str, object] = {}
    for user_key, fert_col in _FERTILITY_COL_MAP.items():
        raw[fert_col] = inp.get(user_key, _DEFAULTS[user_key])

    # Encode categorical values using the saved LabelEncoders
    cat_map = {
        "Menstrual_Regularity": "menstrual_regularity",
        "PCOS"                : "pcos",
        "Stress_Level"        : "stress_level",
        "Smoking"             : "smoking",
        "Alcohol_Intake"      : "alcohol",
        "Treatment_Type"      : "treatment_type",
    }
    for col, _ in cat_map.items():
        le = le_dict.get(col)
        if le:
            val = str(raw.get(col, "Unknown"))
            # Handle unseen labels gracefully
            if val not in le.classes_:
                val = le.classes_[0]
            raw[col] = float(le.transform([val])[0])
        else:
            raw[col] = 0.0

    # Assemble the feature vector in the correct column order
    num_vec = np.array(
        [float(raw.get(col, 0.0)) for col in feat_names],
        dtype=np.float32
    ).reshape(1, -1)

    # Apply the scaler (only on numeric columns — identify by type mismatch)
    # The scaler was fit on numeric cols only, so we pass the full vec
    # (categorical ones are already encoded to float).
    if scaler is not None:
        # The scaler was fit on ALL numeric cols of fertility_df (post-encode).
        # We constructed the same order (feat_names), so direct transform works.
        try:
            num_vec = scaler.transform(num_vec)
        except Exception:
            pass  # fallback: use raw values

    return num_vec


# ──────────────────────────────────────────────────────────────────────────────
# RECOMMENDATION ENGINE
# ──────────────────────────────────────────────────────────────────────────────
def _generate_recommendations(inp: dict,
                               predicted_length: float,
                               is_irregular: bool,
                               irr_prob: float) -> list[str]:
    """
    Rule-based + ML-driven recommendations based on predictions and user data.

    Rules cover:
      - Cycle regularity
      - BMI-related advice
      - Stress management
      - Lifestyle (smoking, alcohol, exercise)
      - Fertility (if trying to conceive)
    """
    recs: list[str] = []
    bmi            = float(inp.get("bmi", _DEFAULTS["bmi"]))
    age            = int(inp.get("age", _DEFAULTS["age"]))
    unusual_bleed  = int(inp.get("unusual_bleeding", 0))
    try_conceive   = bool(inp.get("trying_to_conceive", False))
    stress         = str(inp.get("stress_level", "Low")).lower()
    smoking        = str(inp.get("smoking", "No")).lower()
    alcohol        = str(inp.get("alcohol", "Never")).lower()
    pcos           = str(inp.get("pcos", "No")).lower()

    # ── Cycle regularity ──────────────────────────────────────────────────────
    if is_irregular:
        recs.append(
            f"⚠️  Your cycle is predicted to be irregular "
            f"(probability: {irr_prob:.0%}). "
            "Consult a gynaecologist if irregularity persists beyond 2 cycles."
        )
        if irr_prob > 0.7:
            recs.append(
                "📋 Consider tracking your cycle daily with this app for at "
                "least 3 months to establish a pattern before a clinical visit."
            )
    else:
        recs.append(
            f"✅ Your cycle is predicted to be regular "
            f"(~{predicted_length:.0f} days). Keep up your current healthy habits!"
        )

    # ── Cycle length extremes ────────────────────────────────────────────────
    if predicted_length < 21:
        recs.append(
            "🔴 A predicted cycle length under 21 days (polymenorrhoea) may "
            "indicate hormonal imbalance. Please seek medical advice."
        )
    elif predicted_length > 35:
        recs.append(
            "🔴 A predicted cycle length over 35 days (oligomenorrhoea) may "
            "signal conditions like PCOS or thyroid issues. Medical review recommended."
        )

    # ── Unusual bleeding ─────────────────────────────────────────────────────
    if unusual_bleed:
        recs.append(
            "🩸 Unusual bleeding between periods detected. Track timing, "
            "duration and volume. Report to your doctor if it recurs."
        )

    # ── BMI ──────────────────────────────────────────────────────────────────
    if bmi < 18.5:
        recs.append(
            "⚖️  Low BMI (<18.5) can disrupt hormonal balance and stop "
            "ovulation. Aim for a nutrient-rich, calorie-adequate diet."
        )
    elif bmi > 25:
        recs.append(
            "⚖️  BMI above 25 is associated with higher rates of irregular "
            "cycles. Regular aerobic exercise (30 min/day) and a balanced "
            "diet can help restore cycle regularity."
        )

    # ── PCOS ─────────────────────────────────────────────────────────────────
    if pcos in ("yes", "1", "true"):
        recs.append(
            "🔬 PCOS detected. Low-glycaemic-index diet, regular exercise, "
            "and stress reduction are first-line lifestyle interventions. "
            "Discuss hormonal therapy options with your doctor."
        )

    # ── Stress ───────────────────────────────────────────────────────────────
    if stress in ("high", "medium"):
        recs.append(
            "🧘 Elevated stress can delay or suppress ovulation. Incorporate "
            "mindfulness, yoga, or breathing exercises into your daily routine."
        )

    # ── Smoking ──────────────────────────────────────────────────────────────
    if smoking not in ("no", "never", "0"):
        recs.append(
            "🚭 Smoking is linked to earlier menopause and reduced fertility. "
            "Consider a smoking-cessation programme."
        )

    # ── Alcohol ──────────────────────────────────────────────────────────────
    if alcohol in ("regularly", "occasional", "occasionally"):
        recs.append(
            "🍷 Alcohol disrupts hormonal regulation. Limit to ≤1 unit/day "
            "and avoid alcohol entirely if trying to conceive."
        )

    # ── Age-specific ─────────────────────────────────────────────────────────
    if age > 35 and try_conceive:
        recs.append(
            "⏱️  Age >35 reduces egg reserve. If trying to conceive, seek a "
            "fertility specialist review early rather than waiting 12 months."
        )

    # ── Fertility ────────────────────────────────────────────────────────────
    if try_conceive:
        recs.append(
            "💊 While trying to conceive, take a daily prenatal supplement "
            "with folic acid (400 µg), vitamin D, and omega-3."
        )
        recs.append(
            "📅 Track your fertile window: ovulation typically occurs "
            "~14 days before your next period. Use LH strips for accuracy."
        )

    # Ensure at least one general recommendation
    if not recs:
        recs.append(
            "✅ No specific concerns detected. Maintain a balanced diet, "
            "regular exercise, and adequate sleep to support hormonal health."
        )

    return recs


def detect_cycle_phase(cycle_day: int) -> str:
    """Return cycle phase given the 1-based cycle day."""
    try:
        d = int(cycle_day)
    except Exception:
        return "Unknown"
    if d <= 5:
        return "Menstrual"
    if d <= 13:
        return "Follicular"
    if d <= 16:
        return "Ovulation"
    return "Luteal"


def fertility_window(cycle_length: int) -> dict:
    """Calculate ovulation day and fertility window.

    Returns dict with keys:
      - ovulation_day (int)
      - best_days (list[int])
      - fertility_score (float)  # heuristic 0..1 representing peak chance
    """
    try:
        cl = int(cycle_length)
    except Exception:
        cl = 28
    ovulation_day = max(10, cl - 14)
    start = max(1, ovulation_day - 2)
    end = min(cl, ovulation_day + 2)
    best_days = list(range(start, end + 1))
    # Simple heuristic: peak probability on ovulation day
    fertility_score = 0.9
    return {"ovulation_day": ovulation_day, "best_days": best_days, "fertility_score": fertility_score}


def predict_all(user_input: dict) -> dict:
    """
    Unified prediction function requested by the project spec.

    Returns JSON-like dict with keys:
      - pregnancy_chance: "High"/"Medium"/"Low"/"N/A"
      - fertility_window: list[int]
      - fertility_probability: float
      - cycle_phase: str
      - food: list[str]
      - tips: list[str]
    """
    # Base predictions from existing pipeline
    res = predict(user_input)

    # Fertility window calculation
    cycle_length = int(user_input.get("cycle_length", user_input.get("mean_cycle_length", 28)))
    fw = fertility_window(cycle_length)

    # Cycle phase detection — prefer explicit `cycle_day` if provided
    cycle_day = int(user_input.get("cycle_day", 1))
    phase = detect_cycle_phase(cycle_day)

    # Pregnancy chance string
    preg_prob = res.get("pregnancy_probability")
    if preg_prob is None:
        preg_str = "N/A"
    else:
        if preg_prob >= 0.66:
            preg_str = "High"
        elif preg_prob >= 0.34:
            preg_str = "Medium"
        else:
            preg_str = "Low"

    # Recommendation engine returns food + tips
    recs = get_recommendations(
        phase=phase,
        pregnancy_status=res.get("pregnancy_likelihood"),
        stress=user_input.get("stress_level"),
        sleep_hours=user_input.get("sleep_hours"),
        bmi=user_input.get("bmi"),
        pcos=user_input.get("pcos"),
        trying_to_conceive=bool(user_input.get("trying_to_conceive", False)),
    )

    return {
        "pregnancy_chance": preg_str,
        "pregnancy_probability": preg_prob,
        "fertility_window": fw["best_days"],
        "fertility_probability": fw["fertility_score"],
        "cycle_phase": phase,
        "food": recs.get("food", []),
        "tips": recs.get("tips", []),
        "raw": res,
    }


# ──────────────────────────────────────────────────────────────────────────────
# PUBLIC API
# ──────────────────────────────────────────────────────────────────────────────
def predict(user_input: dict) -> dict:
    """
    Run inference on user input and return structured predictions +
    personalised recommendations.

    Parameters
    ----------
    user_input : dict
        Keys (all optional — defaults are used for missing keys):
          age, bmi, cycle_length, menses_length, mean_cycle_length,
          mean_menses_length, mean_bleeding, total_menses_score,
          luteal_phase, estimated_ovulation, total_high_days, total_peak_days,
          total_fertility_days, num_intercourse, intercourse_fertile,
          unusual_bleeding, cycle_with_peak, reproductive_cat,
          num_pregnancies, miscarriages, abortions,
          trying_to_conceive (bool),
          male_age, menstrual_regularity, pcos, stress_level,
          smoking, alcohol, sperm_count, motility,
          trying_months, treatment_type

    Returns
    -------
    dict with keys:
        predicted_cycle_length   : float
        cycle_status             : str   ("Regular" | "Irregular")
        irregularity_probability : float (0.0 – 1.0)
        pregnancy_likelihood     : str   ("Success" | "Failure" | "N/A")
        pregnancy_probability    : float (0.0 – 1.0, or None)
        recommendations          : list[str]
    """
    bundle = _load_bundle()

    # ── MODEL 1: Cycle Length Regression ──────────────────────────────────────
    cycle_fc       = bundle["feature_cols"]["cycle_length"]
    cycle_vec      = _build_cycle_vector(user_input, cycle_fc["features"])
    predicted_len  = float(bundle["cycle_length_model"].predict(cycle_vec)[0])
    predicted_len  = max(15.0, min(60.0, predicted_len))   # physiological clip

    # ── MODEL 2: Irregularity Classification ──────────────────────────────────
    irr_fc         = bundle["feature_cols"]["irregularity"]
    irr_vec        = _build_cycle_vector(user_input, irr_fc["features"])
    irr_pred       = int(bundle["irregularity_model"].predict(irr_vec)[0])
    irr_prob       = float(
        bundle["irregularity_model"].predict_proba(irr_vec)[0][1]
    )
    cycle_status   = "Irregular" if irr_pred == 1 else "Regular"

    # ── MODEL 3: Pregnancy Outcome (only if trying to conceive) ───────────────
    preg_likelihood = "N/A"
    preg_prob       = None

    if user_input.get("trying_to_conceive", False):
        fert_vec = _build_fertility_vector(user_input, bundle)
        if fert_vec is not None:
            preg_pred   = int(bundle["pregnancy_model"].predict(fert_vec)[0])
            preg_prob   = float(
                bundle["pregnancy_model"].predict_proba(fert_vec)[0][1]
            )
            # Decode using saved LabelEncoder
            le_preg = bundle["label_encoders"].get("Pregnancy_Outcome")
            if le_preg:
                preg_likelihood = str(le_preg.inverse_transform([preg_pred])[0])
            else:
                preg_likelihood = "Success" if preg_pred == 1 else "Failure"

    # ── Recommendations ───────────────────────────────────────────────────────
    recommendations = _generate_recommendations(
        inp            = user_input,
        predicted_length = predicted_len,
        is_irregular   = (irr_pred == 1),
        irr_prob       = irr_prob,
    )

    return {
        "predicted_cycle_length"  : round(predicted_len, 1),
        "cycle_status"            : cycle_status,
        "irregularity_probability": round(irr_prob, 4),
        "pregnancy_likelihood"    : preg_likelihood,
        "pregnancy_probability"   : round(preg_prob, 4) if preg_prob is not None else None,
        "recommendations"         : recommendations,
    }


# ---------------------------------------------------------------------------
# Convenience wrappers requested by the API spec
# ---------------------------------------------------------------------------
def predict_cycle_length(user_input: dict) -> dict:
    """Return only cycle length prediction and basic status.

    This wrapper uses the unified `predict` function and extracts the
    cycle-related fields. It keeps behaviour predictable even if models
    are stored as a single bundle (model.pkl) or as separate files.
    """
    res = predict(user_input)
    return {
        "cycle_length": res["predicted_cycle_length"],
        "status": res["cycle_status"],
    }


def predict_irregularity(user_input: dict) -> dict:
    """Return irregularity classification and probability."""
    res = predict(user_input)
    return {
        "is_irregular": res["cycle_status"] == "Irregular",
        "probability": res["irregularity_probability"],
    }


def predict_pregnancy(user_input: dict) -> dict:
    """Return pregnancy likelihood and probability (or N/A).

    If `trying_to_conceive` is not True, this returns N/A.
    """
    res = predict(user_input)
    return {
        "likelihood": res.get("pregnancy_likelihood", "N/A"),
        "probability": res.get("pregnancy_probability"),
    }


# ──────────────────────────────────────────────────────────────────────────────
# DEMO — standalone test run
# ──────────────────────────────────────────────────────────────────────────────
def _demo() -> None:
    """Run two example predictions and pretty-print the results."""

    examples = [
        {
            "label": "Regular 28-year-old, not trying to conceive",
            "data" : {
                "age"                 : 28,
                "bmi"                 : 22.5,
                "cycle_length"        : 28,
                "menses_length"       : 5,
                "luteal_phase"        : 14,
                "total_high_days"     : 6,
                "intercourse_fertile" : 1,
                "unusual_bleeding"    : 0,
                "num_pregnancies"     : 0,
                "miscarriages"        : 0,
                "pcos"                : "No",
                "stress_level"        : "Low",
                "smoking"             : "No",
                "alcohol"             : "Never",
                "trying_to_conceive"  : False,
            },
        },
        {
            "label": "36-year-old with PCOS, trying to conceive",
            "data" : {
                "age"                 : 36,
                "bmi"                 : 27.3,
                "cycle_length"        : 42,
                "menses_length"       : 7,
                "luteal_phase"        : 10,
                "total_high_days"     : 3,
                "intercourse_fertile" : 1,
                "unusual_bleeding"    : 1,
                "num_pregnancies"     : 1,
                "miscarriages"        : 1,
                "pcos"                : "Yes",
                "stress_level"        : "High",
                "smoking"             : "No",
                "alcohol"             : "Occasionally",
                "trying_to_conceive"  : True,
                "male_age"            : 38,
                "sperm_count"         : 15.0,
                "motility"            : 42.0,
                "trying_months"       : 18,
                "menstrual_regularity": "Irregular",
                "treatment_type"      : "IVF",
            },
        },
    ]

    print("\n" + "=" * 60)
    print("  PREDICT.PY — DEMO MODE")
    print("=" * 60)

    for ex in examples:
        print(f"\n{'─'*60}")
        print(f"  Case: {ex['label']}")
        print(f"{'─'*60}")
        result = predict(ex["data"])
        print(f"  Predicted Cycle Length   : {result['predicted_cycle_length']} days")
        print(f"  Cycle Status             : {result['cycle_status']}")
        print(f"  Irregularity Probability : {result['irregularity_probability']:.2%}")
        print(f"  Pregnancy Likelihood     : {result['pregnancy_likelihood']}")
        if result["pregnancy_probability"] is not None:
            print(f"  Pregnancy Probability    : {result['pregnancy_probability']:.2%}")
        print("\n  Recommendations:")
        for i, rec in enumerate(result["recommendations"], 1):
            print(f"    {i}. {rec}")

    print("\n" + "=" * 60)


if __name__ == "__main__":
    _demo()
