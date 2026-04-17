import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/screens/chat/chatbot_screen.dart';
import 'package:femi_friendly/screens/cycle/cycle_tracker_screen.dart';
import 'package:femi_friendly/screens/dashboard/dashboard_screen.dart';
import 'package:femi_friendly/screens/insights/ai_insights_screen.dart';
import 'package:femi_friendly/screens/pcod/hormonal_conditions_screen.dart';
import 'package:femi_friendly/screens/pregnancy/pregnancy_screen.dart';
import 'package:femi_friendly/screens/profile/profile_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late int _currentIndex;
  late final AnimationController _fabController;

  final GlobalKey<CycleTrackerScreenState> _cycleScreenKey =
      GlobalKey<CycleTrackerScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _jumpToTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _handleAddCycle() {
    HapticFeedback.lightImpact();
    if (_currentIndex != 1) {
      _jumpToTab(1);
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        _cycleScreenKey.currentState?.openAddCycleSheet();
      });
      return;
    }
    _cycleScreenKey.currentState?.openAddCycleSheet();
  }

  // 6 tabs: Home | Cycle | Pregnancy | PCOD | AI | Profile
  static const _tabs =
      <({IconData icon, IconData activeIcon, String label, String emoji})>[
        (
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Home',
          emoji: 'HM',
        ),
        (
          icon: Icons.calendar_month_outlined,
          activeIcon: Icons.calendar_month_rounded,
          label: 'Cycle',
          emoji: 'CY',
        ),
        (
          icon: Icons.favorite_border_rounded,
          activeIcon: Icons.favorite_rounded,
          label: 'Pregnancy',
          emoji: 'PG',
        ),
        (
          icon: Icons.monitor_heart_outlined,
          activeIcon: Icons.monitor_heart_rounded,
          label: 'HHDT',
          emoji: 'PC',
        ),
        (
          icon: Icons.psychology_outlined,
          activeIcon: Icons.psychology_rounded,
          label: 'AI',
          emoji: 'AI',
        ),
        (
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profile',
          emoji: 'PR',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          DashboardScreen(onQuickActionTap: _jumpToTab),
          CycleTrackerScreen(key: _cycleScreenKey),
          const PregnancyScreen(),
          const HormonalConditionsScreen(),
          const AIInsightsAndChatScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? ScaleTransition(
              scale: CurvedAnimation(
                parent: _fabController,
                curve: Curves.easeOutBack,
              ),
              child: FloatingActionButton.extended(
                key: const ValueKey<String>('addCycleFab'),
                onPressed: _handleAddCycle,
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add Cycle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _jumpToTab,
        tabs: _tabs,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<({IconData icon, IconData activeIcon, String label, String emoji})>
      tabs;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.asMap().entries.map((entry) {
              final i = entry.key;
              final tab = entry.value;
              final isActive = currentIndex == i;
              return _NavItem(
                icon: isActive ? tab.activeIcon : tab.icon,
                label: tab.label,
                emoji: tab.emoji,
                isActive: isActive,
                onTap: () => onTap(i),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.reverse();

  void _onTapUp(TapUpDetails _) {
    _ctrl.forward();
    widget.onTap();
  }

  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  key: ValueKey<bool>(widget.isActive),
                  color: widget.isActive
                      ? AppColors.primary
                      : AppColors.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isActive
                      ? AppColors.primary
                      : AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AIInsightsAndChatScreen extends StatefulWidget {
  const AIInsightsAndChatScreen({super.key});

  @override
  State<AIInsightsAndChatScreen> createState() =>
      _AIInsightsAndChatScreenState();
}

class _AIInsightsAndChatScreenState extends State<AIInsightsAndChatScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: AppColors.background,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.xs,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondaryPink],
                  ),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.psychology_rounded, size: 18),
                    text: 'AI Insights',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                  Tab(
                    icon: Icon(Icons.chat_bubble_rounded, size: 18),
                    text: 'AI Chat',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AIInsightsScreen(),
                ChatbotScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

