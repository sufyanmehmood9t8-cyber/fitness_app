import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/app_providers.dart';
import '../../data/services/notification_service.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/flow_background.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  NotificationPermissionStatus? _permissionStatus;
  bool _checkingPermission = true;
  bool _resetting = false;
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPermissionStatus();
      _loadVersion();
    });
  }

  Future<void> _loadPermissionStatus({bool request = false}) async {
    if (mounted) setState(() => _checkingPermission = true);
    final service = ref.read(notificationServiceProvider);
    try {
      final status = request
          ? await service.requestPermissions()
          : await service.checkPermissions();
      if (!mounted) return;
      setState(() {
        _permissionStatus = status;
        _checkingPermission = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingPermission = false);
    }
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = info.buildNumber.isEmpty
            ? info.version
            : '${info.version}+${info.buildNumber}';
      });
    } catch (_) {}
  }

  Future<void> _toggleNotifications(bool enabled) async {
    final settings = ref.read(settingsProvider.notifier);
    final service = ref.read(notificationServiceProvider);
    if (!enabled) {
      await settings.setNotificationsEnabled(false);
      await service.cancelAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder notifications paused')),
      );
      return;
    }

    final status = await service.requestPermissions();
    if (!mounted) return;
    setState(() => _permissionStatus = status);
    if (!status.notificationsGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifications are blocked. Allow them in system settings.',
          ),
        ),
      );
      return;
    }
    await settings.setNotificationsEnabled(true);
    await _rescheduleReminders();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder notifications enabled')),
    );
  }

  Future<void> _toggleSmartReminders(bool enabled) async {
    await ref.read(settingsProvider.notifier).setSmartReminders(enabled);
    if (ref.read(settingsProvider).notificationsEnabled) {
      await _rescheduleReminders();
    }
  }

  Future<void> _rescheduleReminders() async {
    final service = ref.read(notificationServiceProvider);
    final reminders = ref.read(remindersProvider);
    final smart = ref.read(settingsProvider).smartReminders;
    final workedOut = ref.read(todayWorkoutProvider);
    for (final reminder in reminders) {
      if (!reminder.enabled) continue;
      await service.scheduleReminder(
        reminder,
        skipToday: smart && reminder.smart && workedOut,
      );
    }
  }

  Future<void> _reviewPermission() async {
    await _loadPermissionStatus(request: true);
    if (!mounted) return;
    final status = _permissionStatus;
    if (status?.notificationsGranted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications are allowed')),
      );
    }
  }

  Future<void> _shareApp() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text:
              'I am building a gentle daily stretching habit with Flow. '
              'Small flows, better days.',
          subject: 'Flow - daily stretching',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sharing is unavailable right now.')),
      );
    }
  }

  Future<void> _rateApp() async {
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
      } else {
        await review.openStoreListing();
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The store is not available on this device.'),
        ),
      );
    }
  }

  void _showPrivacy() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.68,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Privacy Policy', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        'Flow keeps your workout progress, reminders and '
                        'preferences on this device. We do not create an '
                        'account, sell personal data, or send your activity '
                        'to an advertising network.\n\n'
                        'Reminders are scheduled locally by your operating '
                        'system. You can turn them off at any time from '
                        'Settings or your device settings.\n\n'
                        'Choosing a stretch stores that choice on this '
                        'device. Resetting progress removes your workout '
                        'history and saved reminders from the app.\n\n'
                        'If you contact support, only the information you '
                        'choose to share is used to respond to your note.',
                        style: AppTextStyles.body.copyWith(height: 1.65),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This clears workout stats, program progress, and saved '
            'reminders. This cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.urgent,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _resetting = true);
    try {
      await ref.read(notificationServiceProvider).cancelAll();
      await ref.read(storageProvider).clearAll();
      ref.invalidate(progressProvider);
      ref.invalidate(remindersProvider);
      ref.invalidate(settingsProvider);
      await _loadPermissionStatus();
      if (!mounted) return;
      setState(() => _resetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your progress has been reset')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _resetting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not reset progress.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final status = _permissionStatus;
    final permissionLabel = _checkingPermission
        ? 'Checking...'
        : status == null
            ? 'Unavailable on this device'
            : status.notificationsGranted
                ? status.exactAlarmsGranted
                    ? 'Allowed'
                    : 'Allowed • exact alarms off'
                : 'Not allowed';
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final navHeight = screenWidth < 360 ? 56.0 : 64.0;
    final bottomPadding = navHeight + 12.0 + mediaQuery.viewPadding.bottom + 16.0;

    return FlowBackground(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const AppTopBar(title: 'Settings', showBack: false),
            const SizedBox(height: AppSpacing.xs),
            _SectionLabel(label: 'Preferences'),
            _SettingsGroup(
              children: <Widget>[
                _SwitchRow(
                  icon: LucideIcons.bell,
                  title: 'Reminder notifications',
                  subtitle: 'Gentle nudges for your saved flows.',
                  value: settings.notificationsEnabled,
                  onChanged: _toggleNotifications,
                ),
                const Divider(),
                _SwitchRow(
                  icon: LucideIcons.sparkles,
                  title: 'Smart reminders',
                  subtitle: 'Skip today if you have already worked out.',
                  value: settings.smartReminders,
                  onChanged: _toggleSmartReminders,
                ),
                const Divider(),
                _ActionRow(
                  icon: LucideIcons.shieldCheck,
                  title: 'Notification permission',
                  subtitle: permissionLabel,
                  titleColor: status?.notificationsGranted == true
                      ? AppColors.success
                      : null,
                  trailing: TextButton(
                    onPressed:
                        _checkingPermission ? null : _reviewPermission,
                    child: const Text('Review'),
                  ),
                ),
              ],
            ),
            _SectionLabel(label: 'Support'),
            _SettingsGroup(
              children: <Widget>[
                _ActionRow(
                  icon: LucideIcons.helpCircle,
                  title: 'Help & FAQ',
                  subtitle: 'Answers about reminders and flows.',
                  onTap: () => context.push('/help'),
                ),
                const Divider(),
                _ActionRow(
                  icon: LucideIcons.lock,
                  title: 'Privacy Policy',
                  subtitle: 'How your data stays on this device.',
                  onTap: _showPrivacy,
                ),
                const Divider(),
                _ActionRow(
                  icon: LucideIcons.star,
                  title: 'Rate Flow',
                  subtitle: 'A small review helps a lot.',
                  onTap: _rateApp,
                ),
                const Divider(),
                _ActionRow(
                  icon: LucideIcons.share2,
                  title: 'Share Flow',
                  subtitle: 'Pass a gentle habit along.',
                  onTap: _shareApp,
                ),
              ],
            ),
            _SectionLabel(label: 'About'),
            _SettingsGroup(
              children: <Widget>[
                _ActionRow(
                  icon: LucideIcons.info,
                  title: 'App version',
                  subtitle: _version,
                ),
                const Divider(),
                _ActionRow(
                  icon: LucideIcons.rotateCcw,
                  title: 'Reset progress',
                  subtitle: 'Clear workout history and reminders.',
                  titleColor: AppColors.urgent,
                  trailing: _resetting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                  onTap: _resetting ? null : _resetProgress,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    'Flow',
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Move gently. Come back tomorrow.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.xs,
        left: AppSpacing.xxs,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 0.9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            _RowIcon(icon: icon),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: AppTextStyles.bodyStrong),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Switch.adaptive(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            _RowIcon(icon: icon),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.bodyStrong.copyWith(
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _RowIcon extends StatelessWidget {
  const _RowIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppColors.primaryFaint,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.primary),
    );
  }
}
