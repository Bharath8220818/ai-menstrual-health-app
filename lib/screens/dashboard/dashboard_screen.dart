import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/core/constants/app_strings.dart';
import 'package:femi_friendly/core/utils/date_format_helper.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';
import 'package:femi_friendly/routes/routes.dart';
import 'package:femi_friendly/screens/phase/phase_detail_screen.dart';
import 'package:femi_friendly/widgets/card_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onQuickActionTap});

  final void Function(int index)? onQuickActionTap;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cycle = context.watch<CycleProvider>();
    final preg = context.watch<PregnancyProvider>();
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _DashboardHeader(
              greeting: greeting,
              name: auth.name,
              now: now,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Pregnancy Mode Banner (shown when active)
                if (preg.pregnancyMode)
                  _PregnancyBanner(
                    preg: preg,
                    onTap: () => onQuickActionTap?.call(2),
                  ),
                if (preg.pregnancyMode) const SizedBox(height: AppSpacing.md),
                // Main cycle card
                _CycleCard(cycle: cycle),
                const SizedBox(height: AppSpacing.md),
                // 4 Phase cards row
                _PhaseSelectorRow(cycle: cycle),
                const SizedBox(height: AppSpacing.md),
                // Daily recommendation section
                _DailyRecommendations(cycle: cycle),
                const SizedBox(height: AppSpacing.md),
                _PcodFocusCard(cycle: cycle, onTap: () => onQuickActionTap?.call(3)),
                const SizedBox(height: AppSpacing.md),
                // Quick actions (5 actions)
                _QuickActionsGrid(onTap: onQuickActionTap),
                const SizedBox(height: AppSpacing.md),
                // Phase info
                _PhaseInfoCard(cycle: cycle),
                const SizedBox(height: AppSpacing.md),
                // Disclaimer
                _DisclaimerCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header ─────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.greeting,
    required this.name,
    required this.now,
  });

  final String greeting;
  final String name;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAD1457), Color(0xFFE91E63), Color(0xFFFF80AB)],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Femi-Friendly',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Notification bell
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.notifications,
                        ),
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF69F0AE),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Profile avatar
                  IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.profile),
                    icon: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$greeting, 🌸',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatDate(now),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cycle Card ──────────────────────────────────────────────────────────────
class _CycleCard extends StatelessWidget {
  const _CycleCard({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final daysUntilPeriod =
        cycle.nextPeriodDate.difference(DateTime.now()).inDays;
    final progress = cycle.cycleProgress;
    final isNormal = cycle.cycleStatus == 'Normal';

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isNormal ? AppColors.successLight : AppColors.warningLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cycle.cycleStatus,
                    style: TextStyle(
                      color: isNormal ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Day ${cycle.currentDayInCycle}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                ),
                const Text(
                  'of cycle',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 15, color: AppColors.textMuted),
                    const SizedBox(width: 5),
                    Text(
                      'Next period: ${daysUntilPeriod < 0 ? 'Overdue' : 'in $daysUntilPeriod days'}',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(cycle.nextPeriodDate),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
          _ProgressRing(progress: progress, cycleLength: cycle.predictedCycleLength),
        ],
      ),
    );
  }
}

// ─── Progress Ring ───────────────────────────────────────────────────────────
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.cycleLength});
  final double progress;
  final int cycleLength;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: AppColors.accent.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeCap: StrokeCap.round,
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              Text(
                '$cycleLength days',
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Phase Selector Row ──────────────────────────────────────────────────────
class _PhaseSelectorRow extends StatelessWidget {
  const _PhaseSelectorRow({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final day = cycle.currentDayInCycle;

    final phases = [
      (
        label: 'Menstrual',
        emoji: '🩸',
        color: AppColors.menstrualPhase,
        active: day <= 5,
        phase: CyclePhase.menstrual,
        days: '1–5',
      ),
      (
        label: 'Follicular',
        emoji: '🌱',
        color: AppColors.follicularPhase,
        active: day > 5 && day <= 13,
        phase: CyclePhase.follicular,
        days: '6–13',
      ),
      (
        label: 'Ovulation',
        emoji: '✨',
        color: AppColors.ovulationPhase,
        active: day > 13 && day <= 16,
        phase: CyclePhase.ovulation,
        days: '14–16',
      ),
      (
        label: 'Luteal',
        emoji: '🌙',
        color: AppColors.lutealPhase,
        active: day > 16,
        phase: CyclePhase.luteal,
        days: '17–28',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cycle Phases',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: phases.map((p) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.phaseDetail,
                    arguments: p.phase,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: p.active
                          ? p.color
                          : Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      boxShadow: p.active
                          ? [
                              BoxShadow(
                                color: p.color.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        Text(p.emoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          p.label,
                          style: TextStyle(
                            color: p.active ? Colors.white : AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Day ${p.days}',
                          style: TextStyle(
                            color: p.active
                                ? Colors.white.withValues(alpha: 0.8)
                                : AppColors.textMuted.withValues(alpha: 0.6),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Daily Recommendations ───────────────────────────────────────────────────
class _DailyRecommendations extends StatelessWidget {
  const _DailyRecommendations({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final day = cycle.currentDayInCycle;
    final recommendations = _getRecommendations(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Recommendations',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _RecommendationCard(
                icon: '🥗',
                label: 'Food',
                tip: recommendations['food']!,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _RecommendationCard(
                icon: '🏃‍♀️',
                label: 'Activity',
                tip: recommendations['activity']!,
                color: const Color(0xFF2196F3),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _RecommendationCard(
                icon: '😊',
                label: 'Mood',
                tip: recommendations['mood']!,
                color: const Color(0xFFFF9800),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, String> _getRecommendations(int day) {
    if (day <= 5) {
      return {
        'food': 'Iron-rich foods: spinach, lentils, dark chocolate',
        'activity': 'Light yoga, gentle walks, rest',
        'mood': 'Practice self-compassion, journaling',
      };
    } else if (day <= 13) {
      return {
        'food': 'Antioxidants: berries, leafy greens, eggs',
        'activity': 'Cardio, strength training, dancing',
        'mood': 'Social activities, creative projects',
      };
    } else if (day <= 16) {
      return {
        'food': 'Light meals: salads, smoothies, nuts',
        'activity': 'High intensity workouts, runs',
        'mood': 'Channel high energy productively',
      };
    } else {
      return {
        'food': 'Magnesium: dark chocolate, bananas, avocado',
        'activity': 'Pilates, swimming, stretching',
        'mood': 'Wind down, limit caffeine, meditate',
      };
    }
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.icon,
    required this.label,
    required this.tip,
    required this.color,
  });

  final String icon;
  final String label;
  final String tip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            tip,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _PcodFocusCard extends StatelessWidget {
  const _PcodFocusCard({
    required this.cycle,
    required this.onTap,
  });

  final CycleProvider cycle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tracked = cycle.trackedPcodSymptoms;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF1E6), Color(0xFFFFFBF7)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: const Color(0xFFF2C29B)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF6C00).withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE3CC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_rounded,
                    color: Color(0xFFEF6C00),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Hormonal Health Disorder Tracker',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFEF6C00),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tracked.isEmpty
                  ? 'Open HHDT to compare tracked symptoms with common hormonal and reproductive health condition patterns.'
                  : 'Tracked signs: ${tracked.take(4).join(', ')}',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _PcodMiniTip(
                    title: 'What to do',
                    text: 'Walk, strength train, and sleep on schedule.',
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _PcodMiniTip(
                    title: 'What to eat',
                    text: 'Protein, fiber, low-GI carbs, nuts, and seeds.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Other problems to watch: acne, hair thinning, facial hair growth, cravings, dark patches, heavy bleeding, and pelvic pain.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PcodMiniTip extends StatelessWidget {
  const _PcodMiniTip({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFEF6C00),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions Grid ──────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({this.onTap});
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        label: 'Log Symptoms',
        icon: Icons.add_circle_outline_rounded,
        emoji: '🩸',
        gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFFF4081)]),
        onPressed: () => onTap?.call(1),
      ),
      (
        label: 'Water Track',
        icon: Icons.water_drop_rounded,
        emoji: '💧',
        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.waterTracker),
      ),
      (
        label: 'Shop',
        icon: Icons.shopping_bag_rounded,
        emoji: '🛍️',
        gradient: const LinearGradient(colors: [Color(0xFFAD1457), Color(0xFFE91E63)]),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.productShop),
      ),
      (
        label: 'Nearby',
        icon: Icons.location_on_rounded,
        emoji: '🗺️',
        gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)]),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.mapScreen),
      ),
      (
        label: 'AI Chat',
        icon: Icons.chat_rounded,
        emoji: '🤖',
        gradient: const LinearGradient(colors: [Color(0xFF00695C), Color(0xFF26A69A)]),
        onPressed: () => onTap?.call(4),
      ),
    ];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
          children: actions.map((a) {
            return GestureDetector(
              onTap: a.onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: a.gradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  boxShadow: [
                    BoxShadow(
                      color: (a.gradient.colors.first).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(a.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 9),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Phase Info Card ─────────────────────────────────────────────────────────
class _PhaseInfoCard extends StatelessWidget {
  const _PhaseInfoCard({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final day = cycle.currentDayInCycle;
    String phase;
    String phaseDesc;
    Color phaseColor;
    CyclePhase cyclePhase;

    if (day <= 5) {
      phase = 'Menstrual Phase';
      phaseDesc = 'Rest, restore, and nourish yourself.';
      phaseColor = AppColors.menstrualPhase;
      cyclePhase = CyclePhase.menstrual;
    } else if (day <= 13) {
      phase = 'Follicular Phase';
      phaseDesc = 'Energy rising! Great time to try new things.';
      phaseColor = AppColors.follicularPhase;
      cyclePhase = CyclePhase.follicular;
    } else if (day <= 16) {
      phase = 'Ovulation Phase';
      phaseDesc = 'Peak fertility and energy. You are at your best!';
      phaseColor = AppColors.ovulationPhase;
      cyclePhase = CyclePhase.ovulation;
    } else {
      phase = 'Luteal Phase';
      phaseDesc = 'Wind down and prioritize self-care.';
      phaseColor = AppColors.lutealPhase;
      cyclePhase = CyclePhase.luteal;
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.phaseDetail,
        arguments: cyclePhase,
      ),
      child: CardWidget(
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: phaseColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Phase',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phase,
                    style: TextStyle(color: phaseColor, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  Text(
                    phaseDesc,
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: phaseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Learn more',
                    style: TextStyle(color: phaseColor, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_ios_rounded, color: phaseColor, size: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Disclaimer ──────────────────────────────────────────────────────────────
class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.health_and_safety_outlined, color: AppColors.warning, size: 20),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              AppStrings.disclaimer,
              style: TextStyle(color: AppColors.warning, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pregnancy Banner ─────────────────────────────────────────────────────────
class _PregnancyBanner extends StatelessWidget {
  const _PregnancyBanner({required this.preg, required this.onTap});
  final PregnancyProvider preg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, val, child) => Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, (1 - val) * 10),
            child: child,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFAD1457), Color(0xFFE91E63), Color(0xFFFF80AB)],
              stops: [0.0, 0.5, 1.0],
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text('🤰', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pregnancy Mode Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Week ${preg.currentWeek} of 40 • ${preg.trimester} • ${preg.daysRemaining} days to go',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

