import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockinfoapp/src/app.dart';
import 'package:stockinfoapp/src/providers/app_state_provider.dart';
import 'package:stockinfoapp/src/models/stock_item.dart';
import 'package:stockinfoapp/src/models/user_profile.dart';
import 'package:stockinfoapp/src/models/app_settings.dart';

void main() {
  group('Data Persistence Flow Integration Tests', () {
    late AppStateProvider appStateProvider;

    setUp(() {
      appStateProvider = AppStateProvider();
    });

    testWidgets('Data persistence across app restarts', (WidgetTester tester) async {
      // First app session - add data
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Add a stock to watchlist
      final testStock = StockItem(
        id: 'TEST123',
        name: 'Test Company',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: StockIdentifierType.isin,
        isInWatchlist: true,
      );

      await appStateProvider.addToWatchlist(testStock);
      await tester.pumpAndSettle();

      // Verify stock was added
      expect(appStateProvider.watchlist.length, greaterThan(0));
      expect(appStateProvider.watchlist.any((stock) => stock.id == 'TEST123'), isTrue);

      // Update user profile
      final testProfile = UserProfile(
        name: 'Test User',
        email: 'test@example.com',
        preferredCurrency: 'USD',
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await appStateProvider.updateUserProfile(testProfile);
      await tester.pumpAndSettle();

      // Verify profile was updated
      expect(appStateProvider.userProfile?.name, equals('Test User'));
      expect(appStateProvider.userProfile?.email, equals('test@example.com'));

      // Update app settings
      const testSettings = AppSettings(
        currency: 'USD',
        themeMode: ThemeMode.dark,
        enableNotifications: false,
      );

      await appStateProvider.updateAppSettings(testSettings);
      await tester.pumpAndSettle();

      // Verify settings were updated
      expect(appStateProvider.appSettings?.currency, equals('USD'));
      expect(appStateProvider.appSettings?.themeMode, equals(ThemeMode.dark));

      // Simulate app restart by creating new provider and initializing
      final newAppStateProvider = AppStateProvider();
      await newAppStateProvider.initializeAppData();

      // Verify data persisted across restart
      expect(newAppStateProvider.watchlist.any((stock) => stock.id == 'TEST123'), isTrue);
      expect(newAppStateProvider.userProfile?.name, equals('Test User'));
      expect(newAppStateProvider.userProfile?.email, equals('test@example.com'));
      expect(newAppStateProvider.appSettings?.currency, equals('USD'));
      expect(newAppStateProvider.appSettings?.themeMode, equals(ThemeMode.dark));
    });

    testWidgets('Cross-component data consistency', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Update user profile
      final testProfile = UserProfile(
        name: 'John Doe',
        email: 'john@example.com',
        preferredCurrency: 'EUR',
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      await appStateProvider.updateUserProfile(testProfile);
      await tester.pumpAndSettle();

      // Navigate to drawer to check if profile data is reflected
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify profile data is shown in drawer
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);

      // Close drawer
      await tester.tapAt(const Offset(400, 300));
      await tester.pumpAndSettle();

      // Navigate to profile screen
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();

      // Verify profile data is consistent in profile screen
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);

      // Go back and test settings consistency
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Update currency setting
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify current currency is shown
      expect(find.text('EUR'), findsOneWidget);
    });

    testWidgets('Watchlist data consistency across tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Add a stock to watchlist from main tab
      final testStock = StockItem(
        id: 'CONSISTENCY_TEST',
        name: 'Consistency Test Stock',
        symbol: 'CTS',
        currentValue: 50.0,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: StockIdentifierType.isin,
        isInWatchlist: true,
      );

      await appStateProvider.addToWatchlist(testStock);
      await tester.pumpAndSettle();

      // Verify stock count in main tab
      final initialWatchlistCount = appStateProvider.watchlist.length;
      expect(initialWatchlistCount, greaterThan(0));

      // Switch to news tab
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();

      // Switch to alerts tab
      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pumpAndSettle();

      // Switch back to main tab
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify watchlist data is still consistent
      expect(appStateProvider.watchlist.length, equals(initialWatchlistCount));
      expect(appStateProvider.watchlist.any((stock) => stock.id == 'CONSISTENCY_TEST'), isTrue);

      // Remove the stock
      await appStateProvider.removeFromWatchlist('CONSISTENCY_TEST');
      await tester.pumpAndSettle();

      // Verify removal is reflected
      expect(appStateProvider.watchlist.length, equals(initialWatchlistCount - 1));
      expect(appStateProvider.watchlist.any((stock) => stock.id == 'CONSISTENCY_TEST'), isFalse);
    });

    testWidgets('Storage error handling gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Test that app still functions even if storage operations fail
      // This is more of a behavioral test since we can't easily mock storage failures
      // in widget tests, but we can verify the app doesn't crash

      // Try to add multiple stocks rapidly
      for (int i = 0; i < 5; i++) {
        final stock = StockItem(
          id: 'RAPID_$i',
          name: 'Rapid Test Stock $i',
          symbol: 'RTS$i',
          currentValue: 10.0 + i,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: StockIdentifierType.isin,
          isInWatchlist: true,
        );

        await appStateProvider.addToWatchlist(stock);
        // Don't wait for settle to simulate rapid operations
      }

      await tester.pumpAndSettle();

      // Verify app is still responsive
      expect(find.text('My Watchlist'), findsOneWidget);
      expect(appStateProvider.watchlist.length, greaterThanOrEqualTo(5));

      // Test navigation still works
      await tester.tap(find.byIcon(Icons.newspaper));
      await tester.pumpAndSettle();
      expect(find.text('Financial News'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.text('My Watchlist'), findsOneWidget);
    });

    testWidgets('Theme changes persist and apply immediately', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppStateProvider>.value(
          value: appStateProvider,
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Change theme to dark mode
      const darkSettings = AppSettings(
        themeMode: ThemeMode.dark,
      );

      await appStateProvider.updateAppSettings(darkSettings);
      await tester.pumpAndSettle();

      // Verify theme change is applied
      expect(appStateProvider.appSettings?.themeMode, equals(ThemeMode.dark));

      // Go back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Theme should still be applied
      expect(appStateProvider.appSettings?.themeMode, equals(ThemeMode.dark));
    });
  });
}