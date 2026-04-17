import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/providers/cycle_provider.dart';

/// Water Tracker Screen
class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen>
    with TickerProviderStateMixin {
  int _cups = 0;
  final int _goal = 8;
  int _cupSizeMl = 250;

  late final AnimationController _cupAnimController;
  late final List<AnimationController> _rippleControllers;

  @override
  void initState() {
    super.initState();
    _cupAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleControllers = List.generate(
      _goal,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _cupAnimController.dispose();
    for (final c in _rippleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCup() {
    if (_cups >= _goal) return;
    HapticFeedback.lightImpact();
    final idx = _cups;
    setState(() => _cups++);
    _rippleControllers[idx].forward(from: 0);
    _cupAnimController.forward(from: 0);
  }

  void _removeCup() {
    if (_cups <= 0) return;
    HapticFeedback.selectionClick();
    setState(() => _cups--);
    _rippleControllers[_cups].reverse();
  }

  int get _totalMl => _cups * _cupSizeMl;
  double get _progress => _cups / _goal;

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final isHighDay = cycle.currentDayInCycle <= 5; // Menstrual phase → more water

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _WaterHeader(
              progress: _progress,
              totalMl: _totalMl,
              goalMl: _goal * _cupSizeMl,
              cups: _cups,
              goal: _goal,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Phase recommendation banner
                if (isHighDay) ...[
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1565C0).withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Text('💧', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'During menstrual phase, drink extra water to reduce bloating & cramps.',
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                // Cup grid
                const Text(
                  'Today\'s Intake',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _goal,
                  itemBuilder: (context, i) {
                    final filled = i < _cups;
                    return AnimatedBuilder(
                      animation: _rippleControllers[i],
                      builder: (context, child) {
                        final scale = filled
                            ? 1.0 + (_rippleControllers[i].value * 0.08)
                            : 1.0;
                        return Transform.scale(
                          scale: scale,
                          child: GestureDetector(
                            onTap: () {
                              if (!filled) {
                                _addCup();
                              } else if (i == _cups - 1) {
                                _removeCup();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                color: filled
                                    ? const Color(0xFF1565C0)
                                    : Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  if (filled)
                                    BoxShadow(
                                      color: const Color(0xFF1565C0)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                                border: Border.all(
                                  color: filled
                                      ? Colors.transparent
                                      : const Color(0xFF90CAF9),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    filled ? '💧' : '🫙',
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_cupSizeMl}ml',
                                    style: TextStyle(
                                      color: filled ? Colors.white : const Color(0xFF1565C0),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                // Cup size selector
                const Text(
                  'Cup Size',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [150, 250, 350, 500].map((ml) {
                    final selected = _cupSizeMl == ml;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _cupSizeMl = ml);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF1565C0)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF1565C0)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${ml}ml',
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF1565C0),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  _cupLabel(ml),
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : const Color(0xFF90CAF9),
                                    fontSize: 11,
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
                const SizedBox(height: AppSpacing.lg),
                // Add / Remove buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _removeCup,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF90CAF9),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove, color: Color(0xFF1565C0)),
                              SizedBox(width: 6),
                              Text(
                                'Remove Cup',
                                style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _addCup,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Add Cup',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _cupLabel(int ml) {
    if (ml <= 150) return 'Small';
    if (ml <= 250) return 'Medium';
    if (ml <= 350) return 'Large';
    return 'XL';
  }
}

class _WaterHeader extends StatelessWidget {
  const _WaterHeader({
    required this.progress,
    required this.totalMl,
    required this.goalMl,
    required this.cups,
    required this.goal,
  });

  final double progress;
  final int totalMl;
  final int goalMl;
  final int cups;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Text(
                'Water Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const Icon(
                Icons.water_drop_rounded,
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) {
                    return CircularProgressIndicator(
                      value: v,
                      strokeWidth: 14,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF69F0AE),
                      ),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💧', style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 4),
                    Text(
                      '${totalMl}ml',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'of ${goalMl}ml',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$cups of $goal cups',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            progress >= 1.0
                ? '🎉 Daily goal achieved!'
                : '${goal - cups} more cups to reach your goal',
            style: TextStyle(
              color: progress >= 1.0
                  ? const Color(0xFF69F0AE)
                  : Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

