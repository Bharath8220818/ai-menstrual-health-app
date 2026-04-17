# 🌸 FEMI-FRIENDLY - Deployment & Testing Guide

## ✅ SYSTEM STATUS: PRODUCTION-READY

**Backend Status**: 🟢 RUNNING  
**API Health**: ✅ Responding  
**Version**: 2.0.0  
**All Features**: Activated

---

## 🚀 LIVE BACKEND

### Server Details
- **URL**: `http://localhost:8000`
- **API Docs**: `http://localhost:8000/docs` (Interactive Swagger UI)
- **Status Endpoint**: `http://localhost:8000/health`

---

## 🧪 TESTING THE API

### Option 1: Interactive API Documentation
Visit: `http://localhost:8000/docs`

This opens a live Swagger UI where you can:
- See all available endpoints
- Test endpoints directly from the browser
- View request/response formats
- Try different parameters

### Option 2: Using cURL Commands

#### 1. Health Check
```bash
curl http://localhost:8000/health
```

#### 2. Register a Test User
```bash
curl -X POST http://localhost:8000/auth/register \\
  -H "Content-Type: application/json" \\
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "age": 28,
    "weight": 65,
    "height": 165,
    "cycle_length": 28,
    "period_length": 5
  }'
```

*End of archived DEPLOYMENT_TESTING_GUIDE.md*
