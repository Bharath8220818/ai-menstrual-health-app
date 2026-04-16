// lib/models/health_models.dart
// Advanced health data models for Femi-Friendly v2.0

import 'package:flutter/material.dart';

// ─── Fertility Models ───
class FertilityInsights {
  final double fertilityScore;
  final Map<String, dynamic> personalizedBaseline;
  final List<String> recommendations;
  final List<int>? fertilityWindow;

  FertilityInsights({
    required this.fertilityScore,
    required this.personalizedBaseline,
    required this.recommendations,
    this.fertilityWindow,
  });

  factory FertilityInsights.fromJson(Map<String, dynamic> json) {
    return FertilityInsights(
      fertilityScore: (json['fertility_score'] as num?)?.toDouble() ?? 0,
      personalizedBaseline: json['personalized_baseline'] ?? {},
      recommendations: List<String>.from(json['personalized_recommendations'] ?? []),
      fertilityWindow: (json['fertility_window'] as List?)?.cast<int>(),
    );
  }
}

// ─── Nutrition Models ───
class MealPlan {
  final String date;
  final String? cyclePhase;
  final int pregnancyWeek;
  final Map<String, Meal> meals;
  final DailyNutrition dailyTotals;
  final List<String> recommendations;

  MealPlan({
    required this.date,
    this.cyclePhase,
    required this.pregnancyWeek,
    required this.meals,
    required this.dailyTotals,
    required this.recommendations,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      date: json['date'] ?? '',
      cyclePhase: json['cycle_phase'],
      pregnancyWeek: json['pregnancy_week'] ?? 0,
      meals: (json['meals'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Meal.fromJson(value as Map<String, dynamic>)),
          ) ??
          {},
      dailyTotals: DailyNutrition.fromJson(json['daily_totals'] ?? {}),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class Meal {
  final String name;
  final String type;
  final NutritionInfo nutrition;

  Meal({required this.name, required this.type, required this.nutrition});

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      nutrition: NutritionInfo.fromJson(json['nutrition'] ?? {}),
    );
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double iron;
  final double calcium;
  final double fats;
  final double carbs;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.iron,
    required this.calcium,
    required this.fats,
    required this.carbs,
  });

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      iron: (json['iron'] as num?)?.toDouble() ?? 0,
      calcium: (json['calcium'] as num?)?.toDouble() ?? 0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DailyNutrition {
  final double calories;
  final double protein;
  final double iron;
  final double calcium;
  final double fats;
  final double carbs;

  DailyNutrition({
    required this.calories,
    required this.protein,
    required this.iron,
    required this.calcium,
    required this.fats,
    required this.carbs,
  });

  factory DailyNutrition.fromJson(Map<String, dynamic> json) {
    return DailyNutrition(
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      iron: (json['iron'] as num?)?.toDouble() ?? 0,
      calcium: (json['calcium'] as num?)?.toDouble() ?? 0,
      fats: (json['fats'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    );
  }

  double getPercentage(double value, double target) {
    return target > 0 ? (value / target * 100) : 0;
  }
}

// ─── Pregnancy Models ───
class PregnancyInsights {
  final int pregnancyWeek;
  final TrimesterInfo trimesterInfo;
  final PregnancyRiskAssessment riskAssessment;
  final Map<String, dynamic> weeklyPregnancyTips;

  PregnancyInsights({
    required this.pregnancyWeek,
    required this.trimesterInfo,
    required this.riskAssessment,
    required this.weeklyPregnancyTips,
  });

  factory PregnancyInsights.fromJson(Map<String, dynamic> json) {
    return PregnancyInsights(
      pregnancyWeek: json['pregnancy_week'] ?? 0,
      trimesterInfo: TrimesterInfo.fromJson(json['trimester_info'] ?? {}),
      riskAssessment: PregnancyRiskAssessment.fromJson(json['risk_assessment'] ?? {}),
      weeklyPregnancyTips: json['weekly_pregnancy_tips'] ?? {},
    );
  }
}

class TrimesterInfo {
  final int trimester;
  final String name;
  final int week;
  final List<String> focus;
  final String keyMilestones;

  TrimesterInfo({
    required this.trimester,
    required this.name,
    required this.week,
    required this.focus,
    required this.keyMilestones,
  });

  factory TrimesterInfo.fromJson(Map<String, dynamic> json) {
    return TrimesterInfo(
      trimester: json['trimester'] ?? 0,
      name: json['name'] ?? '',
      week: json['week'] ?? 0,
      focus: List<String>.from(json['focus'] ?? []),
      keyMilestones: json['key_milestones'] ?? '',
    );
  }
}

class PregnancyRiskAssessment {
  final int riskScore;
  final String riskLevel;
  final List<String> riskFactors;
  final List<String> recommendations;

  PregnancyRiskAssessment({
    required this.riskScore,
    required this.riskLevel,
    required this.riskFactors,
    required this.recommendations,
  });

  factory PregnancyRiskAssessment.fromJson(Map<String, dynamic> json) {
    return PregnancyRiskAssessment(
      riskScore: json['risk_score'] ?? 0,
      riskLevel: json['risk_level'] ?? 'low',
      riskFactors: List<String>.from(json['risk_factors'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }

  Color getRiskColor() {
    switch (riskLevel) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

// ─── Mental Health Models ───
class MentalHealthStatus {
  final int currentMood;
  final int currentStress;
  final double currentSleepHours;
  final Map<String, dynamic> healthSummary;
  final List<String> wellnessSuggestions;

  MentalHealthStatus({
    required this.currentMood,
    required this.currentStress,
    required this.currentSleepHours,
    required this.healthSummary,
    required this.wellnessSuggestions,
  });

  factory MentalHealthStatus.fromJson(Map<String, dynamic> json) {
    return MentalHealthStatus(
      currentMood: json['current_mood'] ?? 5,
      currentStress: json['current_stress'] ?? 5,
      currentSleepHours: (json['current_sleep_hours'] as num?)?.toDouble() ?? 7,
      healthSummary: json['health_summary'] ?? {},
      wellnessSuggestions: List<String>.from(json['wellness_suggestions'] ?? []),
    );
  }
}

// ─── Alert Models ───
class HealthAlert {
  final String type; // critical, warning, info
  final String title;
  final String message;
  final String severity;
  final List<AlertAction> actions;
  final DateTime timestamp;

  HealthAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.severity,
    required this.actions,
    required this.timestamp,
  });

  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      type: json['type'] ?? 'info',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'low',
      actions: (json['actions'] as List?)
              ?.map((a) => AlertAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Color getColor() {
    switch (type) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData getIcon() {
    switch (type) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}

class AlertAction {
  final String action;
  final String label;

  AlertAction({required this.action, required this.label});

  factory AlertAction.fromJson(Map<String, dynamic> json) {
    return AlertAction(
      action: json['action'] ?? '',
      label: json['label'] ?? '',
    );
  }
}

class AlertsResponse {
  final List<HealthAlert> alerts;
  final List<HealthAlert> criticalAlerts;
  final List<HealthAlert> warningAlerts;
  final List<HealthAlert> infoAlerts;

  AlertsResponse({
    required this.alerts,
    required this.criticalAlerts,
    required this.warningAlerts,
    required this.infoAlerts,
  });

  factory AlertsResponse.fromJson(Map<String, dynamic> json) {
    return AlertsResponse(
      alerts: (json['alerts'] as List?)
              ?.map((a) => HealthAlert.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      criticalAlerts: (json['critical_alerts'] as List?)
              ?.map((a) => HealthAlert.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      warningAlerts: (json['warning_alerts'] as List?)
              ?.map((a) => HealthAlert.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      infoAlerts: (json['info_alerts'] as List?)
              ?.map((a) => HealthAlert.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// ─── Notification Models ───
class HealthNotification {
  final String type;
  final String title;
  final String message;
  final String priority;
  final String? action;
  final DateTime timestamp;

  HealthNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    this.action,
    required this.timestamp,
  });

  factory HealthNotification.fromJson(Map<String, dynamic> json) {
    return HealthNotification(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      priority: json['priority'] ?? 'normal',
      action: json['action'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Color getPriorityColor() {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'normal':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData getIcon() {
    switch (type) {
      case 'water':
        return Icons.water_drop;
      case 'period':
        return Icons.female;
      case 'fertility':
        return Icons.favorite;
      case 'pregnancy':
        return Icons.pregnant_woman;
      case 'mental_health':
        return Icons.favorite;
      default:
        return Icons.notifications;
    }
  }
}

// ─── Daily Health Recommendation ───
class DailyHealthRecommendation {
  final String date;
  final String? cyclePhase;
  final int pregnancyWeek;
  final Map<String, RecommendationCategory> recommendations;
  final int wellnessScore;
  final String priorityFocus;

  DailyHealthRecommendation({
    required this.date,
    this.cyclePhase,
    required this.pregnancyWeek,
    required this.recommendations,
    required this.wellnessScore,
    required this.priorityFocus,
  });

  factory DailyHealthRecommendation.fromJson(Map<String, dynamic> json) {
    final recs = <String, RecommendationCategory>{};
    (json['recommendations'] as Map<String, dynamic>?)?.forEach((key, value) {
      recs[key] = RecommendationCategory.fromJson(value as Map<String, dynamic>);
    });

    return DailyHealthRecommendation(
      date: json['date'] ?? '',
      cyclePhase: json['cycle_phase'],
      pregnancyWeek: json['pregnancy_week'] ?? 0,
      recommendations: recs,
      wellnessScore: json['wellness_score'] ?? 75,
      priorityFocus: json['priority_focus'] ?? '',
    );
  }
}

class RecommendationCategory {
  final String title;
  final List<String> tips;
  final Map<String, dynamic> additionalInfo;

  RecommendationCategory({
    required this.title,
    required this.tips,
    this.additionalInfo = const {},
  });

  factory RecommendationCategory.fromJson(Map<String, dynamic> json) {
    return RecommendationCategory(
      title: json['title'] ?? '',
      tips: List<String>.from(json['tips'] ?? []),
      additionalInfo: json..remove('title')..remove('tips'),
    );
  }
}

// ─── Cycle Intelligence Models ───
class CycleIntelligence {
  final Map<String, dynamic> irregularityAnalysis;
  final Map<String, dynamic> hormonalImbalanceRisk;
  final Map<String, dynamic> pcosRiskAssessment;
  final double nextPredictedCycle;

  CycleIntelligence({
    required this.irregularityAnalysis,
    required this.hormonalImbalanceRisk,
    required this.pcosRiskAssessment,
    required this.nextPredictedCycle,
  });

  factory CycleIntelligence.fromJson(Map<String, dynamic> json) {
    return CycleIntelligence(
      irregularityAnalysis: json['irregularity_analysis'] ?? {},
      hormonalImbalanceRisk: json['hormonal_imbalance_risk'] ?? {},
      pcosRiskAssessment: json['pcos_risk_assessment'] ?? {},
      nextPredictedCycle: (json['next_predicted_cycle'] as num?)?.toDouble() ?? 28,
    );
  }
}
