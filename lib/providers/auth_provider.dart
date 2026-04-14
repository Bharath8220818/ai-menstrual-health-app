import 'package:flutter/material.dart';

import 'package:femi_friendly/core/constants/app_strings.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _hasCompletedSetup = false;

  String _name = 'Femi User';
  String _email = AppStrings.demoEmail;
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
  int get periodLength => _periodLength;
  int get cycleLength => _cycleLength;
  bool get notificationsEnabled => _notificationsEnabled;

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
    notifyListeners();
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
    notifyListeners();
  }

  void updateProfile({
    String? name,
    double? weight,
    double? height,
    DateTime? birthday,
    bool? notificationsEnabled,
  }) {
    if (name != null && name.isNotEmpty) _name = name;
    if (weight != null) _weight = weight;
    if (height != null) _height = height;
    if (birthday != null) _birthday = birthday;
    if (notificationsEnabled != null) {
      _notificationsEnabled = notificationsEnabled;
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _hasCompletedSetup = false;
    _name = 'Femi User';
    _email = AppStrings.demoEmail;
    notifyListeners();
  }
}
