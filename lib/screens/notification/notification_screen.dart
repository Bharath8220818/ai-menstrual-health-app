import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';

/// Notifications Screen
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notifications = <_NotifItem>[
    _NotifItem(
      icon: '🩸',
      title: 'Period Reminder',
      body: 'Your period is expected in 2 days. Stock up on supplies!',
      time: '2 hours ago',
      type: _NotifType.period,
      isRead: false,
    ),
    _NotifItem(
      icon: '💧',
      title: 'Water Intake Reminder',
      body: 'You\'ve only logged 3 cups today. Remember to stay hydrated!',
      time: '4 hours ago',
      type: _NotifType.water,
      isRead: false,
    ),
    _NotifItem(
      icon: '🤖',
      title: 'AI Insight Ready',
      body:
          'Your personalized weekly health report is ready. Tap to view.',
      time: '6 hours ago',
      type: _NotifType.insight,
      isRead: true,
    ),
    _NotifItem(
      icon: '✨',
      title: 'Ovulation Window',
      body: 'You are entering your ovulation window. Your energy peaks now!',
      time: 'Yesterday',
      type: _NotifType.phase,
      isRead: true,
    ),
    _NotifItem(
      icon: '😊',
      title: 'Daily Check-in',
      body: 'How are you feeling today? Log your mood and symptoms.',
      time: 'Yesterday',
      type: _NotifType.mood,
      isRead: true,
    ),
    _NotifItem(
      icon: '💊',
      title: 'Medication Reminder',
      body: 'Don\'t forget to take your contraceptive pill today.',
      time: '2 days ago',
      type: _NotifType.reminder,
      isRead: true,
    ),
    _NotifItem(
      icon: '📊',
      title: 'Monthly Report',
      body: 'Your March cycle report is ready. Your cycle was 28 days.',
      time: '3 days ago',
      type: _NotifType.report,
      isRead: true,
    ),
  ];

  void _markAllRead() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  void _dismiss(int index) {
    HapticFeedback.lightImpact();
    setState(() => _notifications.removeAt(index));
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _NotifHeader(
              unread: _unreadCount,
              onMarkAll: _markAllRead,
            ),
          ),
          if (_notifications.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final notif = _notifications[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Dismissible(
                        key: ValueKey(notif.title + notif.time),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _dismiss(index),
                        background: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(AppSpacing.radius),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration: Duration(milliseconds: 250 + (index * 60)),
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) {
                            return Opacity(
                              opacity: v,
                              child: Transform.translate(
                                offset: Offset(0, (1 - v) * 10),
                                child: child,
                              ),
                            );
                          },
                          child: _NotifCard(
                            item: notif,
                            onTap: () => setState(() => notif.isRead = true),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _notifications.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotifHeader extends StatelessWidget {
  const _NotifHeader({required this.unread, required this.onMarkAll});
  final int unread;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAD1457), Color(0xFFE91E63), Color(0xFFFF4081)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const Expanded(
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (unread > 0)
                TextButton(
                  onPressed: onMarkAll,
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          if (unread > 0) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unread unread notification${unread > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.item, required this.onTap});
  final _NotifItem item;
  final VoidCallback onTap;

  Color get _accent {
    switch (item.type) {
      case _NotifType.period:
        return AppColors.periodColor;
      case _NotifType.water:
        return const Color(0xFF1565C0);
      case _NotifType.insight:
        return const Color(0xFF7B1FA2);
      case _NotifType.phase:
        return const Color(0xFFFF9800);
      case _NotifType.mood:
        return const Color(0xFF4CAF50);
      case _NotifType.reminder:
        return AppColors.primary;
      case _NotifType.report:
        return const Color(0xFF3F51B5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: item.isRead
              ? Colors.white
              : _accent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: item.isRead
                ? Colors.transparent
                : _accent.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
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
                color: _accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(item.icon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: AppColors.textDark,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!item.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔔', style: TextStyle(fontSize: 52)),
          SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No new notifications at the moment.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

enum _NotifType { period, water, insight, phase, mood, reminder, report }

class _NotifItem {
  _NotifItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.isRead,
  });

  final String icon;
  final String title;
  final String body;
  final String time;
  final _NotifType type;
  bool isRead;
}

