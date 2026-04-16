// lib/providers/ai_provider.dart
// State management for AI predictions and recommendations

import 'package:flutter/foundation.dart';
import 'package:femi_friendly/services/api_service.dart';

class AIProvider extends ChangeNotifier {
  // State variables
  Map<String, dynamic>? _predictionResult;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasError = false;

  // Getters
  Map<String, dynamic>? get predictionResult => _predictionResult;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _hasError;

  /// Fetch prediction from backend
  /// 
  /// Input data format:
  /// {
  ///   'age': 25,
  ///   'bmi': 22.5,
  ///   'cycle_length': 28,
  ///   'stress': 5,
  ///   'sleep': 7.5,
  ///   'symptoms': ['cramping', 'bloating'],
  ///   'weight': 65,
  ///   'exercise': 'moderate'
  /// }
  Future<void> fetchPrediction(Map<String, dynamic> inputData) async {
    try {
      // Reset error state
      _hasError = false;
      _errorMessage = null;

      // Set loading state
      _isLoading = true;
      notifyListeners();
      print('📤 Fetching prediction with data: $inputData');

      // Validate input
      if (!_validateInput(inputData)) {
        throw Exception('Invalid input data. Please check all required fields.');
      }

      // Call API
      final result = await ApiService.predict(inputData);

      // Store result
      _predictionResult = result;
      _hasError = false;
      _errorMessage = null;

      print('✅ Prediction fetched successfully: $result');
    } catch (e) {
      print('❌ Prediction error: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _predictionResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch recommendations from backend
  Future<void> fetchRecommendations(Map<String, dynamic> inputData) async {
    try {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      print('📤 Fetching recommendations with data: $inputData');

      final result = await ApiService.getRecommendations(inputData);
      _predictionResult = result;
      _hasError = false;

      print('✅ Recommendations fetched successfully: $result');
    } catch (e) {
      print('❌ Recommendations error: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _predictionResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch daily recommendations from advanced engine
  Future<void> fetchDailyRecommendations(Map<String, dynamic> inputData) async {
    try {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      print('📤 Fetching daily recommendations with data: $inputData');

      final result = await ApiService.getDailyRecommendations(inputData);
      _predictionResult = result;
      _hasError = false;

      print('✅ Daily recommendations fetched successfully');
    } catch (e) {
      print('❌ Daily recommendations error: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _predictionResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch cycle intelligence analysis
  Future<void> fetchCycleIntelligence(Map<String, dynamic> inputData) async {
    try {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.getCycleIntelligence(inputData);
      _predictionResult = result;
      _hasError = false;

      print('✅ Cycle intelligence fetched successfully');
    } catch (e) {
      print('❌ Cycle intelligence error: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _predictionResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch nutrition plan
  Future<void> fetchNutritionPlan(Map<String, dynamic> inputData) async {
    try {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.getNutritionPlan(inputData);
      _predictionResult = result;
      _hasError = false;

      print('✅ Nutrition plan fetched successfully');
    } catch (e) {
      print('❌ Nutrition plan error: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _predictionResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch health alerts
  Future<void> fetchHealthAlerts(Map<String, dynamic> inputData) async {
    try {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.getHealthAlerts(inputData);
      _predictionResult = result;
      _hasError = false;

      print('✅ Health alerts fetched successfully');
    } catch (e) {
      print('❌ Health alerts error: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _predictionResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check API connectivity
  Future<bool> checkAPIHealth() async {
    try {
      final isHealthy = await ApiService.checkHealth();
      if (!isHealthy) {
        _errorMessage = 'Backend is not responding';
      }
      return isHealthy;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Clear results and errors
  void clearResults() {
    _predictionResult = null;
    _hasError = false;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Validate required input fields
  bool _validateInput(Map<String, dynamic> data) {
    final requiredFields = ['age', 'bmi', 'cycle_length'];
    
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        print('❌ Missing required field: $field');
        return false;
      }
    }
    
    // Validate data types and ranges
    try {
      final age = data['age'];
      final bmi = data['bmi'];
      final cycleLength = data['cycle_length'];

      if (age is! int || age < 0 || age > 120) {
        print('❌ Invalid age value');
        return false;
      }

      if (bmi is! num || bmi < 10 || bmi > 60) {
        print('❌ Invalid BMI value');
        return false;
      }

      if (cycleLength is! int || cycleLength < 15 || cycleLength > 60) {
        print('❌ Invalid cycle length value');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Validation error: $e');
      return false;
    }
  }

  /// Get formatted cycle status
  String? getCycleStatus() {
    return _predictionResult?['status'] as String?;
  }

  /// Get predicted cycle length
  num? getPredictedCycleLength() {
    return _predictionResult?['cycle_length'] as num?;
  }

  /// Get water intake recommendation
  num? getWaterIntake() {
    return _predictionResult?['water_intake'] as num?;
  }

  /// Get food recommendations
  List<String>? getFoodRecommendations() {
    final food = _predictionResult?['food_recommendations'];
    if (food is List) {
      return food.cast<String>();
    }
    return null;
  }

  /// Get health tips
  List<String>? getHealthTips() {
    final tips = _predictionResult?['health_tips'];
    if (tips is List) {
      return tips.cast<String>();
    }
    return null;
  }

  /// Get recommendations list
  List<String>? getRecommendations() {
    final recs = _predictionResult?['recommendations'];
    if (recs is List) {
      return recs.cast<String>();
    }
    return null;
  }

  /// Retry last failed request
  Future<void> retry(
    Future<void> Function(Map<String, dynamic>) requestFunction,
    Map<String, dynamic> inputData,
  ) async {
    await requestFunction(inputData);
  }
}
