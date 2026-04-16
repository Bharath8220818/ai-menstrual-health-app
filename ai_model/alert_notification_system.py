"""
alert_notification_system.py
=============================
Smart Alert & Real-time Notification System

Features:
  - Health alerts (missed period, abnormal bleeding, severe pain)
  - Periodic notifications (water reminders, fertility alerts, period reminders)
  - Pregnancy updates
  - Smart scheduling based on user activity
"""

from typing import Dict, List, Optional
from datetime import datetime, timedelta
from enum import Enum
import json


class AlertType(Enum):
    CRITICAL = "critical"
    WARNING = "warning"
    INFO = "info"


class NotificationType(Enum):
    WATER = "water"
    PERIOD = "period"
    FERTILITY = "fertility"
    PREGNANCY = "pregnancy"
    MEDICATION = "medication"
    EXERCISE = "exercise"
    MENTAL_HEALTH = "mental_health"


class SmartAlertSystem:
    """
    Intelligent alert generation for health warnings
    """

    def __init__(self):
        self.active_alerts = []
        self.alert_history = []

    def check_missed_period_alert(
        self,
        last_period_date: str,
        cycle_length: int,
        days_missed: int
    ) -> Optional[Dict]:
        """
        Check for missed period alert
        Trigger if > 7 days overdue
        """
        if days_missed > 7:
            alert = {
                "type": AlertType.WARNING.value,
                "title": f"Period overdue by {days_missed} days",
                "message": f"Your period is {days_missed} days late. Consider taking a pregnancy test or consulting your doctor.",
                "severity": "high" if days_missed > 14 else "medium",
                "actions": [
                    {"action": "take_pregnancy_test", "label": "Take Pregnancy Test"},
                    {"action": "consult_doctor", "label": "Consult Doctor"},
                    {"action": "log_symptoms", "label": "Log Symptoms"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        elif days_missed > 3:
            alert = {
                "type": AlertType.INFO.value,
                "title": "Period slightly delayed",
                "message": f"Your period is {days_missed} days late. This can be normal, but monitor closely.",
                "severity": "low",
                "actions": [
                    {"action": "log_symptoms", "label": "Log Symptoms"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        return None

    def check_abnormal_bleeding_alert(
        self,
        flow_level: str,
        duration_days: int,
        normal_duration: int = 5
    ) -> Optional[Dict]:
        """
        Check for abnormal bleeding alert
        """
        if flow_level == "Heavy" and duration_days > normal_duration + 3:
            alert = {
                "type": AlertType.WARNING.value,
                "title": "Heavy prolonged menstrual bleeding",
                "message": f"You've experienced heavy bleeding for {duration_days} days. Consult your doctor to rule out complications.",
                "severity": "high",
                "actions": [
                    {"action": "consult_doctor", "label": "Consult Doctor"},
                    {"action": "track_symptoms", "label": "Track Symptoms"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        elif flow_level == "Very Heavy":
            alert = {
                "type": AlertType.CRITICAL.value,
                "title": "⚠️ Severe menstrual bleeding",
                "message": "Very heavy bleeding detected. Seek medical attention if accompanied by dizziness or weakness.",
                "severity": "critical",
                "actions": [
                    {"action": "seek_emergency", "label": "Seek Medical Help"},
                    {"action": "consult_doctor", "label": "Call Doctor"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        elif flow_level == "Very Light" and duration_days > 1:
            alert = {
                "type": AlertType.INFO.value,
                "title": "Light menstrual flow",
                "message": "Your flow is lighter than usual. Ensure adequate nutrition and hydration.",
                "severity": "low",
                "actions": [
                    {"action": "improve_nutrition", "label": "Nutrition Tips"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        return None

    def check_severe_pain_alert(
        self,
        pain_level: int,  # 1-10 scale
        pain_duration_hours: float
    ) -> Optional[Dict]:
        """
        Check for severe menstrual pain alert
        """
        if pain_level > 8 or (pain_level > 6 and pain_duration_hours > 4):
            alert = {
                "type": AlertType.WARNING.value,
                "title": "⚠️ Severe menstrual pain",
                "message": f"Pain level {pain_level}/10 for {pain_duration_hours} hours. Try pain relief or consult doctor.",
                "severity": "high",
                "actions": [
                    {"action": "pain_relief", "label": "Pain Relief Tips"},
                    {"action": "consult_doctor", "label": "Consult Doctor"},
                    {"action": "log_pain", "label": "Log Pain"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        elif pain_level > 6 and pain_duration_hours > 2:
            alert = {
                "type": AlertType.INFO.value,
                "title": "Moderate menstrual pain",
                "message": f"Try relaxation techniques, heat therapy, or over-the-counter pain relief.",
                "severity": "medium",
                "actions": [
                    {"action": "pain_relief", "label": "Pain Relief Tips"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        return None

    def check_irregular_cycle_alert(
        self,
        irregularity_score: float,
        trend: str
    ) -> Optional[Dict]:
        """
        Check for irregular cycle pattern alert
        """
        if irregularity_score > 70:
            alert = {
                "type": AlertType.WARNING.value,
                "title": "Highly irregular cycle detected",
                "message": f"Your cycles show high irregularity ({irregularity_score:.0f}%). Trending: {trend}. Monitor symptoms and consult doctor if persistent.",
                "severity": "high",
                "actions": [
                    {"action": "track_symptoms", "label": "Track Symptoms"},
                    {"action": "consult_doctor", "label": "Consult Doctor"},
                    {"action": "hormone_test", "label": "Consider Hormone Panel"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        elif irregularity_score > 40:
            alert = {
                "type": AlertType.INFO.value,
                "title": "Moderate cycle irregularity",
                "message": f"Your cycles show moderate variation. Trends: {trend}. Continue tracking.",
                "severity": "medium",
                "actions": [
                    {"action": "continue_tracking", "label": "Continue Tracking"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        return None

    def check_pregnancy_risk_alert(
        self,
        risk_level: str,
        risk_factors: List[str]
    ) -> Optional[Dict]:
        """
        Check for pregnancy-related risk alerts
        """
        if risk_level == "high":
            alert = {
                "type": AlertType.WARNING.value,
                "title": "High pregnancy risk factors detected",
                "message": f"Risk factors: {', '.join(risk_factors[:2])}. Frequent monitoring recommended.",
                "severity": "high",
                "actions": [
                    {"action": "schedule_checkup", "label": "Schedule Checkup"},
                    {"action": "prenatal_care", "label": "Prenatal Care Tips"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        elif risk_level == "medium":
            alert = {
                "type": AlertType.INFO.value,
                "title": "Moderate pregnancy risk factors",
                "message": f"Risk factors identified: {', '.join(risk_factors[:2])}. Regular monitoring advised.",
                "severity": "medium",
                "actions": [
                    {"action": "schedule_checkup", "label": "Schedule Checkup"}
                ],
                "timestamp": datetime.now().isoformat()
            }
            return alert

        return None

    def generate_all_alerts(self, user_data: Dict) -> List[Dict]:
        """Generate all applicable alerts for user"""
        alerts = []

        # Check missed period
        if "days_missed" in user_data:
            missed_alert = self.check_missed_period_alert(
                user_data.get("last_period_date", ""),
                user_data.get("cycle_length", 28),
                user_data.get("days_missed", 0)
            )
            if missed_alert:
                alerts.append(missed_alert)

        # Check abnormal bleeding
        if "flow_level" in user_data:
            bleeding_alert = self.check_abnormal_bleeding_alert(
                user_data.get("flow_level", "Normal"),
                user_data.get("period_duration_days", 5)
            )
            if bleeding_alert:
                alerts.append(bleeding_alert)

        # Check severe pain
        if "pain_level" in user_data:
            pain_alert = self.check_severe_pain_alert(
                user_data.get("pain_level", 0),
                user_data.get("pain_duration_hours", 0)
            )
            if pain_alert:
                alerts.append(pain_alert)

        # Check irregular cycle
        if "irregularity_score" in user_data:
            irregular_alert = self.check_irregular_cycle_alert(
                user_data.get("irregularity_score", 0),
                user_data.get("cycle_trend", "stable")
            )
            if irregular_alert:
                alerts.append(irregular_alert)

        # Check pregnancy risks
        if "pregnancy_risk_level" in user_data:
            pregnancy_alert = self.check_pregnancy_risk_alert(
                user_data.get("pregnancy_risk_level", "low"),
                user_data.get("pregnancy_risk_factors", [])
            )
            if pregnancy_alert:
                alerts.append(pregnancy_alert)

        return alerts


class NotificationScheduler:
    """
    Intelligent notification scheduling
    """

    def __init__(self):
        self.scheduled_notifications = []

    def generate_water_reminders(
        self,
        activity_level: str = "moderate",
        pregnancy_week: int = 0,
        time_last_water: int = 120  # minutes ago
    ) -> Optional[Dict]:
        """
        Generate smart water reminders
        """
        # Calculate recommended water intake
        daily_water = 2000  # ml

        if pregnancy_week > 0:
            daily_water = 2500  # Increased for pregnancy

        if activity_level == "high":
            daily_water += 500

        # Recommend reminder if > 2 hours since last water
        if time_last_water > 120:
            variants = [
                "💧 Time to hydrate! Drink a glass of water.",
                "💧 Stay hydrated! How about some water?",
                f"💧 You've been inactive for {time_last_water // 60} hours — drink water to stay refreshed!",
                "💧 Your body needs hydration. Drink up!",
                "💧 Hydration tip: Regular water intake improves menstrual health."
            ]

            import random
            return {
                "type": NotificationType.WATER.value,
                "title": "Time to drink water",
                "message": random.choice(variants),
                "priority": "normal",
                "action": "log_water_intake",
                "timestamp": datetime.now().isoformat()
            }

        return None

    def generate_period_reminder(
        self,
        days_until_period: int
    ) -> Optional[Dict]:
        """
        Generate period reminder notifications
        """
        if days_until_period == 1:
            return {
                "type": NotificationType.PERIOD.value,
                "title": "🩸 Period coming tomorrow",
                "message": "Your period is expected tomorrow. Prepare supplies and adjust your schedule if needed.",
                "priority": "high",
                "timestamp": datetime.now().isoformat()
            }

        elif days_until_period == 0:
            return {
                "type": NotificationType.PERIOD.value,
                "title": "🩸 Period day today",
                "message": "Your period started or is starting today. Focus on self-care!",
                "priority": "high",
                "timestamp": datetime.now().isoformat()
            }

        elif days_until_period in [2, 3]:
            return {
                "type": NotificationType.PERIOD.value,
                "title": f"📅 Period in {days_until_period} days",
                "message": "Your period is coming soon. Stock up on supplies if needed.",
                "priority": "normal",
                "timestamp": datetime.now().isoformat()
            }

        return None

    def generate_fertility_alert(
        self,
        days_until_ovulation: int,
        fertility_score: float,
        trying_to_conceive: bool = False
    ) -> Optional[Dict]:
        """
        Generate fertility window alerts
        """
        if not trying_to_conceive:
            return None

        if days_until_ovulation == 0:
            return {
                "type": NotificationType.FERTILITY.value,
                "title": "🌸 Peak fertility day!",
                "message": f"Today is your peak fertility day (Score: {fertility_score:.0f}/100). Best time to conceive! 💚",
                "priority": "high",
                "timestamp": datetime.now().isoformat()
            }

        elif days_until_ovulation in [-1, 1]:
            return {
                "type": NotificationType.FERTILITY.value,
                "title": "🌸 High fertility window",
                "message": f"High fertility days ahead (Score: {fertility_score:.0f}/100). Favorable time to conceive.",
                "priority": "high",
                "timestamp": datetime.now().isoformat()
            }

        elif days_until_ovulation in [-2, 2, -3, 3]:
            return {
                "type": NotificationType.FERTILITY.value,
                "title": "🌸 Fertility window approaching",
                "message": f"Fertility window starting soon. Fertility score: {fertility_score:.0f}/100",
                "priority": "normal",
                "timestamp": datetime.now().isoformat()
            }

        return None

    def generate_pregnancy_update(self, pregnancy_week: int) -> Optional[Dict]:
        """
        Generate weekly pregnancy updates
        """
        if pregnancy_week <= 0 or pregnancy_week > 40:
            return None

        # Trimester-specific messages
        messages = {
            "week_early": "Congratulations! Your pregnancy has begun. Week 1-4: Rest and start prenatal vitamins.",
            "week_5_8": f"Week {pregnancy_week}: Fetal heartbeat forms. Nausea common - eat small frequent meals.",
            "week_9_12": f"Week {pregnancy_week}: Baby is fingerprint-sized. Continue prenatal care.",
            "week_13_16": f"Week {pregnancy_week}: Morning sickness may ease. Energy returning!",
            "week_17_20": f"Week {pregnancy_week}: Halfway there! Baby movements may be felt.",
            "week_21_24": f"Week {pregnancy_week}: Baby developing rapidly. Adequate nutrition crucial.",
            "week_25_28": f"Week {pregnancy_week}: Viable if early delivery. Strengthen pregnancy fitness.",
            "week_29_32": f"Week {pregnancy_week}: Baby positions for birth. Pelvic floor exercises important.",
            "week_33_36": f"Week {pregnancy_week}: Final weeks approaching. Prepare birth plan.",
            "week_37_40": f"Week {pregnancy_week}: Full term! Labor can begin anytime. Stay alert for signs."
        }

        if pregnancy_week <= 4:
            msg_type = "week_early"
        elif pregnancy_week <= 8:
            msg_type = "week_5_8"
        elif pregnancy_week <= 12:
            msg_type = "week_9_12"
        elif pregnancy_week <= 16:
            msg_type = "week_13_16"
        elif pregnancy_week <= 20:
            msg_type = "week_17_20"
        elif pregnancy_week <= 24:
            msg_type = "week_21_24"
        elif pregnancy_week <= 28:
            msg_type = "week_25_28"
        elif pregnancy_week <= 32:
            msg_type = "week_29_32"
        elif pregnancy_week <= 36:
            msg_type = "week_33_36"
        else:
            msg_type = "week_37_40"

        return {
            "type": NotificationType.PREGNANCY.value,
            "title": f"👶 Week {pregnancy_week} pregnancy update",
            "message": messages[msg_type],
            "priority": "normal",
            "timestamp": datetime.now().isoformat()
        }

    def generate_mental_health_check_in(self) -> Dict:
        """Generate mental health check-in reminder"""
        return {
            "type": NotificationType.MENTAL_HEALTH.value,
            "title": "🧠 How are you feeling today?",
            "message": "Check in with your mental health. Log your mood, stress, and sleep.",
            "priority": "normal",
            "action": "log_mental_health",
            "timestamp": datetime.now().isoformat()
        }

    def generate_daily_health_engine_notification(self, recommendations: Dict) -> Dict:
        """Generate notification based on Daily Health Engine"""
        return {
            "type": NotificationType.INFO.value,
            "title": "📊 Today's health recommendations",
            "message": f"Cycle phase: {recommendations.get('cycle_phase', 'unknown')}. "
                     f"Food: {recommendations.get('food_tip', '')}. "
                     f"Water: {recommendations.get('water_recommendation', '')}. "
                     f"Exercise: {recommendations.get('exercise_tip', '')}",
            "priority": "normal",
            "timestamp": datetime.now().isoformat()
        }


# Export
__all__ = [
    "SmartAlertSystem",
    "NotificationScheduler",
    "AlertType",
    "NotificationType"
]
