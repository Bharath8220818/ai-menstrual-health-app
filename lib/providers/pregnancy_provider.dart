import 'package:flutter/material.dart';

class PregnancyProvider extends ChangeNotifier {
  bool _pregnancyMode = false;
  DateTime? _dueDate;
  DateTime? _conceptionDate;

  bool get pregnancyMode => _pregnancyMode;
  DateTime? get dueDate => _dueDate;
  DateTime? get conceptionDate => _conceptionDate;

  void togglePregnancyMode() {
    _pregnancyMode = !_pregnancyMode;
    if (_pregnancyMode && _conceptionDate == null) {
      // Default: 2 weeks ago
      _conceptionDate = DateTime.now().subtract(const Duration(days: 14));
      _dueDate = _conceptionDate!.add(const Duration(days: 280));
    }
    notifyListeners();
  }

  void setDueDate(DateTime date) {
    _dueDate = date;
    _conceptionDate = date.subtract(const Duration(days: 280));
    notifyListeners();
  }

  void setConceptionDate(DateTime date) {
    _conceptionDate = date;
    _dueDate = date.add(const Duration(days: 280));
    notifyListeners();
  }

  int get currentWeek {
    if (_conceptionDate == null) return 0;
    final days = DateTime.now().difference(_conceptionDate!).inDays;
    return (days ~/ 7).clamp(1, 40);
  }

  int get daysRemaining {
    if (_dueDate == null) return 0;
    final days = _dueDate!.difference(DateTime.now()).inDays;
    return days.clamp(0, 280);
  }

  double get progressPercent {
    final week = currentWeek;
    return (week / 40).clamp(0.0, 1.0);
  }

  String get trimester {
    final week = currentWeek;
    if (week <= 12) return 'First Trimester';
    if (week <= 27) return 'Second Trimester';
    return 'Third Trimester';
  }

  int get trimesterNumber {
    final week = currentWeek;
    if (week <= 12) return 1;
    if (week <= 27) return 2;
    return 3;
  }

  String get babySize {
    final week = currentWeek;
    if (week <= 4) return '🌱 Poppy Seed';
    if (week <= 6) return '🫐 Blueberry';
    if (week <= 8) return '🍇 Raspberry';
    if (week <= 10) return '🍓 Strawberry';
    if (week <= 12) return '🍋 Lime';
    if (week <= 14) return '🍑 Peach';
    if (week <= 16) return '🥑 Avocado';
    if (week <= 18) return '🍠 Sweet Potato';
    if (week <= 20) return '🍌 Banana';
    if (week <= 24) return '🌽 Corn';
    if (week <= 28) return '🥦 Broccoli';
    if (week <= 32) return '🥥 Coconut';
    if (week <= 36) return '🍉 Honeydew';
    return '🎃 Pumpkin';
  }

  String get babySizeDescription {
    final week = currentWeek;
    if (week <= 4) return 'About 1–2 mm. Your baby is just beginning to form!';
    if (week <= 6) return 'About 6 mm. The heart is beginning to beat.';
    if (week <= 8) return 'About 1.6 cm. Tiny fingers are forming.';
    if (week <= 10) return 'About 3 cm. Your baby can now hiccup!';
    if (week <= 12) return 'About 5 cm. Vital organs are in place.';
    if (week <= 14) return 'About 8 cm. Baby can make facial expressions.';
    if (week <= 16) return 'About 12 cm. You may start to feel movement.';
    if (week <= 18) return 'About 14 cm. Baby can hear sounds now.';
    if (week <= 20) return 'About 25 cm. Halfway there!';
    if (week <= 24) return 'About 30 cm. Baby has a regular sleep cycle.';
    if (week <= 28) return 'About 37 cm. Baby opens and closes eyes.';
    if (week <= 32) return 'About 42 cm. Brain is developing rapidly.';
    if (week <= 36) return 'About 48 cm. Baby is gaining weight fast.';
    return 'About 50 cm. Baby is ready!';
  }

  List<Map<String, String>> get trimesterTips {
    switch (trimesterNumber) {
      case 1:
        return [
          {
            'title': '🥗 Nutrition',
            'tip': 'Take folic acid (400–800 mcg/day). Eat leafy greens, citrus, beans.',
          },
          {
            'title': '💧 Hydration',
            'tip': 'Drink 8–10 glasses of water daily to ease morning sickness.',
          },
          {
            'title': '😴 Sleep',
            'tip': 'Aim for 8–9 hours. Sleep on your left side for better circulation.',
          },
          {
            'title': '🚫 Avoid',
            'tip': 'Raw seafood, unpasteurized cheese, alcohol, and excess caffeine.',
          },
        ];
      case 2:
        return [
          {
            'title': '🥩 Iron & Calcium',
            'tip': 'Increase iron (27 mg/day) and calcium (1000 mg/day). Eat red meat, dairy.',
          },
          {
            'title': '🏃 Exercise',
            'tip': 'Light walks, prenatal yoga, and swimming are great during this phase.',
          },
          {
            'title': '🌞 Vitamin D',
            'tip': 'Get 15 min of sunlight daily and take a Vitamin D supplement.',
          },
          {
            'title': '💆 Stress',
            'tip': 'Practice meditation and deep breathing. Manage stress proactively.',
          },
        ];
      case 3:
        return [
          {
            'title': '🍳 Protein',
            'tip': 'Eat 70–100g of protein daily. Eggs, chicken, tofu, and legumes.',
          },
          {
            'title': '💧 Hydration++',
            'tip': 'Drink 10–12 cups daily. Swelling is common; elevate your legs.',
          },
          {
            'title': '🛏 Rest',
            'tip': 'Rest as much as possible. Use a pregnancy pillow for better sleep.',
          },
          {
            'title': '🏥 Checkups',
            'tip': 'Increase prenatal visits to weekly. Prepare your birth plan.',
          },
        ];
      default:
        return [];
    }
  }

  String get weeklyHighlight {
    final week = currentWeek;
    final highlights = {
      1: 'Fertilization has occurred! Your journey begins.',
      2: 'The fertilized egg travels to the uterus.',
      4: 'Baby\'s heart starts forming — the neural tube is developing.',
      8: 'All major organs have begun to form!',
      12: 'End of first trimester — risk of miscarriage drops significantly.',
      16: 'You might start to feel baby\'s kicks!',
      20: 'Anatomy scan reveals baby\'s sex (if you want to know!).',
      24: 'Baby can now survive outside the womb with medical help.',
      28: 'Third trimester begins — baby gains weight rapidly.',
      36: 'Baby is considered "early term" and is mostly ready.',
      40: 'Full term! Your baby could arrive any day now!',
    };
    for (var w in highlights.keys.toList().reversed) {
      if (week >= w) return highlights[w]!;
    }
    return 'Your miracle is growing day by day!';
  }
}
