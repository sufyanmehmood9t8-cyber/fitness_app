import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/notification_service.dart';
import 'widgets/reminder_banner_host.dart';

class FlowApp extends StatefulWidget {
  const FlowApp({super.key, this.initialExerciseId});

  final String? initialExerciseId;

  @override
  State<FlowApp> createState() => _FlowAppState();
}

class _FlowAppState extends State<FlowApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(
      initialExerciseId: widget.initialExerciseId,
    );
    NotificationService.instance.onNotificationTap = (exerciseId) {
      _router.push('/exercise/$exerciseId');
    };
  }

  @override
  void dispose() {
    NotificationService.instance.onNotificationTap = null;
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
      builder: (context, child) {
        return Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (_) => ReminderBannerHost(
                enabled: widget.initialExerciseId == null,
                onOpen: (exerciseId) {
                  _router.push('/exercise/$exerciseId');
                },
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
