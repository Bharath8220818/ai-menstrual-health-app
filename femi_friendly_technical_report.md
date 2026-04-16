# Femi-Friendly: Project Analysis and Completion Report

Updated on: April 14, 2026

## 1. Current Project Status (Folder Analysis)

This repository contains:
- A Flutter app (`lib/`) with UI for auth, cycle tracking, pregnancy mode, AI insights, chat, profile, notifications, and water tracking.
- A Python AI/ML layer (`ai_model/`) with preprocessing, model training, and prediction logic.
- A Python API layer (`api/`) using FastAPI routes and service wrappers.

What is already working:
- Multi-screen Flutter app with Provider-based state management.
- Cycle history calculations (predicted length, status, trends).
- Pregnancy mode UI and trimester guidance content.
- Backend prediction wrappers (`/predict/cycle`, `/predict/irregular`, `/predict/fertility`, `/recommend`).
- Trained model artifact present (`ai_model/model.pkl`).

Main gaps found:
- Frontend AI screens and chat are still local/simulated, not connected to backend API.
- App state is mostly in-memory only (lost on restart).
- Auth flow is demo-only and inconsistent (`register` vs `login` behavior).
- `ReportScreen` exists but is not wired into route/tab navigation.
- `requirements.txt` is mismatched (lists Flask while backend code is FastAPI).
- README is still default template and does not document real setup/run flow.

---

## 2. Functions to Add

Below is the practical function backlog required to complete the project.

### 2.1 Frontend (Flutter)

1. API client and network layer
- `Future<Map<String, dynamic>> predictAll(Map<String, dynamic> payload)`
- `Future<Map<String, dynamic>> recommend(Map<String, dynamic> payload)`
- `Future<Map<String, dynamic>> sendChatMessage(String message, List<Map<String, String>> history)`

Suggested file: `lib/services/api_client.dart`

2. Chat integration
- `Future<void> sendMessageToApi(String text)` in `ChatProvider`
- `Map<String, dynamic> _buildChatContext()` for request payload construction
- `String _extractAssistantReply(Map<String, dynamic> response)` for robust parsing

Suggested file update: `lib/providers/chat_provider.dart`

3. Insights integration
- `Future<void> fetchInsights()` to replace static insight values
- `Map<String, dynamic> buildPredictionPayload()` from `AuthProvider + CycleProvider`
- `void refreshInsights()` for pull-to-refresh / manual refresh

Suggested files:
- `lib/providers/insights_provider.dart` (new)
- `lib/screens/insights/ai_insights_screen.dart` (consume provider)

4. Persistence functions (app restart safety)
- `Future<void> loadSession()` / `Future<void> saveSession()` in `AuthProvider`
- `Future<void> loadCycleEntries()` / `Future<void> saveCycleEntries()` in `CycleProvider`
- `Future<void> loadPregnancyState()` / `Future<void> savePregnancyState()` in `PregnancyProvider`
- `Future<void> loadWaterState()` / `Future<void> saveWaterState()` for water tracking

Suggested storage: `shared_preferences` initially, then migrate to `Hive/Isar` if needed.

5. Auth flow completion
- `Future<bool> loginWithCredentials(String email, String password)` (not demo-only)
- `Future<bool> registerUser(...)` with stored user record or backend auth
- `Future<void> logoutAndClearSession()`

Current issue to fix: `register()` sets state, but `login()` only accepts hardcoded demo credentials.

6. Cycle CRUD improvements
- `void updateCycle(int index, CycleEntry entry)`
- `void deleteCycle(int index)`
- `bool validateCycleRange(DateTime start, DateTime end)`

Suggested file update: `lib/providers/cycle_provider.dart`

7. Routing and flow control
- `Future<String> resolveInitialRoute()` to choose splash/landing/onboarding/login/home based on first run + auth state.
- Add route for report screen: `AppRoutes.report`.

Current issue to fix: splash directly navigates to login; onboarding/landing flow is bypassed.

### 2.2 Backend (API + AI)

1. API completeness and standardization
- `GET /health` endpoint for uptime checks
- `POST /predict` unified endpoint (already supported in model layer via `predict_all`, not exposed as API route)
- `POST /chat` endpoint (if AI chat is expected from backend)

Suggested files:
- `api/routes.py`
- `api/services.py`

2. Input validation hardening
- `validate_numeric_ranges(payload)` before inference
- `normalize_categorical_inputs(payload)` for safe encoder handling

Suggested file: `api/services.py`

3. Prediction output consistency
- Fix probability handling in `ai_model/predict.py`:
  - currently `round(preg_prob, 4) if preg_prob else None` turns `0.0` into `None`
  - should check `preg_prob is not None`

4. Dependency correction
- Replace Flask packages with FastAPI stack in `requirements.txt`:
  - `fastapi`
  - `uvicorn`
  - `pydantic`

### 2.3 Testing and Quality

1. Flutter tests
- Provider unit tests (`AuthProvider`, `CycleProvider`, `ChatProvider`)
- Widget tests for route flow and form validation

2. Backend tests
- API contract tests for all endpoints
- Model wrapper tests for expected output schema and edge cases

3. Integration tests
- End-to-end test from Flutter request payload to API response rendering in AI screens.

---

## 3. Next Steps to Complete the Folder

Priority plan:

1. Fix blockers (Day 1)
- Correct `requirements.txt` for FastAPI.
- Add `/health` endpoint.
- Validate backend starts cleanly.

2. Connect frontend to backend (Days 1-2)
- Create `lib/services/api_client.dart`.
- Integrate real calls in `ChatProvider` and AI Insights.
- Add loading/error/empty states for network failures.

3. Make data persistent (Days 2-3)
- Add provider load/save methods using `shared_preferences`.
- Persist auth session, cycle entries, pregnancy mode, and water progress.

4. Correct app flow and routing (Day 3)
- Implement first-run route resolver.
- Wire `Landing -> Onboarding -> Login` correctly.
- Add report route entry and navigation access.

5. Stabilize auth and profile setup (Day 3)
- Align register/login behavior.
- Persist actual registered profile.
- Ensure profile setup name field is used when setup completes.

6. Add tests and docs (Days 4-5)
- Add core provider and API tests.
- Replace default README with real setup commands for Flutter + backend.
- Document API request/response schemas.

---

## 4. Definition of Complete

Folder can be considered complete when:
- AI Insights and Chat use live backend calls (no simulated-only logic).
- User data survives app restart.
- Auth flow is consistent for non-demo users.
- All major screens/routes are reachable through intended flow.
- Backend dependencies and endpoints are aligned with implementation.
- Core tests pass and README documents exact run steps.

---

## 5. Tools and Software Required for Next Steps

To continue development and run the full project end-to-end, you need:

1. Core tools
- Git
- VS Code (or Android Studio)
- PowerShell / terminal

2. Flutter stack
- Flutter SDK (stable channel, Dart included)
- Android Studio (Android SDK + emulator) for Android testing
- Chrome (for `flutter run -d chrome`)
- Xcode (macOS only, if iOS build is needed)

3. Python backend stack
- Python 3.10+ recommended
- `pip` and virtual environment tool (`venv`)
- Required packages from `requirements.txt`:
  - fastapi
  - uvicorn
  - pydantic
  - numpy
  - pandas
  - scikit-learn
  - joblib

4. Optional but recommended
- Postman or Insomnia (API testing)
- Docker Desktop (for containerized deployment)
- pytest (backend automated tests)

5. Runtime configuration needed
- Backend base URL for Flutter via Dart define:
  - `--dart-define=API_BASE_URL=http://127.0.0.1:8000`
- CORS is already enabled in backend for development.
