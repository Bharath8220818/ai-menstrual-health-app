import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/services/api_service.dart';
import 'package:femi_friendly/widgets/card_widget.dart';
import 'package:femi_friendly/widgets/loading_indicator.dart';

class FertilityInsightsScreen extends StatefulWidget {
  const FertilityInsightsScreen({super.key});

  @override
  State<FertilityInsightsScreen> createState() => _FertilityInsightsScreenState();
}

class _FertilityInsightsScreenState extends State<FertilityInsightsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Map<String, dynamic>? fertilityData;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fetchFertilityInsights();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchFertilityInsights() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await ApiService.getFertilityInsights({
        'age': auth.age,
        'weight': auth.weight,
        'height': auth.height,
        'cycle_length': auth.cycleLength,
        'ovulation_day': (auth.cycleLength ~/ 2),
        'trying_to_conceive': false,
        'pcos': 'No',
        'stress_level': 'Medium',
      });

      setState(() {
        fertilityData = result;
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
        title: const Text('Fertility Insights'),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: LoadingIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fetchFertilityInsights,
        backgroundColor: AppColors.primary,
        label: const Text('Refresh'),
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
            'Error loading fertility insights',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorMessage ?? 'Unknown error',
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
          // Fertility Score Card
          _buildFertilityScoreCard(),
          const SizedBox(height: AppSpacing.md),

          // Fertile Window
          _buildFertileWindowCard(),
          const SizedBox(height: AppSpacing.md),

          // Fertility Trend Chart
          _buildFertilityTrendChart(),
          const SizedBox(height: AppSpacing.md),

          // Personalized Recommendations
          _buildPersonalizedRecommendations(),
          const SizedBox(height: AppSpacing.md),

          // Fertility Factors
          _buildFertilityFactors(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFertilityScoreCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Fertility Score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary,
                          AppColors.accent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '78%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Good',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScoreFactor('Age', 92, Colors.green),
                    _buildScoreFactor('Cycle Health', 85, Colors.green),
                    _buildScoreFactor('Lifestyle', 65, Colors.orange),
                    _buildScoreFactor('Stress', 55, Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreFactor(String label, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text('$score%', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertileWindowCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fertile Window',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peak Fertility',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Days 12-16',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Success Rate',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '85%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'If trying to conceive, intercourse on days 12-16 has the highest pregnancy probability.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilityTrendChart() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fertility Trend (Last 3 Months)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Month 1', 'Month 2', 'Month 3'];
                        if (value.toInt() < titles.length) {
                          return Text(
                            titles[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 75),
                      FlSpot(1, 78),
                      FlSpot(2, 80),
                    ],
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedRecommendations() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Recommendations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRecommendationItem(
            '💊',
            'Prenatal vitamins',
            'Start taking daily folic acid, Vitamin D, and omega-3 supplements.',
          ),
          _buildRecommendationItem(
            '🏃',
            'Moderate exercise',
            'Aim for 150 min/week of moderate activity to improve fertility.',
          ),
          _buildRecommendationItem(
            '😴',
            'Quality sleep',
            'Get 7-9 hours nightly for optimal hormonal balance.',
          ),
          _buildRecommendationItem(
            '🥗',
            'Anti-inflammatory diet',
            'Focus on omega-3s, antioxidants, and whole foods.',
          ),
          _buildRecommendationItem(
            '🧘',
            'Stress management',
            'Practice meditation, yoga, or breathing exercises daily.',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilityFactors() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Factors Affecting Fertility',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFactorItem(
            '✓',
            'Positive Factors',
            ['Regular 28-day cycle', 'BMI within normal range', 'No PCOS symptoms'],
            Colors.green,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFactorItem(
            '⚠',
            'Areas to Monitor',
            ['Stress levels', 'Sleep quality', 'Exercise frequency'],
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildFactorItem(String icon, String title, List<String> factors, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...factors.map((factor) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const SizedBox(width: 28),
                  Text(
                    '• $factor',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
