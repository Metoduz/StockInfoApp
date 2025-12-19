import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/screens/watchlist_screen.dart';
import 'package:stockinfoapp/src/models/stock_item.dart';
import 'package:stockinfoapp/src/services/storage_service.dart';
import 'dart:math';

void main() {
  group('Watchlist Properties', () {
    testWidgets('Property 3: Watchlist Persistence Round Trip - For any valid stock added to the watchlist, the stock should be retrievable from local storage and displayed in the watchlist',
        (WidgetTester tester) async {
      // **Feature: enhanced-navigation, Property 3: Watchlist Persistence Round Trip**
      // **Validates: Requirements 2.3, 2.4**
      
      final storageService = StorageService();
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a random stock for testing
        final testStock = _generateRandomStock(random);
        
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
        
        // Add the stock to watchlist by tapping add button
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        
        // Verify search dialog opens
        expect(find.text('Add Stock to Watchlist'), findsOneWidget);
        
        // Since we can't easily add a completely new stock through the UI,
        // we'll test the storage service directly for the round trip property
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        
        // Test the storage service round trip directly
        final testWatchlist = [testStock];
        
        // Save the stock to storage
        await storageService.saveWatchlist(testWatchlist);
        
        // Load the stock from storage
        final loadedWatchlist = await storageService.loadWatchlist();
        
        // Verify the round trip property: saved stock should be retrievable
        expect(loadedWatchlist.length, equals(1),
            reason: 'Saved watchlist should contain exactly one stock');
        
        final loadedStock = loadedWatchlist.first;
        expect(loadedStock.id, equals(testStock.id),
            reason: 'Loaded stock ID should match saved stock ID');
        expect(loadedStock.name, equals(testStock.name),
            reason: 'Loaded stock name should match saved stock name');
        expect(loadedStock.symbol, equals(testStock.symbol),
            reason: 'Loaded stock symbol should match saved stock symbol');
        expect(loadedStock.currentValue, equals(testStock.currentValue),
            reason: 'Loaded stock value should match saved stock value');
        expect(loadedStock.currency, equals(testStock.currency),
            reason: 'Loaded stock currency should match saved stock currency');
        expect(loadedStock.isInWatchlist, equals(testStock.isInWatchlist),
            reason: 'Loaded stock watchlist status should match saved stock');
        
        // Test with a fresh widget to verify persistence across app restarts
        await tester.pumpWidget(
          const MaterialApp(
            home: WatchlistScreen(),
          ),
        );
        await tester.pumpAndSettle();
        
        // Verify the stock appears in the UI after restart
        expect(find.text(testStock.name), findsOneWidget,
            reason: 'Stock should be displayed in watchlist after persistence');
        expect(find.text('${testStock.currentValue} ${testStock.currency}'), findsOneWidget,
            reason: 'Stock value should be displayed correctly after persistence');
        
        // Test removal round trip
        final emptyWatchlist = <StockItem>[];
        await storageService.saveWatchlist(emptyWatchlist);
        final loadedEmptyWatchlist = await storageService.loadWatchlist();
        
        expect(loadedEmptyWatchlist.isEmpty, isTrue,
            reason: 'Empty watchlist should persist correctly');
      }
    });
    
    testWidgets('Property 3 Extended: Multiple Stock Persistence - For any list of valid stocks added to the watchlist, all stocks should be retrievable from local storage in the same order',
        (WidgetTester tester) async {
      // **Feature: enhanced-navigation, Property 3: Watchlist Persistence Round Trip**
      // **Validates: Requirements 2.3, 2.4**
      
      final storageService = StorageService();
      final random = Random();
      
      // Test with multiple iterations and varying numbers of stocks
      for (int iteration = 0; iteration < 50; iteration++) {
        // Generate a random number of stocks (1-10)
        final stockCount = random.nextInt(10) + 1;
        final testStocks = List.generate(stockCount, (index) => _generateRandomStock(random));
        
        // Save the stocks to storage
        await storageService.saveWatchlist(testStocks);
        
        // Load the stocks from storage
        final loadedWatchlist = await storageService.loadWatchlist();
        
        // Verify the round trip property: all saved stocks should be retrievable
        expect(loadedWatchlist.length, equals(testStocks.length),
            reason: 'Loaded watchlist should contain same number of stocks as saved');
        
        // Verify each stock matches
        for (int i = 0; i < testStocks.length; i++) {
          final originalStock = testStocks[i];
          final loadedStock = loadedWatchlist[i];
          
          expect(loadedStock.id, equals(originalStock.id),
              reason: 'Stock $i: ID should match after round trip');
          expect(loadedStock.name, equals(originalStock.name),
              reason: 'Stock $i: Name should match after round trip');
          expect(loadedStock.symbol, equals(originalStock.symbol),
              reason: 'Stock $i: Symbol should match after round trip');
          expect(loadedStock.currentValue, equals(originalStock.currentValue),
              reason: 'Stock $i: Value should match after round trip');
          expect(loadedStock.currency, equals(originalStock.currency),
              reason: 'Stock $i: Currency should match after round trip');
          expect(loadedStock.isInWatchlist, equals(originalStock.isInWatchlist),
              reason: 'Stock $i: Watchlist status should match after round trip');
        }
        
        // Test UI display with the loaded watchlist
        await tester.pumpWidget(
          const MaterialApp(
            home: WatchlistScreen(),
          ),
        );
        await tester.pumpAndSettle();
        
        // Verify all stocks appear in the UI
        for (final stock in testStocks) {
          expect(find.text(stock.name), findsOneWidget,
              reason: 'Stock ${stock.name} should be displayed in watchlist');
        }
      }
    });
  });
}

StockItem _generateRandomStock(Random random) {
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
    hints: _generateRandomHints(random),
  );
}

List<StockHint> _generateRandomHints(Random random) {
  final hintTypes = ['buy_zone', 'trendline', 'support', 'resistance'];
  final hintCount = random.nextInt(3); // 0-2 hints
  
  return List.generate(hintCount, (index) {
    final type = hintTypes[random.nextInt(hintTypes.length)];
    return StockHint(
      type: type,
      description: 'Random $type hint ${random.nextInt(100)}',
      value: random.nextBool() ? 100.0 + random.nextDouble() * 200.0 : null,
      timestamp: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    );
  });
}