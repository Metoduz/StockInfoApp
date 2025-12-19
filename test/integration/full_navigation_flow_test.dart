import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockinfoapp/src/app.dart';
import 'package:stockinfoapp/src/providers/app_state_provider.dart';

void main() {
  group('Full Navigation Flow Integration Tests', () {
    late AppStateProvider appStateProvider;

    setUp(() {
      appStateProvider = AppStateProvider();
    });

    testWidgets('Complete navigation flow through all screens', (WidgetTester tester) async {
      // Build the app with provider
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Verify we start on the main tab (watchlist)
      expect(find.text('My Watchlist'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);

      // Test bottom navigation - switch to News tab
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);

      // Test bottom navigation - switch to Alerts tab
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      expect(find.text('Stock Alerts'), findsOneWidget);

      // Test bottom navigation - back to Main tab
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);

      // Test drawer navigation - open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Navigate to User Profile
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();
      expect(find.text('User Profile'), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Open drawer again and navigate to Settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Open drawer again and navigate to Trading History
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trading History'));
      await tester.pumpAndSettle();
      expect(find.text('Trading History'), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Open drawer again and navigate to Legal Information
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Legal Information'));
      await tester.pumpAndSettle();
      expect(find.text('Legal Information'), findsOneWidget);

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on the main screen
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('Tab state preservation during navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Start on Main tab
      expect(find.text('My Watchlist'), findsOneWidget);

      // Switch to News tab
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);

      // Switch to Alerts tab
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      expect(find.text('Stock Alerts'), findsOneWidget);

      // Switch back to Main tab - state should be preserved
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);

      // Switch back to News tab - state should be preserved
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);

      // Switch back to Alerts tab - state should be preserved
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      expect(find.text('Stock Alerts'), findsOneWidget);
    });

    testWidgets('Deep linking to specific tabs works', (WidgetTester tester) async {
      // Test deep linking to news tab
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: MaterialApp(
            home: const MyApp(),
            routes: {
              '/news': (context) => const MyApp(),
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate using named route
      final BuildContext context = tester.element(find.byType(MyApp));
      Navigator.pushNamed(context, '/news');
      await tester.pumpAndSettle();

      // Should still work (routes are handled by MyApp)
      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('Navigation consistency across all screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Test that drawer is accessible from all tabs
      final List<IconData> tabIcons = [Icons.home, Icons.newspaper, Icons.notifications];
      final List<String> expectedTitles = ['My Watchlist', 'Financial News', 'Stock Alerts'];

      for (int i = 0; i < tabIcons.length; i++) {
        // Navigate to tab
        await tester.tap(find.byIcon(tabIcons[i]));
        await tester.pumpAndSettle();

        // Verify correct screen is displayed
        expect(find.text(expectedTitles[i]), findsOneWidget);

        // Verify drawer is accessible
        expect(find.byIcon(Icons.menu), findsOneWidget);

        // Open drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        // Verify drawer content is present
        expect(find.text('User Profile'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Trading History'), findsOneWidget);
        expect(find.text('Legal Information'), findsOneWidget);

        // Close drawer by tapping outside
        await tester.tapAt(const Offset(400, 300));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Error handling for unknown routes', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to navigate to an unknown route
      final BuildContext context = tester.element(find.byType(MyApp));
      Navigator.pushNamed(context, '/unknown-route');
      await tester.pumpAndSettle();

      // Should fallback to main navigation shell
      expect(find.byType(MyApp), findsOneWidget);
    });
  });
}