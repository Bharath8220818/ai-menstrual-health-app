// lib/screens/advanced_health_screens.dart
// Advanced health tracking screens for Femi-Friendly v2.0

import 'package:flutter/material.dart';
import 'package:femi_friendly/models/health_models.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FERTILITY INSIGHTS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class FertilityInsightsScreen extends StatefulWidget {
  final FertilityInsights insights;

  const FertilityInsightsScreen({
    super.key,
    required this.insights,
  });

  @override
  State<FertilityInsightsScreen> createState() => _FertilityInsightsScreenState();
}

class _FertilityInsightsScreenState extends State<FertilityInsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌸 Fertility Insights'),
        elevation: 0,
        backgroundColor: Colors.pink.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fertility Score Card
            ScaleTransition(
              scale: _scaleAnimation,
              child: FertilityScoreCard(
                score: widget.insights.fertilityScore,
              ),
            ),
            const SizedBox(height: 20),

            // Fertility Window
            if (widget.insights.fertilityWindow != null)
              FertilityWindowCard(
                fertilityWindow: widget.insights.fertilityWindow!,
              ),
            const SizedBox(height: 20),

            // Personalized Baseline
            _buildBaselineCard(),
            const SizedBox(height: 20),

            // Recommendations
            _buildRecommendationsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBaselineCard() {
    final baseline = widget.insights.personalizedBaseline;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Your Personalized Baseline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.pink),
              title: const Text('Baseline Cycle'),
              trailing: Text(
                '${baseline['baseline_cycle']} days',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Expected Range'),
              trailing: Text(
                '${baseline['expected_range'][0]}-${baseline['expected_range'][1]} days',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Personalized Tips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.insights.recommendations
                .map((rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Text('✓', style: TextStyle(color: Colors.green, fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(rec),
                          ),
                        ],
                      ),
                    ))
                ,
          ],
        ),
      ),
    );
  }
}

class FertilityScoreCard extends StatelessWidget {
  final double score;

  const FertilityScoreCard({super.key, required this.score});

  Color _getScoreColor() {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel() {
    if (score >= 80) return 'Excellent Fertility';
    if (score >= 60) return 'Good Fertility';
    return 'Needs Attention';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Your Fertility Score',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor()),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${score.toStringAsFixed(0)}/100',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getScoreLabel(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getScoreColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FertilityWindowCard extends StatelessWidget {
  final List<int> fertilityWindow;

  const FertilityWindowCard({super.key, required this.fertilityWindow});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.pink.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🌸 Fertility Window (Days of cycle)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: fertilityWindow
                  .map((day) => Chip(
                        label: Text('Day $day'),
                        backgroundColor: Colors.pink.shade200,
                        labelStyle: const TextStyle(color: Colors.white),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text(
              'Peak fertility is usually around the middle day of this window.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NUTRITION PLANNER SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class NutritionPlannerScreen extends StatefulWidget {
  final MealPlan mealPlan;

  const NutritionPlannerScreen({
    super.key,
    required this.mealPlan,
  });

  @override
  State<NutritionPlannerScreen> createState() => _NutritionPlannerScreenState();
}

class _NutritionPlannerScreenState extends State<NutritionPlannerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥗 Daily Nutrition Plan'),
        elevation: 0,
        backgroundColor: Colors.green.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Nutrition Summary
            _buildNutritionSummary(),
            const SizedBox(height: 24),

            // Meal Plan Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: '🌅 Breakfast'),
                      Tab(text: '🍽️ Lunch'),
                      Tab(text: '🌙 Dinner'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      children: [
                        _buildMealCard('breakfast'),
                        _buildMealCard('lunch'),
                        _buildMealCard('dinner'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommendations
            _buildRecommendationsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionSummary() {
    final totals = widget.mealPlan.dailyTotals;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Nutrition Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildNutrientBar('Calories', totals.calories, 2000),
            _buildNutrientBar('Protein', totals.protein, 50),
            _buildNutrientBar('Iron', totals.iron, 18),
            _buildNutrientBar('Calcium', totals.calcium, 1000),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBar(String name, double value, double target) {
    final double percentage = ((value / target * 100).clamp(0, 150)).toDouble();
    final exceeds = value > target;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name),
              Text(
                '${value.toStringAsFixed(0)}/${target.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: exceeds ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ((percentage / 150).clamp(0, 1)).toDouble(),
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 100 ? Colors.orange : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String mealType) {
    final meal = widget.mealPlan.meals[mealType];
    if (meal == null) return const Center(child: Text('No meal data'));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildNutrientBadge('Calories', '${meal.nutrition.calories.toStringAsFixed(0)} cal'),
            _buildNutrientBadge('Protein', '${meal.nutrition.protein.toStringAsFixed(1)}g'),
            _buildNutrientBadge('Iron', '${meal.nutrition.iron.toStringAsFixed(1)}mg'),
            _buildNutrientBadge('Calcium', '${meal.nutrition.calcium.toStringAsFixed(0)}mg'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBadge(String name, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Chip(
        label: Text('$name: $value'),
        avatar: const CircleAvatar(child: Icon(Icons.info, size: 16)),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Today\'s Nutrition Tips',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.mealPlan.recommendations
                .map((rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Text('✓', style: TextStyle(color: Colors.green, fontSize: 18)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    ))
                ,
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PREGNANCY TRACKER SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PregnancyTrackerScreen extends StatefulWidget {
  final PregnancyInsights insights;

  const PregnancyTrackerScreen({
    super.key,
    required this.insights,
  });

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final trimester = widget.insights.trimesterInfo;
    final risk = widget.insights.riskAssessment;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👶 Pregnancy Tracker'),
        elevation: 0,
        backgroundColor: Colors.purple.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pregnancy Progress
            _buildProgressCard(trimester),
            const SizedBox(height: 20),

            // Risk Assessment
            _buildRiskCard(risk),
            const SizedBox(height: 20),

            // Trimester Info
            _buildTrimesterCard(trimester),
            const SizedBox(height: 20),

            // Weekly Tips
            _buildWeeklyTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(TrimesterInfo trimester) {
    final double progressPercent = ((trimester.week / 40).clamp(0, 1)).toDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trimester.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Week ${trimester.week} of 40',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progressPercent * 100).toStringAsFixed(0)}% Complete',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Key Milestone: ${trimester.keyMilestones}',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCard(PregnancyRiskAssessment risk) {
    return Card(
      elevation: 2,
      color: risk.riskLevel == 'high' ? Colors.red.shade50 : Colors.orange.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health Risk Assessment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: risk.getRiskColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    risk.riskLevel.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (risk.riskFactors.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Risk Factors:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...risk.riskFactors
                      .map((factor) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Text('⚠️'),
                                const SizedBox(width: 8),
                                Expanded(child: Text(factor)),
                              ],
                            ),
                          ))
                      ,
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimesterCard(TrimesterInfo trimester) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Focus Areas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...trimester.focus
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Text('●', style: TextStyle(color: Colors.purple, fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTipsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 This Week\'s Recommendations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.insights.weeklyPregnancyTips['title'] ?? 'Pregnancy Tips',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...(widget.insights.weeklyPregnancyTips['tips'] as List?)
                    ?.map((tip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              const Text('✓', style: TextStyle(color: Colors.green)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip as String)),
                            ],
                          ),
                        ))
                    .toList() ??
                [],
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MENTAL HEALTH DASHBOARD
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class MentalHealthDashboard extends StatefulWidget {
  final MentalHealthStatus status;

  const MentalHealthDashboard({
    super.key,
    required this.status,
  });

  @override
  State<MentalHealthDashboard> createState() => _MentalHealthDashboardState();
}

class _MentalHealthDashboardState extends State<MentalHealthDashboard> {
  late int _mood;
  late int _stress;

  @override
  void initState() {
    super.initState();
    _mood = widget.status.currentMood;
    _stress = widget.status.currentStress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Mental Health'),
        elevation: 0,
        backgroundColor: Colors.indigo.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Tracker
            _buildMoodCard(),
            const SizedBox(height: 20),

            // Stress Level
            _buildStressCard(),
            const SizedBox(height: 20),

            // Sleep Info
            _buildSleepCard(),
            const SizedBox(height: 20),

            // Wellness Suggestions
            _buildWellnessSuggestionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                final moodValue = index + 1;
                final emojis = ['😢', '😟', '😐', '🙂', '😊'];
                final moodLabels = ['Very Bad', 'Bad', 'Okay', 'Good', 'Great'];

                return GestureDetector(
                  onTap: () {
                    setState(() => _mood = moodValue);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _mood == moodValue ? Colors.indigo.shade200 : Colors.grey.shade100,
                        ),
                        child: Text(
                          emojis[index],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moodLabels[index],
                        style: TextStyle(
                          fontSize: 12,
                          color: _mood == moodValue ? Colors.indigo : Colors.grey,
                          fontWeight: _mood == moodValue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Current Mood: $_mood/5',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stress Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Slider(
              value: _stress.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() => _stress = value.toInt());
              },
            ),
            Center(
              child: Text(
                'Current Stress: $_stress/10',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
          child: Row(
          children: [
            const Icon(Icons.bedtime, size: 40, color: Colors.indigo),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sleep Last Night', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '${widget.status.currentSleepHours.toStringAsFixed(1)} hours',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const Text('💤 Monitor your sleep', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessSuggestionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Wellness Suggestions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.status.wellnessSuggestions
                .map((suggestion) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          const Text('🌟', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(suggestion)),
                        ],
                      ),
                    ))
                ,
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HEALTH ALERTS SCREEN
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class HealthAlertsScreen extends StatefulWidget {
  final AlertsResponse alertsResponse;

  const HealthAlertsScreen({
    super.key,
    required this.alertsResponse,
  });

  @override
  State<HealthAlertsScreen> createState() => _HealthAlertsScreenState();
}

class _HealthAlertsScreenState extends State<HealthAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 Health Alerts'),
        elevation: 0,
        backgroundColor: Colors.red.shade400,
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '🔴 Critical (${widget.alertsResponse.criticalAlerts.length})'),
              Tab(text: '🟡 Warnings (${widget.alertsResponse.warningAlerts.length})'),
              Tab(text: 'ℹ️ Info (${widget.alertsResponse.infoAlerts.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertsList(widget.alertsResponse.criticalAlerts),
                _buildAlertsList(widget.alertsResponse.warningAlerts),
                _buildAlertsList(widget.alertsResponse.infoAlerts),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(List<HealthAlert> alerts) {
    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            SizedBox(height: 16),
            Text('No alerts in this category', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        return _buildAlertCard(alerts[index]);
      },
    );
  }

  Widget _buildAlertCard(HealthAlert alert) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: alert.getColor(), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(alert.getIcon(), color: alert.getColor(), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Severity: ${alert.severity}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.message,
              style: const TextStyle(fontSize: 14),
            ),
            if (alert.actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: alert.actions
                    .map((action) => ElevatedButton(
                          onPressed: () {
                            // Handle action
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Action: ${action.label}')),
                            );
                          },
                          child: Text(action.label),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DAILY HEALTH CENTER (Dashboard combining all recommendations)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class DailyHealthCenterScreen extends StatefulWidget {
  final DailyHealthRecommendation recommendations;

  const DailyHealthCenterScreen({
    super.key,
    required this.recommendations,
  });

  @override
  State<DailyHealthCenterScreen> createState() => _DailyHealthCenterScreenState();
}

class _DailyHealthCenterScreenState extends State<DailyHealthCenterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Daily Health Center'),
        elevation: 0,
        backgroundColor: Colors.teal.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wellness Score
            _buildWellnessScoreCard(),
            const SizedBox(height: 20),

            // Priority Focus
            _buildPriorityFocusCard(),
            const SizedBox(height: 20),

            // Recommendations by Category
            ...widget.recommendations.recommendations.entries
                .map((entry) => _buildRecommendationCategory(entry.key, entry.value))
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessScoreCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Today\'s Wellness Score',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: widget.recommendations.wellnessScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
                Text(
                  '${widget.recommendations.wellnessScore}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '✓ Great start to your day!',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityFocusCard() {
    return Card(
      elevation: 2,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Priority Focus',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.recommendations.priorityFocus,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            if (widget.recommendations.cyclePhase != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('📅 Cycle Phase: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.recommendations.cyclePhase ?? 'N/A',
                    style: const TextStyle(fontSize: 15, color: Colors.teal),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCategory(
    String category,
    RecommendationCategory recommendation,
  ) {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...recommendation.tips
                    .map((tip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✓', style: TextStyle(color: Colors.green, fontSize: 18)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        ))
                    ,
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

