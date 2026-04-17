import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/auth_provider.dart';

import 'package:femi_friendly/services/api_service.dart';
import 'package:femi_friendly/widgets/card_widget.dart';
import 'package:femi_friendly/widgets/loading_indicator.dart';

class NutritionPlannerScreen extends StatefulWidget {
  const NutritionPlannerScreen({super.key});

  @override
  State<NutritionPlannerScreen> createState() => _NutritionPlannerScreenState();
}

class _NutritionPlannerScreenState extends State<NutritionPlannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Map<String, dynamic>? nutritionPlan;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fetchNutritionPlan();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchNutritionPlan() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await ApiService.getNutritionPlan({
        'cycle_phase': 'follicular',
        'pregnancy_week': 0,
        'calories_target': 2000,
        'diet_type': 'balanced',
        'age': auth.age,
        'weight': auth.weight,
        'height': auth.height,
        'bmi': auth.weight / ((auth.height / 100) * (auth.height / 100)),
      });

      setState(() {
        nutritionPlan = result;
        isLoading = false;
      });

      _animController.forward();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrition Planner'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchNutritionPlan,
        backgroundColor: AppColors.primary,
        label: const Text('Refresh Plan'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Error loading nutrition plan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Daily Summary Card
          CardWidget(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Nutrition Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildNutrientRow('Calories', '2000 kcal', Colors.orange),
                _buildNutrientRow('Protein', '75g (15%)', Colors.red.shade400),
                _buildNutrientRow(
                    'Carbs', '250g (50%)', Colors.yellow.shade600),
                _buildNutrientRow('Fat', '65g (35%)', Colors.green.shade400),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Meals Section
          _buildMealsSection(),
          const SizedBox(height: AppSpacing.md),

          // Food Recommendations
          _buildFoodRecommendationsSection(),
          const SizedBox(height: AppSpacing.md),

          // Phase-Specific Tips
          _buildPhaseSpecificTips(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsSection() {
    final meals = [
      {
        'time': 'Breakfast',
        'meal': 'Oatmeal with berries & almonds',
        'cals': '350 kcal',
        'icon': '🌅',
      },
      {
        'time': 'Mid-Morning Snack',
        'meal': 'Greek yogurt with honey',
        'cals': '150 kcal',
        'icon': '🥛',
      },
      {
        'time': 'Lunch',
        'meal': 'Grilled salmon with quinoa & vegetables',
        'cals': '550 kcal',
        'icon': '🍽️',
      },
      {
        'time': 'Afternoon Snack',
        'meal': 'Apple with peanut butter',
        'cals': '200 kcal',
        'icon': '🍎',
      },
      {
        'time': 'Dinner',
        'meal': 'Chicken with sweet potato & broccoli',
        'cals': '500 kcal',
        'icon': '🍗',
      },
    ];

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Meal Plan',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...meals.asMap().entries.map((entry) {
            final meal = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text(meal['icon'] as String, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal['time'] as String,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal['meal'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    meal['cals'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFoodRecommendationsSection() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended Foods',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildFoodChip('Spinach'),
              _buildFoodChip('Salmon'),
              _buildFoodChip('Almonds'),
              _buildFoodChip('Eggs'),
              _buildFoodChip('Berries'),
              _buildFoodChip('Chickpeas'),
              _buildFoodChip('Dark Chocolate'),
              _buildFoodChip('Ginger'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foods to Avoid',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Limit caffeine, processed foods, and high-sugar items during your cycle.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.primary),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
    );
  }

  Widget _buildPhaseSpecificTips() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follicular Phase Tips',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTipItem(
            '⚡',
            'Increase protein intake',
            'Your energy is rising, fuel workouts with lean proteins.',
          ),
          _buildTipItem(
            '💧',
            'Stay hydrated',
            'Drink 2-3 liters of water daily to support hormonal balance.',
          ),
          _buildTipItem(
            '🥗',
            'Focus on iron',
            'Replenish iron after menstruation with spinach and legumes.',
          ),
          _buildTipItem(
            '🧘',
            'Light meals',
            'Your digestion is strongest in this phase - larger meals OK.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

