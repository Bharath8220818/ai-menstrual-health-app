import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/providers/insights_provider.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';
import 'package:femi_friendly/routes/routes.dart';

/// Comprehensive AI Insights Screen with Fertility window integration
class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapInsights());
  }

  Future<void> _bootstrapInsights() async {
    final auth = context.read<AuthProvider>();
    final cycle = context.read<CycleProvider>();
    final pregnancy = context.read<PregnancyProvider>();
    final insights = context.read<InsightsProvider>();

    await Future.wait([
      insights.fetchInsights(
        auth: auth,
        cycle: cycle,
        pregnancy: pregnancy,
      ),
      Future<void>.delayed(const Duration(milliseconds: 800)),
    ]);

    if (!mounted) return;
    setState(() => _isLoading = false);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final insights = context.watch<InsightsProvider>();
    final day = cycle.currentDayInCycle;

    final cycleLengthLabel =
        '${insights.cycleLength ?? cycle.predictedCycleLength} days';
    final cycleSubtitle = insights.cycleStatus != null
        ? 'AI API status: ${insights.cycleStatus}'
        : 'Based on your last ${cycle.history.length} cycles';

    final waterLabel = insights.waterIntake != null
        ? '${insights.waterIntake!.toStringAsFixed(1)}L / day'
        : '2.5L / day';

    final foodValue = insights.foodRecommendations.isNotEmpty
        ? insights.foodRecommendations.first
        : _getFoodValue(day);

    final foodTips = insights.foodRecommendations.isNotEmpty
        ? insights.foodRecommendations
            .take(3)
            .map((item) => 'Include $item in your meals this phase')
            .toList()
        : _getFoodTips(day);

    final waterTips = insights.healthTips.isNotEmpty
        ? insights.healthTips.take(3).toList()
        : <String>[
            'Drink at least 8 glasses per day',
            'Add lemon or cucumber for electrolytes',
            'Herbal teas count towards daily intake',
          ];

    final wellnessTips = insights.healthTips.isNotEmpty
        ? insights.healthTips.take(3).toList()
        : <String>[
            'Consistent sleep schedule regulates hormones',
            'Reduce screen time 1 hour before bed',
            'Light stretching before sleep reduces cramps',
          ];

    final pregnancyLabel = insights.pregnancyChance ?? _getPregnancyChance(day);
    final pregnancyTips = insights.fertilityWindow.isNotEmpty
        ? <String>[
            'Estimated fertile window: Day ${insights.fertilityWindow.first}–${insights.fertilityWindow.last}',
            if (insights.pregnancyProbability != null)
              'Predicted pregnancy probability: ${(insights.pregnancyProbability! * 100).toStringAsFixed(1)}%',
            'Use cycle + symptom logging daily for better model confidence',
          ]
        : _getPregnancyTips(day);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _InsightsHeader(cycle: cycle)),
          if (!_isLoading && insights.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  0,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radius),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    'Using fallback insights: ${insights.error}',
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: _LoadingSkeleton(),
                  ),
                  childCount: 5,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, 100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        _ProductRecommendationCta(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.productRecommendations,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Fertility Card
                        _FertilityInsightCard(cycle: cycle),
                        const SizedBox(height: AppSpacing.md),
                        _PcodSupportCard(cycle: cycle),
                        const SizedBox(height: AppSpacing.md),
                        // Cycle Prediction
                        _buildInsightCard(
                          index: 0,
                          title: 'Cycle Prediction',
                          value: cycleLengthLabel,
                          subtitle: cycleSubtitle,
                          emoji: '📊',
                          gradient: const [Color(0xFFE91E63), Color(0xFFFF4081)],
                          tips: [
                            'Your cycle is ${cycle.cycleStatus == "Normal" ? "within the normal range (21–35 days)" : "irregular — consult a doctor"}',
                            if (insights.cyclePhase != null)
                              'Model phase estimate: ${insights.cyclePhase}',
                            'Track symptoms daily for better accuracy',
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Phase info
                        _PhaseInsightBanner(cycle: cycle),
                        const SizedBox(height: AppSpacing.md),
                        _buildInsightCard(
                          index: 1,
                          title: 'Water Intake',
                          value: waterLabel,
                          subtitle: insights.waterIntake != null
                              ? 'Personalized from your profile'
                              : 'Recommended during your current phase',
                          emoji: '💧',
                          gradient: const [Color(0xFF2196F3), Color(0xFF42A5F5)],
                          tips: waterTips,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInsightCard(
                          index: 2,
                          title: 'Food Recommendations',
                          value: foodValue,
                          subtitle: insights.foodRecommendations.isNotEmpty
                              ? 'AI-generated nutrition suggestions'
                              : 'Priority nutrients for your phase',
                          emoji: '🥗',
                          gradient: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          tips: foodTips,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInsightCard(
                          index: 3,
                          title: 'Sleep & Recovery',
                          value: 'Sleep 7–9h',
                          subtitle: 'Personalized wellness for your phase',
                          emoji: '✨',
                          gradient: const [Color(0xFF9C27B0), Color(0xFFAB47BC)],
                          tips: wellnessTips,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildInsightCard(
                          index: 4,
                          title: 'Pregnancy Chance',
                          value: pregnancyLabel,
                          subtitle: insights.pregnancyProbability != null
                              ? 'Model-assisted probability estimate'
                              : 'Based on your current cycle day',
                          emoji: '🤰',
                          gradient: const [Color(0xFFFF6F00), Color(0xFFFFB300)],
                          tips: pregnancyTips,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _DisclaimerCard(),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required int index,
    required String title,
    required String value,
    required String subtitle,
    required String emoji,
    required List<Color> gradient,
    required List<String> tips,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, (1 - val) * 18),
            child: child,
          ),
        );
      },
      child: _InsightCard(
        title: title,
        value: value,
        subtitle: subtitle,
        emoji: emoji,
        gradient: gradient,
        tips: tips,
      ),
    );
  }

  String _getFoodValue(int day) {
    if (day <= 5) return 'Iron-Rich';
    if (day <= 13) return 'Antioxidants';
    if (day <= 16) return 'Light & Clean';
    return 'Magnesium';
  }

  List<String> _getFoodTips(int day) {
    if (day <= 5) {
      return [
        'Lean meats, lentils, and spinach for iron',
        'Vitamin C helps iron absorption',
        'Avoid processed foods and excess sugar',
      ];
    } else if (day <= 13) {
      return [
        'Berries, leafy greens, and eggs for antioxidants',
        'Increase protein for muscle recovery',
        'Fermented foods support gut health',
      ];
    } else if (day <= 16) {
      return [
        'Light salads, smoothies, and lean proteins',
        'Healthy fats: avocado, nuts, olive oil',
        'Stay hydrated — energy peaks now',
      ];
    } else {
      return [
        'Dark chocolate, bananas, and avocado for magnesium',
        'Complex carbs help regulate mood',
        'Limit sodium to reduce bloating',
      ];
    }
  }

  String _getPregnancyChance(int day) {
    if (day >= 12 && day <= 16) return 'HIGH ✨';
    if ((day >= 10 && day < 12) || (day > 16 && day <= 18)) return 'Moderate';
    return 'Low';
  }

  List<String> _getPregnancyTips(int day) {
    if (day >= 12 && day <= 16) {
      return [
        'You are in your fertile window — highest chance of conception!',
        'Ovulation typically occurs around Day 14 of a 28-day cycle',
        'Track basal body temperature for accurate ovulation detection',
      ];
    } else if ((day >= 10 && day < 12) || (day > 16 && day <= 18)) {
      return [
        'Approaching or just past peak fertility',
        'Sperm can survive 3–5 days inside the female body',
        'Use an ovulation predictor kit for better accuracy',
      ];
    } else {
      return [
        'Low chance of conception during this phase',
        'Focus on cycle health and nutrition during this time',
        'Consistent tracking helps improve future accuracy',
      ];
    }
  }
}

class _PcodSupportCard extends StatelessWidget {
  const _PcodSupportCard({required this.cycle});

  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final tracked = cycle.trackedPcodSymptoms;
    final value = tracked.isEmpty
        ? (cycle.predictedCycleLength > 35 ? 'Long cycle watch' : 'Prevention tips')
        : '${tracked.length} signs logged';

    final subtitle = tracked.isEmpty
        ? 'Track changes early to spot PCOD-related patterns'
        : 'Based on symptoms you tracked in the Cycle tab';

    return _InsightCard(
      title: 'PCOD Support',
      value: value,
      subtitle: subtitle,
      emoji: '🩺',
      gradient: const [Color(0xFFEF6C00), Color(0xFFFFA726)],
      tips: cycle.pcodSupportTips,
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _InsightsHeader extends StatelessWidget {
  const _InsightsHeader({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B1FA2), Color(0xFFE91E63)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_rounded, color: Colors.white, size: 26),
              SizedBox(width: 10),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Personalized health insights powered by AI — based on your cycle data.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                label: 'Day ${cycle.currentDayInCycle}',
                icon: Icons.calendar_today_rounded,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: cycle.cycleStatus,
                icon: Icons.show_chart_rounded,
              ),
              const SizedBox(width: 8),
              _StatChip(
                label: '${cycle.predictedCycleLength}d cycle',
                icon: Icons.loop_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRecommendationCta extends StatelessWidget {
  const _ProductRecommendationCta({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5D4037), Color(0xFF8D6E63)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4037).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Get personalized product picks with direct external buy links.',
                  style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5D4037),
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

// ── Fertility Insight Card ────────────────────────────────────────────────────

class _FertilityInsightCard extends StatelessWidget {
  const _FertilityInsightCard({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final day = cycle.currentDayInCycle;
    final cycleLen = cycle.predictedCycleLength;

    // Ovulation at ~day 14 of a 28-day cycle; adjust proportionally
    final ovulationDay = (cycleLen * 14 / 28).round();
    final fertileStart = ovulationDay - 4;
    final fertileEnd = ovulationDay + 1;

    final bool isInFertileWindow = day >= fertileStart && day <= fertileEnd;
    final bool isOvulationDay = day == ovulationDay;

    final Color cardColor = isOvulationDay
        ? const Color(0xFF9C27B0)
        : isInFertileWindow
            ? const Color(0xFFE91E63)
            : const Color(0xFF1565C0);

    final String fertileStatus = isOvulationDay
        ? '🌟 Ovulation Day!'
        : isInFertileWindow
            ? '🌸 Fertile Window'
            : '💙 Low Fertility';

    final String description = isOvulationDay
        ? 'Today is your peak ovulation day. Highest chance of conception!'
        : isInFertileWindow
            ? 'You are in your fertile window. Days $fertileStart–$fertileEnd of your cycle.'
            : 'You are outside the fertile window. Next ovulation around Day $ovulationDay.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.15),
            blurRadius: 24,
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
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🌺', style: TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fertility Insights',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      fertileStatus,
                      style: TextStyle(
                        color: cardColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Day $day',
                  style: TextStyle(
                    color: cardColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fertility calendar strip
          _FertilityStrip(
            currentDay: day,
            ovulationDay: ovulationDay,
            fertileStart: fertileStart,
            fertileEnd: fertileEnd,
            cycleLen: cycleLen,
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: cardColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: cardColor.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Fertility facts
          Row(
            children: [
              _FertilityChip(
                label: 'Ovulation: Day $ovulationDay',
                color: const Color(0xFF9C27B0),
              ),
              const SizedBox(width: 8),
              _FertilityChip(
                label: 'Window: Day $fertileStart–$fertileEnd',
                color: const Color(0xFFE91E63),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FertilityStrip extends StatelessWidget {
  const _FertilityStrip({
    required this.currentDay,
    required this.ovulationDay,
    required this.fertileStart,
    required this.fertileEnd,
    required this.cycleLen,
  });

  final int currentDay;
  final int ovulationDay;
  final int fertileStart;
  final int fertileEnd;
  final int cycleLen;

  @override
  Widget build(BuildContext context) {
    // Show a window of 7 days centered on ovulation
    final displayStart = (ovulationDay - 6).clamp(1, cycleLen);
    final displayEnd = (ovulationDay + 3).clamp(1, cycleLen);
    final days = List.generate(displayEnd - displayStart + 1, (i) => displayStart + i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fertile Window (Day $fertileStart – $fertileEnd)',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: days.map((day) {
            final isCurrent = day == currentDay;
            final isOvulation = day == ovulationDay;
            final isFertile = day >= fertileStart && day <= fertileEnd;

            Color bg;
            Color textColor;
            if (isOvulation) {
              bg = const Color(0xFF9C27B0);
              textColor = Colors.white;
            } else if (isFertile) {
              bg = AppColors.primary.withValues(alpha: 0.8);
              textColor = Colors.white;
            } else {
              bg = AppColors.background;
              textColor = AppColors.textMuted;
            }

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 36,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                  border: isCurrent
                      ? Border.all(color: Colors.amber, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),
        const Row(
          children: [
            _Legend(color: Color(0xFF9C27B0), label: 'Ovulation'),
            SizedBox(width: 12),
            _Legend(color: AppColors.primary, label: 'Fertile'),
            SizedBox(width: 12),
            _Legend(color: Colors.amber, label: 'Today'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
      ],
    );
  }
}

class _FertilityChip extends StatelessWidget {
  const _FertilityChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Phase Banner ─────────────────────────────────────────────────────────────

class _PhaseInsightBanner extends StatelessWidget {
  const _PhaseInsightBanner({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final day = cycle.currentDayInCycle;
    String phase, emoji;
    Color color;

    if (day <= 5) {
      phase = 'Menstrual Phase';
      emoji = '🩸';
      color = AppColors.menstrualPhase;
    } else if (day <= 13) {
      phase = 'Follicular Phase';
      emoji = '🌱';
      color = AppColors.follicularPhase;
    } else if (day <= 16) {
      phase = 'Ovulation Phase';
      emoji = '✨';
      color = AppColors.ovulationPhase;
    } else {
      phase = 'Luteal Phase';
      emoji = '🌙';
      color = AppColors.lutealPhase;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Currently in $phase • AI optimizing recommendations for you',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insight Card ─────────────────────────────────────────────────────────────

class _InsightCard extends StatefulWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.tips,
  });

  final String title;
  final String value;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final List<String> tips;

  @override
  State<_InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<_InsightCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.value,
                          style: TextStyle(
                            color: widget.gradient.first,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.gradient.first,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      color: widget.gradient.first.withValues(alpha: 0.15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...widget.tips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: widget.gradient.first,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatefulWidget {
  const _LoadingSkeleton();

  @override
  State<_LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<_LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shimmer = Color.lerp(
          Colors.grey.shade200,
          Colors.grey.shade300,
          _anim.value,
        )!;
        return Container(
          height: 88,
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        );
      },
    );
  }
}

// ── Disclaimer ────────────────────────────────────────────────────────────────

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️', style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This app provides general health insights and is not a substitute for professional medical advice. Always consult your healthcare provider.',
              style: TextStyle(
                color: Color(0xFF5C4A00),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
