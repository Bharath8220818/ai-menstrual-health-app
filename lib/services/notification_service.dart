import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'dart:convert';
import 'package:flutter/foundation.dart';


class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  FirebaseMessaging? _firebaseMessaging;
  bool _firebaseEnabled = false;
  bool _isInitialized = false;

  /// Initialize notifications - should be called at app startup
  Future<void> initNotifications() async {
    if (_isInitialized) return;

    tzdata.initializeTimeZones();

    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _handleNotificationTapStatic,
    );

    // Handle notification if the app was opened via a notification
    final NotificationResponse? launchResponse =
        await _localNotifications.getNotificationAppLaunchDetails().then(
      (details) => details?.notificationResponse,
    );
    if (launchResponse != null) {
      _handleNotificationTap(launchResponse);
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      // Try both possible method names depending on version
      try {
        await (androidPlugin as dynamic).requestNotificationsPermission();
      } catch (_) {
        try {
          await (androidPlugin as dynamic).requestPermission();
        } catch (_) {}
      }
    }

    // Create notification channels for Android
    await _createNotificationChannels();

    if (kIsWeb) {
      _isInitialized = true;
      debugPrint('✅ Notifications initialized for web (FCM disabled)');
      return;
    }

    if (Firebase.apps.isNotEmpty) {
      _firebaseMessaging = FirebaseMessaging.instance;
      _firebaseEnabled = true;

      // Request Firebase permissions
    if (_firebaseMessaging != null) {
      await _firebaseMessaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } else {
      debugPrint('Firebase not configured; FCM features disabled.');
    }

    _isInitialized = true;
    debugPrint('✅ Notifications initialized successfully');

    // Auto-fetch and log FCM token (used by backend for push delivery)
    if (_firebaseEnabled) {
      final token = await getFCMToken();
      if (token != null) {
        debugPrint('📱 FCM Device Token: ${token.substring(0, 20)}...');
      }
    }
  }

  /// Returns the FCM device registration token for this device.
  /// Send this to the backend via POST /notifications/device-token
  Future<String?> getFCMToken() async {
    if (!_firebaseEnabled || _firebaseMessaging == null) return null;
    try {
      return await _firebaseMessaging!.getToken();
    } catch (e) {
      debugPrint('FCM token fetch error: $e');
      return null;
    }
  }

  /// Listen for FCM token refresh events and re-register with backend
  void listenForTokenRefresh(void Function(String token) onRefresh) {
    if (!_firebaseEnabled || _firebaseMessaging == null) return;
    FirebaseMessaging.instance.onTokenRefresh.listen(onRefresh);
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    const AndroidNotificationChannel waterChannel = AndroidNotificationChannel(
      'water_reminders',
      'Water Reminders',
      description: 'Reminders to drink water throughout the day',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    const AndroidNotificationChannel cycleChannel = AndroidNotificationChannel(
      'cycle_alerts',
      'Cycle Alerts',
      description: 'Notifications about your menstrual cycle',
      importance: Importance.high,
      enableVibration: true,
    );

    const AndroidNotificationChannel fertilityChannel = AndroidNotificationChannel(
      'fertility_alerts',
      'Fertility Alerts',
      description: 'Notifications about your fertile window',
      importance: Importance.high,
      enableVibration: true,
    );

    const AndroidNotificationChannel pregnancyChannel = AndroidNotificationChannel(
      'pregnancy_updates',
      'Pregnancy Updates',
      description: 'Weekly pregnancy development updates',
      importance: Importance.defaultImportance,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(waterChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(cycleChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(fertilityChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(pregnancyChannel);
  }

  /// Show an instant notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    required String type, // water_reminder, cycle_alert, fertility_alert, pregnancy_update
    Map<String, dynamic>? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails details = const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payloadJson = payload == null ? null : jsonEncode(payload);

    await _localNotifications.show(
      id: DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payloadJson,
    );

    debugPrint('🔔 Instant notification shown: $title');
  }

  /// Schedule a repeating water reminder notification
  Future<void> scheduleWaterReminders(List<String> times) async {
    // Schedule water reminders at specific times
    for (int i = 0; i < times.length; i++) {
      final timeParts = times[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'water_reminders',
        'Water Reminders',
        importance: Importance.defaultImportance,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

    await _localNotifications.zonedSchedule(
      id: i,
      title: '💧 Time to Drink Water',
      body: 'Stay hydrated! Drink a glass of water now.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

      debugPrint('📅 Water reminder scheduled for ${times[i]}');
    }
  }

  /// Schedule cycle alert notification
  Future<void> scheduleCycleAlert(DateTime cycleDate) async {
    final scheduledDate = tz.TZDateTime.from(cycleDate, tz.local)
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: 9)); // 9 AM the day before

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cycle_alerts',
      'Cycle Alerts',
      importance: Importance.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.zonedSchedule(
      id: 100,
      title: '🩸 Period Coming',
      body: 'Your period is expected tomorrow. Are you prepared?',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('📅 Cycle alert scheduled for $cycleDate');
  }

  /// Schedule fertility window alerts
  Future<void> scheduleFertilityAlerts(List<int> fertileDays) async {
    for (int i = 0; i < fertileDays.length; i++) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day + (fertileDays[i] - now.day), 8, 0);

      if (scheduledDate.isBefore(now)) {
        continue; // Skip if date has passed
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'fertility_alerts',
        'Fertility Alerts',
        importance: Importance.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      await _localNotifications.zonedSchedule(
        id: 200 + i,
        title: '🌸 High Fertility Window',
        body: 'Today is a fertile day. Track your cycle for accurate predictions.',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('📅 Fertility alert scheduled for day ${fertileDays[i]}');
    }
  }

  /// Schedule weekly pregnancy update notification
  Future<void> schedulePregnancyUpdate(int weekNumber, DateTime nextUpdateDate) async {
    final scheduledDate = tz.TZDateTime.from(nextUpdateDate, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pregnancy_updates',
      'Pregnancy Updates',
      importance: Importance.defaultImportance,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.zonedSchedule(
      id: 300 + weekNumber,
      title: '👶 Week $weekNumber: Baby Development Update',
      body: 'Tap to see what\'s happening with your baby this week.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('📅 Pregnancy update scheduled for week $weekNumber');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    debugPrint('❌ All notifications cancelled');
  }

  /// Handle notification tap
  void _handleNotificationTap(NotificationResponse response) {
    debugPrint('🎯 Notification tapped: ${response.payload}');
    // Handle navigation based on notification type
    if (response.payload != null) {
      // You can add navigation logic here
    }
  }

  /// Handle foreground messages from Firebase
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Foreground message received: ${message.notification?.title}');

    showInstantNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      type: 'firebase',
      payload: message.data,
    );
  }

  /// Static method to handle background messages
  @pragma('vm:entry-point')
  static void _handleNotificationTapStatic(NotificationResponse response) {
    debugPrint('🎯 Static notification tapped: ${response.payload}');
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundMessageHandler(RemoteMessage message) async {
    debugPrint('🔔 Background message received: ${message.notification?.title}');
  }
}
