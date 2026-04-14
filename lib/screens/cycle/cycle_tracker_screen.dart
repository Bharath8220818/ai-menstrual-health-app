import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/core/utils/date_format_helper.dart';
import 'package:femi_friendly/models/cycle_entry.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';
import 'package:femi_friendly/widgets/custom_button.dart';

class CycleTrackerScreen extends StatefulWidget {
  const CycleTrackerScreen({super.key});

  @override
  State<CycleTrackerScreen> createState() => CycleTrackerScreenState();
}

class CycleTrackerScreenState extends State<CycleTrackerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  final List<String> _symptoms = const [
    'Mild cramps',
    'Severe cramps',
    'Headache',
    'Fatigue',
    'Mood swings',
    'Back pain',
    'Bloating',
    'Nausea',
    'Spotting',
  ];

  final List<String> _flowLevels = const [
    'Light',
    'Medium',
    'Heavy',
    'Spotting',
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  /// Called from [HomeShellScreen] tab switch to open the add sheet.
  void openAddCycleSheet() => _openAddCycleSheet();

  Future<void> _openAddCycleSheet() async {
    DateTime? startDate;
    DateTime? endDate;
    String symptom = _symptoms.first;
    String flowLevel = _flowLevels[1];

    final startController = TextEditingController();
    final endController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> pickDate(bool isStart) async {
                final base = isStart
                    ? DateTime.now()
                    : (startDate ?? DateTime.now());
                final picked = await showDatePicker(
                  context: context,
                  initialDate: base,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked == null) return;
                setModalState(() {
                  if (isStart) {
                    startDate = picked;
                    startController.text = formatDate(picked);
                  } else {
                    endDate = picked;
                    endController.text = formatDate(picked);
                  }
                });
              }

              return Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  top: AppSpacing.lg,
                  bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accentLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_circle_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add Cycle Entry',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      // Date fields row
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              controller: startController,
                              label: 'Start Date',
                              onTap: () => pickDate(true),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _DateField(
                              controller: endController,
                              label: 'End Date',
                              onTap: () => pickDate(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Symptoms
                      Text(
                        'Symptoms',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _symptoms
                            .map(
                              (s) => FilterChip(
                                label: Text(s),
                                selected: symptom == s,
                                onSelected: (_) =>
                                    setModalState(() => symptom = s),
                                selectedColor: AppColors.accent,
                                checkmarkColor: AppColors.primary,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Flow level
                      Text(
                        'Flow Level',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: _flowLevels
                            .map(
                              (f) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: f == _flowLevels.last
                                        ? 0
                                        : AppSpacing.xs,
                                  ),
                                  child: GestureDetector(
                                    onTap: () =>
                                        setModalState(() => flowLevel = f),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: flowLevel == f
                                            ? AppColors.primary
                                            : AppColors.accentLight,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.chipRadius,
                                        ),
                                      ),
                                      child: Text(
                                        f,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: flowLevel == f
                                              ? Colors.white
                                              : AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CustomButton(
                        label: 'Save Cycle Entry',
                        icon: Icons.check_rounded,
                        onPressed: () {
                          if (startDate == null || endDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please select start and end dates.'),
                              ),
                            );
                            return;
                          }
                          if (endDate!.isBefore(startDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('End date must be after start date.'),
                              ),
                            );
                            return;
                          }
                          this.context.read<CycleProvider>().addCycle(
                                CycleEntry(
                                  startDate: startDate!,
                                  endDate: endDate!,
                                  symptom: '$symptom ($flowLevel flow)',
                                ),
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text('Cycle entry saved!'),
                                ],
                              ),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    startController.dispose();
    endController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.background,
            title: const Text(
              'Cycle Tracker',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                onPressed: _openAddCycleSheet,
                tooltip: 'Add Cycle',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.07),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TableCalendar<CycleEntry>(
                      firstDay: DateTime(2020),
                      lastDay: DateTime(2035),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      onFormatChanged: (f) =>
                          setState(() => _calendarFormat = f),
                      selectedDayPredicate: (day) =>
                          isSameDay(cycle.selectedDate, day),
                      onDaySelected: (selected, focused) {
                        cycle.updateSelectedDate(selected);
                        setState(() => _focusedDay = focused);
                      },
                      onPageChanged: (focused) =>
                          setState(() => _focusedDay = focused),
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focused) {
                          if (cycle.isCycleDay(day)) {
                            return _CycleDayMarker(
                              day: day,
                              color: AppColors.periodColor,
                            );
                          }
                          if (_isOvulationDay(day, cycle)) {
                            return _CycleDayMarker(
                              day: day,
                              color: AppColors.ovulationColor,
                            );
                          }
                          return null;
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.secondaryPink],
                          ),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: AppColors.primary,
                        ),
                        outsideDaysVisible: false,
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius:
                              BorderRadius.all(Radius.circular(12)),
                        ),
                        formatButtonTextStyle: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.primary,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                        ),
                        titleTextStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Legend
                  _CalendarLegend(),
                  const SizedBox(height: AppSpacing.md),
                  // Cycle stats
                  _CycleStats(cycle: cycle),
                  const SizedBox(height: AppSpacing.md),
                  // History
                  const Text(
                    'Cycle History',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
          // History list
          cycle.history.isEmpty
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🌸',
                            style: TextStyle(fontSize: 52),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No cycles logged yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first cycle entry.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    100,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = cycle.history[index];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _CycleHistoryCard(entry: entry, index: index),
                        );
                      },
                      childCount: cycle.history.length,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCycleSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Cycle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  bool _isOvulationDay(DateTime day, CycleProvider cycle) {
    for (final entry in cycle.history) {
      final ovDay = entry.startDate
          .add(Duration(days: cycle.predictedCycleLength ~/ 2));
      if (isSameDay(ovDay, day)) return true;
    }
    return false;
  }
}

class _CycleDayMarker extends StatelessWidget {
  const _CycleDayMarker({required this.day, required this.color});
  final DateTime day;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppColors.periodColor, label: 'Period'),
        SizedBox(width: 20),
        _LegendDot(color: AppColors.ovulationColor, label: 'Ovulation'),
        SizedBox(width: 20),
        _LegendDot(color: AppColors.primary, label: 'Selected'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _CycleStats extends StatelessWidget {
  const _CycleStats({required this.cycle});
  final CycleProvider cycle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Cycle Length',
            value: '${cycle.predictedCycleLength}d',
            icon: Icons.loop_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Current Day',
            value: '${cycle.currentDayInCycle}',
            icon: Icons.today_rounded,
            color: AppColors.ovulationColor,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(
            label: 'Total Entries',
            value: '${cycle.history.length}',
            icon: Icons.list_alt_rounded,
            color: AppColors.follicularPhase,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
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
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleHistoryCard extends StatelessWidget {
  const _CycleHistoryCard({required this.entry, required this.index});
  final CycleEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final duration = entry.endDate.difference(entry.startDate).inDays + 1;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 15),
            child: child,
          ),
        );
      },
      child: Container(
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
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${formatDate(entry.startDate)} → ${formatDate(entry.endDate)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.symptom,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${duration}d',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.controller,
    required this.label,
    required this.onTap,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Select date',
                prefixIcon: Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
