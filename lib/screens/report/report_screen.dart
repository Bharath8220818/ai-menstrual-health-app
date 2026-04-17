import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/core/constants/app_strings.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final isAlert = cycle.irregularityAlert;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ReportHeader(cycle: cycle),
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
                // Alert card
                _AlertCard(isAlert: isAlert),
                const SizedBox(height: AppSpacing.md),
                // Cycle trend graph
                _CycleTrendCard(cycle: cycle),
                const SizedBox(height: AppSpacing.md),
                // Mood tracking
                _MoodTrackingCard(),
                const SizedBox(height: AppSpacing.md),
                // Cycle summary
                _CycleSummaryCard(cycle: cycle),
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

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({required this.cycle});
  final CycleProvider cycle;

  Future<void> _exportPdf(BuildContext context) async {
    final doc = pw.Document();
    final date = DateTime.now();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Femi-Friendly Health Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('Generated: ${date.day}/${date.month}/${date.year}',
                  style: const pw.TextStyle(fontSize: 12)),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text('Cycle Summary',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _pdfRow('Average Cycle Length', '${cycle.predictedCycleLength} days'),
              _pdfRow('Current Day in Cycle', 'Day ${cycle.currentDayInCycle}'),
              _pdfRow('Total Cycles Tracked', '${cycle.history.length}'),
              _pdfRow('Cycle Status', cycle.cycleStatus),
              _pdfRow('Irregularity Alert', cycle.irregularityAlert ? 'Yes' : 'No'),
              pw.SizedBox(height: 16),
              pw.Text('Disclaimer',
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 6),
              pw.Text(
                AppStrings.disclaimer,
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          );
        },
      ),
    );
    await Printing.sharePdf(
      bytes: await doc.save(),
      filename: 'femi_friendly_report_${date.year}${date.month}${date.day}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

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
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3F51B5)],
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
            children: [
              const Icon(Icons.query_stats_rounded, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              const Text(
                'Health Reports',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.white),
                tooltip: 'Export PDF',
                onPressed: () => _exportPdf(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Track your cycle trends, mood patterns, and health analysis.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.isAlert});
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.warningLight : AppColors.successLight,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: isAlert
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.success.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isAlert
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAlert
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_rounded,
              color: isAlert ? AppColors.warning : AppColors.success,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAlert ? '⚠️ Cycle Irregularity Detected' : '✅ Cycle Looks Stable',
                  style: TextStyle(
                    color: isAlert ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAlert
                      ? 'Your recent cycle shows irregular patterns. Consider consulting a healthcare provider.'
                      : 'Your cycle is within the normal range. Keep tracking for better insights.',
                  style: TextStyle(
                    color: isAlert
                        ? AppColors.warning.withValues(alpha: 0.85)
                        : AppColors.success.withValues(alpha: 0.85),
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

class _CycleTrendCard extends StatelessWidget {
  const _CycleTrendCard({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    final trend = cycle.cycleLengthTrend;
    final maxVal = trend.isEmpty ? 35.0 : trend.reduce((a, b) => a > b ? a : b).toDouble();
    final minVal = trend.isEmpty ? 21.0 : trend.reduce((a, b) => a < b ? a : b).toDouble();
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: Color(0xFF3F51B5),
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Cycle Trend',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (trend.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Add at least 2 cycles to see trend data',
                  style: TextStyle(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(trend.length, (i) {
                  final val = trend[i].toDouble();
                  final normalized = (val - minVal) / range;
                  final barHeight = 20 + normalized * 70;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${trend[i]}d',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: barHeight),
                            duration: Duration(milliseconds: 500 + i * 100),
                            curve: Curves.easeOutCubic,
                            builder: (context, h, _) {
                              return Container(
                                height: h,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFF3F51B5),
                                      Color(0xFF7986CB),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'C${i + 1}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          if (trend.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TrendStat(
                  label: 'Shortest',
                  value: '${trend.reduce((a, b) => a < b ? a : b)}d',
                  color: AppColors.success,
                ),
                _TrendStat(
                  label: 'Average',
                  value: '${cycle.predictedCycleLength}d',
                  color: const Color(0xFF3F51B5),
                ),
                _TrendStat(
                  label: 'Longest',
                  value: '${trend.reduce((a, b) => a > b ? a : b)}d',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendStat extends StatelessWidget {
  const _TrendStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MoodTrackingCard extends StatelessWidget {
  final _moods = const [
    (emoji: '😊', label: 'Happy', days: 8),
    (emoji: '😐', label: 'Neutral', days: 12),
    (emoji: '😔', label: 'Low', days: 5),
    (emoji: '😠', label: 'Irritable', days: 3),
  ];

  @override
  Widget build(BuildContext context) {
    const total = 28;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mood_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Mood Tracking',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Sample mood distribution (last 28 days)',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._moods.map(
            (mood) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 56,
                    child: Text(
                      mood.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0,
                          end: mood.days / total,
                        ),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor:
                                AppColors.accent.withValues(alpha: 0.2),
                            color: AppColors.primary,
                            minHeight: 8,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${mood.days}d',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
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

class _CycleSummaryCard extends StatelessWidget {
  const _CycleSummaryCard({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE0EC), Color(0xFFFFF1F5)],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Summary',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SummaryRow(
            label: 'Average Cycle Length',
            value: '${cycle.predictedCycleLength} days',
          ),
          _SummaryRow(
            label: 'Total Cycles Tracked',
            value: '${cycle.history.length}',
          ),
          _SummaryRow(
            label: 'Cycle Status',
            value: cycle.cycleStatus,
            valueColor: cycle.cycleStatus == 'Normal'
                ? AppColors.success
                : AppColors.warning,
          ),
          _SummaryRow(
            label: 'Current Day',
            value: 'Day ${cycle.currentDayInCycle}',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: AppColors.warning,
            size: 20,
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              AppStrings.disclaimer,
              style: TextStyle(
                color: AppColors.warning,
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

