# FEMI-FRIENDLY — Consolidated Documentation (MASTER)

**Last Updated:** April 16, 2026
**Version:** v2.5.1

This master document consolidates previously scattered or partially-complete documentation into a single, actionable reference. It includes setup steps, API testing instructions, integration guidance, and a short spec for the product-recommendation API.

---

## Table of Contents
- Quick Start
- API Keys & Configuration
- Backend: Run & Test (Health & Endpoints)
- Integration: Flutter ↔ FastAPI
- Product Recommendation API (spec)
- Archive: Original files moved to `docs/archive/`
- Next Steps

---

## Quick Start

1. Start backend (Terminal A)

```bash
venv\\Scripts\\activate
python -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

2. Start frontend (Terminal B)

```bash
cd d:/project/ai-menstrual-health-app
flutter pub get
flutter run
```

Notes:
- For Android emulator the Flutter app uses `http://10.0.2.2:8000` as the backend default.
- For a physical device, replace the base URL in `lib/services/api_service.dart` with your machine IP (e.g. `http://192.168.1.100:8000`).

---

## API Keys & Configuration

- Maps: This project now uses OpenStreetMap tiles via `flutter_map` (no API key required). If you prefer Google Maps, follow the steps under "Optional: Google Maps Key" below.
- Firebase: Required if you want push notifications (manual step). See instructions below.

### Optional: Google Maps API Key (only if switching back to Google Maps)
1. Create or select a project in Google Cloud Console
2. Enable Maps SDK for Android & iOS
3. Create an API key (restrict by app/package name)
4. Add to `android/app/build.gradle.kts`:

```kotlin
android {
  defaultConfig {
    manifestPlaceholders["MAPS_API_KEY"] = "AIzaSyD_YOUR_KEY_HERE"
  }
}
```

For iOS, add to `ios/Runner/Info.plist`:

```xml
<key>com.google.ios.maps.API_KEY</key>
<string>AIzaSyD_YOUR_KEY_HERE</string>
```

### Firebase (Push Notifications)
1. Create Firebase project at https://console.firebase.google.com/
2. Register Android app with package `com.example.femi_friendly` and download `google-services.json` → place in `android/app/`
3. Register iOS app and download `GoogleService-Info.plist` → place in `ios/Runner/`
4. Add Firebase plugins and BOM to `android/app/build.gradle.kts` and include `com.google.gms.google-services` plugin per Firebase docs.
5. Initialize notifications in `lib/main.dart` (see `NotificationService().initNotifications()` example in archived API_KEYS_SETUP.md)

### Environment file (.env)
Create `.env` at project root (do not commit secrets):

```
API_BASE_URL=http://127.0.0.1:8000
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-firebase-key
JWT_SECRET_KEY=replace-in-production
```

---

## Backend: Run & Test (Health & Endpoints)

- Health check: `GET http://localhost:8000/health`
- API docs (interactive): `http://localhost:8000/docs`

### Common cURL examples

Health:

```bash
curl http://localhost:8000/health
```

Register test user:

```bash
curl -X POST http://localhost:8000/auth/register \\
  -H "Content-Type: application/json" \\
  -d '{"email":"test@example.com","password":"password123","age":28,"weight":65,"height":165,"cycle_length":28,"period_length":5}'
```

Predict:

```bash
curl -X POST http://localhost:8000/predict \\
  -H "Content-Type: application/json" \\
  -d '{"email":"test@example.com","age":28,"bmi":23.8,"cycle_length":28,"cycle_day":14}'
```

See `DEPLOYMENT_TESTING_GUIDE.md` in the archive for a longer set of sample requests.

---

## Integration: Flutter ↔ FastAPI

1. Ensure backend is running and reachable from device/emulator.
2. Emulator uses `10.0.2.2` to reach host machine. Physical device must use the host IP.
3. Run `flutter pub get` before `flutter run`.

Troubleshooting tips:
- If the app cannot reach the backend on a physical device, confirm Windows firewall rules or that both device and host are on the same LAN; then set `baseUrl` in `lib/services/api_service.dart` to your host IP.
- If `flutter pub get` fails, run `flutter clean` then `flutter pub get`.

---

## Product Recommendation API (SPEC)

This spec consolidates the product recommendation requirement into a simple request/response contract suitable for the FastAPI backend.

Endpoint: `POST /recommend-products`

Request JSON:

```json
{
  "cycle_phase": "menstrual",  
  "flow": "heavy",            
  "pain": "high",            
  "pregnancy_status": "not_pregnant"
}
```

Behavior (initial rule-based logic):
- If `pregnancy_status` == "pregnant" → recommend pregnancy supplements
- Else if `cycle_phase` == "menstrual" and `flow` in ["heavy","moderate"] → recommend sanitary pads and pain relief
- If `pain` in ["high","moderate"] → include pain relief products
- If `cycle_phase` == "follicular" or `flow` == "light" → suggest menstrual cup or femi-wash if relevant

Response JSON:

```json
{
  "products": [
    {"name": "UltraComfort Sanitary Pads", "reason": "Heavy flow protection", "link": "https://www.amazon.in/...", "image": "https://.../pads.jpg"},
    {"name": "PainRelief Tablets", "reason": "Recommended for high cramps", "link": "https://www.pharmeasy.in/...", "image": "https://.../pills.jpg"}
  ]
}
```

Notes for implementers:
- Store product documents in MongoDB with fields: `name`, `category`, `image_url`, `purchase_link`.
- Provide a seed script `api/seed_products.py` (not included here) to populate sample products for categories: `sanitary_pads`, `menstrual_cups`, `femi_wash`, `pain_relief`, `pregnancy_supplements`.
- Frontend must open `purchase_link` in external browser via `url_launcher`.

---

## Archive (original files)

As requested, the original files that contained pending items have been moved to `docs/archive/` to keep the repo root concise. The archived originals include:

- API_KEYS_SETUP.md
- PENDING_WORK_ROADMAP.md
- DEPLOYMENT_TESTING_GUIDE.md
- INTEGRATION_TESTING_GUIDE.md
- QUICKSTART.md

These archived files are exact copies of the originals and may contain historical notes and step-by-step instructions — use them for reference.

---

## Next Steps

1. If you want me to also implement the `POST /recommend-products` endpoint and seed MongoDB with product documents, I can add the backend code and a small `seed_products.py` script.
2. After code changes, run the test scenarios from the archived `DEPLOYMENT_TESTING_GUIDE.md` to verify everything.

---

*End of DOCUMENTATION_MASTER.md*
