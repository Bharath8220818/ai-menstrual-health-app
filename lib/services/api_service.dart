// lib/services/api_service.dart
// API Service for communicating with FastAPI backend

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // 🚀 Production: Render cloud server
  static const String baseUrl = 'https://ai-menstrual-health-app-1.onrender.com';
  // 🧪 Local dev (Android emulator): 'http://10.0.2.2:8000'
  // 🧪 Local dev (physical device):  'http://YOUR_PC_IP:8000'

  /// Make HTTP POST request to /predict endpoint
  /// 
  /// Input data should contain:
  /// - age (int)
  /// - bmi (double)
  /// - cycle_length (int)
  /// - stress (int, 1-10)
  /// - sleep (double, hours)
  /// - symptoms (`List<String>`)
  /// - weight (double, kg)
  /// - exercise (String)
  /// 
  /// Returns parsed JSON response from backend
  static Future<Map<String, dynamic>> predict(Map<String, dynamic> data) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/predict');
      debugPrint('📤 Sending data: $data');

      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('API request timed out. Is the backend running?');
        },
      );

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('✅ API Success: $jsonResponse');
        return jsonResponse;
      } else if (response.statusCode == 422) {
        // Validation error
        throw Exception('Invalid input data: ${response.body}');
      } else if (response.statusCode == 500) {
        throw Exception('Backend server error. Check logs.');
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ Connection Error: $e');
      throw Exception(
        'Cannot connect to backend. Make sure:\n'
        '1. Backend is running (uvicorn api.main:app --reload)\n'
        '2. Correct IP/port in ApiService.baseUrl\n'
        '3. Network connection is working\n\n'
        'Error: $e',
      );
    } catch (e) {
      debugPrint('❌ Error: $e');
      rethrow;
    }
  }

  /// Get AI recommendations (consolidated endpoint)
  static Future<Map<String, dynamic>> getRecommendations(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/recommend');
      
      final response = await http.post(
        Uri.parse('$baseUrl/recommend'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get recommendations: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Recommendations Error: $e');
      rethrow;
    }
  }

  /// Get personalized external product recommendations
  static Future<Map<String, dynamic>> getProductRecommendations(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/recommend-products');

      final response = await http.post(
        Uri.parse('$baseUrl/recommend-products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to get product recommendations: ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ Product Recommendations Error: $e');
      rethrow;
    }
  }

  /// Check API health/connectivity
  static Future<bool> checkHealth() async {
    try {
      debugPrint('🔗 Checking API health...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Backend is healthy');
        return true;
      } else {
        debugPrint('❌ Backend returned: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return false;
    }
  }

  /// Get daily recommendations from advanced engine
  static Future<Map<String, dynamic>> getDailyRecommendations(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/daily-recommendations');
      
      final response = await http.post(
        Uri.parse('$baseUrl/daily-recommendations'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get daily recommendations: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Daily Recommendations Error: $e');
      rethrow;
    }
  }

  /// Get cycle intelligence analysis
  static Future<Map<String, dynamic>> getCycleIntelligence(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/cycle-intelligence');
      
      final response = await http.post(
        Uri.parse('$baseUrl/cycle-intelligence'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get cycle intelligence: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Cycle Intelligence Error: $e');
      rethrow;
    }
  }

  /// Get nutrition plan
  static Future<Map<String, dynamic>> getNutritionPlan(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/nutrition-plan');
      
      final response = await http.post(
        Uri.parse('$baseUrl/nutrition-plan'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get nutrition plan: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Nutrition Plan Error: $e');
      rethrow;
    }
  }

  /// Get health alerts
  static Future<Map<String, dynamic>> getHealthAlerts(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/health-alerts');
      
      final response = await http.post(
        Uri.parse('$baseUrl/health-alerts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get health alerts: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Health Alerts Error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTHENTICATION ENDPOINTS
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required double weight,
    required double height,
  }) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/auth/register');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'age': age,
          'weight': weight,
          'height': height,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Registration failed');
      }
    } catch (e) {
      debugPrint('❌ Registration error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/auth/login');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProfile(String email) async {
    try {
      debugPrint('🔗 API Request: GET $baseUrl/auth/profile/$email');
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/$email'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      debugPrint('❌ Get profile error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String email,
    Map<String, dynamic> profileData,
  ) async {
    try {
      debugPrint('🔗 API Request: PUT $baseUrl/auth/profile/$email');
      
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/$email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profileData),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Profile update failed');
      }
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CYCLE HISTORY ENDPOINTS
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> addCycleEntry({
    required String email,
    required String date,
    required int dayOfCycle,
    required int flowIntensity,
    List<String>? symptoms,
    String? notes,
  }) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/cycle-history/add');
      
      final response = await http.post(
        Uri.parse('$baseUrl/cycle-history/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'date': date,
          'day_of_cycle': dayOfCycle,
          'flow_intensity': flowIntensity,
          'symptoms': symptoms ?? [],
          'notes': notes ?? '',
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add cycle entry');
      }
    } catch (e) {
      debugPrint('❌ Add cycle entry error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCycleHistory(
    String email, {
    int limit = 12,
    int offset = 0,
  }) async {
    try {
      debugPrint('🔗 API Request: GET $baseUrl/cycle-history/history/$email');
      
      final response = await http.get(
        Uri.parse(
          '$baseUrl/cycle-history/history/$email?limit=$limit&offset=$offset',
        ),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get cycle history');
      }
    } catch (e) {
      debugPrint('❌ Get cycle history error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCycleStats(String email) async {
    try {
      debugPrint('🔗 API Request: GET $baseUrl/cycle-history/stats/$email');
      
      final response = await http.get(
        Uri.parse('$baseUrl/cycle-history/stats/$email'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get cycle stats');
      }
    } catch (e) {
      debugPrint('❌ Get cycle stats error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ADVANCED ENDPOINTS (v2.0)
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getFertilityInsights(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/fertility-insights');
      
      final response = await http.post(
        Uri.parse('$baseUrl/fertility-insights'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get fertility insights');
      }
    } catch (e) {
      debugPrint('❌ Fertility insights error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPregnancyInsights(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/pregnancy-insights');
      
      final response = await http.post(
        Uri.parse('$baseUrl/pregnancy-insights'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get pregnancy insights');
      }
    } catch (e) {
      debugPrint('❌ Pregnancy insights error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMentalHealthStatus(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/mental-health');
      
      final response = await http.post(
        Uri.parse('$baseUrl/mental-health'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get mental health status');
      }
    } catch (e) {
      debugPrint('❌ Mental health error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getNotifications(
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/notifications');
      
      final response = await http.post(
        Uri.parse('$baseUrl/notifications'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get notifications');
      }
    } catch (e) {
      debugPrint('❌ Notifications error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    List<Map<String, String>>? history,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? cycle,
  }) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/chat');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'history': history ?? [],
          'profile': profile ?? {},
          'cycle': cycle ?? {},
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Chat failed');
      }
    } catch (e) {
      debugPrint('❌ Chat error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PUSH NOTIFICATION ENDPOINTS
  // ─────────────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> registerDeviceToken({
    required String email,
    required String token,
    String platform = 'android',
  }) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/notifications/device-token');

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/device-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'platform': platform,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register device token: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Register device token error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> sendPushNotification({
    required String title,
    required String body,
    String? email,
    String? token,
    Map<String, String>? data,
  }) async {
    try {
      debugPrint('🔗 API Request: POST $baseUrl/notifications/push');

      final response = await http.post(
        Uri.parse('$baseUrl/notifications/push'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'body': body,
          if (email != null && email.isNotEmpty) 'email': email,
          if (token != null && token.isNotEmpty) 'token': token,
          'data': data ?? {},
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to send push notification: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Send push notification error: $e');
      rethrow;
    }
  }

  /// Update base URL for different environments
  static void setBaseUrl(String newUrl) {
    // Note: This is a demonstration. In production, use environment variables
    debugPrint('🔄 Base URL would be updated to: $newUrl');
  }
}
