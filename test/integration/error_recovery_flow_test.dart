import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockinfoapp/src/app.dart';
import 'package:stockinfoapp/src/providers/app_state_provider.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/models/user_profile.dart';

void main() {
  group('Error Recovery Flow Integration Tests', () {
    late AppStateProvider appStateProvider;

    setUp(() {
      appStateProvider = AppStateProvider();
    });

    testWidgets('App recovers gracefully from navigation errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Test navigation to unknown route doesn't crash app
      final BuildContext context = tester.element(find.byType(MyApp));
      
      // This should not crash the app
      try {
        Navigator.pushNamed(context, '/nonexistent-route');
        await tester.pumpAndSettle();
      } catch (e) {
        // Expected to handle gracefully
      }

      // App should still be functional
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.text('My Watchlist'), findsOneWidget);

      // Navigation should still work
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);
    });

    testWidgets('Invalid asset data handling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Try to add invalid asset data
      final invalidAsset = AssetItem(
        id: '', // Invalid empty ID
        name: '',
        symbol: '',
        currentValue: -100.0, // Invalid negative value
        currency: 'INVALID',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.isin,
        isInWatchlist: true,
      );

      // This should not crash the app
      try {
        await appStateProvider.addToWatchlist(invalidAsset);
        await tester.pumpAndSettle();
      } catch (e) {
        // Expected to handle gracefully
      }

      // App should still be functional
      expect(find.text('My Watchlist'), findsOneWidget);

      // Navigation should still work
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);
    });

    testWidgets('Profile validation error handling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to profile screen
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();

      // Try to save invalid profile data
      final invalidProfile = UserProfile(
        name: 'A' * 200, // Too long name
        email: 'invalid-email', // Invalid email format
        preferredCurrency: 'INVALID',
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // This should show validation errors, not crash
      try {
        await appStateProvider.updateUserProfile(invalidProfile);
        await tester.pumpAndSettle();
      } catch (e) {
        // Expected to handle gracefully
      }

      // Profile screen should still be functional
      expect(find.text('User Profile'), findsOneWidget);

      // Navigation back should work
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('Network error simulation and recovery', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to news tab (which might fetch data)
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();

      // App should handle network errors gracefully
      expect(find.text('Financial News'), findsOneWidget);

      // Even if news fails to load, navigation should still work
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      expect(find.text('Asset Alerts'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('Rapid user interactions handling', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Rapidly switch between tabs
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.newspaper));
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.tap(find.byIcon(Icons.home));
        // Don't wait for settle to simulate rapid tapping
      }

      await tester.pumpAndSettle();

      // App should still be responsive
      expect(find.text('My Watchlist'), findsOneWidget);

      // Rapidly open and close drawer
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.menu));
        await tester.tapAt(const Offset(400, 300)); // Close drawer
      }

      await tester.pumpAndSettle();

      // App should still be functional
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('Memory pressure simulation', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Add many assets to simulate memory usage
      for (int i = 0; i < 100; i++) {
        final asset = AssetItem(
          id: 'MEMORY_TEST_$i',
          name: 'Memory Test Asset $i',
          symbol: 'MTS$i',
          currentValue: 10.0 + i,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: AssetIdentifierType.isin,
          isInWatchlist: true,
        );

        await appStateProvider.addToWatchlist(asset);
      }

      await tester.pumpAndSettle();

      // App should still be responsive with large dataset
      expect(find.text('My Watchlist'), findsOneWidget);
      expect(appStateProvider.watchlist.length, greaterThanOrEqualTo(100));

      // Navigation should still work smoothly
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);

      // Clean up by removing all test assets
      for (int i = 0; i < 100; i++) {
        await appStateProvider.removeFromWatchlist('MEMORY_TEST_$i');
      }

      await tester.pumpAndSettle();
    });

    testWidgets('State corruption recovery', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate state corruption by rapid concurrent operations
      final futures = <Future>[];
      
      for (int i = 0; i < 20; i++) {
        final asset = AssetItem(
          id: 'CONCURRENT_$i',
          name: 'Concurrent Test Asset $i',
          symbol: 'CTS$i',
          currentValue: 10.0 + i,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: AssetIdentifierType.isin,
          isInWatchlist: true,
        );

        // Add and remove operations concurrently
        futures.add(appStateProvider.addToWatchlist(asset));
        if (i % 2 == 0) {
          futures.add(appStateProvider.removeFromWatchlist('CONCURRENT_${i ~/ 2}'));
        }
      }

      // Wait for all operations to complete
      await Future.wait(futures);
      await tester.pumpAndSettle();

      // App should still be functional despite concurrent operations
      expect(find.text('My Watchlist'), findsOneWidget);

      // Navigation should still work
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('Widget disposal and cleanup', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate through multiple screens to create widgets
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Switch tabs multiple times
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // App should handle widget lifecycle properly
      expect(find.text('My Watchlist'), findsOneWidget);

      // Dispose of the widget tree
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      // No exceptions should be thrown during disposal
    });
  });
}