# 🔑 API KEYS & CONFIGURATION GUIDE

## QUICK ANSWER: What API Keys Do You Need?

For testing the app in a mobile vertical environment, you need **exactly 2 API keys**:

### 1. **Google Maps API Key** ✅ REQUIRED
- **What it does**: Enables the Map screen to show locations and nearby places
- **Cost**: FREE (with $200/month free tier)
- **Get it**: [Google Cloud Console](https://console.cloud.google.com/)
- **Takes**: 20-30 minutes

### 2. **Firebase Project** ✅ REQUIRED
- **What it does**: Enables push notifications
- **Cost**: FREE (with limits)
- **Get it**: [Firebase Console](https://console.firebase.google.com/)
- **Takes**: 20-30 minutes

### Everything else is **ALREADY CONFIGURED** ✅

---

## DETAILED SETUP

### Step 1: Get Google Maps API Key

**Location**: Google Cloud Console

**Steps**:
1. Go to https://console.cloud.google.com/
2. Click "Create Project" → Name it "Femi-Friendly"
3. Wait for project to create
4. Search for "Maps SDK for Android" → Click "Enable"
5. Search for "Maps SDK for iOS" → Click "Enable"
6. Go to "Credentials" on left sidebar
7. Click "Create Credentials" → "API Key"
8. Copy the key (looks like: `AIzaSyD...`)
9. Save it somewhere safe

**Then add it to your app**:

#### For Android:
Edit `android/app/build.gradle.kts`:
```kotlin
android {
    defaultConfig {
        // Add this line:
        manifestPlaceholders["MAPS_API_KEY"] = "AIzaSyD_YOUR_KEY_HERE"
    }
}
```

#### For iOS:
Edit `ios/Runner/Info.plist`:
```xml
<!-- Add after the closing </dict> of NSLocationUsageDescription -->
<key>com.google.ios.maps.API_KEY</key>
<string>AIzaSyD_YOUR_KEY_HERE</string>
```

**Status**: ⏳ PENDING

---

### Step 2: Setup Firebase

**Location**: Firebase Console

**Steps**:
1. Go to https://console.firebase.google.com/
2. Click "Create Project" → Name it "Femi-Friendly"
3. Wait for project to create
4. Click "Create App" → Choose "Android"
   - Package name: `com.example.femi_friendly`
   - Click "Register App"
   - Download `google-services.json`
   - Place it in: `android/app/google-services.json`
5. Click "Add App" → Choose "iOS"
   - Bundle ID: `com.example.femi_friendly`
   - Click "Register App"
   - Download `GoogleService-Info.plist`
   - Place it in: `ios/Runner/GoogleService-Info.plist`
6. Go to "Project Settings" (gear icon)
   - Copy Project ID
   - Go to "Cloud Messaging" tab
   - Copy Server Key (for backend, optional)

**Then update Android build file**:

Edit `android/app/build.gradle.kts`:
```kotlin
// Add at TOP of file:
plugins {
    id "com.google.gms.google-services"
}

// In dependencies section, add:
dependencies {
    implementation platform("com.google.firebase:firebase-bom:32.0.0")
    implementation "com.google.firebase:firebase-messaging"
}
```

**Then update iOS Podfile**:

Edit `ios/Podfile`:
```ruby
# Add this after the main Flutter app target:
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

Then run:
```bash
cd ios
pod install
cd ..
```

**Status**: ⏳ PENDING

---

### Step 3: Initialize in Flutter

**File**: `lib/main.dart`

**Current code**:
```dart
void main() {
  runApp(const FemiFriendlyApp());
}
```

**Change to**:
```dart
import 'package:femi_friendly/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initNotifications();
  
  runApp(const FemiFriendlyApp());
}
```

**Status**: ⏳ PENDING

---

## OPTIONAL: Additional Configuration

### Environment File (.env)

**File to create**: `.env` in project root

**Content**:
```
# Backend Configuration
API_BASE_URL=http://127.0.0.1:8000

# For physical device testing, change to:
# API_BASE_URL=http://192.168.1.100:8000
# (Replace 192.168.1.100 with your machine's IP from: ipconfig)

# Firebase Configuration (from Firebase Console)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-firebase-key
FIREBASE_SERVER_KEY=optional-for-backend-push

# JWT Configuration (already set, no change needed)
JWT_SECRET_KEY=your-secret-key-change-in-production
```

**Status**: ✅ OPTIONAL

---

*End of archived API_KEYS_SETUP.md*
