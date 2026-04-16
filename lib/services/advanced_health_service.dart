// lib/services/advanced_health_service.dart
// Service for communicating with advanced health API endpoints

import 'package:dio/dio.dart';
import 'package:femi_friendly/models/health_models.dart';

class AdvancedHealthService {
  final Dio dio;
  final String baseUrl;

  AdvancedHealthService({
    required this.dio,
    required this.baseUrl,
  });

  // ─── Cycle Intelligence ───
  Future<CycleIntelligence> getCycleIntelligence(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/cycle-intelligence',
        data: userData,
      );

      if (response.statusCode == 200) {
        return CycleIntelligence.fromJson(response.data);
      } else {
        throw Exception('Failed to get cycle intelligence');
      }
    } catch (e) {
      throw Exception('Cycle intelligence error: $e');
    }
  }

  // ─── Nutrition Plan ───
  Future<MealPlan> getNutritionPlan(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/nutrition-plan',
        data: userData,
      );

      if (response.statusCode == 200) {
        return MealPlan.fromJson(response.data);
      } else {
        throw Exception('Failed to get nutrition plan');
      }
    } catch (e) {
      throw Exception('Nutrition plan error: $e');
    }
  }

  // ─── Fertility Insights ───
  Future<FertilityInsights> getFertilityInsights(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/fertility-insights',
        data: userData,
      );

      if (response.statusCode == 200) {
        return FertilityInsights.fromJson(response.data);
      } else {
        throw Exception('Failed to get fertility insights');
      }
    } catch (e) {
      throw Exception('Fertility insights error: $e');
    }
  }

  // ─── Pregnancy Insights ───
  Future<PregnancyInsights> getPregnancyInsights(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/pregnancy-insights',
        data: userData,
      );

      if (response.statusCode == 200) {
        return PregnancyInsights.fromJson(response.data);
      } else {
        throw Exception('Failed to get pregnancy insights');
      }
    } catch (e) {
      throw Exception('Pregnancy insights error: $e');
    }
  }

  // ─── Mental Health Status ───
  Future<MentalHealthStatus> getMentalHealthStatus(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/mental-health',
        data: userData,
      );

      if (response.statusCode == 200) {
        return MentalHealthStatus.fromJson(response.data);
      } else {
        throw Exception('Failed to get mental health status');
      }
    } catch (e) {
      throw Exception('Mental health status error: $e');
    }
  }

  // ─── Health Alerts ───
  Future<AlertsResponse> getHealthAlerts(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/health-alerts',
        data: userData,
      );

      if (response.statusCode == 200) {
        return AlertsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get health alerts');
      }
    } catch (e) {
      throw Exception('Health alerts error: $e');
    }
  }

  // ─── Notifications ───
  Future<List<HealthNotification>> getNotifications(Map<String, dynamic> userData) async {
    try {
      final response = await dio.post(
        '$baseUrl/notifications',
        data: userData,
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificationsList = response.data['notifications'] ?? [];
        return notificationsList
            .map((notif) => HealthNotification.fromJson(notif as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get notifications');
      }
    } catch (e) {
      throw Exception('Notifications error: $e');
    }
  }

  // ─── Daily Health Recommendations ───
  Future<DailyHealthRecommendation> getDailyRecommendations(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/daily-recommendations',
        data: userData,
      );

      if (response.statusCode == 200) {
        return DailyHealthRecommendation.fromJson(response.data);
      } else {
        throw Exception('Failed to get daily recommendations');
      }
    } catch (e) {
      throw Exception('Daily recommendations error: $e');
    }
  }

  // ─── Get All Data (Dashboard) ───
  /// Fetch all health data for the dashboard in one call
  Future<Map<String, dynamic>> getAllHealthData(Map<String, dynamic> userData) async {
    try {
      final futures = <Future<dynamic>>[
        getCycleIntelligence(userData),
        getFertilityInsights(userData),
        getNutritionPlan(userData),
        getMentalHealthStatus(userData),
        getHealthAlerts(userData),
        getNotifications(userData),
        getDailyRecommendations(userData),
      ];

      if (userData.containsKey('pregnancy_week') && userData['pregnancy_week'] > 0) {
        futures.add(getPregnancyInsights(userData));
      }

      final results = await Future.wait(futures);

      return {
        'cycleIntelligence': results[0],
        'fertilityInsights': results[1],
        'nutritionPlan': results[2],
        'mentalHealth': results[3],
        'alerts': results[4],
        'notifications': results[5],
        'dailyRecommendations': results[6],
        'pregnancyInsights': results.length > 7 ? results[7] : null,
      };
    } catch (e) {
      throw Exception('Failed to get all health data: $e');
    }
  }
}
