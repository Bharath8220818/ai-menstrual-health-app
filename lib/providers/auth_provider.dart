import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:femi_friendly/core/constants/app_strings.dart';
import 'package:femi_friendly/services/api_service.dart';
import 'package:femi_friendly/services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _hasCompletedSetup = false;

  String _name = 'Femi User';
  String _email = AppStrings.demoEmail;
  String? _avatarPath;
  double _weight = 60;
  double _height = 165;
  DateTime? _birthday;
  int _periodLength = 5;
  int _cycleLength = 28;
  bool _notificationsEnabled = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get hasCompletedSetup => _hasCompletedSetup;
  String get name => _name;
  String get email => _email;
  double get weight => _weight;
  double get height => _height;
  DateTime? get birthday => _birthday;
  String? get avatarPath => _avatarPath;
  int get periodLength => _periodLength;
  int get cycleLength => _cycleLength;
  bool get notificationsEnabled => _notificationsEnabled;

  // Shared Preferences keys
  static const _kNameKey = 'profile_name';
  static const _kEmailKey = 'profile_email';
  static const _kAvatarKey = 'profile_avatar';
  static const _kWeightKey = 'profile_weight';
  static const _kHeightKey = 'profile_height';
  static const _kBirthdayKey = 'profile_birthday';
  static const _kPeriodLengthKey = 'profile_period_length';
  static const _kCycleLengthKey = 'profile_cycle_length';
  static const _kNotificationsKey = 'profile_notifications';

  /// Load persisted profile values (if available).
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _name = prefs.getString(_kNameKey) ?? _name;
      _email = prefs.getString(_kEmailKey) ?? _email;
      _avatarPath = prefs.getString(_kAvatarKey);
      _weight = prefs.getDouble(_kWeightKey) ?? _weight;
      _height = prefs.getDouble(_kHeightKey) ?? _height;
      final b = prefs.getString(_kBirthdayKey);
      if (b != null && b.isNotEmpty) _birthday = DateTime.tryParse(b);
      _periodLength = prefs.getInt(_kPeriodLengthKey) ?? _periodLength;
      _cycleLength = prefs.getInt(_kCycleLengthKey) ?? _cycleLength;
      _notificationsEnabled = prefs.getBool(_kNotificationsKey) ?? _notificationsEnabled;
      notifyListeners();
    } catch (_) {
      // ignore errors reading prefs
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kNameKey, _name);
      await prefs.setString(_kEmailKey, _email);
      if (_avatarPath != null && _avatarPath!.isNotEmpty) {
        await prefs.setString(_kAvatarKey, _avatarPath!);
      } else {
        await prefs.remove(_kAvatarKey);
      }
      await prefs.setDouble(_kWeightKey, _weight);
      await prefs.setDouble(_kHeightKey, _height);
      if (_birthday != null) {
        await prefs.setString(_kBirthdayKey, _birthday!.toIso8601String());
      } else {
        await prefs.remove(_kBirthdayKey);
      }
      await prefs.setInt(_kPeriodLengthKey, _periodLength);
      await prefs.setInt(_kCycleLengthKey, _cycleLength);
      await prefs.setBool(_kNotificationsKey, _notificationsEnabled);
    } catch (_) {
      // ignore write errors
    }
  }

  int? get age {
    if (_birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - _birthday!.year;
    if (now.month < _birthday!.month ||
        (now.month == _birthday!.month && now.day < _birthday!.day)) {
      age--;
    }
    return age;
  }

  double get bmi {
    if (_height <= 0) return 0;
    final hm = _height / 100;
    return _weight / (hm * hm);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    final isValid = email.trim() == AppStrings.demoEmail &&
        password.trim() == AppStrings.demoPassword;

    _isLoggedIn = isValid;
    if (isValid) {
      _name = 'Admin User';
      _email = AppStrings.demoEmail;
      _hasCompletedSetup = true; // already set up in demo
      await _syncFcmTokenForUser(_email);
    }

    _isLoading = false;
    notifyListeners();
    return isValid;
  }

  void register({
    required String name,
    required String email,
    required String password,
  }) {
    _name = name.trim().isEmpty ? 'Femi User' : name.trim();
    _email = email.trim();
    _isLoggedIn = true;
    _hasCompletedSetup = false;
    _syncFcmTokenForUser(_email);
    notifyListeners();
  }

  Future<void> _syncFcmTokenForUser(String email) async {
    if (email.trim().isEmpty) return;
    try {
      final token = await NotificationService().getFCMToken();
      if (token == null || token.isEmpty) return;

      await ApiService.registerDeviceToken(
        email: email,
        token: token,
        platform: 'android',
      );
      debugPrint('✅ FCM token synced for $email');
    } catch (e) {
      debugPrint('FCM token sync skipped: $e');
    }
  }

  void completeSetup({
    double? weight,
    double? height,
    DateTime? birthday,
    int? periodLength,
    int? cycleLength,
  }) {
    if (weight != null) _weight = weight;
    if (height != null) _height = height;
    if (birthday != null) _birthday = birthday;
    if (periodLength != null) _periodLength = periodLength;
    if (cycleLength != null) _cycleLength = cycleLength;
    _hasCompletedSetup = true;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    double? weight,
    double? height,
    DateTime? birthday,
    String? avatarPath,
    bool? notificationsEnabled,
  }) {
    if (name != null && name.isNotEmpty) _name = name;
    if (weight != null) _weight = weight;
    if (height != null) _height = height;
    if (birthday != null) _birthday = birthday;
    if (avatarPath != null) {
      // Treat empty string as explicit removal of avatar
      _avatarPath = avatarPath.isEmpty ? null : avatarPath;
    }
    if (notificationsEnabled != null) {
      _notificationsEnabled = notificationsEnabled;
    }
    // Persist and notify once write completes.
    return _saveToPrefs().whenComplete(() => notifyListeners());
  }

  void logout() {
    _isLoggedIn = false;
    _hasCompletedSetup = false;
    _name = 'Femi User';
    _email = AppStrings.demoEmail;
    _avatarPath = null;
    // remove persisted profile on logout
    _saveToPrefs();
    notifyListeners();
  }
}

