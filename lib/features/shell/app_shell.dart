import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  int get _activeIndex {
    if (location.startsWith('/category')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _select(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/category');
      case 2:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: child,
      bottomNavigationBar: BottomNav(
        activeIndex: _activeIndex,
        onSelect: (index) => _select(context, index),
      ),
    );
  }
}
