# femi_friendly

A Flutter application that provides menstrual-health tracking, AI-driven insights, and recommendations.

## Documentation

- Full consolidated documentation (master): [DOCUMENTATION_MASTER.md](DOCUMENTATION_MASTER.md)
- Documentation index: [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)

## Getting Started

1. Start backend

```bash
venv\\Scripts\\activate
python -m uvicorn api.main:app --reload --host 0.0.0.0 --port 8000
```

2. Start the Flutter app

```bash
cd d:/project/ai-menstrual-health-app
flutter pub get
flutter run
```

## Quick Links

- API docs: `http://localhost:8000/docs`
- Health check: `http://localhost:8000/health`

If you prefer, open the consolidated docs for full setup, testing, and integration instructions: [DOCUMENTATION_MASTER.md](DOCUMENTATION_MASTER.md)
