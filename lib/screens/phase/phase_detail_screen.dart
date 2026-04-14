import 'package:flutter/material.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';

/// Phase Detail Screen (Menstrual, Follicular, Ovulation, Luteal)
class PhaseDetailScreen extends StatelessWidget {
  const PhaseDetailScreen({super.key, required this.phase});

  final CyclePhase phase;

  static const _phases = <CyclePhase, _PhaseData>{
    CyclePhase.menstrual: _PhaseData(
      name: 'Menstrual Phase',
      emoji: '🩸',
      days: 'Days 1–5',
      description:
          'The uterine lining sheds during this phase. Estrogen and progesterone are at their lowest levels.',
      gradientColors: [Color(0xFFE91E63), Color(0xFFFF5252)],
      accentColor: Color(0xFFE91E63),
      tips: [
        _Tip(emoji: '🥗', title: 'Eat Iron-Rich Foods', body: 'Spinach, lentils, lean meats and dark chocolate help replenish iron lost during menstruation.'),
        _Tip(emoji: '🧘', title: 'Gentle Movement', body: 'Light yoga, stretching or a slow walk can ease cramps and improve mood without overtaxing your body.'),
        _Tip(emoji: '💊', title: 'Pain Management', body: 'Over-the-counter NSAIDs like ibuprofen work best when taken at the first sign of cramps.'),
        _Tip(emoji: '🌡️', title: 'Heat Therapy', body: 'A heating pad on the lower abdomen relaxes the uterine muscles and reduces cramping.'),
        _Tip(emoji: '😴', title: 'Rest & Restore', body: 'Your body is working hard. Prioritize 7–9 hours of sleep and give yourself permission to slow down.'),
      ],
      hormoneInfo: 'Estrogen: LOW · Progesterone: LOW · FSH: Rising',
    ),
    CyclePhase.follicular: _PhaseData(
      name: 'Follicular Phase',
      emoji: '🌱',
      days: 'Days 1–13',
      description:
          'Estrogen rises as follicles in the ovary mature. Energy and mood improve significantly.',
      gradientColors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
      accentColor: Color(0xFF4CAF50),
      tips: [
        _Tip(emoji: '🏋️', title: 'High-Intensity Workouts', body: 'Rising estrogen boosts strength and endurance — perfect for HIIT, lifting, or cardio challenges.'),
        _Tip(emoji: '🫐', title: 'Antioxidant-Rich Diet', body: 'Berries, leafy greens, eggs, and fermented foods support follicle development and detoxification.'),
        _Tip(emoji: '💡', title: 'Creative Projects', body: 'Estrogen enhances focus and creativity. Great time to start new projects or learn new skills.'),
        _Tip(emoji: '🤸', title: 'Try New Things', body: 'Your energy levels are high and mood is optimistic — embrace social engagements and new experiences.'),
        _Tip(emoji: '☀️', title: 'Morning Routine', body: 'Use your rising energy to establish productive morning habits like journaling, meditation, or exercise.'),
      ],
      hormoneInfo: 'Estrogen: RISING · FSH: HIGH · LH: Low',
    ),
    CyclePhase.ovulation: _PhaseData(
      name: 'Ovulation Phase',
      emoji: '✨',
      days: 'Days 14–16',
      description:
          'A mature egg is released from the ovary. This is your peak fertility window — estrogen spikes and LH surges.',
      gradientColors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
      accentColor: Color(0xFFFF9800),
      tips: [
        _Tip(emoji: '💪', title: 'Peak Performance', body: 'You are at your physical and mental best. Push hard in workouts and tackle your most demanding tasks.'),
        _Tip(emoji: '🥑', title: 'Healthy Fats', body: 'Avocados, nuts, and olive oil support hormone production and egg quality during ovulation.'),
        _Tip(emoji: '🌡️', title: 'Track BBT', body: 'Basal body temperature rises slightly (0.2–0.5°C) after ovulation — a reliable fertility sign.'),
        _Tip(emoji: '💬', title: 'Social & Communicative', body: 'LH surge enhances your communication skills and confidence. Perfect for presentations or important conversations.'),
        _Tip(emoji: '🎯', title: 'Fertility Window', body: 'The 3–5 days around ovulation represent your highest fertility window for conception.'),
      ],
      hormoneInfo: 'Estrogen: PEAK · LH: SURGE · Progesterone: Rising',
    ),
    CyclePhase.luteal: _PhaseData(
      name: 'Luteal Phase',
      emoji: '🌙',
      days: 'Days 17–28',
      description:
          'Progesterone rises to prepare the uterus for possible pregnancy. PMS symptoms may appear.',
      gradientColors: [Color(0xFF9C27B0), Color(0xFFAB47BC)],
      accentColor: Color(0xFF9C27B0),
      tips: [
        _Tip(emoji: '🍫', title: 'Magnesium-Rich Foods', body: 'Dark chocolate, bananas, pumpkin seeds, and avocado reduce PMS symptoms and mood swings.'),
        _Tip(emoji: '🏊', title: 'Low-to-Moderate Exercise', body: 'Swimming, pilates or slow jogs are ideal during this phase — avoid pushing too hard.'),
        _Tip(emoji: '😴', title: 'Prioritize Sleep', body: 'Progesterone can cause fatigue. Aim for consistent sleep schedules and limit screen time after 9pm.'),
        _Tip(emoji: '🧘', title: 'Stress Management', body: 'Cortisol worsens PMS. Practice meditation, breathwork, or gentle yoga to keep stress in check.'),
        _Tip(emoji: '☕', title: 'Reduce Caffeine & Salt', body: 'Both can worsen bloating and irritability. Switch to herbal teas and reduce processed food intake.'),
      ],
      hormoneInfo: 'Progesterone: PEAK · Estrogen: Falling · LH: LOW',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final data = _phases[phase]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _PhaseHeader(data: data, context: context),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Description
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    boxShadow: [
                      BoxShadow(
                        color: data.accentColor.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About This Phase',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.description,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          height: 1.6,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Hormone info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: data.accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    border: Border.all(
                      color: data.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.science_rounded,
                        color: data.accentColor,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hormone Levels',
                              style: TextStyle(
                                color: data.accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.hormoneInfo,
                              style: TextStyle(
                                color: data.accentColor.withValues(alpha: 0.75),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Health Tips',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...data.tips.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (e.key * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) {
                        return Opacity(
                          opacity: v,
                          child: Transform.translate(
                            offset: Offset(0, (1 - v) * 12),
                            child: child,
                          ),
                        );
                      },
                      child: _TipCard(tip: e.value, color: data.accentColor),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseHeader extends StatelessWidget {
  const _PhaseHeader({required this.data, required this.context});
  final _PhaseData data;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 24,
        bottom: 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(data.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 12),
          Text(
            data.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              data.days,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.color});
  final _Tip tip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(tip.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.body,
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

enum CyclePhase { menstrual, follicular, ovulation, luteal }

class _PhaseData {
  const _PhaseData({
    required this.name,
    required this.emoji,
    required this.days,
    required this.description,
    required this.gradientColors,
    required this.accentColor,
    required this.tips,
    required this.hormoneInfo,
  });

  final String name;
  final String emoji;
  final String days;
  final String description;
  final List<Color> gradientColors;
  final Color accentColor;
  final List<_Tip> tips;
  final String hormoneInfo;
}

class _Tip {
  const _Tip({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
  final String title;
  final String body;
}
