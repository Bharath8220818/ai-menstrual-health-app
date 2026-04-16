# Flutter-FastAPI Integration Testing Guide

## Overview

This guide walks you through testing the complete integration between the Flutter frontend, FastAPI backend, and AI models for the Femi-Friendly app.

## ✅ Prerequisites

Before testing, ensure:
- ✓ Python 3.9+ installed
- ✓ Flutter SDK installed
- ✓ Android SDK/iOS SDK configured
- ✓ FastAPI backend dependencies installed
- ✓ All Python files in place (`api/`, `ai_model/`)
- ✓ `lib/services/api_service.dart` created
- ✓ `lib/providers/ai_provider.dart` created
- ✓ `lib/screens/ai_insights_screen.dart` created
- ✓ `lib/main.dart` updated with `AIProvider`

---

## 📋 Step 1: Start the FastAPI Backend

### 1.1 Install Backend Dependencies

```bash
# Navigate to project root
cd d:\project\ai-menstrual-health-app

# Create virtual environment (if not existing)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate

# On Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn pandas numpy scikit-learn python-multipart
```

### 1.2 Start the Backend Server

```bash
# From project root with venv activated
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

**Expected Output:**
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
```

### 1.3 Verify Backend is Running

Open browser to: **http://127.0.0.1:8000/docs**

You should see the Swagger UI with all endpoints listed:
- `POST /predict` ← Main endpoint used by Flutter
- `GET /predict-cycle`
- `GET /recommendations`
- And 8+ others

---

## 🧪 Step 2: Test Backend Endpoints Manually

### 2.1 Test the `/predict` Endpoint

**Using Swagger UI (easiest):**
1. Go to http://127.0.0.1:8000/docs
2. Find the `POST /predict` endpoint
3. Click "Try it out"
4. Paste this sample data in the request body:

```json
{
  "age": 28,
  "bmi": 22.5,
  "cycle_length": 28,
  "stress": 6,
  "sleep": 7.5,
  "weight": 65.5,
  "exercise": "moderate",
  "symptoms": ["cramping", "bloating"]
}
```

5. Click "Execute"
6. **Expected Response (Status 200):**

```json
{
  "status": "Regular",
  "cycle_length": 28.0,
  "water_intake": 2.5,
  "food_recommendations": [
    "Iron-rich foods for menstrual phase",
    "Protein-rich foods for follicular phase"
  ],
  "health_tips": [
    "Drink plenty of water daily",
    "Manage stress with yoga"
  ],
  "recommendations": [
    "Track symptoms daily for better insights"
  ]
}
```

### 2.2 Test Using cURL (Alternative)

```bash
curl -X POST "http://127.0.0.1:8000/predict" \
  -H "Content-Type: application/json" \
  -d '{
    "age": 28,
    "bmi": 22.5,
    "cycle_length": 28,
    "stress": 6,
    "sleep": 7.5,
    "weight": 65.5,
    "exercise": "moderate",
    "symptoms": ["cramping"]
  }'
```

### 2.3 Check Backend Logs

Watch the terminal where you ran `uvicorn` for logs like:
```
INFO:     127.0.0.1:52345 - "POST /predict HTTP/1.1" 200 OK
```

---

## 📱 Step 3: Run Flutter App

### 3.1 Get Dependencies

```bash
# From project root
flutter pub get
```

### 3.2 Run on Android Emulator

```bash
# List available devices
flutter devices

# Run on emulator
flutter run -d emulator-5554

# Or let Flutter choose:
flutter run
```

**For Android Emulator:**
- The app will automatically use `10.0.2.2:8000` (host machine localhost)
- This is the default IP address in `api_service.dart`

### 3.3 Run on Physical Device

**IMPORTANT:** For physical Android device, you must update the backend IP:

1. Find your machine's local IP:
   ```bash
   # On Windows
   ipconfig
   
   # Look for "IPv4 Address" (usually 192.168.x.x or 10.0.x.x)
   ```

2. Update `lib/services/api_service.dart`:
   ```dart
   // Change this line:
   static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
   
   // To your machine's IP:
   static const String baseUrl = 'http://192.168.1.100:8000'; // Replace with your IP
   ```

3. Rebuild and run:
   ```bash
   flutter run
   ```

### 3.4 Run on Web (Optional)

```bash
flutter run -d chrome

# Run on specific port
flutter run -d chrome --web-port=3000
```

---

## 🔌 Step 4: Test Integration

### 4.1 Navigate to AI Insights Screen

1. Launch the app
2. Navigate to the **🤖 AI Health Insights** screen (via navigation drawer or routes)
3. You should see the input form with:
   - Age, BMI, Cycle Length inputs
   - Stress level slider
   - Sleep hours input
   - Exercise level dropdown
   - Symptom checkboxes

### 4.2 Fill in Sample Data

Enter the following:
- **Age:** 28
- **BMI:** 22.5
- **Cycle Length:** 28
- **Stress:** 6 (move slider)
- **Sleep:** 7.5
- **Weight:** 65.5
- **Exercise:** Moderate
- **Symptoms:** Check "cramping" and "bloating"

### 4.3 Submit Form

1. Tap the **"Get AI Prediction"** button
2. Screen should show:
   - 🔄 Loading indicator appears ("Processing your data...")
   - Spinner animation shows in center

### 4.4 Wait for Results

After 2-5 seconds, you should see:
- ✅ Success card appears
- 📊 Results display:
  - **Cycle Status:** (e.g., "Regular")
  - **Predicted Cycle Length:** 28.0 days
  - **Daily Water Intake:** 2.5 L
  - 🥗 Food Recommendations (list)
  - 💡 Health Tips (list)
  - 📋 Recommendations (list)

### 4.5 Check Backend Logs

In the terminal where you ran `uvicorn`, you should see:
```
INFO:     127.0.0.1:XXXXX - "POST /predict HTTP/1.1" 200 OK
```

---

## 🐛 Troubleshooting

### Issue 1: "Connection refused" or "Failed to connect"

**Cause:** Backend not running

**Solution:**
```bash
# Make sure backend is running
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000

# Verify it's running:
# Open http://127.0.0.1:8000/docs in browser
```

### Issue 2: "Connection timeout" (30 seconds)

**Cause:** Backend is running but not responding

**Solution:**
- Check backend logs for errors
- Make sure FastAPI app started without errors
- Try the Swagger endpoint manually first

### Issue 3: Empty or "N/A" results

**Cause:** API returned data but parsing failed

**Solution:**
- Open browser DevTools (F12 on Chrome)
- Look for network requests in Network tab
- Check the response JSON matches expected format

### Issue 4: "Error: Phone could not connect to X.X.X.X"

**Cause:** Wrong IP address for physical device

**Solution:**
1. Find your machine's correct IP:
   ```bash
   ipconfig
   ```
2. Update `lib/services/api_service.dart` with correct IP
3. Rebuild: `flutter clean && flutter run`

### Issue 5: Android Emulator Error "10.0.2.2 refused connection"

**Cause:** Backend not running, or port not accessible

**Solution:**
```bash
# Ensure backend is on 0.0.0.0 (all interfaces):
uvicorn api.main:app --host 0.0.0.0 --port 8000
```

---

## 📊 Step 5: Debug Logging

### 5.1 Flutter Debug Logs

Run with verbose logging:
```bash
flutter run -v
```

Look for API service logs like:
```
I/flutter (12345): 🔄 Fetching prediction from: http://10.0.2.2:8000/predict
I/flutter (12345): 📤 Request body: {...}
I/flutter (12345): ✅ Response Status: 200
I/flutter (12345): 📥 Response body: {...}
```

### 5.2 Backend Debug Logs

Backend logs appear in Uvicorn terminal:
```
INFO:     127.0.0.1:52345 - "POST /predict HTTP/1.1" 200 OK
```

Check for errors:
```
ERROR:     Exception in ASGI application
```

### 5.3 Real Device Testing

For physical device, install app and view logs:

**Android:**
```bash
flutter logs
```

**iOS:**
```bash
flutter logs -v
```

---

## ✨ Step 6: Test Edge Cases

### 6.1 Invalid Input

Try submitting with invalid data to verify validation:
- **Age:** 0 or 150 → Should see validation error
- **BMI:** 5 or 100 → Should see validation error
- **Cycle Length:** 10 or 80 → Should see validation error

**Expected:** Snackbar shows "❌ Please fill in all required fields"

### 6.2 Network Failure

Stop the backend and try to submit:
```bash
# In backend terminal, press Ctrl+C to stop server
```

**Expected:** 
- Loading indicator shows for 30 seconds
- Then error card appears: "❌ Error - Is the backend running on 10.0.2.2:8000?"
- Retry button available

### 6.3 Retry After Failure

1. After seeing error, tap "🔄 Retry"
2. Before backend comes back, it should fail again
3. Restart backend and tap Retry again
4. Should see success

---

## 📈 Step 7: Performance Testing

### 7.1 Response Time

Measure time from "Get AI Prediction" click to results display:
- **Expected:** 2-5 seconds
- **Acceptable:** Up to 10 seconds
- **Too slow:** >30 seconds (timeout limit)

### 7.2 Memory Usage

Monitor app memory in profiler:
- Flutter DevTools: `flutter pub global run devtools`
- Should not exceed 200MB for basic operation

### 7.3 Multiple Requests

Try submitting 5 different predictions:
- Each should complete independently
- No crashes or memory leaks
- Results update correctly each time

---

## ✅ Test Checklist

Use this checklist to verify complete integration:

```
Backend:
  [ ] FastAPI server starts without errors
  [ ] Swagger UI loads at http://127.0.0.1:8000/docs
  [ ] POST /predict endpoint accessible
  [ ] Manual API test via Swagger returns 200 with valid JSON

Frontend - Setup:
  [ ] Flutter pub get completes
  [ ] lib/services/api_service.dart exists
  [ ] lib/providers/ai_provider.dart exists
  [ ] lib/main.dart includes AIProvider in MultiProvider
  [ ] App compiles without errors

Frontend - Functionality:
  [ ] AI Insights screen displays form
  [ ] Form input validation works (invalid data rejected)
  [ ] Submit button triggers API call
  [ ] Loading indicator shows during request
  [ ] Results display after success
  [ ] Error handling works (shows error card with retry)
  [ ] Retry button works after error
  [ ] Pull-to-refresh works

Integration:
  [ ] Data sent from app matches backend expectations
  [ ] Response data displayed correctly in results
  [ ] Multiple requests work independently
  [ ] Network failure handled gracefully
  [ ] Response time acceptable (<5 seconds)
  [ ] No crashes or memory leaks
```

---

## 🎯 Success Criteria

✅ **Integration Complete When:**

1. **Backend Ready:**
   - Uvicorn running without errors
   - Swagger UI accessible
   - POST /predict returns valid responses

2. **Frontend Ready:**
   - AI Insights screen loads
   - Form validates input
   - API calls successful

3. **Full Integration:**
   - Form data → Backend → AI Model → Results display
   - All 4 components working together
   - Error handling working
   - No timeouts or connection issues

---

## 📞 Support

If you encounter issues:

1. **Check logs** - Both Flutter and Backend logs
2. **Verify IPs** - Correct IP for your device type
3. **Test endpoint** - Use Swagger to test backend directly
4. **Check dependencies** - Run `flutter pub get` and `pip install -r requirements.txt`
5. **Restart services** - Stop and restart both backend and app

---

## 🎉 Next Steps After Integration

Once integration is complete:

1. Update other screens to use AIProvider
2. Add more AI features (fertility, pregnancy insights, etc.)
3. Implement local caching with `shared_preferences`
4. Add push notifications
5. Deploy backend to production server
6. Build release APK/IPA for app store

---

**Created:** 2025-02-14  
**Updated:** Phase 5 - Flutter-FastAPI Integration
