import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/routes/routes.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form values
  final TextEditingController _nameCtrl = TextEditingController();
  DateTime? _birthday;
  double _weight = 60;
  double _height = 165;
  int _periodLength = 5;
  int _cycleLength = 28;

  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<AuthProvider>().completeSetup(
          weight: _weight,
          height: _height,
          birthday: _birthday,
          periodLength: _periodLength,
          cycleLength: _cycleLength,
        );
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE0EC), Color(0xFFFFF1F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          IconButton(
                            onPressed: () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                            ),
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          )
                        else
                          const SizedBox(width: 48),
                        Text(
                          'Step ${_currentPage + 1} of 5',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        TextButton(
                          onPressed: _finish,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentPage + 1) / 5,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.3),
                      color: AppColors.primary,
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ],
                ),
              ),
              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: [
                    _NamePage(controller: _nameCtrl),
                    _BirthdayPage(
                      birthday: _birthday,
                      onPick: (d) => setState(() => _birthday = d),
                    ),
                    _BodyStatsPage(
                      weight: _weight,
                      height: _height,
                      onWeightChange: (v) => setState(() => _weight = v),
                      onHeightChange: (v) => setState(() => _height = v),
                    ),
                    _PeriodLengthPage(
                      value: _periodLength,
                      onChange: (v) => setState(() => _periodLength = v),
                    ),
                    _CycleLengthPage(
                      value: _cycleLength,
                      onChange: (v) => setState(() => _cycleLength = v),
                    ),
                  ],
                ),
              ),
              // Next button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _SetupButton(
                  label: _currentPage == 4 ? 'Get Started 🌸' : 'Continue',
                  onTap: _nextPage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page 1: Name ────────────────────────────────────────────────────────────
class _NamePage extends StatelessWidget {
  const _NamePage({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'What should we\ncall you?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your name helps us personalize your experience.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: 'Enter your name',
              hintStyle: TextStyle(
                color: AppColors.textMuted.withValues(alpha: 0.5),
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: Birthday ────────────────────────────────────────────────────────
class _BirthdayPage extends StatelessWidget {
  const _BirthdayPage({required this.birthday, required this.onPick});
  final DateTime? birthday;
  final void Function(DateTime) onPick;

  String _formatDate(DateTime? d) {
    if (d == null) return 'Tap to select';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎂', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'When were\nyou born?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your age helps us give better cycle predictions.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: birthday ?? DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) onPick(picked);
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _formatDate(birthday),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: birthday != null ? FontWeight.w700 : FontWeight.w400,
                      color: birthday != null ? AppColors.textDark : AppColors.textMuted,
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
}

// ─── Page 3: Body Stats ──────────────────────────────────────────────────────
class _BodyStatsPage extends StatelessWidget {
  const _BodyStatsPage({
    required this.weight,
    required this.height,
    required this.onWeightChange,
    required this.onHeightChange,
  });
  final double weight;
  final double height;
  final void Function(double) onWeightChange;
  final void Function(double) onHeightChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚖️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Your body\nmeasurements',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Used to calculate BMI and personalize health tips.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SliderCard(
            emoji: '⚖️',
            label: 'Weight',
            value: weight,
            min: 30,
            max: 150,
            unit: 'kg',
            onChanged: onWeightChange,
          ),
          const SizedBox(height: AppSpacing.md),
          _SliderCard(
            emoji: '📏',
            label: 'Height',
            value: height,
            min: 120,
            max: 220,
            unit: 'cm',
            onChanged: onHeightChange,
          ),
        ],
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });
  final String emoji;
  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$emoji $label', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${value.round()} $unit',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.accent.withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.round()} $unit', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text('${max.round()} $unit', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Page 4: Period Length ───────────────────────────────────────────────────
class _PeriodLengthPage extends StatelessWidget {
  const _PeriodLengthPage({required this.value, required this.onChange});
  final int value;
  final void Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🩸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'How long is\nyour period?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'On average, a period lasts 3–7 days.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          _CircleDial(
            value: value,
            min: 1,
            max: 10,
            unit: 'days',
            label: 'Period Length',
            color: AppColors.periodColor,
            onChange: onChange,
          ),
        ],
      ),
    );
  }
}

// ─── Page 5: Cycle Length ────────────────────────────────────────────────────
class _CycleLengthPage extends StatelessWidget {
  const _CycleLengthPage({required this.value, required this.onChange});
  final int value;
  final void Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'How long is\nyour cycle?',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A typical menstrual cycle is 21–35 days long.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),
          _CircleDial(
            value: value,
            min: 21,
            max: 45,
            unit: 'days',
            label: 'Cycle Length',
            color: AppColors.primary,
            onChange: onChange,
          ),
        ],
      ),
    );
  }
}

// ─── Circle Dial Widget ──────────────────────────────────────────────────────
class _CircleDial extends StatelessWidget {
  const _CircleDial({
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.label,
    required this.color,
    required this.onChange,
  });
  final int value;
  final int min;
  final int max;
  final String unit;
  final String label;
  final Color color;
  final void Function(int) onChange;

  @override
  Widget build(BuildContext context) {
    final progress = (value - min) / (max - min);
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) {
                    return CircularProgressIndicator(
                      value: v,
                      strokeWidth: 12,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$value',
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      unit,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // +/- controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _DialButton(
                icon: Icons.remove,
                color: color,
                onTap: () {
                  if (value > min) onChange(value - 1);
                },
              ),
              const SizedBox(width: 40),
              _DialButton(
                icon: Icons.add,
                color: color,
                onTap: () {
                  if (value < max) onChange(value + 1);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            activeColor: color,
            inactiveColor: color.withValues(alpha: 0.2),
            onChanged: (v) => onChange(v.round()),
          ),
        ],
      ),
    );
  }
}

class _DialButton extends StatelessWidget {
  const _DialButton({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}

// ─── Setup Button ────────────────────────────────────────────────────────────
class _SetupButton extends StatelessWidget {
  const _SetupButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF4081)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

