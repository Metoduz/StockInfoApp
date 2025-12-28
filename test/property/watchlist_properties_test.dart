import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/screens/watchlist_screen.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/services/storage_service.dart';
import 'dart:math';

void main() {
  group('Watchlist Properties', () {
    testWidgets('Property 3: Watchlist Persistence Round Trip - For any valid asset added to the watchlist, the asset should be retrievable from local storage and displayed in the watchlist',
        (WidgetTester tester) async {
      // **Feature: enhanced-navigation, Property 3: Watchlist Persistence Round Trip**
      // **Validates: Requirements 2.3, 2.4**
      
      final storageService = StorageService();
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a random asset for testing
        final testAsset = _generateRandomAsset(random);
        
        // Clear any existing watchlist
        await storageService.saveWatchlist([]);
        
        // Build the WatchlistScreen widget
        await tester.pumpWidget(
          const MaterialApp(
            home: WatchlistScreen(),
          ),
        );
        await tester.pumpAndSettle();
        
        // Verify empty state initially
        expect(find.text('Your watchlist is empty'), findsOneWidget);
        
        // Add the asset to watchlist by tapping add button
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        
        // Verify search dialog opens
        expect(find.text('Add Asset to Watchlist'), findsOneWidget);
        
        // Since we can't easily add a completely new asset through the UI,
        // we'll test the storage service directly for the round trip property
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        
        // Test the storage service round trip directly
        final testWatchlist = [testAsset];
        
        // Save the asset to storage
        await storageService.saveWatchlist(testWatchlist);
        
        // Load the asset from storage
        final loadedWatchlist = await storageService.loadWatchlist();
        
        // Verify the round trip property: saved asset should be retrievable
        expect(loadedWatchlist.length, equals(1),
            reason: 'Saved watchlist should contain exactly one asset');
        
        final loadedAsset = loadedWatchlist.first;
        expect(loadedAsset.id, equals(testAsset.id),
            reason: 'Loaded asset ID should match saved asset ID');
        expect(loadedAsset.name, equals(testAsset.name),
            reason: 'Loaded asset name should match saved asset name');
        expect(loadedAsset.symbol, equals(testAsset.symbol),
            reason: 'Loaded asset symbol should match saved asset symbol');
        expect(loadedAsset.currentValue, equals(testAsset.currentValue),
            reason: 'Loaded asset value should match saved asset value');
        expect(loadedAsset.currency, equals(testAsset.currency),
            reason: 'Loaded asset currency should match saved asset currency');
        expect(loadedAsset.isInWatchlist, equals(testAsset.isInWatchlist),
            reason: 'Loaded asset watchlist status should match saved asset');
        
        // Test with a fresh widget to verify persistence across app restarts
        await tester.pumpWidget(
          const MaterialApp(
            home: WatchlistScreen(),
          ),
        );
        await tester.pumpAndSettle();
        
        // Verify the asset appears in the UI after restart
        expect(find.text(testAsset.name), findsOneWidget,
            reason: 'Asset should be displayed in watchlist after persistence');
        expect(find.text('${testAsset.currentValue} ${testAsset.currency}'), findsOneWidget,
            reason: 'Asset value should be displayed correctly after persistence');
        
        // Test removal round trip
        final emptyWatchlist = <AssetItem>[];
        await storageService.saveWatchlist(emptyWatchlist);
        final loadedEmptyWatchlist = await storageService.loadWatchlist();
        
        expect(loadedEmptyWatchlist.isEmpty, isTrue,
            reason: 'Empty watchlist should persist correctly');
      }
    });
    
    testWidgets('Property 3 Extended: Multiple Asset Persistence - For any list of valid assets added to the watchlist, all assets should be retrievable from local storage in the same order',
        (WidgetTester tester) async {
      // **Feature: enhanced-navigation, Property 3: Watchlist Persistence Round Trip**
      // **Validates: Requirements 2.3, 2.4**
      
      final storageService = StorageService();
      final random = Random();
      
      // Test with multiple iterations and varying numbers of assets
      for (int iteration = 0; iteration < 50; iteration++) {
        // Generate a random number of assets (1-10)
        final assetCount = random.nextInt(10) + 1;
        final testAssets = List.generate(assetCount, (index) => _generateRandomAsset(random));
        
        // Save the assets to storage
        await storageService.saveWatchlist(testAssets);
        
        // Load the assets from storage
        final loadedWatchlist = await storageService.loadWatchlist();
        
        // Verify the round trip property: all saved assets should be retrievable
        expect(loadedWatchlist.length, equals(testAssets.length),
            reason: 'Loaded watchlist should contain same number of assets as saved');
        
        // Verify each asset matches
        for (int i = 0; i < testAssets.length; i++) {
          final originalAsset = testAssets[i];
          final loadedAsset = loadedWatchlist[i];
          
          expect(loadedAsset.id, equals(originalAsset.id),
              reason: 'Asset $i: ID should match after round trip');
          expect(loadedAsset.name, equals(originalAsset.name),
              reason: 'Asset $i: Name should match after round trip');
          expect(loadedAsset.symbol, equals(originalAsset.symbol),
              reason: 'Asset $i: Symbol should match after round trip');
          expect(loadedAsset.currentValue, equals(originalAsset.currentValue),
              reason: 'Asset $i: Value should match after round trip');
          expect(loadedAsset.currency, equals(originalAsset.currency),
              reason: 'Asset $i: Currency should match after round trip');
          expect(loadedAsset.isInWatchlist, equals(originalAsset.isInWatchlist),
              reason: 'Asset $i: Watchlist status should match after round trip');
        }
        
        // Test UI display with the loaded watchlist
        await tester.pumpWidget(
          const MaterialApp(
            home: WatchlistScreen(),
          ),
        );
        await tester.pumpAndSettle();
        
        // Verify all assets appear in the UI
        for (final asset in testAssets) {
          expect(find.text(asset.name), findsOneWidget,
              reason: 'Asset ${asset.name} should be displayed in watchlist');
        }
      }
    });
  });
}

AssetItem _generateRandomAsset(Random random) {
  final companies = [
    {'name': 'BASF SE', 'symbol': 'BAS', 'isin': 'DE000BASF111'},
    {'name': 'SAP SE', 'symbol': 'SAP', 'isin': 'DE0007164600'},
    {'name': 'Mercedes-Benz Group AG', 'symbol': 'MBG', 'isin': 'DE0007100000'},
    {'name': 'Munich Re', 'symbol': 'MUV2', 'isin': 'DE0008430026'},
    {'name': 'Adidas AG', 'symbol': 'ADS', 'isin': 'DE000A1EWWW0'},
    {'name': 'Siemens AG', 'symbol': 'SIE', 'isin': 'DE0007236101'},
    {'name': 'Allianz SE', 'symbol': 'ALV', 'isin': 'DE0008404005'},
    {'name': 'Deutsche Bank AG', 'symbol': 'DBK', 'isin': 'DE0005140008'},
  ];
  
  final company = companies[random.nextInt(companies.length)];
  final currentValue = 50.0 + random.nextDouble() * 400.0; // Random value between 50-450
  final previousClose = currentValue + (random.nextDouble() - 0.5) * 10.0; // +/- 5 from current
  
  return AssetItem(
    id: '${company['symbol']}_${random.nextInt(1000)}',
    isin: company['isin'],
    name: company['name']!,
    symbol: company['symbol']!,
    currentValue: double.parse(currentValue.toStringAsFixed(2)),
    previousClose: double.parse(previousClose.toStringAsFixed(2)),
    currency: 'EUR',
    lastUpdated: DateTime.now().subtract(Duration(minutes: random.nextInt(60))),
    primaryIdentifierType: AssetIdentifierType.isin,
    isInWatchlist: true,
    hints: _generateRandomHints(random),
  );
}

List<AssetHint> _generateRandomHints(Random random) {
  final hintTypes = ['buy_zone', 'trendline', 'support', 'resistance'];
  final hintCount = random.nextInt(3); // 0-2 hints
  
  return List.generate(hintCount, (index) {
    final type = hintTypes[random.nextInt(hintTypes.length)];
    return AssetHint(
      type: type,
      description: 'Random $type hint ${random.nextInt(100)}',
      value: random.nextBool() ? 100.0 + random.nextDouble() * 200.0 : null,
      timestamp: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    );
  });
}