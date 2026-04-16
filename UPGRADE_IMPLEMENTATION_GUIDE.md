# Femi-Friendly v2.0 - Intelligent Health Assistant
## Complete Implementation Guide

---

## 🎯 OVERVIEW

Femi-Friendly has been upgraded from a basic menstrual cycle tracker to an **Intelligent AI-powered Women's Healthcare Assistant** with advanced health tracking, real-time recommendations, and smart notifications.

### Version Info
- **Previous Version**: 0.1.0 (Basic predictions)
- **Current Version**: 2.0.0 (Advanced AI + Real-time + Clinical-grade)
- **Date**: April 2026

---

## 🚀 ARCHITECTURE OVERVIEW

### Backend Stack
```
FastAPI (api/) 
├── routes.py (12 new endpoints)
├── services.py (Updated with 7 new service functions)
└── schemas.py (Pydantic models)

AI/ML Models (ai_model/)
├── advanced_models.py ⭐ NEW
│   ├── TimeSeriesAnalyzer (trend analysis, anomaly detection)
│   ├── PersonalizationEngine (user-specific predictions)
│   ├── CycleIntelligenceEngine (advanced cycle analysis)
│   ├── PregnancyHealthSystem (pregnancy tracking)
│   └── MentalHealthModule (wellness tracking)
├── nutrition_engine.py ⭐ NEW
│   └── NutritionIntelligenceEngine (meal plans, macro tracking)
├── alert_notification_system.py ⭐ NEW
│   ├── SmartAlertSystem (health alerts)
│   └── NotificationScheduler (smart reminders)
├── daily_health_engine.py ⭐ NEW
│   └── DailyHealthEngine (core recommendation engine)
├── predict.py (Existing ML models)
└── train.py (Model training)

Flutter Frontend (lib/)
├── models/health_models.dart ⭐ NEW
│   ├── FertilityInsights
│   ├── MealPlan & NutritionInfo
│   ├── PregnancyInsights
│   ├── MentalHealthStatus
│   ├── HealthAlert
│   ├── HealthNotification
│   └── DailyHealthRecommendation
├── screens/advanced_health_screens.dart ⭐ NEW
│   ├── FertilityInsightsScreen
│   ├── NutritionPlannerScreen
│   ├── PregnancyTrackerScreen
│   ├── MentalHealthDashboard
│   ├── HealthAlertsScreen
│   └── DailyHealthCenterScreen
└── services/advanced_health_service.dart ⭐ NEW
    └── AdvancedHealthService (API integration)
```

---

## 📡 NEW API ENDPOINTS (v2.0)

All endpoints accept POST requests with user health data.

### 1. **Cycle Intelligence**
```
POST /cycle-intelligence
Input: {cycle_history, stress_level, bmi, pcos, ...}
Output: {
  irregularity_analysis,
  hormonal_imbalance_risk,
  pcos_risk_assessment,
  next_predicted_cycle
}
```
**Features**: 
- Trend analysis using time-series data
- Anomaly detection
- Hormonal imbalance risk scoring
- PCOS risk assessment

### 2. **Nutrition Plan**
```
POST /nutrition-plan
Input: {cycle_phase, pregnancy_week, calories_target, diet_type}
Output: {
  meals: {breakfast, lunch, dinner, snack},
  daily_totals: {calories, protein, iron, calcium, fats, carbs},
  recommendations: [...]
}
```
**Features**:
- AI-generated meal plans (25+ meals)
- Cycle-phase specific recommendations
- Pregnancy-adjusted nutrition
- Nutritional tracking & goals

### 3. **Fertility Insights**
```
POST /fertility-insights
Input: {age, bmi, stress_level, ovulation_day, cycle_length, ...}
Output: {
  fertility_score (0-100),
  personalized_baseline,
  personalized_recommendations,
  fertility_window
}
```
**Features**:
- Personalized fertility scoring
- Ovulation window calculation
- Fertility history tracking
- Conception timing suggestions

### 4. **Pregnancy Insights**
```
POST /pregnancy-insights
Input: {last_period_date, age, bmi, stress_level, miscarriages, ...}
Output: {
  pregnancy_week,
  trimester_info: {name, focus, milestones},
  risk_assessment: {score, risk_level, factors},
  weekly_pregnancy_tips
}
```
**Features**:
- Week-by-week pregnancy tracking (1-40 weeks)
- Trimester-specific information
- Pregnancy risk assessment
- Weekly tips & milestones

### 5. **Mental Health**
```
POST /mental-health
Input: {mood (1-10), stress (1-10), sleep_hours}
Output: {
  current_mood,
  current_stress,
  current_sleep_hours,
  health_summary,
  wellness_suggestions: [...]
}
```
**Features**:
- Mood tracking
- Stress monitoring
- Sleep analysis
- Personalized wellness suggestions

### 6. **Health Alerts**
```
POST /health-alerts
Input: {days_missed, flow_level, pain_level, irregularity_score, ...}
Output: {
  alerts: [{type, title, message, severity, actions}],
  critical_alerts: [...],
  warning_alerts: [...],
  info_alerts: [...]
}
```
**Alert Types**:
- Missed period (>7 days)
- Abnormal bleeding
- Severe pain (>6/10)
- Irregular cycles
- Pregnancy risk factors

### 7. **Notifications**
```
POST /notifications
Input: {activity_level, pregnancy_week, days_until_period, fertility_score, ...}
Output: {
  notifications: [{type, title, message, priority}],
  total_count
}
```
**Notification Types**:
- 💧 Water reminders (smart timing)
- 🩸 Period reminders
- 🌸 Fertility alerts
- 👶 Pregnancy weekly updates
- 🧠 Mental health check-ins

### 8. **Daily Recommendations**
```
POST /daily-recommendations
Input: {cycle_phase, pregnancy_week, stress_level, sleep_hours, bmi, ...}
Output: {
  recommendations: {
    nutrition: {...},
    hydration: {...},
    exercise: {...},
    mental_health: {...},
    sleep: {...}
  },
  wellness_score,
  priority_focus
}
```
**Generates**:
- Nutrition tips for the day
- Water intake targets
- Exercise recommendations
- Mental health suggestions
- Sleep prescriptions
- Overall wellness score

---

## 🧠 AI ENGINES EXPLAINED

### 1. **Cycle Intelligence Engine**
**What it does**: Analyzes menstrual cycles intelligently

**Key Functions**:
- `predict_irregular_patterns()` - Detects cycle irregularities using trend analysis
- `detect_hormonal_imbalance_risk()` - Scores hormonal imbalance risk (0-100)
- `detect_pcos_risk()` - Identifies PCOS indicators
- `predict_next_cycle()` - Predicts next cycle length

**Algorithm**:
```python
# Time-series rolling window analysis
history = [28, 29, 27, 30, 28, 31, 26, 32]  # Last 8 cycles
mean = 28.6
std_dev = 1.77  # Measure of variance
trend = calculate_recent_trend(history)  # Increasing/decreasing/stable

# Classification
if std_dev < 3: pattern = "regular"
elif std_dev < 7: pattern = "irregular"
else: pattern = "highly_irregular"

# Risk scoring
if std_dev > 5: add +20% to hormonal imbalance risk
if stress == "High": add +20%
if bmi < 18.5 or bmi > 30: add +15%
if pcos == "Yes": add +30%
```

### 2. **Personalization Engine**
**What it does**: Creates user-specific predictions

**Personalization Factors**:
- Age (impacts fertility)
- BMI (impacts cycle health)
- Stress level (impacts regularity)
- Sleep quality
- Activity level
- Diet type
- PCOS status
- Pregnancy attempt timeline

**Example**:
```python
baseline_cycle = 28  # Start with 28
if has_pcos: baseline_cycle += 5  # PCOS → longer cycles
if stress == "High": baseline_cycle += 2  # Stress → longer cycles
if bmi < 18.5: baseline_cycle -= 1  # Underweight
if activity_level == "High": baseline_cycle -= 1  # Athletes
# Result: Personalized cycle baseline

fertility_score = 100
if bmi outside 18.5-25: fertility_score -= 15
if age > 35: fertility_score -= 20
if age > 40: fertility_score -= 40
if stress == "High": fertility_score -= 10
if sleep < 7hrs: fertility_score -= 10
if has_pcos: fertility_score -= 20
# Result: 0-100 fertility score
```

### 3. **Nutrition Intelligence Engine**
**What it does**: Generates personalized meal plans

**Features**:
- 25+ meals in database with complete nutrition profiles
- Cycle-phase specific recommendations
- Pregnancy-adjusted nutrition
- Integration with user preferences

**Recommendations by Cycle Phase**:
```
Menstrual Phase:
- Focus: Iron-rich foods
- Meals: Rice+spinach+dal, Lentil soup, Red meat dishes
- Extra: Magnesium, Dark chocolate, Red dates
- Goal: Replace blood loss, prevent anemia

Follicular Phase:
- Focus: Light & energizing
- Meals: Fresh vegetables, Whole grains, Protein breakfast
- Extra: Natural carbs for hormone production
- Goal: Boost energy, hormone support

Ovulation Phase:
- Focus: Antioxidant-rich
- Meals: Berries, Leafy greens, Fermented foods
- Extra: Extra hydration, Healthy fats
- Goal: Support fertility, high metabolism

Luteal Phase:
- Focus: Calming & satisfying
- Meals: Complex carbs, Magnesium-rich, Lighter options
- Extra: Serotonin-boosting foods, Healthy fats
- Goal: Mood support, energy management

Pregnancy:
- Week 1-12: Prenatal vitamins, Folic acid, Hydration
- Week 13-28: Extra 300 calories, Protein focus, Calcium
- Week 29-40: 500+ extra calories, Iron, Prepare for labor
```

### 4. **Pregnancy Health System**
**What it does**: Comprehensive pregnancy tracking

**40 Weeks Divided Into**:
```
Trimester 1 (Weeks 1-13):
- Organ formation begins
- Nausea common, fatigue
- Focus: Rest, prenatal vitamins, avoid harmful substances

Trimester 2 (Weeks 14-27):
- Baby movements felt
- Energy typically returns
- Focus: Regular exercise, strength building, relaxation classes

Trimester 3 (Weeks 28-40):
- Baby positioning for birth
- Final preparations
- Focus: Pelvic floor exercises, birth plan, labor preparation
```

**Risk Detection**:
- Age > 35: +15 points
- Low BMI (< 18.5): +10 points
- High BMI (> 30): +10 points (gestational diabetes)
- High stress: +10 points (preterm labor risk)
- Poor sleep: +8 points
- History of miscarriage: +15 points (each)
- PCOS: +15 points (gestational diabetes risk)

### 5. **Mental Health Module**
**What it does**: Wellness tracking & suggestions

**Tracking**:
- Mood (1-10 scale) with emojis
- Stress level (1-10 scale)
- Sleep hours
- Trend analysis (improving/declining/stable)

**Wellness Suggestions**:
```python
if mood < 5:
    suggest: [breathing exercises, nature walk, hobby time, social connection]
if stress > 7:
    suggest: [meditation, progressive muscle relaxation, yoga, herbal tea]
if sleep < 6 hours:
    suggest: [sleep hygiene improvements, consistent schedule]

# Combine suggestions for holistic wellness
```

### 6. **Smart Alert System**
**What it does**: Generates health alerts

**Alert Triggers**:
```python
# Missed Period Alert
if days_missed > 7:
    trigger: WARNING alert
    message: "Period overdue by X days. Consider pregnancy test or doctor consultation."
if days_missed > 14:
    severity: HIGH
    message: "Urgent: Period significantly late, seek medical attention"

# Abnormal Bleeding Alert
if flow_level == "Very Heavy" OR (flow_level == "Heavy" AND duration > 8 days):
    trigger: CRITICAL alert
    message: "Severe menstrual bleeding detected"
if flow_level == "Very Light" AND duration > 1:
    trigger: info alert
    message: "Light flow detected, ensure nutrition"

# Severe Pain Alert
if pain_level > 8 OR (pain_level > 6 AND duration > 4 hours):
    trigger: WARNING alert
    message: "Severe pain detected, try relief techniques or see doctor"

# Irregular Cycle Alert
if irregularity_score > 70:
    trigger: WARNING alert
    message: "Highly irregular cycles detected"
if irregularity_score > 40:
    trigger: info alert
    message: "Moderate irregularity, continue tracking"

# Pregnancy Risk Alert
if pregnancy_risk_score > 70:
    trigger: WARNING alert
    message: "Multiple risk factors detected, frequent monitoring needed"
```

### 7. **Daily Health Engine** ⭐ CORE FEATURE
**What it does**: Generates daily health guidance

**Daily Output Includes**:
1. **Nutrition** → Today's food focus, tips for cycle phase
2. **Hydration** → Water target (mL), reminders
3. **Exercise** → Type, intensity, duration for cycle phase
4. **Mental Health** → Mood support, stress management
5. **Sleep** → Target hours, sleep hygiene tips
6. **General Tips** → Tracking reminders, consistency
7. **Wellness Score** → 0-100 based on stress, sleep, mood
8. **Priority Focus** → What to concentrate on today

**Example Daily Recommendation** (Menstrual Phase, High Stress):
```json
{
  "date": "2026-04-15",
  "cycle_phase": "menstrual",
  "wellness_score": 65,
  "priority_focus": "💪 Rest & Nutrition Recovery",
  "recommendations": {
    "nutrition": {
      "title": "Nutrition",
      "tips": [
        "🥩 Iron-rich foods: Red meat, spinach, legumes",
        "🍫 Dark chocolate for magnesium",
        "💪 Protein with every meal for energy",
        "🥛 Calcium sources for cramping support"
      ]
    },
    "hydration": {
      "daily_target_ml": 2000,
      "tips": ["Aim for 8 glasses of water daily", ...]
    },
    "exercise": {
      "intensity": "Very light",
      "tips": ["Gentle walk (15-20 mins)", "Restorative yoga", ...]
    },
    "mental_health": {
      "tips": [
        "Meditation: 10-15 mins daily",
        "Deep breathing: 5 mins morning & evening",
        "Nature walk for 20 mins"
      ]
    }
  }
}
```

---

## 💻 IMPLEMENTATION CHECKLIST

### Backend Setup ✅
- [x] Create advanced_models.py with 5 AI engines
- [x] Create nutrition_engine.py with 25+ meals
- [x] Create alert_notification_system.py with smart alerts
- [x] Create daily_health_engine.py with core recommendations
- [x] Update services.py with 7 new service functions
- [x] Update routes.py with 8 new API endpoints
- [x] Update requirements.txt (if needed)

### Frontend Setup ✅
- [x] Create health_models.dart with 10 data models
- [x] Create advanced_health_screens.dart with 6 new screens
- [x] Create advanced_health_service.dart for API integration
- [x] Update main.dart to include new routes
- [x] Add navigation to new features

### Testing (Next Steps)
- [ ] Test each API endpoint
- [ ] Validate AI predictions
- [ ] Test alert triggering
- [ ] Verify nutrition plans
- [ ] Test flutter screens

### Deployment (Next Steps)
- [ ] Deploy backend changes
- [ ] Update flutter app
- [ ] Configure push notifications
- [ ] Set up background tasks (for reminders)

---

## 🚀 QUICK START GUIDE

### 1. **For Backend Developers**

Install requirements (if not already):
```bash
cd d:\project\ai-menstrual-health-app
pip install -r requirements.txt  # numpy, pandas, scikit-learn, fastapi, uvicorn, pydantic
```

Run the API server:
```bash
python api/main.py
# Server runs on http://localhost:8000
```

Test an endpoint:
```bash
curl -X POST http://localhost:8000/nutrition-plan \
  -H "Content-Type: application/json" \
  -d '{
    "cycle_phase": "menstrual",
    "pregnancy_week": 0,
    "calories_target": 2000,
    "diet_type": "balanced"
  }'
```

### 2. **For Flutter Developers**

Add the service to your provider/state management:
```dart
// In your main.dart or provider setup
final advancedHealthService = AdvancedHealthService(
  dio: Dio(),
  baseUrl: 'http://localhost:8000',  // Update for production
);
```

Use in a screen:
```dart
// Get daily recommendations
final recommendations = await advancedHealthService.getDailyRecommendations({
  'cycle_phase': 'menstrual',
  'pregnancy_week': 0,
  'stress_level': 'High',
  'sleep_hours': 6.5,
  'bmi': 22.5,
  'activity_level': 'Moderate',
  'mood_score': 6
});

// Navigate to screen
Navigator.push(context, MaterialPageRoute(
  builder: (context) => DailyHealthCenterScreen(
    recommendations: recommendations,
  ),
));
```

### 3. **For Product Managers**

Key Features Delivered:
✅ Advanced Cycle Intelligence (trend analysis, anomaly detection)
✅ Personalized Fertility Insights (0-100 score)
✅ AI Nutrition Planning (25+ meals, phase-specific)
✅ Pregnancy Tracking (1-40 weeks, week-specific tips)
✅ Mental Health Monitoring (mood, stress, sleep)
✅ Smart Alerts (missed period, abnormal bleeding, severe pain)
✅ Real-time Notifications (water, fertility, period, pregnancy)
✅ Daily Health Engine (core recommendation engine)

User Experience Improvements:
✅ Beautiful new screens with animations
✅ Personalized recommendations
✅ Smart alert system
✅ Real-time notifications
✅ Daily wellness score

---

## 📊 DATA FLOW EXAMPLE

### User Opens App → Gets Daily Recommendations

```
1. User logs in
   └─ App fetches user.json (age, bmi, stress_level, etc.)

2. App calls /daily-recommendations endpoint
   └─ Input: {cycle_phase: "menstrual", stress_level: "High", ...}

3. Backend DailyHealthEngine processes:
   ├─ Analyzes stress level (High = needs wellness focus)
   ├─ Analyzes cycle phase (menstrual = iron-rich focus)
   ├─ Calculates wellness score based on sleep, mood, stress
   ├─ Determines priority focus
   └─ Generates recommendations for: nutrition, exercise, hydration, mental health, sleep

4. Backend returns comprehensive recommendation object:
   {"nutrition": {...}, "exercise": {...}, "wellness_score": 65, ...}

5. Flutter app displays DailyHealthCenterScreen
   ├─ Shows wellness score card
   ├─ Highlights priority focus
   └─ Displays all recommendations by category

6. User can:
   ├─ Click "View Nutrition Plan" → NutritionPlannerScreen
   ├─ Click "Mental Health" → MentalHealthDashboard
   ├─ Log mood/stress → Triggers wellness suggestions
   └─ View alerts → HealthAlertsScreen
```

---

## 🔐 PRIVACY & DISCLAIMER

⚠️ **Important**: Add to app settings/splash screen:

```
"This application provides general health insights and is not a 
substitute for professional medical advice. 

Always consult with healthcare providers for:
- Pregnancy-related concerns
- Severe pain or abnormal bleeding
- Hormonal imbalance symptoms
- Mental health crises

Your health data is private and used only for personalized recommendations."
```

---

## 📈 PERFORMANCE METRICS

Expected Performance:
- Daily recommendations generation: < 200ms
- Nutrition plan generation: < 150ms
- Alert checking: < 100ms
- API response time: < 400ms (including network)
- Mobile app responsiveness: 60 FPS animations

---

## 🔄 NEXT PHASE (v2.1+)

Potential future enhancements:
- 🤖 ML model training on user data
- 💬 Chat-based health assistant with NLP
- 📸 Image recognition for food logging
- ⌚ Wearable integration (heart rate, steps)
- 🔔 Local push notifications
- 🌐 Cloud sync & backup
- 👥 Social features & community
- 📊 Advanced analytics & reports

---

## 📞 SUPPORT

For issues or questions:
- Backend issues: Check ai_model/ and api/ folders
- Frontend issues: Check lib/ folder
- API testing: Use Postman or curl
- Flutter testing: Use `flutter run` with debug output

---

**Version**: 2.0.0 (April 2026)
**Status**: ✅ Complete and Ready for Testing
**Next Step**: Integration testing and deployment
