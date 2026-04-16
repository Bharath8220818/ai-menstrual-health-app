import 'package:flutter/material.dart';

import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';
import 'package:femi_friendly/services/api_client.dart';

class InsightsProvider extends ChangeNotifier {
  InsightsProvider({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  bool _isLoading = false;
  String? _error;
  int? _cycleLength;
  String? _cycleStatus;
  double? _waterIntake;
  List<String> _foodRecommendations = <String>[];
  List<String> _healthTips = <String>[];
  String? _pregnancyChance;
  double? _pregnancyProbability;
  List<int> _fertilityWindow = <int>[];
  String? _cyclePhase;
  DateTime? _lastUpdated;

  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get cycleLength => _cycleLength;
  String? get cycleStatus => _cycleStatus;
  double? get waterIntake => _waterIntake;
  List<String> get foodRecommendations =>
      List<String>.unmodifiable(_foodRecommendations);
  List<String> get healthTips => List<String>.unmodifiable(_healthTips);
  String? get pregnancyChance => _pregnancyChance;
  double? get pregnancyProbability => _pregnancyProbability;
  List<int> get fertilityWindow => List<int>.unmodifiable(_fertilityWindow);
  String? get cyclePhase => _cyclePhase;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasRemoteData => _lastUpdated != null;

  Future<void> fetchInsights({
    required AuthProvider auth,
    required CycleProvider cycle,
    required PregnancyProvider pregnancy,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final payload = _sanitizePayload(
      _buildPayload(
        auth: auth,
        cycle: cycle,
        pregnancy: pregnancy,
      ),
    );

    final errors = <String>[];
    Map<String, dynamic> recommendData = <String, dynamic>{};
    Map<String, dynamic> predictData = <String, dynamic>{};

    try {
      recommendData = await _apiClient.recommend(payload);
    } catch (exc) {
      errors.add('recommend failed: $exc');
    }

    try {
      predictData = await _apiClient.predictAll(payload);
    } catch (exc) {
      errors.add('predict failed: $exc');
    }

    if (recommendData.isEmpty && predictData.isEmpty) {
      _isLoading = false;
      _error = errors.isEmpty ? 'Unable to fetch AI insights.' : errors.join(' | ');
      notifyListeners();
      return;
    }

    final fromRecommendCycleLength = _toInt(recommendData['cycle_length']);
    final fromPredictCycleLength = _toInt(
      (predictData['raw'] is Map<String, dynamic>)
          ? (predictData['raw'] as Map<String, dynamic>)['predicted_cycle_length']
          : null,
    );
    _cycleLength = fromRecommendCycleLength ?? fromPredictCycleLength ?? _cycleLength;

    _cycleStatus = _toStringValue(recommendData['status']) ??
        _toStringValue(
          (predictData['raw'] is Map<String, dynamic>)
              ? (predictData['raw'] as Map<String, dynamic>)['cycle_status']
              : null,
        ) ??
        _cycleStatus;

    _waterIntake = _toDouble(recommendData['water_intake']) ?? _waterIntake;

    final foods = _toStringList(recommendData['food_recommendations']);
    if (foods.isNotEmpty) {
      _foodRecommendations = foods;
    } else {
      final altFoods = _toStringList(predictData['food']);
      if (altFoods.isNotEmpty) {
        _foodRecommendations = altFoods;
      }
    }

    final tips = _toStringList(recommendData['health_tips']);
    if (tips.isNotEmpty) {
      _healthTips = tips;
    } else {
      final altTips = _toStringList(predictData['tips']);
      if (altTips.isNotEmpty) {
        _healthTips = altTips;
      }
    }

    _pregnancyChance =
        _toStringValue(predictData['pregnancy_chance']) ?? _pregnancyChance;
    _pregnancyProbability =
        _toDouble(predictData['pregnancy_probability']) ?? _pregnancyProbability;
    _fertilityWindow = _toIntList(predictData['fertility_window']);
    _cyclePhase = _toStringValue(predictData['cycle_phase']) ?? _cyclePhase;
    _lastUpdated = DateTime.now();

    _isLoading = false;
    _error = errors.isEmpty ? null : errors.join(' | ');
    notifyListeners();
  }

  Map<String, dynamic> _buildPayload({
    required AuthProvider auth,
    required CycleProvider cycle,
    required PregnancyProvider pregnancy,
  }) {
    final estimatedOvulationDay = (cycle.predictedCycleLength - 14).clamp(1, 45);
    return {
      'age': auth.age?.toDouble(),
      'bmi': auth.bmi,
      'cycle_length': cycle.predictedCycleLength.toDouble(),
      'menses_length': auth.periodLength.toDouble(),
      'mean_cycle_length': cycle.predictedCycleLength.toDouble(),
      'mean_menses_length': auth.periodLength.toDouble(),
      'luteal_phase': 14.0,
      'estimated_ovulation': estimatedOvulationDay.toDouble(),
      'total_high_days': 5,
      'total_peak_days': 2,
      'total_fertility_days': 6,
      'intercourse_fertile': 0,
      'unusual_bleeding': 0,
      'num_pregnancies': 0,
      'miscarriages': 0,
      'abortions': 0,
      'trying_to_conceive': pregnancy.pregnancyMode,
      'menstrual_regularity': cycle.cycleStatus == 'Normal' ? 'Regular' : 'Irregular',
      'pcos': 'No',
      'stress_level': 'Medium',
      'smoking': 'No',
      'alcohol': 'Never',
      'sleep_hours': 7.0,
      'weight_kg': auth.weight,
      'exercise_minutes_per_day': 30.0,
      'symptoms': _extractSymptoms(cycle),
      'cycle_day': cycle.currentDayInCycle,
    };
  }

  List<String> _extractSymptoms(CycleProvider cycle) {
    if (cycle.history.isEmpty) return <String>[];
    final raw = cycle.history.first.symptom.trim();
    if (raw.isEmpty) return <String>[];
    return raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  Map<String, dynamic> _sanitizePayload(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((key, value) {
      if (value != null) {
        out[key] = value;
      }
    });
    return out;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? _toStringValue(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  List<String> _toStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  List<int> _toIntList(dynamic value) {
    if (value is! List) return <int>[];
    return value
        .map(_toInt)
        .whereType<int>()
        .toList();
  }
}
