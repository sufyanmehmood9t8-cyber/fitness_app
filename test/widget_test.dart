import 'dart:io';

import 'package:fitness_app/app.dart';
import 'package:fitness_app/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDirectory;

  setUpAll(() async {
    tempDirectory =
        await Directory.systemTemp.createTemp('flow_widget_test_');
    await StorageService.initialize(hivePath: tempDirectory.path);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  testWidgets('home to category to exercise detail to player', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: FlowApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text('Hi, Alex crew', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Today Flow'), findsOneWidget);
    expect(find.text('Add Reminder'), findsOneWidget);
    expect(find.text('Continue Program'), findsOneWidget);

    await tester.tap(find.byIcon(LucideIcons.layoutGrid));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Yoga Stretch'), findsOneWidget);

    await tester.tap(find.text('Yoga Stretch').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('How to do it'), findsOneWidget);
    expect(find.text('Start Exercise'), findsOneWidget);
    expect(
      find.text('Cat-Cow Flow'),
      findsAtLeastNWidgets(1),
    );

    await tester.tap(find.text('Start Exercise'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Exercise 1 of 3'), findsOneWidget);
    expect(
      find.text('Cat-Cow Flow'),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Up Next'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('empty saved reminders shows an empty state', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: FlowApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(LucideIcons.bell));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Saved Reminders'), findsOneWidget);
    expect(find.text('No reminders yet'), findsOneWidget);
    expect(find.text('Add Reminder'), findsAtLeastNWidgets(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
