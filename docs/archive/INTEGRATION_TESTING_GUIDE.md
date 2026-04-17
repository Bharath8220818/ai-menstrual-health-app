# Flutter-FastAPI Integration Testing Guide

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

1. Install Backend Dependencies

```bash
# Navigate to project root
cd d:\\project\\ai-menstrual-health-app

# Create virtual environment (if not existing)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\\Scripts\\activate

# On Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn pandas numpy scikit-learn python-multipart
```

2. Start the Backend Server

```bash
uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

*End of archived INTEGRATION_TESTING_GUIDE.md*
