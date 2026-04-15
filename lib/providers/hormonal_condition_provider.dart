import 'package:flutter/material.dart';
import 'package:femi_friendly/models/hormonal_condition.dart';

/// Provider for managing hormonal condition tracking
class HormonalConditionProvider extends ChangeNotifier {
  final Map<String, HormonalCondition> _trackedConditions =
      <String, HormonalCondition>{};

  static const Map<String, List<String>> _conditionSymptomMap =
      <String, List<String>>{
    'pcos': <String>[
      'irregular cycle',
      'irregular periods',
      'missed periods',
      'weight gain',
      'acne flare-ups',
      'acne',
      'facial hair growth',
      'excess facial/body hair',
      'dark neck/underarm patches',
      'dark skin patches',
      'hair thinning',
    ],
    'endometriosis': <String>[
      'severe cramps',
      'severe period pain',
      'chronic pelvic pain',
      'pelvic pain',
      'pain during intercourse',
      'infertility',
      'difficulty getting pregnant',
    ],
    'thyroid': <String>[
      'irregular cycle',
      'irregular periods',
      'sudden weight changes',
      'weight gain',
      'fatigue',
      'hair loss',
      'hair thinning',
    ],
    'fibroids': <String>[
      'heavy bleeding',
      'pelvic pain',
      'frequent urination',
    ],
    'amenorrhea': <String>[
      'no periods for 3+ months',
      'stress',
      'extreme weight loss',
      'missed periods',
    ],
    'pid': <String>[
      'lower abdominal pain',
      'irregular bleeding',
      'fever',
      'unusual discharge',
      'pelvic pain',
    ],
  };

  Map<String, HormonalCondition> get trackedConditions =>
      Map<String, HormonalCondition>.unmodifiable(_trackedConditions);

  List<HormonalCondition> get activeConditions =>
      _trackedConditions.values
          .where((HormonalCondition c) => c.isTracking)
          .toList();

  List<HormonalConditionMatch> analyzeSymptoms(List<String> symptoms) {
    final normalizedSymptoms = symptoms
        .map((symptom) => symptom.toLowerCase().trim())
        .toList();

    final matches = HormonalConditions.allConditions
        .map((condition) {
          final mappedSymptoms = _conditionSymptomMap[condition.id] ?? <String>[];
          final matchedSymptoms = normalizedSymptoms.where((userSymptom) {
            return mappedSymptoms.any(
              (mapped) =>
                  userSymptom.contains(mapped) || mapped.contains(userSymptom),
            );
          }).toList();

          if (matchedSymptoms.isEmpty) {
            return null;
          }

          final matchCount = matchedSymptoms.length;
          final severity = matchCount == 1
              ? 'Low'
              : (matchCount <= 3 ? 'Medium' : 'High');

          return HormonalConditionMatch(
            id: condition.id,
            name: condition.name,
            matchCount: matchCount,
            severity: severity,
            matchedSymptoms: matchedSymptoms,
            explanation:
                'Matched ${matchedSymptoms.take(3).join(', ')}. This is only a possible fit, not a diagnosis.',
          );
        })
        .whereType<HormonalConditionMatch>()
        .toList()
      ..sort((a, b) => b.matchCount.compareTo(a.matchCount));

    final filtered = <HormonalConditionMatch>[];
    for (final match in matches) {
      if (match.matchCount >= 2 || match.severity == 'Low') {
        filtered.add(match);
      }
      if (filtered.length == 4) break;
    }
    return filtered;
  }

  /// Start tracking a condition
  void trackCondition(String conditionId) {
    final condition = HormonalConditions.getConditionById(conditionId);
    _trackedConditions[conditionId] = condition.copyWith(
      isTracking: true,
      startDate: DateTime.now(),
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  /// Stop tracking a condition
  void untrackCondition(String conditionId) {
    if (_trackedConditions.containsKey(conditionId)) {
      _trackedConditions[conditionId] = _trackedConditions[conditionId]!
          .copyWith(isTracking: false);
      notifyListeners();
    }
  }

  /// Update condition severity
  void updateSeverity(String conditionId, String severity) {
    if (_trackedConditions.containsKey(conditionId)) {
      _trackedConditions[conditionId] = _trackedConditions[conditionId]!
          .copyWith(
            severity: severity,
            lastUpdated: DateTime.now(),
          );
      notifyListeners();
    }
  }

  /// Update condition notes
  void updateNotes(String conditionId, String notes) {
    if (_trackedConditions.containsKey(conditionId)) {
      _trackedConditions[conditionId] = _trackedConditions[conditionId]!
          .copyWith(
            notes: notes,
            lastUpdated: DateTime.now(),
          );
      notifyListeners();
    }
  }

  /// Get improvement status (simplified tracking)
  String getImprovementStatus(String conditionId) {
    if (!_trackedConditions.containsKey(conditionId)) return 'Not tracked';

    final condition = _trackedConditions[conditionId]!;
    if (!condition.isTracking) return 'Not tracked';

    // In a real app, this would be calculated from historical data
    return 'Tracking since ${condition.startDate?.toLocal().toString().split(' ').first ?? 'N/A'}';
  }

  /// Get recommendations for a condition
  ({
    List<String> diet,
    List<String> activity,
  }) getRecommendations(String conditionId) {
    final condition = HormonalConditions.getConditionById(conditionId);
    return (
      diet: condition.dietRecommendations,
      activity: condition.activityRecommendations,
    );
  }

  /// Get all symptoms for a condition
  List<String> getSymptoms(String conditionId) {
    return HormonalConditions.getConditionById(conditionId).symptoms;
  }

  /// Clear all tracked conditions
  void clearAll() {
    _trackedConditions.clear();
    notifyListeners();
  }
}
