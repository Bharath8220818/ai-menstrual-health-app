import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:femi_friendly/core/constants/app_colors.dart';
import 'package:femi_friendly/core/constants/app_spacing.dart';
import 'package:femi_friendly/core/constants/app_strings.dart';
import 'package:femi_friendly/providers/auth_provider.dart';
import 'package:femi_friendly/providers/pregnancy_provider.dart';
import 'package:femi_friendly/routes/routes.dart';
import 'package:femi_friendly/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _ProfileHeader(auth: auth),
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
                // Health stats row
                _HealthStats(auth: auth),
                const SizedBox(height: AppSpacing.md),
                // Cycle settings card
                _CycleSettingsCard(auth: auth),
                const SizedBox(height: AppSpacing.md),
                // App Settings
                _AppSettingsCard(auth: auth),
                const SizedBox(height: AppSpacing.md),
                // Disclaimer
                Container(
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
                        size: 18,
                      ),
                      SizedBox(width: 8),
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
                ),
                const SizedBox(height: AppSpacing.md),
                CustomButton(
                  label: 'Sign Out',
                  icon: Icons.logout_rounded,
                  onPressed: () => _showSignOutDialog(context),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Header ──────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: 36,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFAD1457), Color(0xFFE91E63), Color(0xFFFF80AB)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: auth.avatarPath != null
                      ? Image.file(
                          File(auth.avatarPath!),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        )
                      : const Center(child: Text('👩', style: TextStyle(fontSize: 40))),
                ),
              ),
              GestureDetector(
                onTap: () => _showEditProfileDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            auth.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.email,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
            ),
          ),
          if (auth.age != null) ...[
            const SizedBox(height: 4),
            Text(
              '${auth.age} years old',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '🌸 Femi-Friendly Member',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nameCtrl = TextEditingController(text: auth.name);
    final weightCtrl = TextEditingController(text: auth.weight.toString());
    final heightCtrl = TextEditingController(text: auth.height.toString());
    DateTime? selectedDate = auth.birthday;
    String? pickedAvatar = auth.avatarPath;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                      ),
                        child: ClipOval(
                        child: pickedAvatar != null
                            ? Image.file(File(pickedAvatar!), width: 72, height: 72, fit: BoxFit.cover)
                            : const Center(child: Text('👩', style: TextStyle(fontSize: 28))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              showModalBottomSheet<void>(
                                context: ctx,
                                builder: (sheetCtx) => SafeArea(
                                  child: Wrap(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Take Photo'),
                                        onTap: () async {
                                          final picker = ImagePicker();
                                          final XFile? file = await picker.pickImage(
                                            source: ImageSource.camera,
                                            maxWidth: 1200,
                                            maxHeight: 1200,
                                            imageQuality: 85,
                                          );
                                          if (file != null) {
                                            final p = file.path.toLowerCase();
                                            if (p.endsWith('.png') || p.endsWith('.jpg') || p.endsWith('.jpeg')) {
                                              setState(() => pickedAvatar = file.path);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Please select a PNG or JPG image.')),
                                              );
                                            }
                                          }
                                          Navigator.pop(sheetCtx);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_library_outlined),
                                        title: const Text('Choose From Gallery'),
                                        onTap: () async {
                                          final picker = ImagePicker();
                                          final XFile? file = await picker.pickImage(
                                            source: ImageSource.gallery,
                                            maxWidth: 1200,
                                            maxHeight: 1200,
                                            imageQuality: 85,
                                          );
                                          if (file != null) {
                                            final p = file.path.toLowerCase();
                                            if (p.endsWith('.png') || p.endsWith('.jpg') || p.endsWith('.jpeg')) {
                                              setState(() => pickedAvatar = file.path);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Please select a PNG or JPG image.')),
                                              );
                                            }
                                          }
                                          Navigator.pop(sheetCtx);
                                        },
                                      ),
                                                  if (pickedAvatar != null)
                                                    ListTile(
                                                      leading: const Icon(Icons.delete_outline),
                                                      title: const Text('Remove Photo'),
                                                      onTap: () {
                                                        setState(() => pickedAvatar = null);
                                                        Navigator.pop(sheetCtx);
                                                      },
                                                    ),
                                                  ListTile(
                                                    leading: const Icon(Icons.close),
                                                    title: const Text('Cancel'),
                                                    onTap: () => Navigator.pop(sheetCtx),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.photo_library_outlined),
                                        label: const Text('Change Photo'),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                      ),
                          if (pickedAvatar != null)
                            TextButton(
                              onPressed: () => setState(() => pickedAvatar = null),
                              child: const Text('Remove Photo'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightCtrl,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: Icon(Icons.monitor_weight_rounded, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: heightCtrl,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          prefixIcon: Icon(Icons.height, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.cake, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedDate != null ? DateFormat.yMMMd().format(selectedDate!) : 'Birthday not set',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate ?? DateTime(now.year - 25),
                          firstDate: DateTime(1900),
                          lastDate: now,
                        );
                        if (picked != null) setState(() => selectedDate = picked);
                      },
                      child: const Text('Choose'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsedWeight = double.tryParse(weightCtrl.text) ?? auth.weight;
                final parsedHeight = double.tryParse(heightCtrl.text) ?? auth.height;
                // If user cleared the photo, pickedAvatar will be null — pass empty string
                // to indicate explicit removal. Otherwise pass the selected path.
                final avatarParam = pickedAvatar ?? '';
                context.read<AuthProvider>().updateProfile(
                      name: nameCtrl.text.trim(),
                      weight: parsedWeight,
                      height: parsedHeight,
                      birthday: selectedDate,
                      avatarPath: avatarParam,
                    );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save'),
            ),
          ],
        );
      }),
    );
  }
}

// ─── Health Stats ────────────────────────────────────────────────────────────
class _HealthStats extends StatelessWidget {
  const _HealthStats({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            emoji: '⚖️',
            value: '${auth.weight.round()}kg',
            label: 'Weight',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatBox(
            emoji: '📏',
            value: '${auth.height.round()}cm',
            label: 'Height',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatBox(
            emoji: '🏥',
            value: auth.bmi.toStringAsFixed(1),
            label: auth.bmiCategory,
            valueColor: _bmiColor(auth.bmi),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatBox(
            emoji: '📅',
            value: '${auth.cycleLength}d',
            label: 'Cycle',
          ),
        ),
      ],
    );
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return Colors.red;
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.emoji,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String emoji;
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// ─── Cycle Settings Card ─────────────────────────────────────────────────────
class _CycleSettingsCard extends StatelessWidget {
  const _CycleSettingsCard({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Text(
              'Cycle Settings',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark),
            ),
          ),
          _SettingsTile(
            icon: Icons.calendar_month_rounded,
            label: 'Cycle Length',
            value: '${auth.cycleLength} days',
            onTap: () {},
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.water_drop_rounded,
            label: 'Period Length',
            value: '${auth.periodLength} days',
            onTap: () {},
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.edit_calendar_rounded,
            label: 'Update Cycle Info',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profileSetup),
          ),
        ],
      ),
    );
  }
}

// ─── App Settings Card ────────────────────────────────────────────────────────
class _AppSettingsCard extends StatelessWidget {
  const _AppSettingsCard({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: Text(
              'App Settings',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
          ),
          // Pregnancy Mode toggle
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE0EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('\u{1F930}', style: TextStyle(fontSize: 18)),
            ),
            title: const Text(
              'Pregnancy Mode',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: const Text(
              'Track baby growth & trimester tips',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            trailing: Consumer<PregnancyProvider>(
              builder: (context, preg, _) => Switch(
                value: preg.pregnancyMode,
                onChanged: (_) => preg.togglePregnancyMode(),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.accent,
              ),
            ),
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          // Notifications toggle
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: const Text(
              'Period reminders & tips',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            trailing: Switch(
              value: auth.notificationsEnabled,
              onChanged: (v) => context
                  .read<AuthProvider>()
                  .updateProfile(notificationsEnabled: v),
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.accent,
            ),
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.notifications_active_rounded,
            label: 'View Notifications',
            onTap: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.water_drop_outlined,
            label: 'Water Tracker',
            onTap: () => Navigator.pushNamed(context, AppRoutes.waterTracker),
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Privacy & Security',
            onTap: () {},
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () {},
          ),
          Divider(height: 0, indent: 56, color: AppColors.accent.withValues(alpha: 0.2)),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'About Femi-Friendly',
            value: 'v1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Femi-Friendly',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFFFF4081)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(Icons.favorite_rounded, color: Colors.white, size: 28),
        ),
      ),
      children: const [
        Text(
          'An AI-powered menstrual health companion designed to help you understand and track your cycle.',
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark),
      ),
      trailing: value != null
          ? Text(
              value!,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            )
          : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
