# ⚡ QUICK START - NEW FEATURES v2.5.0

**Setup Time**: 5 minutes  
**Complexity**: Beginner-friendly  
**Status**: Ready to use  

---

## 🔧 SETUP (Copy & Paste)

### 1. Install Dependencies
```bash
flutter pub get
flutter pub upgrade
```

### 2. Update main.dart
```dart
import 'package:femi_friendly/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  await NotificationService().initNotifications();
  
  runApp(const MyApp());
}
```

### 3. Test Everything Works
```bash
flutter run
```

---

## 🔔 USE NOTIFICATIONS

### Schedule Water Reminders
```dart
import 'package:femi_friendly/services/notification_service.dart';

final service = NotificationService();

await service.scheduleWaterReminders([
  "10:00",
  "13:00",
  "16:00",
  "19:00",
]);
```

### Show Instant Notification
```dart
await service.showInstantNotification(
  title: "Time to Drink Water",
  body: "Stay hydrated! 💧",
  type: "water_reminder",
);
```

### Alert for Period
```dart
final nextPeriod = DateTime.now().add(Duration(days: 14));
await service.scheduleCycleAlert(nextPeriod);
```

### Fertility Alerts
```dart
await service.scheduleFertilityAlerts([12, 13, 14, 15, 16]);
```

### Pregnancy Update
```dart
await service.schedulePregnancyUpdate(
  weekNumber: 10,
  nextUpdateDate: DateTime.now().add(Duration(days: 7)),
);
```

---

## 🗺️ USE MAPS

### Navigate to Map
```dart
Navigator.pushNamed(context, AppRoutes.mapScreen);
```

That's it! The screen handles:
- ✅ Current location
- ✅ Nearby places
- ✅ Filtering
- ✅ Details popup
- ✅ Phone/Directions

---

## 🎬 USE ANIMATIONS

### Use Animated Card
```dart
import 'package:femi_friendly/widgets/animated_widgets.dart';

AnimatedCard(
  child: Text('Hello'),
  backgroundColor: Colors.white,
  animationDuration: Duration(milliseconds: 600),
)
```

### Use Animated List
```dart
ListView.builder(
  itemCount: 10,
  itemBuilder: (context, index) {
    return AnimatedListItem(
      index: index,
      delay: Duration(milliseconds: 100),
      child: ListTile(title: Text('Item $index')),
    );
  },
)
```

### Use Progress Animation
```dart
AnimatedProgressBar(
  value: 0.75,
  height: 8.0,
  valueColor: Color(0xFFE91E63),
)
```

### Show Loading Dialog
```dart
showDialog(
  context: context,
  builder: (_) => LottieLoadingDialog(
    message: 'Loading...',
    animationPath: 'assets/animations/loading.json',
  ),
);
```

### Use Lottie Animation
```dart
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/animations/splash.json',
  repeat: true,
  animate: true,
)
```

---

## 🎨 ANIMATION OPTIONS

### Available Animations
- `loading.json` - Rotating circle
- `splash.json` - Heart pulse
- `cycle_progress.json` - Cycle circle
- `pregnancy.json` - Baby growth

### Available Widgets
- `AnimatedCard` - Fade + scale
- `AnimatedListItem` - Slide + fade
- `AnimatedProgressBar` - Smooth fill
- `FadeInAnimation` - Simple fade
- `ScaleAndFadeAnimation` - Combined
- `SlideInAnimation` - Slide
- `LottieLoadingDialog` - Dialog
- `AnimatedSplashScreen` - Splash

---

## 🔌 API ENDPOINTS

### Schedule Notifications
```bash
curl "http://localhost:8000/notifications/schedule?email=user@example.com&cycle_length=28&days_until_period=14"
```

Response:
```json
{
  "water_reminder": ["10:00", "13:00", "16:00", "19:00"],
  "cycle_alert": "2026-04-20",
  "fertility_days": [12, 13, 14, 15, 16],
  "pregnancy_week": null
}
```

### Get Nearby Places
```bash
curl "http://localhost:8000/nearby?lat=40.7128&lng=-74.0060&type=hospitals&radius=5"
```

### Get Notification History
```bash
curl "http://localhost:8000/notifications/history?email=user@example.com"
```

### Clear Notifications
```bash
curl -X DELETE "http://localhost:8000/notifications/clear?email=user@example.com"
```

---

## 📱 ROUTES

### Navigate to New Screens
```dart
// Map screen
Navigator.pushNamed(context, AppRoutes.mapScreen);

// Animated splash
Navigator.pushNamed(context, AppRoutes.animatedSplash);

// Nutrition planner
Navigator.pushNamed(context, AppRoutes.nutritionPlanner);

// Fertility insights
Navigator.pushNamed(context, AppRoutes.fertilityInsights);

// Mental health
Navigator.pushNamed(context, AppRoutes.mentalHealth);
```

---

## 🧪 TEST LOCALLY

### Test Notifications
```dart
void testNotifications() async {
  final service = NotificationService();
  
  // Test instant
  await service.showInstantNotification(
    title: "Test",
    body: "This is a test",
    type: "test",
  );
  
  // Test water reminders
  await service.scheduleWaterReminders(["14:00"]);
}
```

### Test Map
1. Run app: `flutter run`
2. Navigate to map: Tap map button or use `AppRoutes.mapScreen`
3. Verify:
   - Location permission requested
   - Map loads
   - Markers show
   - Filters work

### Test Animations
1. Run app: `flutter run`
2. Navigate to `AppRoutes.animatedSplash`
3. Observe smooth animations
4. Should redirect to login after 4s

---

## 🚨 TROUBLESHOOTING

### Notifications not working?
```dart
// Check if initialized
final service = NotificationService();
// Should have been called in main()

// Manual test
await service.showInstantNotification(
  title: "Test",
  body: "Check device notifications",
  type: "test",
);
```

### Maps blank?
- Check Google Maps API key is set
- Verify Maps SDK enabled in Google Cloud
- Try on real device
- Check location permission

### Animations stuttering?
- Run on real device (not emulator)
- Check FPS in dev tools
- Simplify animations if needed
- Profile with `flutter run --profile`

### "Missing dependency" error?
```bash
flutter pub get
flutter pub upgrade
flutter clean
flutter pub get
flutter run
```

---

## 💡 TIPS & TRICKS

### Combine Multiple Animations
```dart
ScaleAndFadeAnimation(
  child: SlideInAnimation(
    child: MyWidget(),
  ),
)
```

### Batch Notifications
```dart
final service = NotificationService();

// Schedule multiple at once
await Future.wait([
  service.showInstantNotification(...),
  service.scheduleWaterReminders([...]),
  service.scheduleCycleAlert(...),
]);
```

### Check Notification Permission
```dart
// In notification_service.dart (already done)
final settings = await _firebaseMessaging.requestPermission();
```

### Customize Animation Duration
```dart
FadeInAnimation(
  duration: Duration(milliseconds: 1000),
  child: MyWidget(),
)
```

---

## 📖 MORE HELP

- **Full Guide**: ADVANCED_UPGRADE_GUIDE.md
- **Detailed Overview**: UPGRADE_COMPLETION_SUMMARY.md
- **Code Comments**: See individual files
- **Examples**: Check screen implementations

---

## 🎯 YOU'RE READY!

```dart
// Copy & paste this to get started:

import 'package:femi_friendly/services/notification_service.dart';
import 'package:femi_friendly/widgets/animated_widgets.dart';

// 1. Initialize in main()
await NotificationService().initNotifications();

// 2. Use notifications
final service = NotificationService();
await service.showInstantNotification(
  title: "Hello",
  body: "Femi-Friendly v2.5.0",
  type: "test",
);

// 3. Use animations
AnimatedCard(
  child: Text('New Features!'),
)

// 4. Navigate to map
Navigator.pushNamed(context, AppRoutes.mapScreen);

// Done! 🎉
```

---

**Happy coding!** 🚀  
**Questions?** Check the full guides or code comments.
