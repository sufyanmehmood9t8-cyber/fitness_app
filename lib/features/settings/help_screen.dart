import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/flow_background.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<(String, String)> _questions = <(String, String)>[
    (
      'How do reminders work?',
      'Choose a time, one or more days, and the stretch you want to return '
          'to. Flow schedules a local notification for each selected day. '
          'Reminders are handled on your device, not by a server.',
    ),
    (
      'Why am I not receiving reminders?',
      'Check that Reminder notifications are on in Settings and that your '
          'device allows notifications for Flow. Android may also require '
          'permission for exact alarms if you want reminders at the precise '
          'time you selected.',
    ),
    (
      'What is a Smart Reminder?',
      'A Smart Reminder skips today when Flow already has a completed '
          'workout recorded for today. Your recurring schedule stays the '
          'same, so it resumes on the next selected day.',
    ),
    (
      'How is my program progress calculated?',
      'Every completed exercise adds to your program progress. Starting a '
          'program session from Home also moves the program forward when the '
          'workout completes.',
    ),
    (
      'Can I repeat a reminder or flow?',
      'Yes. Reminders repeat weekly on every day you select. Workouts can '
          'be started again at any time from Categories or Home.',
    ),
    (
      'Where is my information stored?',
      'Workout progress, reminders and preferences are stored locally on '
          'this device. There is no Flow account and no cloud sync.',
    ),
    (
      'How do I reset my history?',
      'Open Settings, choose Reset progress, and confirm. This removes '
          'workout stats, program progress, and saved reminders from this '
          'device.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBottom,
      body: FlowBackground(
        child: Column(
          children: <Widget>[
            const AppTopBar(title: 'Help & FAQ'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.coralSoft,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                      border: Border.all(color: AppColors.coralBorder),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: AppColors.peachCircle,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.lifeBuoy,
                            color: AppColors.coral,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'A gentle practice, not a race.',
                                style: AppTextStyles.bodyStrong,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Move within comfort and skip anything that '
                                'does not feel right.',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Common questions', style: AppTextStyles.section),
                  const SizedBox(height: AppSpacing.xs),
                  ..._questions.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(color: AppColors.divider),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          shape: const Border(),
                          collapsedShape: const Border(),
                          iconColor: AppColors.primary,
                          collapsedIconColor: AppColors.textMuted,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 2,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          title: Text(
                            item.$1,
                            style: AppTextStyles.bodyStrong,
                          ),
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.$2,
                                style: AppTextStyles.body.copyWith(
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
