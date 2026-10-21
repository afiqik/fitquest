import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:fitquest/providers/app_state.dart';
import 'package:fitquest/core/widgets/bottom_navbar.dart';
import 'package:fitquest/features/home/main_shell.dart';

void main() {
  group('Navigation & Tab Back Navigation Tests', () {
    testWidgets('MainShell starts on Tab 0 and back navigates to Home from Schedule', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: MainShell(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Starts on Tab 0 (Home)
      expect(find.byWidgetPredicate((w) => w is Text && (w.data?.startsWith('Good ') ?? false)), findsOneWidget);

      // Tap Tab 1 (Schedule) in BottomNavBar
      final scheduleTab = find.descendant(
        of: find.byType(BottomNavBar),
        matching: find.text('Schedule'),
      );
      expect(scheduleTab, findsOneWidget);
      await tester.tap(scheduleTab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // We are now on Schedule tab
      expect(find.text('Schedule'), findsWidgets);

      // Simulate Android Back Button via PopScope dispatcher
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Should return to Tab 0 (Home) instead of exiting!
      expect(find.byWidgetPredicate((w) => w is Text && (w.data?.startsWith('Good ') ?? false)), findsOneWidget);
    });

    testWidgets('MainShell multi-tab back navigation returns cleanly to Home without trap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      final appState = AppState();

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: const MaterialApp(
            home: MainShell(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // Tap Schedule (Tab 1)
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Schedule')));
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Nutrition (Tab 2)
      await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Nutrition')));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Nutrition'), findsWidgets);

      // Back 1 -> Schedule
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Schedule'), findsWidgets);

      // Back 2 -> Home
      await widgetsAppState.didPopRoute();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byWidgetPredicate((w) => w is Text && (w.data?.startsWith('Good ') ?? false)), findsOneWidget);
    });
  });

  group('Responsive Layout & Zero Overflow Tests', () {
    final screenSizes = [
      const Size(360, 800), // Small Android
      const Size(375, 812), // iPhone X/11/12 mini
      const Size(390, 844), // iPhone 13/14
      const Size(412, 915), // Pixel 7 / Large Android
    ];

    for (final size in screenSizes) {
      testWidgets('All major screens render with zero overflow at ${size.width}x${size.height}', (tester) async {
        await tester.binding.setSurfaceSize(size);

        final appState = AppState();


        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: appState,
            child: const MaterialApp(
              home: MainShell(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Switch to Schedule
        await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Schedule')));
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);

        // Switch to Nutrition
        await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Nutrition')));
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);

        // Switch to History
        await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('History')));
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);

        // Switch to Profile
        await tester.tap(find.descendant(of: find.byType(BottomNavBar), matching: find.text('Profile')));
        await tester.pump(const Duration(milliseconds: 250));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
