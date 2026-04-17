"""
advanced_models.py
==================
Advanced AI Models for Intelligent Health Assistant

Features:
  - Time-Series Analysis (LSTM-inspired rolling window)
  - Trend Detection (cycle irregularity patterns)
  - Personalization Engine (user-specific models)
  - Hybrid Intelligence (ML + Rule-based logic)
  - Risk Assessment (PCOS, pregnancy complications, stress impact)
"""

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
from typing import Dict, List, Tuple, Optional
from collections import deque
import warnings

warnings.filterwarnings("ignore")


class TimeSeriesAnalyzer:
    """
    Time-Series Analysis for menstrual cycle trends
    Uses rolling window and trend analysis instead of full LSTM
    """

    def __init__(self, window_size: int = 3):
        self.window_size = window_size
        self.cycle_history = deque(maxlen=12)  # Store last 12 cycles

    def add_cycle_data(self, cycle_length: int):
        """Add cycle length to history"""
        self.cycle_history.append(cycle_length)

    def calculate_trend(self) -> Dict:
        """Calculate trend from cycle history"""
        if len(self.cycle_history) < 2:
            return {
                "trend": "insufficient_data",
                "average": float(self.cycle_history[0]) if self.cycle_history else 0,
                "std_dev": 0,
                "direction": "stable"
            }

        history = list(self.cycle_history)
        avg = np.mean(history)
        std = np.std(history)

        # Detect trend direction (last 3 vs previous 3)
        if len(history) >= 6:
            recent_avg = np.mean(history[-3:])
            previous_avg = np.mean(history[-6:-3])
            direction = "increasing" if recent_avg > previous_avg else "decreasing"
        else:
            direction = "stable"

        return {
            "trend": "stable" if std < 5 else "irregular",
            "average": float(avg),
            "std_dev": float(std),
            "direction": direction,
            "regularity_score": float(max(0, 100 - (std * 10)))  # 0-100
        }

    def predict_next_cycle(self) -> float:
        """Predict next cycle length based on trend"""
        if not self.cycle_history:
            return 28  # Default

        history = list(self.cycle_history)

        # Weighted average (recent cycles weighted more)
        weights = np.linspace(0.5, 1.5, len(history))
        weighted_avg = np.average(history, weights=weights)

        return float(weighted_avg)

    def detect_anomaly(self, cycle_length: int, threshold: float = 2.5) -> bool:
        """Detect anomalous cycle length"""
        if len(self.cycle_history) < 2:
            return False

        avg = np.mean(list(self.cycle_history))
        std = np.std(list(self.cycle_history))

        # Anomaly if more than threshold * std away from mean
        return abs(cycle_length - avg) > (threshold * std)


class PersonalizationEngine:
    """
    Personalization for user-specific predictions
    """

    def __init__(self, user_id: str):
        self.user_id = user_id
        self.profile = {}
        self.preferences = {}
        self.health_history = {}

    def build_profile(self, user_data: Dict) -> None:
        """Build personalized user profile"""
        self.profile = {
            "age": user_data.get("age", 28),
            "bmi": user_data.get("bmi", 22.5),
            "stress_level": user_data.get("stress_level", "Medium"),
            "sleep_quality": user_data.get("sleep_quality", "Good"),
            "activity_level": user_data.get("activity_level", "Moderate"),
            "diet_type": user_data.get("diet_type", "Mixed"),
            "has_pcos": user_data.get("pcos") == "Yes",
            "pregnancy_attempts": user_data.get("trying_months", 0),
        }

    def calculate_personalized_baseline(self) -> Dict:
        """Calculate personalized cycle baseline"""
        base = 28

        # Adjust based on profile
        if self.profile.get("has_pcos"):
            base += 5  # PCOS often leads to longer cycles

        if self.profile.get("stress_level") == "High":
            base += 2  # Stress can lengthen cycles

        if self.profile.get("bmi", 22.5) < 18.5:  # Underweight
            base -= 1

        if self.profile.get("activity_level") == "High":
            base -= 1  # Athletes may have shorter cycles

        return {
            "baseline_cycle": base,
            "expected_range": (base - 3, base + 3)
        }

    def get_personalized_recommendations(self, cycle_phase: str) -> List[str]:
        """Get personalized health recommendations"""
        recommendations = []

        base_recs = {
            "menstrual": ["Rest", "Iron-rich diet", "Hydration"],
            "follicular": ["Exercise", "Social activities", "Protein intake"],
            "ovulation": ["Hydration", "Ward off infections", "Rest after ovulation"],
            "luteal": ["Magnesium", "Complex carbs", "Calming activities"]
        }

        recs = base_recs.get(cycle_phase, [])

        # Personalize based on stress
        if self.profile.get("stress_level") == "High":
            recs.append("Meditation/Yoga")

        # Personalize based on PCOS
        if self.profile.get("has_pcos"):
            recs.append("Low-GI foods")
            recs.append("Regular movement")

        return recs

    def estimate_fertility_score(self, ovulation_day: int, cycle_length: int) -> float:
        """
        Estimate personalized fertility score
        Higher score = better fertility conditions
        """
        score = 100.0

        # Adjust based on BMI
        bmi = self.profile.get("bmi", 22.5)
        if bmi < 18.5 or bmi > 30:
            score -= 15

        # Adjust based on age
        age = self.profile.get("age", 28)
        if age > 35:
            score -= 20
        elif age > 40:
            score -= 40

        # Adjust based on stress
        if self.profile.get("stress_level") == "High":
            score -= 10
        elif self.profile.get("stress_level") == "Medium":
            score -= 5

        # Adjust based on sleep
        if self.profile.get("sleep_quality") != "Good":
            score -= 10

        # Adjust based on PCOS
        if self.profile.get("has_pcos"):
            score -= 20

        # Adjust based on activity
        if self.profile.get("activity_level") == "High":
            score += 5

        return max(0, min(100, score))


class CycleIntelligenceEngine:
    """
    Intelligent cycle prediction and anomaly detection
    """

    def __init__(self):
        self.time_series = TimeSeriesAnalyzer()

    def predict_irregular_patterns(self, cycle_history: List[float]) -> Dict:
        """
        Predict irregular cycle patterns
        """
        if len(cycle_history) < 3:
            return {"pattern": "insufficient_data", "risk_level": "low"}

        mean = np.mean(cycle_history)
        std = np.std(cycle_history)

        # Trend analysis
        if len(cycle_history) >= 6:
            recent_trend = np.polyfit(range(len(cycle_history)), cycle_history, 1)[0]
        else:
            recent_trend = 0

        # Classification
        pattern = "regular" if std < 3 else "irregular" if std < 7 else "highly_irregular"
        risk_level = "low" if std < 5 else "medium" if std < 8 else "high"

        return {
            "pattern": pattern,
            "risk_level": risk_level,
            "average_length": float(mean),
            "variability": float(std),
            "trend": "stable" if abs(recent_trend) < 0.5 else ("lengthening" if recent_trend > 0 else "shortening"),
            "anomaly_count": sum(1 for c in cycle_history if abs(c - mean) > 2 * std)
        }

    def detect_hormonal_imbalance_risk(self, user_data: Dict) -> Dict:
        """
        Detect hormonal imbalance risk using input signals
        """
        risk_score = 0
        risk_factors = []

        # High stress
        if user_data.get("stress_level") == "High":
            risk_score += 20
            risk_factors.append("High stress levels")

        # Sleep issues
        if user_data.get("sleep_quality") in ["Poor", "Very Poor"]:
            risk_score += 15
            risk_factors.append("Poor sleep quality")

        # BMI extremes
        bmi = user_data.get("bmi", 22.5)
        if bmi < 18.5 or bmi > 30:
            risk_score += 15
            risk_factors.append("BMI outside healthy range")

        # Irregular cycles
        cycle_history = user_data.get("cycle_history", [28])
        std = np.std(cycle_history) if len(cycle_history) > 1 else 0
        if std > 5:
            risk_score += 20
            risk_factors.append("Highly irregular cycles")

        # PCOS indication
        if user_data.get("pcos") == "Yes":
            risk_score += 30
            risk_factors.append("PCOS diagnosis")

        # Abnormal bleeding
        if user_data.get("unusual_bleeding"):
            risk_score += 15
            risk_factors.append("Unusual bleeding patterns")

        return {
            "imbalance_risk_score": min(100, risk_score),
            "risk_level": "low" if risk_score < 25 else "medium" if risk_score < 50 else "high",
            "risk_factors": risk_factors,
            "recommendation": self._get_imbalance_recommendation(risk_score)
        }

    def _get_imbalance_recommendation(self, risk_score: int) -> str:
        if risk_score < 25:
            return "Maintain current lifestyle"
        elif risk_score < 50:
            return "Monitor closely and manage stress"
        else:
            return "Consult healthcare provider for hormonal assessment"

    def detect_pcos_risk(self, user_data: Dict) -> Dict:
        """
        Detect PCOS risk based on indicators
        """
        pcos_indicators = 0
        indicators_found = []

        # Already diagnosed
        if user_data.get("pcos") == "Yes":
            return {"pcos_risk": "confirmed", "indicators": ["Already diagnosed"], "recommendation": "Follow PCOS management plan"}

        # Irregular cycles (hallmark of PCOS)
        cycle_history = user_data.get("cycle_history", [28])
        std = np.std(cycle_history) if len(cycle_history) > 1 else 0
        if std > 7 or len([c for c in cycle_history if c > 35]) > len(cycle_history) * 0.3:
            pcos_indicators += 2
            indicators_found.append("Irregular/long cycles")

        # BMI > 25
        if user_data.get("bmi", 22.5) > 25:
            pcos_indicators += 1
            indicators_found.append("Elevated BMI")

        # High stress
        if user_data.get("stress_level") == "High":
            pcos_indicators += 1
            indicators_found.append("High stress")

        # Difficulty conceiving
        if user_data.get("trying_months", 0) > 6:
            pcos_indicators += 1
            indicators_found.append("Difficulty conceiving")

        risk_level = "low" if pcos_indicators < 2 else "medium" if pcos_indicators < 3 else "high"

        return {
            "pcos_risk": risk_level,
            "indicators": indicators_found,
            "indicator_count": pcos_indicators,
            "recommendation": "Consult doctor for PCOS screening" if risk_level in ["medium", "high"] else "Continue monitoring"
        }


class PregnancyHealthSystem:
    """
    Pregnancy health tracking and risk detection
    """

    def __init__(self):
        pass

    def estimate_pregnancy_week(self, last_period_date: str) -> int:
        """Calculate pregnancy week from last period date"""
        try:
            lmp = datetime.strptime(last_period_date, "%Y-%m-%d")
            today = datetime.now()
            days_diff = (today - lmp).days
            week = days_diff // 7
            return min(40, week)  # Cap at 40 weeks
        except:
            return 0

    def get_trimester_info(self, week: int) -> Dict:
        """Get trimester-specific information"""
        if week < 13:
            return {
                "trimester": 1,
                "name": "First Trimester",
                "week": week,
                "focus": ["Early development", "Nausea management", "Prenatal care"],
                "key_milestones": "Organ formation begins"
            }
        elif week < 28:
            return {
                "trimester": 2,
                "name": "Second Trimester",
                "week": week,
                "focus": ["Fetal growth", "Energy boost expected", "Regular checkups"],
                "key_milestones": "Baby movements felt"
            }
        else:
            return {
                "trimester": 3,
                "name": "Third Trimester",
                "week": week,
                "focus": ["Final preparations", "Rest", "Monitor contractions"],
                "key_milestones": "Baby positioning for birth"
            }

    def detect_pregnancy_risks(self, user_data: Dict) -> Dict:
        """
        Detect pregnancy risk factors
        """
        risk_factors = []
        risk_score = 0

        # Age > 35
        if user_data.get("age", 28) > 35:
            risk_factors.append("Advanced maternal age (>35)")
            risk_score += 15

        # Low BMI
        if user_data.get("bmi", 22.5) < 18.5:
            risk_factors.append("Low BMI - nutrition concerns")
            risk_score += 10

        # High BMI
        if user_data.get("bmi", 22.5) > 30:
            risk_factors.append("High BMI - gestational diabetes risk")
            risk_score += 10

        # High stress
        if user_data.get("stress_level") == "High":
            risk_factors.append("High stress levels")
            risk_score += 10

        # Poor sleep
        if user_data.get("sleep_quality") in ["Poor", "Very Poor"]:
            risk_factors.append("Poor sleep quality")
            risk_score += 8

        # History of miscarriage
        if user_data.get("miscarriages", 0) > 0:
            risk_factors.append(f"Previous miscarriage(s)")
            risk_score += 15

        # PCOS
        if user_data.get("pcos") == "Yes":
            risk_factors.append("PCOS - gestational diabetes risk")
            risk_score += 15

        return {
            "risk_score": min(100, risk_score),
            "risk_level": "low" if risk_score < 15 else "medium" if risk_score < 35 else "high",
            "risk_factors": risk_factors,
            "recommendations": self._get_pregnancy_recommendations(risk_score)
        }

    def _get_pregnancy_recommendations(self, risk_score: int) -> List[str]:
        """Get pregnancy recommendations based on risk"""
        recs = [
            "Regular prenatal checkups",
            "Prenatal vitamins (especially folic acid)",
            "Stay hydrated (8-10 glasses/day)"
        ]

        if risk_score > 20:
            recs.append("Stress management (yoga, meditation)")
            recs.append("Regular gentle exercise")

        if risk_score > 35:
            recs.append("Frequent monitoring required")
            recs.append("Consider specialist consultation")

        return recs

    def get_weekly_pregnancy_tips(self, week: int) -> Dict:
        """Get week-specific pregnancy tips"""
        tips_map = {
            (1, 4): {"title": "First Month", "tips": ["Rest", "Prenatal vitamins", "Avoid harmful substances"]},
            (5, 8): {"title": "Early Development", "tips": ["Eat 300 extra calories daily", "Continue prenatal vitamins", "Avoid raw/undercooked foods"]},
            (9, 12): {"title": "First Trimester", "tips": ["Stay hydrated", "Get rest", "Manage nausea"]},
            (13, 16): {"title": "Second Trimester Begins", "tips": ["Energy may increase", "Regular exercise", "Calcium-rich foods"]},
            (20, 24): {"title": "Fetal Movement", "tips": ["Baby kicks noticeable", "Iron-rich diet", "Prepare for childbirth class"]},
            (28, 32): {"title": "Third Trimester", "tips": ["Rest more", "Prepare for labor", "Pelvic floor exercises"]},
            (36, 40): {"title": "Final Weeks", "tips": ["Hospital bag ready", "Watch for labor signs", "Stay calm and prepared"]}
        }

        for range_tuple, content in tips_map.items():
            if range_tuple[0] <= week <= range_tuple[1]:
                return content

        return {"title": "General", "tips": ["Regular checkups", "Healthy diet", "Adequate rest"]}


class MentalHealthModule:
    """
    Mental health tracking and recommendations
    """

    def __init__(self):
        self.mood_history = deque(maxlen=30)  # Last 30 days
        self.stress_history = deque(maxlen=30)
        self.sleep_history = deque(maxlen=30)

    def track_mental_health(self, mood: int, stress: int, sleep_hours: float):
        """Track daily mental health metrics (1-10 scale)"""
        self.mood_history.append(mood)
        self.stress_history.append(stress)
        self.sleep_history.append(sleep_hours)

    def get_mental_health_summary(self) -> Dict:
        """Get mental health summary"""
        if not self.mood_history:
            return {"status": "No data"}

        return {
            "average_mood": float(np.mean(list(self.mood_history))),
            "average_stress": float(np.mean(list(self.stress_history))),
            "average_sleep": float(np.mean(list(self.sleep_history))),
            "mood_trend": self._get_trend(list(self.mood_history)),
            "stress_trend": self._get_trend(list(self.stress_history))
        }

    def get_wellness_suggestions(self, mood: int, stress: int) -> List[str]:
        """Get personalized wellness suggestions"""
        suggestions = []

        if mood < 5:
            suggestions.extend([
                "Practice deep breathing (5-10 mins)",
                "Go for a walk in nature",
                "Connect with loved ones",
                "Engage in hobby you enjoy"
            ])

        if stress > 7:
            suggestions.extend([
                "Meditation (10 mins)",
                "Progressive muscle relaxation",
                "Yoga for stress relief",
                "Chamomile tea or herbal drink"
            ])

        if not suggestions:
            suggestions.extend([
                "Continue current wellness routine",
                "Stay active with light exercise",
                "Maintain healthy sleep schedule"
            ])

        return suggestions

    def _get_trend(self, data: List[float]) -> str:
        """Get trend direction"""
        if len(data) < 5:
            return "insufficient_data"
        recent = np.mean(data[-5:])
        previous = np.mean(data[-10:-5]) if len(data) >= 10 else np.mean(data[:-5])
        return "improving" if recent > previous else "declining" if recent < previous else "stable"


# Export all engine classes
__all__ = [
    "TimeSeriesAnalyzer",
    "PersonalizationEngine",
    "CycleIntelligenceEngine",
    "PregnancyHealthSystem",
    "MentalHealthModule"
]
