// lib/services/api_service.dart
// API Service for communicating with FastAPI backend

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Update this based on your environment
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // For real device: 'http://<YOUR_IP>:8000'
  // For web: 'http://localhost:8000'

  /// Make HTTP POST request to /predict endpoint
  /// 
  /// Input data should contain:
  /// - age (int)
  /// - bmi (double)
  /// - cycle_length (int)
  /// - stress (int, 1-10)
  /// - sleep (double, hours)
  /// - symptoms (List<String>)
  /// - weight (double, kg)
  /// - exercise (String)
  /// 
  /// Returns parsed JSON response from backend
  static Future<Map<String, dynamic>> predict(Map<String, dynamic> data) async {
    try {
      print('🔗 API Request: POST $baseUrl/predict');
      print('📤 Sending data: $data');

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

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ API Success: $jsonResponse');
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
      print('❌ Connection Error: $e');
      throw Exception(
        'Cannot connect to backend. Make sure:\n'
        '1. Backend is running (uvicorn api.main:app --reload)\n'
        '2. Correct IP/port in ApiService.baseUrl\n'
        '3. Network connection is working\n\n'
        'Error: $e',
      );
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Get AI recommendations (consolidated endpoint)
  static Future<Map<String, dynamic>> getRecommendations(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/recommend');
      
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
      print('❌ Recommendations Error: $e');
      rethrow;
    }
  }

  /// Get personalized external product recommendations
  static Future<Map<String, dynamic>> getProductRecommendations(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/recommend-products');

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
      print('❌ Product Recommendations Error: $e');
      rethrow;
    }
  }

  /// Check API health/connectivity
  static Future<bool> checkHealth() async {
    try {
      print('🔗 Checking API health...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        print('✅ Backend is healthy');
        return true;
      } else {
        print('❌ Backend returned: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  /// Get daily recommendations from advanced engine
  static Future<Map<String, dynamic>> getDailyRecommendations(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/daily-recommendations');
      
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
      print('❌ Daily Recommendations Error: $e');
      rethrow;
    }
  }

  /// Get cycle intelligence analysis
  static Future<Map<String, dynamic>> getCycleIntelligence(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/cycle-intelligence');
      
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
      print('❌ Cycle Intelligence Error: $e');
      rethrow;
    }
  }

  /// Get nutrition plan
  static Future<Map<String, dynamic>> getNutritionPlan(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/nutrition-plan');
      
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
      print('❌ Nutrition Plan Error: $e');
      rethrow;
    }
  }

  /// Get health alerts
  static Future<Map<String, dynamic>> getHealthAlerts(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/health-alerts');
      
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
      print('❌ Health Alerts Error: $e');
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
      print('🔗 API Request: POST $baseUrl/auth/register');
      
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
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔗 API Request: POST $baseUrl/auth/login');
      
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
      print('❌ Login error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProfile(String email) async {
    try {
      print('🔗 API Request: GET $baseUrl/auth/profile/$email');
      
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
      print('❌ Get profile error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String email,
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('🔗 API Request: PUT $baseUrl/auth/profile/$email');
      
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
      print('❌ Update profile error: $e');
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
      print('🔗 API Request: POST $baseUrl/cycle-history/add');
      
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
      print('❌ Add cycle entry error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCycleHistory(
    String email, {
    int limit = 12,
    int offset = 0,
  }) async {
    try {
      print('🔗 API Request: GET $baseUrl/cycle-history/history/$email');
      
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
      print('❌ Get cycle history error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getCycleStats(String email) async {
    try {
      print('🔗 API Request: GET $baseUrl/cycle-history/stats/$email');
      
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
      print('❌ Get cycle stats error: $e');
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
      print('🔗 API Request: POST $baseUrl/fertility-insights');
      
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
      print('❌ Fertility insights error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPregnancyInsights(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/pregnancy-insights');
      
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
      print('❌ Pregnancy insights error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getMentalHealthStatus(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/mental-health');
      
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
      print('❌ Mental health error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getNotifications(
    Map<String, dynamic> data,
  ) async {
    try {
      print('🔗 API Request: POST $baseUrl/notifications');
      
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
      print('❌ Notifications error: $e');
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
      print('🔗 API Request: POST $baseUrl/chat');
      
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
      print('❌ Chat error: $e');
      rethrow;
    }
  }

  /// Update base URL for different environments
  static void setBaseUrl(String newUrl) {
    // Note: This is a demonstration. In production, use environment variables
    print('🔄 Base URL would be updated to: $newUrl');
  }
}
