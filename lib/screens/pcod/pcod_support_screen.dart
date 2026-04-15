import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';

class PcodSupportScreen extends StatelessWidget {
  const PcodSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final tracked = cycle.trackedPcodSymptoms;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _PcodHeader(tracked: tracked),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _OverviewCard(tracked: tracked, cycle: cycle),
                const SizedBox(height: AppSpacing.md),
                const _SectionCard(
                  title: 'Common Symptoms',
                  icon: Icons.fact_check_outlined,
                  color: Color(0xFFE65100),
                  items: [
                    'Irregular periods or long cycle gaps',
                    'Acne, oily skin, or skin darkening around neck and underarms',
                    'Weight gain, sugar cravings, or trouble sleeping',
                    'Facial hair growth or scalp hair thinning',
                    'Heavy bleeding or pelvic discomfort',
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const _TwoColumnTips(),
                const SizedBox(height: AppSpacing.md),
                const _SectionCard(
                  title: 'Other Problems To Watch',
                  icon: Icons.health_and_safety_outlined,
                  color: Color(0xFFAD1457),
                  items: [
                    'Persistent skipped periods',
                    'Very heavy bleeding or severe pelvic pain',
                    'Acne getting worse quickly',
                    'Fast weight changes or strong fatigue',
                    'New hair loss, facial hair, or dark skin patches',
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'When To See A Doctor',
                  icon: Icons.local_hospital_outlined,
                  color: const Color(0xFF1565C0),
                  items: const [
                    'Periods missing for 3 months or more',
                    'Bleeding is unusually heavy or painful',
                    'Symptoms keep increasing across multiple cycles',
                    'You are trying to conceive and cycles stay irregular',
                  ],
                  footer:
                      'This screen is for support and tracking awareness. A gynecologist can help confirm whether symptoms are related to PCOD/PCOS or another hormone issue.',
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PcodHeader extends StatelessWidget {
  const _PcodHeader({required this.tracked});

  final List<String> tracked;

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
          colors: [Color(0xFFEF6C00), Color(0xFFFFA726), Color(0xFFFFCC80)],
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
              Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                'PCOD Support',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tracked.isEmpty
                ? 'Learn what symptoms to track, what habits can help, and when it is worth getting medical support.'
                : 'You already tracked: ${tracked.take(4).join(', ')}.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.tracked,
    required this.cycle,
  });

  final List<String> tracked;
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
          const Text(
            'Your Quick Snapshot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SnapshotPill(
                  label: 'Cycle Length',
                  value: '${cycle.predictedCycleLength} days',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SnapshotPill(
                  label: 'Tracked Signs',
                  value: tracked.isEmpty ? '0 logged' : '${tracked.length} logged',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tracked.isEmpty
                ? 'Start by logging acne, cravings, weight changes, hair changes, heavy bleeding, or long/irregular cycles in the Cycle tab.'
                : 'Keep logging the same symptoms each month so patterns are easier to spot.',
            style: const TextStyle(
              color: AppColors.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotPill extends StatelessWidget {
  const _SnapshotPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoColumnTips extends StatelessWidget {
  const _TwoColumnTips();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SectionCard(
            title: 'What To Do',
            icon: Icons.check_circle_outline_rounded,
            color: Color(0xFF2E7D32),
            items: [
              'Walk, stretch, or strength train around 30 minutes most days',
              'Sleep 7-9 hours on a consistent schedule',
              'Track symptoms every cycle instead of guessing from memory',
              'Manage stress with yoga, breathing, or light movement',
            ],
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SectionCard(
            title: 'What To Eat',
            icon: Icons.restaurant_menu_rounded,
            color: Color(0xFF00897B),
            items: [
              'Protein: eggs, dal, tofu, paneer, yogurt',
              'Fiber: oats, beans, vegetables, leafy greens',
              'Healthy fats: nuts, seeds, avocado',
              'Low-GI carbs: brown rice, millets, quinoa',
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    this.footer,
  });

  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 8),
            Text(
              footer!,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
