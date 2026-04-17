import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/services/api_service.dart';
import 'package:femi_friendly/widgets/card_widget.dart';
import 'package:femi_friendly/widgets/loading_indicator.dart';

class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  
  int _moodScore = 7;
  int _stressScore = 5;
  double _sleepHours = 7.0;
  Map<String, dynamic>? wellnessData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitMentalHealthData() async {
    setState(() => isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final result = await ApiService.getMentalHealthStatus({
        'mood': _moodScore,
        'stress': _stressScore,
        'sleep_hours': _sleepHours,
        'age': auth.age,
        'weight': auth.weight,
        'cycle_phase': 'follicular',
      });

      setState(() {
        wellnessData = result;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mental health data updated successfully!'),
          backgroundColor: Colors.green.shade600,
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mental Health & Wellness'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // Mood Tracker
            _buildMoodCard(),
            const SizedBox(height: AppSpacing.md),

            // Stress Level
            _buildStressCard(),
            const SizedBox(height: AppSpacing.md),

            // Sleep Tracker
            _buildSleepCard(),
            const SizedBox(height: AppSpacing.md),

            // Wellness Tips
            _buildWellnessTipsCard(),
            const SizedBox(height: AppSpacing.md),

            // Cycle-Mood Connection
            _buildCycleMoodCard(),
            const SizedBox(height: AppSpacing.md),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitMentalHealthData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 24,
                        child: LoadingIndicator(),
                      )
                    : const Text('Save Mental Health Data'),
              ),
            ),

            // Results
            if (wellnessData != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildResultsCard(),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCard() {
    final moodLabels = ['Terrible', 'Poor', 'Okay', 'Good', 'Great', 'Excellent', 'Amazing', 'Perfect', 'Wonderful', 'Extraordinary'];
    final moodEmojis = ['😢', '😞', '😐', '🙂', '😊', '😄', '😃', '🤩', '😍', '🎉'];
    
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Column(
              children: [
                Text(
                  moodEmojis[_moodScore],
                  style: const TextStyle(fontSize: 64),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  moodLabels[_moodScore],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Slider(
            value: _moodScore.toDouble(),
            min: 0,
            max: 9,
            divisions: 9,
            onChanged: (value) => setState(() => _moodScore = value.toInt()),
            activeColor: AppColors.primary,
            inactiveColor: Colors.grey.shade300,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Poor', style: Theme.of(context).textTheme.bodySmall),
              Text('Excellent', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStressCard() {
    final stressLevel = _stressScore <= 3 ? 'Low' : _stressScore <= 6 ? 'Moderate' : 'High';
    final stressColor = _stressScore <= 3 ? Colors.green : _stressScore <= 6 ? Colors.orange : Colors.red;
    
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stress Level',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: stressColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stressLevel,
                  style: TextStyle(
                    color: stressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Slider(
            value: _stressScore.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) => setState(() => _stressScore = value.toInt()),
            activeColor: stressColor,
            inactiveColor: Colors.grey.shade300,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Relaxed', style: Theme.of(context).textTheme.bodySmall),
              Text('Overwhelmed', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stress Relief Tips',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.blue.shade700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ..._getStressReliefTips().map((tip) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '• $tip',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getStressReliefTips() {
    if (_stressScore <= 3) {
      return ['Continue your current healthy habits', 'Practice gratitude journaling'];
    } else if (_stressScore <= 6) {
      return [
        'Take 5-minute breathing breaks',
        'Go for a 20-minute walk',
        'Do light stretching or yoga'
      ];
    } else {
      return [
        'Try meditation or deep breathing now',
        'Consider talking to someone',
        'Limit caffeine and screen time',
        'Schedule relaxing activities today'
      ];
    }
  }

  Widget _buildSleepCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Tracker',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '😴',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${_sleepHours.toStringAsFixed(1)} hours',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Slider(
            value: _sleepHours,
            min: 3,
            max: 12,
            divisions: 18,
            onChanged: (value) => setState(() => _sleepHours = value),
            activeColor: AppColors.primary,
            inactiveColor: Colors.grey.shade300,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Minimal', style: Theme.of(context).textTheme.bodySmall),
              Text('Plenty', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _sleepHours >= 7 ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Column(
              children: [
                Text(
                  _sleepHours >= 7
                      ? '✓ You\'re getting enough sleep!'
                      : '⚠ Consider getting more sleep',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Aim for 7-9 hours nightly for optimal health and hormonal balance.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessTipsCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Wellness Practices',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildWellnessItem('🧘', 'Meditation', 'Start with 5-10 minutes daily'),
          _buildWellnessItem('🏃', 'Exercise', '30 minutes of moderate activity'),
          _buildWellnessItem('🥗', 'Nutrition', 'Eat whole foods, limit processed items'),
          _buildWellnessItem('📝', 'Journaling', 'Write down thoughts and feelings'),
          _buildWellnessItem('🌙', 'Sleep', 'Maintain consistent sleep schedule'),
          _buildWellnessItem('👥', 'Social', 'Connect with loved ones daily'),
        ],
      ),
    );
  }

  Widget _buildWellnessItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
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

  Widget _buildCycleMoodCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cycle & Mental Health Connection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Did you know? Your menstrual cycle affects your mood and energy levels.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildPhaseInfo('🌸 Follicular', 'Rising energy and mood'),
                _buildPhaseInfo('🌞 Ovulation', 'Peak confidence and sociability'),
                _buildPhaseInfo('🍂 Luteal', 'Introspective and need more rest'),
                _buildPhaseInfo('🌙 Menstrual', 'Self-care and gentle movement'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseInfo(String phase, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(phase, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Wellness Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep up your wellness journey! 🌟',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your data has been saved and will help personalize your health recommendations.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
