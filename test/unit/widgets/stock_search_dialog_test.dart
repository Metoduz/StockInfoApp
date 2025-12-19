import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/widgets/stock_search_dialog.dart';
import 'package:stockinfoapp/src/models/stock_item.dart';

void main() {
  group('StockSearchDialog', () {
    late List<StockItem> availableStocks;
    late List<StockItem> currentWatchlist;

    setUp(() {
      availableStocks = [
        StockItem(
          id: 'BASF11',
          isin: 'DE000BASF111',
          name: 'BASF SE',
          symbol: 'BAS',
          currentValue: 45.23,
          previousClose: 44.80,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: StockIdentifierType.isin,
          isInWatchlist: false,
        ),
        StockItem(
          id: 'SAP',
          isin: 'DE0007164600',
          name: 'SAP SE',
          symbol: 'SAP',
          currentValue: 178.65,
          previousClose: 180.20,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: StockIdentifierType.isin,
          isInWatchlist: false,
        ),
        StockItem(
          id: 'MBG',
          isin: 'DE0007100000',
          name: 'Mercedes-Benz Group AG',
          symbol: 'MBG',
          currentValue: 68.91,
          previousClose: 67.50,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: StockIdentifierType.isin,
          isInWatchlist: false,
        ),
      ];

      currentWatchlist = [
        StockItem(
          id: 'AAPL',
          isin: 'US0378331005',
          name: 'Apple Inc.',
          symbol: 'AAPL',
          currentValue: 150.00,
          currency: 'USD',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: StockIdentifierType.isin,
          isInWatchlist: true,
        ),
      ];
    });

    testWidgets('displays search field and available stocks', (WidgetTester tester) async {
      bool stockSelected = false;
      StockItem? selectedStock;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockSearchDialog(
              availableStocks: availableStocks,
              currentWatchlist: currentWatchlist,
              onStockSelected: (stock) {
                stockSelected = true;
                selectedStock = stock;
              },
            ),
          ),
        ),
      );

      // Verify search field is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search stocks'), findsOneWidget);

      // Verify available stocks are displayed (excluding watchlist items)
      expect(find.text('BASF SE'), findsOneWidget);
      expect(find.text('SAP SE'), findsOneWidget);
      expect(find.text('Mercedes-Benz Group AG'), findsOneWidget);
      
      // Verify watchlist stock is not displayed
      expect(find.text('Apple Inc.'), findsNothing);
    });

    testWidgets('filters stocks based on search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockSearchDialog(
              availableStocks: availableStocks,
              currentWatchlist: currentWatchlist,
              onStockSelected: (stock) {},
            ),
          ),
        ),
      );

      // Enter search query
      await tester.enterText(find.byType(TextField), 'BASF');
      await tester.pump();

      // Verify only BASF is shown
      expect(find.text('BASF SE'), findsOneWidget);
      expect(find.text('SAP SE'), findsNothing);
      expect(find.text('Mercedes-Benz Group AG'), findsNothing);
    });

    testWidgets('prevents duplicate stock selection', (WidgetTester tester) async {
      // Add BASF to watchlist to test duplicate prevention
      final watchlistWithBasf = [
        ...currentWatchlist,
        availableStocks[0].addToWatchlist(),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockSearchDialog(
              availableStocks: availableStocks,
              currentWatchlist: watchlistWithBasf,
              onStockSelected: (stock) {},
            ),
          ),
        ),
      );

      // BASF should not be available for selection
      expect(find.text('BASF SE'), findsNothing);
      
      // Other stocks should still be available
      expect(find.text('SAP SE'), findsOneWidget);
      expect(find.text('Mercedes-Benz Group AG'), findsOneWidget);
    });

    testWidgets('shows validation message for no results', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockSearchDialog(
              availableStocks: availableStocks,
              currentWatchlist: currentWatchlist,
              onStockSelected: (stock) {},
            ),
          ),
        ),
      );

      // Enter search query that won't match anything
      await tester.enterText(find.byType(TextField), 'NONEXISTENT');
      await tester.pump();

      // Verify validation message appears
      expect(find.textContaining('No stocks found matching'), findsOneWidget);
    });

    testWidgets('calls onStockSelected when stock is tapped', (WidgetTester tester) async {
      bool stockSelected = false;
      StockItem? selectedStock;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockSearchDialog(
              availableStocks: availableStocks,
              currentWatchlist: currentWatchlist,
              onStockSelected: (stock) {
                stockSelected = true;
                selectedStock = stock;
              },
            ),
          ),
        ),
      );

      // Tap on BASF stock
      await tester.tap(find.text('BASF SE'));
      await tester.pump();

      // Verify callback was called with correct stock
      expect(stockSelected, isTrue);
      expect(selectedStock?.id, equals('BASF11'));
      expect(selectedStock?.name, equals('BASF SE'));
    });

    testWidgets('shows search hints when no query entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockSearchDialog(
              availableStocks: availableStocks,
              currentWatchlist: currentWatchlist,
              onStockSelected: (stock) {},
            ),
          ),
        ),
      );

      // Verify search hints are shown
      expect(find.text('Search Tips:'), findsOneWidget);
      expect(find.textContaining('Company name'), findsOneWidget);
      expect(find.textContaining('Stock symbol'), findsOneWidget);
      expect(find.textContaining('ISIN code'), findsOneWidget);
    });
  });
}