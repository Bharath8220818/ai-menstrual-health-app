# 🌸 FEMI-FRIENDLY - Complete Implementation Guide

## 🚀 Quick Start

### Backend Setup (FastAPI)

1. **Install Dependencies**
```bash
cd d:/project/ai-menstrual-health-app
python -m venv .venv
# On Windows
.\.venv\Scripts\activate
# On macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt
```

2. **Prepare Data Directory**
```bash
mkdir -p data/
# The app will auto-create users.json and cycles.json in data/
```

3. **Run Backend Server**
```bash
python -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`
API Docs at: `http://localhost:8000/docs`

### Frontend Setup (Flutter)

1. **Install Flutter Dependencies**
```bash
cd lib/
flutter pub get
```

2. **Configure Backend URL**
Edit `lib/services/api_service.dart`:
- **Android Emulator**: `http://10.0.2.2:8000`
- **Real Device**: `http://<YOUR_IP>:8000` (e.g., 192.168.1.5)
- **Web**: `http://localhost:8000`

3. **Run Flutter App**

```bash
# Android
flutter run -d emulator-5554

# iOS
flutter run -d iPhone

# Web
flutter run -d chrome
```

---

## 📋 API Endpoints (v2.0)

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login user
- `GET /auth/profile/{email}` - Get user profile
- `PUT /auth/profile/{email}` - Update user profile

### Cycle Tracking
- `POST /cycle-history/add` - Add cycle entry
- `GET /cycle-history/history/{email}` - Get cycle history
- `GET /cycle-history/stats/{email}` - Get cycle statistics
- `PUT /cycle-history/entry/{email}/{date}` - Update entry
- `DELETE /cycle-history/entry/{email}/{date}` - Delete entry

### Predictions
- `POST /predict` - Unified cycle/fertility prediction
- `POST /predict/cycle` - Cycle length prediction only
- `POST /predict/irregular` - Irregularity detection
- `POST /predict/fertility` - Fertility probability

### Recommendations
- `POST /recommend` - Basic health recommendations
- `POST /daily-recommendations` - Comprehensive daily health plan
- `POST /nutrition-plan` - Personalized nutrition plan
- `POST /cycle-intelligence` - Advanced cycle analysis

### Advanced Features
- `POST /fertility-insights` - Fertility scoring & insights
- `POST /pregnancy-insights` - Pregnancy week tracking
- `POST /mental-health` - Mental health assessment
- `POST /health-alerts` - Smart health alerts
- `POST /notifications` - Personalized notifications
- `POST /chat` - AI chatbot responses

### Utility
- `GET /health` - API health check

---

## 🎯 Features Overview

### ✅ Completed Features
- Authentication (login/register/profile)
- Cycle tracking & history
- AI predictions (cycle, fertility, irregularity)
- Health recommendations
- Chatbot with AI responses
- Mental health tracking
- Pregnancy insights
- Nutrition planning
- Health alerts & notifications
- Dashboard with cycle visualization

### 🔄 In Progress
- Report upload & analysis
- Map integration (hospitals/stores)
- Advanced notifications (email/SMS)

---

## 📁 Project Structure

```
femi_friendly/
├── api/                          # FastAPI Backend
│   ├── main.py                   # App entry point
│   ├── auth.py                   # Authentication routes
│   ├── cycle_history.py          # Cycle tracking routes
│   ├── routes.py                 # Main prediction routes
│   ├── services.py               # Business logic layer
│   └── schemas.py                # Input/output models
│
├── ai_model/                     # Machine Learning
│   ├── predict.py                # Core predictions
│   ├── recommendation.py          # Recommendations engine
│   ├── advanced_models.py        # v2.0 Features
│   ├── nutrition_engine.py       # Nutrition planning
│   ├── alert_notification_system.py  # Alerts
│   ├── daily_health_engine.py    # Daily recommendations
│   ├── train.py                  # Model training
│   └── model.pkl                 # Trained model (binary)
│
├── lib/                          # Flutter Frontend
│   ├── main.dart                 # App entry point
│   ├── screens/                  # UI Screens
│   │   ├── auth/                 # Login/Register
│   │   ├── dashboard/            # Home page
│   │   ├── cycle/                # Cycle tracker
│   │   ├── pregnancy/            # Pregnancy mode
│   │   ├── chat/                 # Chatbot
│   │   ├── insights/             # AI insights
│   │   ├── profile/              # Settings
│   │   └── ...
│   ├── providers/                # State Management
│   │   ├── auth_provider.dart
│   │   ├── cycle_provider.dart
│   │   ├── ai_provider.dart
│   │   └── ...
│   ├── services/                 # API Integration
│   │   └── api_service.dart      # HTTP client
│   ├── models/                   # Data models
│   ├── widgets/                  # Reusable components
│   ├── core/                     # Constants, theme
│   └── routes/                   # Navigation
│
├── data/                         # Data Storage
│   ├── users.json                # User profiles
│   └── cycles.json               # Cycle history
│
├── requirements.txt              # Python dependencies
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # This file
```

---

## 🔐 Authentication Flow

1. **Registration** (`/auth/register`)
   - Create user account
   - Store profile (age, weight, height)
   - Return JWT token

2. **Login** (`/auth/login`)
   - Validate credentials
   - Return JWT token + user profile

3. **Profile Management**
   - Update personal info
   - Modify cycle settings
   - Save preferences

---

## 📊 Data Flow Example

**User submits cycle data:**
1. Flutter app collects: date, flow intensity, symptoms
2. Sends to `/cycle-history/add`
3. Backend stores in `data/cycles.json`
4. User sees updated cycle in calendar

**User requests predictions:**
1. Flutter app sends profile + cycle history to `/predict`
2. Backend AI model processes data
3. Returns: cycle_phase, fertility_window, pregnancy_chance
4. Flutter displays recommendations

---

## 🎨 UI/UX Features

- **Pink Theme**: Primary color `#E91E63`
- **Soft Gradients**: Smooth pink/purple fades
- **Rounded Cards**: 16px border radius
- **Smooth Animations**: Fade, slide, pulse effects
- **Responsive Design**: Works on all screen sizes
- **Bottom Navigation**: 5-tab navigation system

---

## 🧪 Testing the API

### Using cURL

```bash
# Check health
curl http://localhost:8000/health

# Make prediction
curl -X POST http://localhost:8000/predict \
  -H "Content-Type: application/json" \
  -d '{
    "age": 28,
    "bmi": 22.5,
    "cycle_length": 28,
    "cycle_day": 14,
    "stress_level": "Low"
  }'
```

### Using Postman
1. Import collection from API docs: `http://localhost:8000/openapi.json`
2. Test endpoints with sample data
3. Verify responses

---

## 🔧 Configuration

### Backend Configuration (api/main.py)
```python
# Update CORS origins for production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com"],  # Specify origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Frontend Configuration (lib/services/api_service.dart)
```dart
// Update for your environment
static const String baseUrl = 'YOUR_API_URL_HERE';
```

---

## 📱 Flutter App Features

### Authentication Screens
- **Login**: Email + password authentication
- **Register**: Create new account with profile
- **Onboarding**: Guided setup wizard

### Main Screens (Bottom Tab Navigation)
1. **Dashboard**: Daily cycle status & recommendations
2. **Calendar**: Monthly cycle tracker with predictions
3. **AI Insights**: Advanced predictions & analysis
4. **Pregnancy**: Pregnancy tracking & week-by-week info
5. **Profile**: Settings & user preferences

### Additional Screens
- **Chatbot**: AI chat for health questions
- **Notifications**: Alerts & reminders
- **Water Tracker**: Daily hydration tracking
- **Phase Detail**: Detailed phase information

---

## 🚨 Troubleshooting

### Backend Issues

**"Cannot connect to backend"**
- Ensure backend is running: `python -m uvicorn api.main:app --reload`
- Check firewall settings
- Verify IP address in Flutter API service
- Check backend logs for errors

**"Model not found"**
- Train model: `python ai_model/train.py`
- Ensure `model.pkl` exists in `ai_model/` directory

### Flutter Issues

**"API request timed out"**
- Increase timeout in `api_service.dart`
- Check network connectivity
- Verify backend is responding

**"CORS error"**
- Update CORS configuration in `api/main.py`
- Ensure correct origin is allowed

---

## 📈 Performance Tips

1. **Backend Optimization**
   - Use connection pooling for database
   - Cache model predictions
   - Implement request rate limiting

2. **Frontend Optimization**
   - Use image caching
   - Lazy load list items
   - Minimize widget rebuilds

3. **Data Management**
   - Archive old cycle data
   - Clean up logs regularly
   - Use pagination for large datasets

---

## 🔮 Future Enhancements

- [ ] Database integration (PostgreSQL)
- [ ] File upload for health reports
- [ ] Map integration (hospitals, pharmacies)
- [ ] Email/SMS notifications
- [ ] Doctor consultation booking
- [ ] Social sharing features
- [ ] Machine learning model improvements
- [ ] Advanced analytics dashboard
- [ ] Mobile app push notifications
- [ ] Web platform support

---

## 📄 License

This project is proprietary. All rights reserved.

---

## 📞 Support

For issues or questions:
1. Check existing documentation
2. Review API error responses
3. Check backend logs: `logs/femi_friendly.log`
4. Verify configuration settings

---

**Last Updated**: April 2026  
**Version**: 2.0.0
