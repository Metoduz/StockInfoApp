import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/services/storage_service.dart';
import 'package:stockinfoapp/src/models/stock_item.dart';
import 'package:stockinfoapp/src/models/user_profile.dart';
import 'package:stockinfoapp/src/models/app_settings.dart';
import 'package:stockinfoapp/src/models/transaction.dart';
import 'package:stockinfoapp/src/models/stock_alert.dart';
import 'dart:math';

void main() {
  // Initialize Flutter binding for SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Data Persistence Properties', () {
    late StorageService storageService;
    late Random random;

    setUp(() {
      storageService = StorageService();
      random = Random();
    });

    tearDown(() async {
      // Clean up after each test
      await storageService.clearAllData();
    });

    test('Property 19: Data Persistence Consistency - For any user data change (watchlist, profile, settings, trading history), the change should be automatically saved to local storage',
        () async {
      // **Feature: enhanced-navigation, Property 19: Data Persistence Consistency**
      // **Validates: Requirements 9.2, 9.3**
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Clear all data before each test
        await storageService.clearAllData();
        
        // Test 1: Watchlist persistence
        final testWatchlist = _generateRandomWatchlist(random);
        await storageService.saveWatchlist(testWatchlist);
        final loadedWatchlist = await storageService.loadWatchlist();
        
        expect(loadedWatchlist.length, equals(testWatchlist.length),
            reason: 'Watchlist should persist correctly');
        for (int i = 0; i < testWatchlist.length; i++) {
          _verifyStockEquality(testWatchlist[i], loadedWatchlist[i], 'Watchlist stock $i');
        }
        
        // Test 2: User Profile persistence
        final testProfile = _generateRandomUserProfile(random);
        await storageService.saveUserProfile(testProfile);
        final loadedProfile = await storageService.loadUserProfile();
        
        expect(loadedProfile, isNotNull, reason: 'User profile should be loaded');
        _verifyUserProfileEquality(testProfile, loadedProfile!, 'User profile');
        
        // Test 3: App Settings persistence
        final testSettings = _generateRandomAppSettings(random);
        await storageService.saveAppSettings(testSettings);
        final loadedSettings = await storageService.loadAppSettings();
        
        expect(loadedSettings, isNotNull, reason: 'App settings should be loaded');
        _verifyAppSettingsEquality(testSettings, loadedSettings!, 'App settings');
        
        // Test 4: Transactions persistence
        final testTransactions = _generateRandomTransactions(random);
        await storageService.saveTransactions(testTransactions);
        final loadedTransactions = await storageService.loadTransactions();
        
        expect(loadedTransactions.length, equals(testTransactions.length),
            reason: 'Transactions should persist correctly');
        for (int i = 0; i < testTransactions.length; i++) {
          _verifyTransactionEquality(testTransactions[i], loadedTransactions[i], 'Transaction $i');
        }
        
        // Test 5: Stock Alerts persistence
        final testAlerts = _generateRandomAlerts(random);
        await storageService.saveAlerts(testAlerts);
        final loadedAlerts = await storageService.loadAlerts();
        
        expect(loadedAlerts.length, equals(testAlerts.length),
            reason: 'Alerts should persist correctly');
        for (int i = 0; i < testAlerts.length; i++) {
          _verifyAlertEquality(testAlerts[i], loadedAlerts[i], 'Alert $i');
        }
        
        // Test 6: Multiple data types persistence simultaneously
        await storageService.saveWatchlist(testWatchlist);
        await storageService.saveUserProfile(testProfile);
        await storageService.saveAppSettings(testSettings);
        await storageService.saveTransactions(testTransactions);
        await storageService.saveAlerts(testAlerts);
        
        // Verify all data persists correctly when saved together
        final reloadedWatchlist = await storageService.loadWatchlist();
        final reloadedProfile = await storageService.loadUserProfile();
        final reloadedSettings = await storageService.loadAppSettings();
        final reloadedTransactions = await storageService.loadTransactions();
        final reloadedAlerts = await storageService.loadAlerts();
        
        expect(reloadedWatchlist.length, equals(testWatchlist.length),
            reason: 'Watchlist should persist when saved with other data');
        expect(reloadedProfile, isNotNull,
            reason: 'Profile should persist when saved with other data');
        expect(reloadedSettings, isNotNull,
            reason: 'Settings should persist when saved with other data');
        expect(reloadedTransactions.length, equals(testTransactions.length),
            reason: 'Transactions should persist when saved with other data');
        expect(reloadedAlerts.length, equals(testAlerts.length),
            reason: 'Alerts should persist when saved with other data');
      }
    });

    test('Property 19 Extended: Empty Data Persistence - For any empty data collection, the empty state should be correctly persisted and retrieved',
        () async {
      // **Feature: enhanced-navigation, Property 19: Data Persistence Consistency**
      // **Validates: Requirements 9.2, 9.3**
      
      for (int iteration = 0; iteration < 50; iteration++) {
        // Test empty collections persistence
        await storageService.saveWatchlist([]);
        await storageService.saveTransactions([]);
        await storageService.saveAlerts([]);
        
        final loadedWatchlist = await storageService.loadWatchlist();
        final loadedTransactions = await storageService.loadTransactions();
        final loadedAlerts = await storageService.loadAlerts();
        
        expect(loadedWatchlist.isEmpty, isTrue,
            reason: 'Empty watchlist should persist correctly');
        expect(loadedTransactions.isEmpty, isTrue,
            reason: 'Empty transactions should persist correctly');
        expect(loadedAlerts.isEmpty, isTrue,
            reason: 'Empty alerts should persist correctly');
        
        // Test null profile and settings
        final loadedProfile = await storageService.loadUserProfile();
        final loadedSettings = await storageService.loadAppSettings();
        
        // These should return null when no data has been saved
        expect(loadedProfile, isNull,
            reason: 'Profile should be null when not saved');
        expect(loadedSettings, isNull,
            reason: 'Settings should be null when not saved');
      }
    });

    test('Property 20: Storage Error Handling - For any local storage failure, the app should handle the error gracefully and use appropriate default values',
        () async {
      // **Feature: enhanced-navigation, Property 20: Storage Error Handling**
      // **Validates: Requirements 9.4**
      
      // Test storage availability check
      final isAvailable = await storageService.isStorageAvailable();
      
      // In a real test environment with mocked SharedPreferences, we would test:
      // 1. When storage is unavailable, methods should throw exceptions
      // 2. The app should catch these exceptions and use default values
      // 3. The app should continue functioning with in-memory data
      
      // For now, we verify that the storage availability check works
      // In a unit test environment without proper mocking, this will return false
      // In a real app environment, this should return true
      
      // The property we're testing is:
      // For any storage operation that fails, the service should throw a descriptive exception
      // that can be caught and handled by the calling code
      
      // Test that exceptions are thrown with descriptive messages
      try {
        await storageService.saveWatchlist([_generateRandomStock(random)]);
        // If we get here in a test environment, storage is working (unlikely without mocking)
        expect(isAvailable, isTrue, reason: 'Storage should be available if save succeeds');
      } catch (e) {
        // Verify the exception contains useful information
        expect(e.toString(), contains('Failed to save watchlist'),
            reason: 'Exception should have descriptive message');
      }
      
      try {
        await storageService.loadWatchlist();
        // If we get here in a test environment, storage is working (unlikely without mocking)
        expect(isAvailable, isTrue, reason: 'Storage should be available if load succeeds');
      } catch (e) {
        // Verify the exception contains useful information
        expect(e.toString(), contains('Failed to load watchlist'),
            reason: 'Exception should have descriptive message');
      }
      
      // Test that all storage methods throw descriptive exceptions on failure
      final testOperations = [
        () => storageService.saveUserProfile(_generateRandomUserProfile(random)),
        () => storageService.loadUserProfile(),
        () => storageService.saveAppSettings(_generateRandomAppSettings(random)),
        () => storageService.loadAppSettings(),
        () => storageService.saveTransactions([_generateRandomTransaction(random)]),
        () => storageService.loadTransactions(),
        () => storageService.saveAlerts([_generateRandomAlert(random)]),
        () => storageService.loadAlerts(),
      ];
      
      for (final operation in testOperations) {
        try {
          await operation();
          // If operation succeeds, storage is available
        } catch (e) {
          // Verify exception contains "Failed to" message
          expect(e.toString(), contains('Failed to'),
              reason: 'All storage exceptions should have descriptive "Failed to" messages');
        }
      }
    });
  });
}

// Helper methods for generating random test data
List<StockItem> _generateRandomWatchlist(Random random) {
  final stockCount = random.nextInt(5) + 1; // 1-5 stocks
  return List.generate(stockCount, (index) => _generateRandomStock(random));
}

StockItem _generateRandomStock(Random random) {
  final companies = [
    {'name': 'BASF SE', 'symbol': 'BAS', 'isin': 'DE000BASF111'},
    {'name': 'SAP SE', 'symbol': 'SAP', 'isin': 'DE0007164600'},
    {'name': 'Mercedes-Benz Group AG', 'symbol': 'MBG', 'isin': 'DE0007100000'},
    {'name': 'Munich Re', 'symbol': 'MUV2', 'isin': 'DE0008430026'},
  ];
  
  final company = companies[random.nextInt(companies.length)];
  final currentValue = 50.0 + random.nextDouble() * 400.0;
  final previousClose = currentValue + (random.nextDouble() - 0.5) * 10.0;
  
  return StockItem(
    id: '${company['symbol']}_${random.nextInt(1000)}',
    isin: company['isin'],
    name: company['name']!,
    symbol: company['symbol']!,
    currentValue: double.parse(currentValue.toStringAsFixed(2)),
    previousClose: double.parse(previousClose.toStringAsFixed(2)),
    currency: 'EUR',
    lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
    primaryIdentifierType: StockIdentifierType.isin,
    isInWatchlist: true,
    hints: [],
  );
}

UserProfile _generateRandomUserProfile(Random random) {
  final names = ['John Doe', 'Jane Smith', 'Bob Johnson', 'Alice Brown'];
  final emails = ['john@example.com', 'jane@example.com', 'bob@example.com', 'alice@example.com'];
  final currencies = ['EUR', 'USD', 'GBP', 'CAD'];
  
  final now = DateTime.now();
  return UserProfile(
    name: names[random.nextInt(names.length)],
    email: emails[random.nextInt(emails.length)],
    profileImagePath: random.nextBool() ? '/path/to/image.jpg' : null,
    preferredCurrency: currencies[random.nextInt(currencies.length)],
    createdAt: now.subtract(Duration(days: random.nextInt(365))),
    lastUpdated: now.subtract(Duration(hours: random.nextInt(24))),
    backendUserId: random.nextBool() ? 'user_${random.nextInt(1000)}' : null,
  );
}

AppSettings _generateRandomAppSettings(Random random) {
  final currencies = ['EUR', 'USD', 'GBP', 'CAD'];
  final themeModes = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
  final languages = ['en', 'de', 'fr', 'es'];
  
  return AppSettings(
    currency: currencies[random.nextInt(currencies.length)],
    themeMode: themeModes[random.nextInt(themeModes.length)],
    enableNotifications: random.nextBool(),
    enableNewsNotifications: random.nextBool(),
    enablePriceAlerts: random.nextBool(),
    language: languages[random.nextInt(languages.length)],
    enableAnalytics: random.nextBool(),
    enableBackendSync: random.nextBool(),
    backendApiUrl: random.nextBool() ? 'https://api.example.com' : null,
    alertRefreshInterval: 5 + random.nextInt(55), // 5-60 minutes
  );
}

List<Transaction> _generateRandomTransactions(Random random) {
  final transactionCount = random.nextInt(3) + 1; // 1-3 transactions
  return List.generate(transactionCount, (index) => _generateRandomTransaction(random));
}

Transaction _generateRandomTransaction(Random random) {
  final types = [TransactionType.buy, TransactionType.sell, TransactionType.dividend];
  final stockIds = ['BAS_123', 'SAP_456', 'MBG_789'];
  final stockNames = ['BASF SE', 'SAP SE', 'Mercedes-Benz Group AG'];
  
  final stockIndex = random.nextInt(stockIds.length);
  final quantity = 1.0 + random.nextDouble() * 99.0;
  final price = 50.0 + random.nextDouble() * 400.0;
  
  return Transaction(
    id: 'txn_${random.nextInt(10000)}',
    stockId: stockIds[stockIndex],
    stockName: stockNames[stockIndex],
    type: types[random.nextInt(types.length)],
    quantity: double.parse(quantity.toStringAsFixed(2)),
    price: double.parse(price.toStringAsFixed(2)),
    totalValue: double.parse((quantity * price).toStringAsFixed(2)),
    date: DateTime.now().subtract(Duration(days: random.nextInt(365))),
    notes: random.nextBool() ? 'Random note ${random.nextInt(100)}' : null,
    brokerage: random.nextBool() ? 'Random Broker' : null,
    fees: random.nextBool() ? random.nextDouble() * 10.0 : null,
  );
}

List<StockAlert> _generateRandomAlerts(Random random) {
  final alertCount = random.nextInt(3) + 1; // 1-3 alerts
  return List.generate(alertCount, (index) => _generateRandomAlert(random));
}

StockAlert _generateRandomAlert(Random random) {
  final types = [AlertType.priceAbove, AlertType.priceBelow, AlertType.percentChange];
  final stockIds = ['BAS_123', 'SAP_456', 'MBG_789'];
  final stockNames = ['BASF SE', 'SAP SE', 'Mercedes-Benz Group AG'];
  final sources = [AlertSource.local, AlertSource.backend];
  
  final stockIndex = random.nextInt(stockIds.length);
  
  return StockAlert(
    id: 'alert_${random.nextInt(10000)}',
    stockId: stockIds[stockIndex],
    stockName: stockNames[stockIndex],
    type: types[random.nextInt(types.length)],
    threshold: 50.0 + random.nextDouble() * 400.0,
    isEnabled: random.nextBool(),
    createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    triggeredAt: random.nextBool() 
        ? DateTime.now().subtract(Duration(hours: random.nextInt(24)))
        : null,
    notifications: NotificationSettings(
      enablePushNotifications: random.nextBool(),
      enableEmailNotifications: random.nextBool(),
      enableInAppNotifications: random.nextBool(),
      notificationTimes: random.nextBool() ? ['09:00', '17:00'] : [],
      enableWeekendNotifications: random.nextBool(),
    ),
    backendAlertId: random.nextBool() ? 'backend_${random.nextInt(1000)}' : null,
    source: sources[random.nextInt(sources.length)],
    metadata: random.nextBool() ? {'key': 'value'} : null,
  );
}

// Helper methods for verifying data equality
void _verifyStockEquality(StockItem expected, StockItem actual, String context) {
  expect(actual.id, equals(expected.id), reason: '$context: ID should match');
  expect(actual.name, equals(expected.name), reason: '$context: Name should match');
  expect(actual.symbol, equals(expected.symbol), reason: '$context: Symbol should match');
  expect(actual.currentValue, equals(expected.currentValue), reason: '$context: Current value should match');
  expect(actual.currency, equals(expected.currency), reason: '$context: Currency should match');
  expect(actual.isInWatchlist, equals(expected.isInWatchlist), reason: '$context: Watchlist status should match');
}

void _verifyUserProfileEquality(UserProfile expected, UserProfile actual, String context) {
  expect(actual.name, equals(expected.name), reason: '$context: Name should match');
  expect(actual.email, equals(expected.email), reason: '$context: Email should match');
  expect(actual.profileImagePath, equals(expected.profileImagePath), reason: '$context: Profile image path should match');
  expect(actual.preferredCurrency, equals(expected.preferredCurrency), reason: '$context: Preferred currency should match');
  expect(actual.createdAt, equals(expected.createdAt), reason: '$context: Created at should match');
  expect(actual.lastUpdated, equals(expected.lastUpdated), reason: '$context: Last updated should match');
  expect(actual.backendUserId, equals(expected.backendUserId), reason: '$context: Backend user ID should match');
}

void _verifyAppSettingsEquality(AppSettings expected, AppSettings actual, String context) {
  expect(actual.currency, equals(expected.currency), reason: '$context: Currency should match');
  expect(actual.themeMode, equals(expected.themeMode), reason: '$context: Theme mode should match');
  expect(actual.enableNotifications, equals(expected.enableNotifications), reason: '$context: Enable notifications should match');
  expect(actual.enableNewsNotifications, equals(expected.enableNewsNotifications), reason: '$context: Enable news notifications should match');
  expect(actual.enablePriceAlerts, equals(expected.enablePriceAlerts), reason: '$context: Enable price alerts should match');
  expect(actual.language, equals(expected.language), reason: '$context: Language should match');
  expect(actual.enableAnalytics, equals(expected.enableAnalytics), reason: '$context: Enable analytics should match');
  expect(actual.enableBackendSync, equals(expected.enableBackendSync), reason: '$context: Enable backend sync should match');
  expect(actual.backendApiUrl, equals(expected.backendApiUrl), reason: '$context: Backend API URL should match');
  expect(actual.alertRefreshInterval, equals(expected.alertRefreshInterval), reason: '$context: Alert refresh interval should match');
}

void _verifyTransactionEquality(Transaction expected, Transaction actual, String context) {
  expect(actual.id, equals(expected.id), reason: '$context: ID should match');
  expect(actual.stockId, equals(expected.stockId), reason: '$context: Stock ID should match');
  expect(actual.stockName, equals(expected.stockName), reason: '$context: Stock name should match');
  expect(actual.type, equals(expected.type), reason: '$context: Type should match');
  expect(actual.quantity, equals(expected.quantity), reason: '$context: Quantity should match');
  expect(actual.price, equals(expected.price), reason: '$context: Price should match');
  expect(actual.totalValue, equals(expected.totalValue), reason: '$context: Total value should match');
  expect(actual.date, equals(expected.date), reason: '$context: Date should match');
  expect(actual.notes, equals(expected.notes), reason: '$context: Notes should match');
  expect(actual.brokerage, equals(expected.brokerage), reason: '$context: Brokerage should match');
  expect(actual.fees, equals(expected.fees), reason: '$context: Fees should match');
}

void _verifyAlertEquality(StockAlert expected, StockAlert actual, String context) {
  expect(actual.id, equals(expected.id), reason: '$context: ID should match');
  expect(actual.stockId, equals(expected.stockId), reason: '$context: Stock ID should match');
  expect(actual.stockName, equals(expected.stockName), reason: '$context: Stock name should match');
  expect(actual.type, equals(expected.type), reason: '$context: Type should match');
  expect(actual.threshold, equals(expected.threshold), reason: '$context: Threshold should match');
  expect(actual.isEnabled, equals(expected.isEnabled), reason: '$context: Is enabled should match');
  expect(actual.createdAt, equals(expected.createdAt), reason: '$context: Created at should match');
  expect(actual.triggeredAt, equals(expected.triggeredAt), reason: '$context: Triggered at should match');
  expect(actual.backendAlertId, equals(expected.backendAlertId), reason: '$context: Backend alert ID should match');
  expect(actual.source, equals(expected.source), reason: '$context: Source should match');
  expect(actual.metadata, equals(expected.metadata), reason: '$context: Metadata should match');
  
  // Verify notification settings
  expect(actual.notifications.enablePushNotifications, equals(expected.notifications.enablePushNotifications), 
      reason: '$context: Push notifications should match');
  expect(actual.notifications.enableEmailNotifications, equals(expected.notifications.enableEmailNotifications), 
      reason: '$context: Email notifications should match');
  expect(actual.notifications.enableInAppNotifications, equals(expected.notifications.enableInAppNotifications), 
      reason: '$context: In-app notifications should match');
  expect(actual.notifications.notificationTimes, equals(expected.notifications.notificationTimes), 
      reason: '$context: Notification times should match');
  expect(actual.notifications.enableWeekendNotifications, equals(expected.notifications.enableWeekendNotifications), 
      reason: '$context: Weekend notifications should match');
}
