"""
daily_health_engine.py
=====================
Daily Health Recommendation Engine

Core feature that synthesizes all health data and generates personalized:
  - Food recommendations
  - Water intake targets
  - Exercise suggestions
  - Mental health tips
  - General wellness guidance

Input: Cycle phase, pregnancy status, health metrics
Output: Personalized daily recommendations
"""

from typing import Dict, List, Optional
from datetime import datetime, timedelta
import random


class DailyHealthEngine:
    """
    Central recommendation engine for daily health guidance
    """

    def __init__(self):
        self.recommendations_history = []

    def generate_daily_recommendations(
        self,
        cycle_phase: Optional[str] = None,
        pregnancy_week: int = 0,
        stress_level: str = "Medium",
        sleep_hours: float = 7,
        bmi: float = 22.5,
        activity_level: str = "Moderate",
        mood_score: int = 7  # 1-10
    ) -> Dict:
        """
        Generate comprehensive daily health recommendations
        """
        recommendations = {
            "date": datetime.now().strftime("%Y-%m-%d"),
            "cycle_phase": cycle_phase or "N/A",
            "pregnancy_week": pregnancy_week,
            "recommendations": {}
        }

        # Generate all recommendation categories
        recommendations["recommendations"]["nutrition"] = self._get_nutrition_recommendation(
            cycle_phase, pregnancy_week, bmi
        )

        recommendations["recommendations"]["hydration"] = self._get_hydration_recommendation(
            pregnancy_week, activity_level
        )

        recommendations["recommendations"]["exercise"] = self._get_exercise_recommendation(
            cycle_phase, pregnancy_week, activity_level, stress_level
        )

        recommendations["recommendations"]["mental_health"] = self._get_mental_health_recommendation(
            stress_level, mood_score, sleep_hours
        )

        recommendations["recommendations"]["sleep"] = self._get_sleep_recommendation(
            pregnancy_week, stress_level
        )

        recommendations["recommendations"]["general_tips"] = self._get_general_tips(
            cycle_phase, pregnancy_week, stress_level
        )

        recommendations["wellness_score"] = self._calculate_wellness_score(
            stress_level, sleep_hours, mood_score
        )

        recommendations["priority_focus"] = self._determine_priority_focus(
            cycle_phase, pregnancy_week, stress_level
        )

        return recommendations

    def _get_nutrition_recommendation(
        self,
        cycle_phase: Optional[str],
        pregnancy_week: int,
        bmi: float
    ) -> Dict:
        """Get daily nutrition recommendations"""
        recommendation = {
            "title": "Nutrition",
            "tips": []
        }

        if cycle_phase == "menstrual":
            recommendation["tips"] = [
                "🥩 Iron-rich foods: Red meat, spinach, legumes",
                "🍫 Dark chocolate for magnesium",
                "💪 Protein with every meal for energy",
                "🥛 Calcium sources for cramping support"
            ]
            recommendation["meal_focus"] = "Iron & nutrient-dense"

        elif cycle_phase == "follicular":
            recommendation["tips"] = [
                "🥗 Fresh vegetables and fruits",
                "🌾 Whole grains for stable energy",
                "🥚 Protein-rich breakfast",
                "🍌 Natural carbs for hormone production"
            ]
            recommendation["meal_focus"] = "Light & energizing"

        elif cycle_phase == "ovulation":
            recommendation["tips"] = [
                "💧 Extra hydration (8-10 glasses)",
                "🍓 Antioxidant-rich foods (berries)",
                "🥒 Fermented foods for gut health",
                "🥜 Healthy fats for hormone balance"
            ]
            recommendation["meal_focus"] = "Antioxidant-rich"

        elif cycle_phase == "luteal":
            recommendation["tips"] = [
                "🍫 Magnesium-rich foods (nuts, seeds)",
                "🍠 Complex carbohydrates",
                "🥑 Healthy fats (avocado, olive oil)",
                "🍞 Serotonin-boosting foods"
            ]
            recommendation["meal_focus"] = "Calming & satisfying"

        elif pregnancy_week > 0:
            recommendation["tips"] = [
                f"👶 Week {pregnancy_week}: Extra 300-500 calories needed",
                "🥛 Calcium: Yogurt, cheese, leafy greens",
                "🥩 Protein: Essential for fetal development",
                "🍊 Vitamin C: Citrus, tomatoes, peppers"
            ]
            if pregnancy_week <= 12:
                recommendation["tips"].append("💊 Continue prenatal vitamins")
            recommendation["meal_focus"] = "Nutrient-dense for fetal development"

        else:
            recommendation["tips"] = [
                "🥗 Balanced plate: 1/2 vegetables, 1/4 protein, 1/4 carbs",
                "🥤 Stay hydrated throughout the day",
                "🍎 Include fiber-rich foods",
                "🥜 Don't skip meals"
            ]
            recommendation["meal_focus"] = "Balanced & nourishing"

        # BMI-specific recommendations
        if bmi < 18.5:
            recommendation["tips"].append("⚠️ Consider increasing calorie intake (underweight)")
        elif bmi > 30:
            recommendation["tips"].append("⚠️ Focus on whole foods and portion control (overweight)")

        return recommendation

    def _get_hydration_recommendation(
        self,
        pregnancy_week: int,
        activity_level: str
    ) -> Dict:
        """Get daily hydration recommendations"""
        base_intake = 2000  # ml

        if pregnancy_week > 0:
            base_intake = 2500

        if activity_level == "High":
            base_intake += 500
        elif activity_level == "Low":
            base_intake -= 200

        return {
            "title": "Hydration",
            "daily_target_ml": base_intake,
            "daily_target_glasses": base_intake // 240,
            "tips": [
                f"💧 Aim for {base_intake // 240} glasses of water daily",
                "📍 Drink water with every meal",
                "☕ Limit caffeine (dehydrating)",
                "🏃 Drink extra water after exercise",
                "⏰ Drink first thing in morning"
            ],
            "reminder_frequency": "every 2-3 hours"
        }

    def _get_exercise_recommendation(
        self,
        cycle_phase: Optional[str],
        pregnancy_week: int,
        activity_level: str,
        stress_level: str
    ) -> Dict:
        """Get exercise recommendations"""
        recommendation = {
            "title": "Exercise",
            "tips": []
        }

        if pregnancy_week > 0:
            if pregnancy_week <= 12:
                recommendation["tips"] = [
                    "🚶 Light walking (30 mins)",
                    "🧘 Prenatal yoga recommended",
                    "🏊 Swimming is excellent",
                    "⚠️ Avoid high-impact activities"
                ]
            else:
                recommendation["tips"] = [
                    "🚶 Continue walking daily",
                    "🧘 Modified prenatal exercises",
                    "🏊 Water aerobics excellent",
                    "💪 Pelvic floor exercises important"
                ]
            recommendation["intensity"] = "Light to moderate"

        elif cycle_phase == "menstrual":
            recommendation["tips"] = [
                "🚶 Gentle walk (15-20 mins)",
                "🧘 Restorative yoga",
                "🏊 Water aerobics if no cramping",
                "😴 Consider rest day if heavy flow"
            ]
            recommendation["intensity"] = "Very light"

        elif cycle_phase == "follicular":
            recommendation["tips"] = [
                "🏃 This is your strongest phase!",
                "💪 Weight training recommended",
                "🚴 Cardio: 45 mins",
                "🎯 Peak performance phase"
            ]
            recommendation["intensity"] = "High"

        elif cycle_phase == "ovulation":
            recommendation["tips"] = [
                "🏃 Moderate cardio (30 mins)",
                "💪 Strength training: shorter sessions",
                "🧘 Yoga with dynamic poses",
                "⚠️ Be cautious of overtraining"
            ]
            recommendation["intensity"] = "Moderate to high"

        elif cycle_phase == "luteal":
            recommendation["tips"] = [
                "🚶 Moderate walking (30 mins)",
                "🧘 Yoga with calming poses",
                "🏊 Swimming or water aerobics",
                "💪 Strength training: lighter weights"
            ]
            recommendation["intensity"] = "Moderate"

        else:
            recommendation["tips"] = [
                "🏃 Aim for 150 mins moderate cardio/week",
                "💪 Strength training 2-3x/week",
                "🧘 Flexibility work daily",
                "🎯 Mix variety for best results"
            ]
            recommendation["intensity"] = "Moderate"

        # Stress-based adjustment
        if stress_level == "High":
            recommendation["tips"].append("🧘 Consider calming activities (yoga, tai chi)")

        return recommendation

    def _get_mental_health_recommendation(
        self,
        stress_level: str,
        mood_score: int,
        sleep_hours: float
    ) -> Dict:
        """Get mental health recommendations"""
        recommendation = {
            "title": "Mental Health",
            "tips": []
        }

        if stress_level == "High":
            recommendation["tips"] = [
                "🧘 Meditation: 10-15 mins daily",
                "🌬️ Deep breathing: 5 mins morning & evening",
                "🚶 Nature walk for 20 mins",
                "📝 Journaling to process emotions"
            ]
        elif stress_level == "Medium":
            recommendation["tips"] = [
                "🧘 Meditation: 5-10 mins",
                "🌬️ Breathing exercises when stressed",
                "😊 Do something you enjoy daily",
                "🤝 Connect with friends/family"
            ]
        else:
            recommendation["tips"] = [
                "😊 Continue positive activities",
                "🤝 Maintain social connections",
                "🎯 Keep routines consistent",
                "✨ Practice gratitude daily"
            ]

        if mood_score < 5:
            recommendation["tips"].append("⚠️ Consider talking to someone if low mood persists")
        elif mood_score < 6:
            recommendation["tips"].append("💭 Try mood-boosting activities: music, hobbies")

        if sleep_hours < 6:
            recommendation["tips"].append("😴 Prioritize sleep for mental health recovery")

        recommendation["focus"] = f"Current mood: {mood_score}/10"
        return recommendation

    def _get_sleep_recommendation(
        self,
        pregnancy_week: int,
        stress_level: str
    ) -> Dict:
        """Get sleep recommendations"""
        target_hours = 8

        if pregnancy_week > 0:
            if pregnancy_week <= 12:
                target_hours = 8.5  # Extra rest first trimester
            else:
                target_hours = 9  # More rest later pregnancy

        if stress_level == "High":
            target_hours = 9

        return {
            "title": "Sleep",
            "target_hours": target_hours,
            "tips": [
                f"🛏️ Aim for {target_hours} hours sleep",
                "⏰ Consistent sleep schedule (same time daily)",
                "🌙 Bedroom dark, cool, quiet",
                "📱 No screens 30 mins before bed",
                "☕ No caffeine after 2 PM",
                "🚫 Avoid alcohol before sleep"
            ]
        }

    def _get_general_tips(
        self,
        cycle_phase: Optional[str],
        pregnancy_week: int,
        stress_level: str
    ) -> List[str]:
        """Get general daily tips"""
        tips = []

        if pregnancy_week > 0:
            tips.append(f"👶 Pregnancy week {pregnancy_week}: Prenatal checkup scheduled?")
            tips.append("💊 Remember prenatal vitamins")
            tips.append("🩺 Monitor for warning signs")

        if cycle_phase:
            tips.append(f"📅 Current phase: {cycle_phase}")

        if stress_level == "High":
            tips.append("😌 Remember: Self-care is not selfish")

        tips.extend([
            "✅ Track your health data consistently",
            "🩺 Regular medical checkups important",
            "💬 Don't hesitate to consult healthcare provider",
            "⚠️ This app is for tracking, not diagnosis"
        ])

        return tips

    def _calculate_wellness_score(
        self,
        stress_level: str,
        sleep_hours: float,
        mood_score: int
    ) -> int:
        """Calculate overall wellness score (0-100)"""
        score = 100

        # Stress impact
        if stress_level == "High":
            score -= 20
        elif stress_level == "Medium":
            score -= 10

        # Sleep impact
        if sleep_hours < 6:
            score -= 20
        elif sleep_hours < 7:
            score -= 10
        elif sleep_hours > 9:
            score -= 5

        # Mood impact
        if mood_score < 4:
            score -= 20
        elif mood_score < 6:
            score -= 10
        elif mood_score < 7:
            score -= 5

        return max(0, min(100, score))

    def _determine_priority_focus(
        self,
        cycle_phase: Optional[str],
        pregnancy_week: int,
        stress_level: str
    ) -> str:
        """Determine what to focus on today"""
        if stress_level == "High":
            return "🧘 Stress management & Mental health"

        if pregnancy_week > 0 and pregnancy_week <= 12:
            return "👶 Rest & Prenatal care (1st trimester)"

        if pregnancy_week in range(20, 28):
            return "👶 Nutrition & Fetal development"

        if cycle_phase == "menstrual":
            return "💪 Rest & Nutrition recovery"

        if cycle_phase == "follicular":
            return "🏃 Energy & Activity"

        if cycle_phase == "ovulation":
            return "💧 Hydration & Peak performance"

        if cycle_phase == "luteal":
            return "😴 Rest & Self-care"

        return "⚖️ Balance & Consistency"

    def get_weekly_summary(
        self,
        daily_recommendations_list: List[Dict]
    ) -> Dict:
        """Generate weekly summary from daily recommendations"""
        if not daily_recommendations_list:
            return {"summary": "No data"}

        return {
            "week_summary": {
                "days_tracked": len(daily_recommendations_list),
                "average_wellness_score": sum(
                    d.get("wellness_score", 75) for d in daily_recommendations_list
                ) // len(daily_recommendations_list),
                "key_themes": self._extract_key_themes(daily_recommendations_list),
                "areas_of_focus": self._extract_focus_areas(daily_recommendations_list)
            }
        }

    def _extract_key_themes(self, daily_recommendations_list: List[Dict]) -> List[str]:
        """Extract key themes from week's recommendations"""
        themes = set()
        for day_rec in daily_recommendations_list:
            if day_rec.get("priority_focus"):
                themes.add(day_rec["priority_focus"])
        return list(themes)[:3]

    def _extract_focus_areas(self, daily_recommendations_list: List[Dict]) -> List[str]:
        """Extract main focus areas for improvement"""
        areas = []
        stress_count = sum(1 for d in daily_recommendations_list if d.get("stress_level") == "High")
        if stress_count > 3:
            areas.append("Stress management needs attention")

        wellness_avg = sum(d.get("wellness_score", 75) for d in daily_recommendations_list) / len(daily_recommendations_list)
        if wellness_avg < 60:
            areas.append("Overall wellness below optimal - consider lifestyle adjustments")

        return areas if areas else ["Overall health is good - maintain current routines"]


# Export
__all__ = ["DailyHealthEngine"]
