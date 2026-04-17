"""
nutrition_engine.py
===================
Advanced Nutrition Intelligence System

Features:
  - Daily meal plan generation
  - Nutritional tracking (calories, protein, iron, calcium)
  - Cycle-phase specific recommendations
  - Pregnancy trimester-specific meal plans
  - Personalized dietary preferences
"""

from typing import Dict, List, Optional
import random
from dataclasses import dataclass
from enum import Enum


@dataclass
class NutritionInfo:
    """Nutrition information for a food/meal"""
    calories: float
    protein: float  # grams
    iron: float     # mg
    calcium: float  # mg
    fats: float
    carbs: float


class CyclePhase(Enum):
    MENSTRUAL = "menstrual"
    FOLLICULAR = "follicular"
    OVULATION = "ovulation"
    LUTEAL = "luteal"


class NutritionIntelligenceEngine:
    """
    Intelligent nutrition planning and tracking system
    """

    def __init__(self):
        self._init_food_database()
        self.daily_tracking = {}

    def _init_food_database(self):
        """Initialize comprehensive food database with nutrition info"""
        self.foods = {
            # Breakfast options
            "Oats with milk and fruits": NutritionInfo(
                calories=350, protein=12, iron=4.5, calcium=250, fats=8, carbs=55
            ),
            "Scrambled eggs with toast": NutritionInfo(
                calories=280, protein=18, iron=3.2, calcium=80, fats=12, carbs=28
            ),
            "Yogurt with granola": NutritionInfo(
                calories=300, protein=10, iron=2.1, calcium=200, fats=8, carbs=45
            ),
            "Smoothie (banana, spinach, milk)": NutritionInfo(
                calories=250, protein=8, iron=2.5, calcium=180, fats=4, carbs=48
            ),
            "Whole wheat pancakes": NutritionInfo(
                calories=320, protein=10, iron=2.8, calcium=120, fats=6, carbs=56
            ),
            "Avocado toast": NutritionInfo(
                calories=280, protein=8, iron=2.4, calcium=95, fats=14, carbs=30
            ),

            # Lunch options
            "Rice with spinach and dal": NutritionInfo(
                calories=450, protein=16, iron=5.2, calcium=180, fats=8, carbs=72
            ),
            "Chicken breast with broccoli": NutritionInfo(
                calories=380, protein=45, iron=1.8, calcium=120, fats=6, carbs=15
            ),
            "Lentil soup with vegetables": NutritionInfo(
                calories=320, protein=18, iron=6.1, calcium=140, fats=4, carbs=48
            ),
            "Tuna salad": NutritionInfo(
                calories=350, protein=35, iron=3.2, calcium=200, fats=8, carbs=12
            ),
            "Quinoa bowl with roasted vegetables": NutritionInfo(
                calories=420, protein=15, iron=4.2, calcium=180, fats=10, carbs=58
            ),
            "Chickpea curry with bread": NutritionInfo(
                calories=480, protein=14, iron=5.8, calcium=200, fats=12, carbs=70
            ),

            # Dinner options
            "Chapati with vegetables": NutritionInfo(
                calories=400, protein=10, iron=3.5, calcium=150, fats=8, carbs=68
            ),
            "Grilled salmon with sweet potato": NutritionInfo(
                calories=450, protein=38, iron=2.8, calcium=95, fats=14, carbs=35
            ),
            "Lentils with rice": NutritionInfo(
                calories=420, protein=16, iron=5.8, calcium=160, fats=6, carbs=72
            ),
            "Turkey meatballs with pasta": NutritionInfo(
                calories=480, protein=32, iron=2.4, calcium=120, fats=10, carbs=58
            ),
            "Vegetable stir-fry with tofu": NutritionInfo(
                calories=380, protein=20, iron=6.2, calcium=280, fats=12, carbs=42
            ),
            "Baked chicken with quinoa": NutritionInfo(
                calories=520, protein=42, iron=3.8, calcium=140, fats=10, carbs=48
            ),

            # Snacks
            "Almonds (handful)": NutritionInfo(
                calories=160, protein=6, iron=2.1, calcium=75, fats=14, carbs=6
            ),
            "Apple with peanut butter": NutritionInfo(
                calories=240, protein=8, iron=0.8, calcium=50, fats=12, carbs=26
            ),
            "Greek yogurt": NutritionInfo(
                calories=150, protein=20, iron=0.5, calcium=200, fats=3, carbs=8
            ),
            "Banana": NutritionInfo(
                calories=90, protein=1, iron=0.3, calcium=5, fats=0, carbs=23
            ),
            "Dark chocolate (30g)": NutritionInfo(
                calories=170, protein=2, iron=3.5, calcium=35, fats=12, carbs=16
            ),
        }

    def generate_daily_meal_plan(
        self,
        cycle_phase: Optional[str] = None,
        pregnancy_week: int = 0,
        calories_target: float = 2000,
        diet_type: str = "balanced"
    ) -> Dict:
        """
        Generate comprehensive daily meal plan
        """
        plan = {
            "date": str(__import__('datetime').datetime.now().date()),
            "cycle_phase": cycle_phase or "general",
            "pregnancy_week": pregnancy_week,
            "meals": {},
            "daily_totals": {},
            "recommendations": []
        }

        # Get meal suggestions based on phase
        breakfast_options = self._get_breakfast_options(cycle_phase, pregnancy_week)
        lunch_options = self._get_lunch_options(cycle_phase, pregnancy_week)
        dinner_options = self._get_dinner_options(cycle_phase, pregnancy_week)

        # Select meals
        breakfast = random.choice(breakfast_options)
        lunch = random.choice(lunch_options)
        dinner = random.choice(dinner_options)

        plan["meals"] = {
            "breakfast": self._format_meal(breakfast, "Breakfast"),
            "lunch": self._format_meal(lunch, "Lunch"),
            "dinner": self._format_meal(dinner, "Dinner"),
            "snack": self._get_snack_suggestions(cycle_phase, pregnancy_week)
        }

        # Calculate totals
        plan["daily_totals"] = self._calculate_totals(breakfast, lunch, dinner)

        # Add recommendations
        plan["recommendations"] = self._get_nutrition_recommendations(
            cycle_phase, pregnancy_week, diet_type
        )

        return plan

    def _get_breakfast_options(self, cycle_phase: Optional[str], pregnancy_week: int) -> List[str]:
        """Get breakfast options based on cycle phase and pregnancy"""
        base_options = [
            "Oats with milk and fruits",
            "Scrambled eggs with toast",
            "Yogurt with granola",
            "Smoothie (banana, spinach, milk)",
            "Whole wheat pancakes"
        ]

        if cycle_phase == "menstrual" or pregnancy_week in [0, 1]:
            # Iron-rich breakfast
            return [
                "Scrambled eggs with toast",
                "Oats with milk and fruits"
            ]
        elif cycle_phase == "follicular":
            return base_options
        elif cycle_phase == "ovulation":
            return [
                "Yogurt with granola",
                "Smoothie (banana, spinach, milk)",
                "Avocado toast"
            ]
        elif pregnancy_week > 0:
            # Pregnancy-specific
            return [
                "Oats with milk and fruits",
                "Yogurt with granola",
                "Scrambled eggs with toast"
            ]
        else:
            return base_options

    def _get_lunch_options(self, cycle_phase: Optional[str], pregnancy_week: int) -> List[str]:
        """Get lunch options based on cycle phase and pregnancy"""
        base_options = [
            "Rice with spinach and dal",
            "Chicken breast with broccoli",
            "Lentil soup with vegetables",
            "Tuna salad",
            "Quinoa bowl with roasted vegetables",
            "Chickpea curry with bread"
        ]

        if cycle_phase == "menstrual":
            # Iron-rich lunch
            return [
                "Rice with spinach and dal",
                "Lentil soup with vegetables",
                "Chickpea curry with bread"
            ]
        elif pregnancy_week > 0 and pregnancy_week <= 12:
            # Early pregnancy
            return [
                "Lentil soup with vegetables",
                "Quinoa bowl with roasted vegetables",
                "Chicken breast with broccoli"
            ]
        elif pregnancy_week > 12:
            # Protein-rich for fetal growth
            return [
                "Chicken breast with broccoli",
                "Tuna salad",
                "Chickpea curry with bread"
            ]
        else:
            return base_options

    def _get_dinner_options(self, cycle_phase: Optional[str], pregnancy_week: int) -> List[str]:
        """Get dinner options based on cycle phase and pregnancy"""
        base_options = [
            "Chapati with vegetables",
            "Grilled salmon with sweet potato",
            "Lentils with rice",
            "Turkey meatballs with pasta",
            "Vegetable stir-fry with tofu",
            "Baked chicken with quinoa"
        ]

        if cycle_phase == "luteal":
            # Magnesium-rich, lighter dinner
            return [
                "Vegetable stir-fry with tofu",
                "Lentils with rice",
                "Chapati with vegetables"
            ]
        elif pregnancy_week in range(20, 40):
            # Later pregnancy - easy to digest
            return [
                "Grilled salmon with sweet potato",
                "Lentils with rice",
                "Baked chicken with quinoa"
            ]
        else:
            return base_options

    def _get_snack_suggestions(self, cycle_phase: Optional[str], pregnancy_week: int) -> List[Dict]:
        """Get snack suggestions"""
        base_snacks = [
            {"name": "Almonds (handful)", "time": "10:30 AM"},
            {"name": "Apple with peanut butter", "time": "3:00 PM"},
            {"name": "Greek yogurt", "time": "4:00 PM"},
            {"name": "Banana", "time": "before workout"},
        ]

        if pregnancy_week > 0:
            return base_snacks + [{"name": "Dark chocolate (30g)", "time": "evening"}]

        return base_snacks

    def _format_meal(self, meal_name: str, meal_type: str) -> Dict:
        """Format meal information"""
        nutrition = self.foods.get(meal_name, NutritionInfo(0, 0, 0, 0, 0, 0))
        return {
            "name": meal_name,
            "type": meal_type,
            "nutrition": {
                "calories": nutrition.calories,
                "protein": nutrition.protein,
                "iron": nutrition.iron,
                "calcium": nutrition.calcium,
                "fats": nutrition.fats,
                "carbs": nutrition.carbs
            }
        }

    def _calculate_totals(self, breakfast: str, lunch: str, dinner: str) -> Dict:
        """Calculate daily nutrition totals"""
        meals = [breakfast, lunch, dinner]
        totals = {
            "calories": 0,
            "protein": 0,
            "iron": 0,
            "calcium": 0,
            "fats": 0,
            "carbs": 0
        }

        for meal in meals:
            nutrition = self.foods.get(meal, NutritionInfo(0, 0, 0, 0, 0, 0))
            totals["calories"] += nutrition.calories
            totals["protein"] += nutrition.protein
            totals["iron"] += nutrition.iron
            totals["calcium"] += nutrition.calcium
            totals["fats"] += nutrition.fats
            totals["carbs"] += nutrition.carbs

        return totals

    def _get_nutrition_recommendations(
        self,
        cycle_phase: Optional[str],
        pregnancy_week: int,
        diet_type: str
    ) -> List[str]:
        """Get personalized nutrition recommendations"""
        recommendations = []

        if cycle_phase == "menstrual":
            recommendations = [
                "Increase iron intake (spinach, red meat, legumes)",
                "Stay hydrated (3-4 liters of water daily)",
                "Add extra calories (+200-300)",
                "Include magnesium-rich foods (dark chocolate, nuts)"
            ]
        elif cycle_phase == "follicular":
            recommendations = [
                "Eat plenty of fresh vegetables and fruits",
                "Include protein for hormone production",
                "Stay active - energy is increasing"
            ]
        elif cycle_phase == "ovulation":
            recommendations = [
                "Stay hydrated (very important)",
                "Eat antioxidant-rich foods (berries, leafy greens)",
                "Maintain regular meal times"
            ]
        elif cycle_phase == "luteal":
            recommendations = [
                "Include magnesium-rich foods",
                "Add complex carbohydrates",
                "Increase healthy fats",
                "Manage portions - metabolism increases"
            ]

        if pregnancy_week > 0:
            recommendations = [
                f"Week {pregnancy_week}: Baby is developing",
                "Extra 300-500 calories needed (especially 2nd/3rd trimester)",
                "Prenatal vitamins daily (especially folic acid)",
                "Calcium-rich foods essential (strong bones and teeth)",
                "Iron supplementation may be recommended"
            ]

        return recommendations

    def track_daily_nutrition(self, meals_eaten: List[Dict]) -> Dict:
        """
        Track daily nutrition intake
        """
        totals = {
            "calories": 0,
            "protein": 0,
            "iron": 0,
            "calcium": 0,
            "fats": 0,
            "carbs": 0
        }

        for meal in meals_eaten:
            meal_name = meal.get("name")
            nutrition = self.foods.get(meal_name, NutritionInfo(0, 0, 0, 0, 0, 0))
            totals["calories"] += nutrition.calories
            totals["protein"] += nutrition.protein
            totals["iron"] += nutrition.iron
            totals["calcium"] += nutrition.calcium
            totals["fats"] += nutrition.fats
            totals["carbs"] += nutrition.carbs

        # Calculate against recommendations
        targets = {
            "calories": 2000,
            "protein": 50,
            "iron": 18,
            "calcium": 1000,
            "fats": 70,
            "carbs": 275
        }

        status = {}
        for key in targets:
            actual = totals[key]
            target = targets[key]
            percentage = (actual / target * 100) if target > 0 else 0
            status[key] = {
                "actual": actual,
                "target": target,
                "percentage": round(percentage, 1),
                "status": "✓ Good" if 90 <= percentage <= 110 else "⚠ Low" if percentage < 90 else "⚠ High"
            }

        return {
            "totals": totals,
            "status": status,
            "summary": self._generate_nutrition_summary(status)
        }

    def _generate_nutrition_summary(self, status: Dict) -> str:
        """Generate summary of nutrition status"""
        issues = []
        for nutrient, info in status.items():
            if info["status"] != "✓ Good":
                issues.append(f"{nutrient}: {info['status']}")

        if not issues:
            return "✓ Excellent nutrition today!"
        else:
            return "Areas to improve: " + ", ".join(issues)


# Export
__all__ = ["NutritionIntelligenceEngine", "CyclePhase", "NutritionInfo"]
