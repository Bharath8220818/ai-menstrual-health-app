import 'dart:math';

import 'package:flutter/material.dart';

import 'package:femi_friendly/models/cycle_entry.dart';

class CycleProvider extends ChangeNotifier {
  static const Set<String> _pcodSymptomKeywords = <String>{
    'irregular cycle',
    'acne flare-ups',
    'weight gain',
    'facial hair growth',
    'hair thinning',
    'dark neck/underarm patches',
    'pelvic pain',
    'heavy bleeding',
    'sugar cravings',
    'difficulty sleeping',
  };

  final List<CycleEntry> _entries = <CycleEntry>[
    CycleEntry(
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().subtract(const Duration(days: 25)),
      symptom: 'Mild cramps',
    ),
    CycleEntry(
      startDate: DateTime.now().subtract(const Duration(days: 58)),
      endDate: DateTime.now().subtract(const Duration(days: 54)),
      symptom: 'Fatigue',
    ),
    CycleEntry(
      startDate: DateTime.now().subtract(const Duration(days: 86)),
      endDate: DateTime.now().subtract(const Duration(days: 82)),
      symptom: 'Mood swings',
    ),
  ];

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  List<CycleEntry> get history {
    final sorted = List<CycleEntry>.from(_entries)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    return List<CycleEntry>.unmodifiable(sorted);
  }

  List<String> get trackedSymptoms {
    final seen = <String>{};
    final symptoms = <String>[];

    for (final entry in history) {
      final parts = entry.symptom
          .split(RegExp(r'[,\u2022]'))
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty);

      for (final part in parts) {
        final normalized = part.toLowerCase();
        if (normalized.contains('flow')) continue;
        if (seen.add(normalized)) {
          symptoms.add(part);
        }
      }
    }

    return symptoms;
  }

  List<String> get trackedPcodSymptoms {
    return trackedSymptoms
        .where(
          (symptom) => _pcodSymptomKeywords.contains(symptom.toLowerCase()),
        )
        .toList();
  }

  bool get hasPcodPattern {
    return trackedPcodSymptoms.isNotEmpty || predictedCycleLength > 35;
  }

  List<String> get pcodSupportTips {
    final tips = <String>[];

    if (predictedCycleLength > 35) {
      tips.add(
        'Longer cycles can happen with PCOD. Keep logging for 2-3 months and plan a gynecologist review if this continues.',
      );
    }
    if (trackedPcodSymptoms.isNotEmpty) {
      tips.add(
        'Tracked signs like ${trackedPcodSymptoms.take(3).join(', ')} can be associated with PCOD and are worth monitoring closely.',
      );
    }

    tips.addAll(<String>[
      'What to do: aim for 30 minutes of walking, strength work, or yoga most days to support insulin sensitivity.',
      'What to eat: choose high-fiber, high-protein meals like eggs, dal, Greek yogurt, nuts, seeds, vegetables, and low-GI fruits.',
      'Limit sugary drinks, ultra-processed snacks, and long gaps between meals if you notice fatigue, cravings, or cycle swings.',
      'Other problems to watch: acne, unwanted facial hair, scalp hair thinning, weight changes, dark skin patches, and trouble sleeping.',
      'Seek medical care sooner for severe pelvic pain, very heavy bleeding, missed periods for 3+ months, or rapid symptom worsening.',
    ]);

    return tips;
  }

  void updateSelectedDate(DateTime value) {
    _selectedDate = value;
    notifyListeners();
  }

  void addCycle(CycleEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  Future<void> refreshHistory() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    notifyListeners();
  }

  int get predictedCycleLength {
    if (_entries.length < 2) {
      return 28;
    }

    final sorted = List<CycleEntry>.from(_entries)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final differences = <int>[];
    for (var index = 1; index < sorted.length; index++) {
      final days = sorted[index]
          .startDate
          .difference(sorted[index - 1].startDate)
          .inDays
          .abs();
      if (days > 0) {
        differences.add(days);
      }
    }

    if (differences.isEmpty) {
      return 28;
    }

    final average = differences.reduce((a, b) => a + b) / differences.length;
    return average.round();
  }

  DateTime get nextPeriodDate {
    if (_entries.isEmpty) {
      return DateTime.now().add(const Duration(days: 28));
    }

    final latest = history.first.startDate;
    return latest.add(Duration(days: predictedCycleLength));
  }

  String get cycleStatus {
    final length = predictedCycleLength;
    return length >= 21 && length <= 35 ? 'Normal' : 'Irregular';
  }

  bool get irregularityAlert {
    if (_entries.length < 2) {
      return false;
    }

    final sorted = List<CycleEntry>.from(_entries)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final recent = sorted.last.startDate;
    final previous = sorted[sorted.length - 2].startDate;
    final gap = recent.difference(previous).inDays.abs();

    return (gap - predictedCycleLength).abs() > max(3, predictedCycleLength ~/ 5);
  }

  int get currentDayInCycle {
    if (_entries.isEmpty) {
      return 0;
    }

    final latest = history.first.startDate;
    final days = DateTime.now().difference(latest).inDays + 1;
    return days.clamp(1, max(predictedCycleLength, 1));
  }

  double get cycleProgress {
    if (predictedCycleLength <= 0) {
      return 0;
    }
    return (currentDayInCycle / predictedCycleLength).clamp(0, 1);
  }

  bool isCycleDay(DateTime day) {
    for (final entry in _entries) {
      final start = DateTime(
        entry.startDate.year,
        entry.startDate.month,
        entry.startDate.day,
      );
      final end = DateTime(
        entry.endDate.year,
        entry.endDate.month,
        entry.endDate.day,
      );
      final value = DateTime(day.year, day.month, day.day);

      if ((value.isAfter(start) || value == start) &&
          (value.isBefore(end) || value == end)) {
        return true;
      }
    }

    return false;
  }

  List<int> get cycleLengthTrend {
    if (_entries.length < 2) {
      return <int>[28, 29, 27, 30];
    }

    final sorted = List<CycleEntry>.from(_entries)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final trend = <int>[];
    for (var index = 1; index < sorted.length; index++) {
      trend.add(
        sorted[index]
            .startDate
            .difference(sorted[index - 1].startDate)
            .inDays
            .abs(),
      );
    }

    if (trend.isEmpty) {
      return <int>[28, 29, 27, 30];
    }

    return trend;
  }
}

