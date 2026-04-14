import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preg = context.watch<PregnancyProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(preg)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (!preg.pregnancyMode) ...[
                    _buildOffModeCard(preg),
                  ] else ...[
                    _buildWeekProgressCard(preg),
                    const SizedBox(height: AppSpacing.md),
                    _buildBabyVisualization(preg),
                    const SizedBox(height: AppSpacing.md),
                    _buildWeeklyHighlight(preg),
                    const SizedBox(height: AppSpacing.md),
                    _buildTrimesterTips(preg),
                    const SizedBox(height: AppSpacing.md),
                    _buildHealthStats(preg),
                    const SizedBox(height: AppSpacing.md),
                    _buildDueDateCard(preg),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PregnancyProvider preg) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: preg.pregnancyMode
              ? [const Color(0xFFAD1457), const Color(0xFFE91E63), const Color(0xFFFF80AB)]
              : [const Color(0xFF616161), const Color(0xFF9E9E9E)],
          stops: preg.pregnancyMode ? const [0.0, 0.5, 1.0] : null,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🤰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    'Pregnancy Mode',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              _ToggleSwitch(
                value: preg.pregnancyMode,
                onChanged: (_) => preg.togglePregnancyMode(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            preg.pregnancyMode
                ? 'Week ${preg.currentWeek} of 40 • ${preg.trimester}'
                : 'Toggle to activate pregnancy tracking',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffModeCard(PregnancyProvider preg) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🤰', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Track Your Pregnancy Journey',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Enable Pregnancy Mode to track baby growth, get trimester-specific tips, and monitor your health week by week.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: preg.togglePregnancyMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondaryPink],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Enable Pregnancy Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem('📅', 'Track all 40 weeks'),
          _buildFeatureItem('🍎', 'Week-by-week nutrition tips'),
          _buildFeatureItem('💤', 'Trimester sleep advice'),
          _buildFeatureItem('🎯', 'Baby growth milestones'),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekProgressCard(PregnancyProvider preg) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE0EC), Color(0xFFFFF1F5)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    preg.trimester,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Week ${preg.currentWeek}',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'of 40 weeks',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text(
                      '${preg.daysRemaining} days until due',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _AnimatedPregnancyRing(progress: preg.progressPercent, week: preg.currentWeek),
        ],
      ),
    );
  }

  Widget _buildBabyVisualization(PregnancyProvider preg) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Transform.scale(scale: _pulseAnim.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Baby This Week',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Week size',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentLight,
                    AppColors.background,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  preg.babySize.split(' ').first,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              preg.babySize,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preg.babySizeDescription,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyHighlight(PregnancyProvider preg) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE91E63), Color(0xFFFF80AB)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('⭐', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Week Highlight',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  preg.weeklyHighlight,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimesterTips(PregnancyProvider preg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${preg.trimester} Tips',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...preg.trimesterTips.asMap().entries.map((e) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 350 + (e.key * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Opacity(
                opacity: val,
                child: Transform.translate(
                  offset: Offset(0, (1 - val) * 15),
                  child: child,
                ),
              );
            },
            child: _TrimesterTipCard(
              title: e.value['title']!,
              tip: e.value['tip']!,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHealthStats(PregnancyProvider preg) {
    final trimNum = preg.trimesterNumber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Health Goals',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _HealthStatCard(
                emoji: '💧',
                label: 'Water',
                value: trimNum == 3 ? '10–12 cups' : '8–10 cups',
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _HealthStatCard(
                emoji: '😴',
                label: 'Sleep',
                value: '8–9 hrs',
                color: const Color(0xFF9C27B0),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _HealthStatCard(
                emoji: '🥩',
                label: 'Protein',
                value: trimNum == 3 ? '100g' : '75g',
                color: const Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDueDateCard(PregnancyProvider preg) {
    final due = preg.dueDate;
    if (due == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              shape: BoxShape.circle,
            ),
            child: const Text('📅', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Due Date',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_monthName(due.month)} ${due.day}, ${due.year}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${preg.daysRemaining} days remaining',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.favorite_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _ToggleSwitch extends StatelessWidget {
  const _ToggleSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: value ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: value ? 26 : 2,
              top: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPregnancyRing extends StatelessWidget {
  const _AnimatedPregnancyRing({required this.progress, required this.week});
  final double progress;
  final int week;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CustomPaint(
                size: const Size(100, 100),
                painter: _RingPainter(progress: value),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Wk $week',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background track
    final trackPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.secondaryPink],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _TrimesterTipCard extends StatelessWidget {
  const _TrimesterTipCard({required this.title, required this.tip});
  final String title;
  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              title.split(' ').first,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthStatCard extends StatelessWidget {
  const _HealthStatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  final String emoji;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
