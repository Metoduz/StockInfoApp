import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/widgets/asset_search_dialog.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';

void main() {
  group('AssetSearchDialog', () {
    late List<AssetItem> availableAssets;
    late List<AssetItem> currentWatchlist;

    setUp(() {
      availableAssets = [
        AssetItem(
          id: 'BASF11',
          isin: 'DE000BASF111',
          name: 'BASF SE',
          symbol: 'BAS',
          currentValue: 45.23,
          previousClose: 44.80,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: AssetIdentifierType.isin,
          isInWatchlist: false,
        ),
        AssetItem(
          id: 'SAP',
          isin: 'DE0007164600',
          name: 'SAP SE',
          symbol: 'SAP',
          currentValue: 178.65,
          previousClose: 180.20,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: AssetIdentifierType.isin,
          isInWatchlist: false,
        ),
        AssetItem(
          id: 'MBG',
          isin: 'DE0007100000',
          name: 'Mercedes-Benz Group AG',
          symbol: 'MBG',
          currentValue: 68.91,
          previousClose: 67.50,
          currency: 'EUR',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: AssetIdentifierType.isin,
          isInWatchlist: false,
        ),
      ];

      currentWatchlist = [
        AssetItem(
          id: 'AAPL',
          isin: 'US0378331005',
          name: 'Apple Inc.',
          symbol: 'AAPL',
          currentValue: 150.00,
          currency: 'USD',
          lastUpdated: DateTime.now(),
          primaryIdentifierType: AssetIdentifierType.isin,
          isInWatchlist: true,
        ),
      ];
    });

    testWidgets('displays search field and available assets', (WidgetTester tester) async {
      bool assetSelected = false;
      AssetItem? selectedAsset;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetSearchDialog(
              availableAssets: availableAssets,
              currentWatchlist: currentWatchlist,
              onAssetSelected: (asset) {
                assetSelected = true;
                selectedAsset = asset;
              },
            ),
          ),
        ),
      );

      // Verify search field is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search assets'), findsOneWidget);

      // Verify available assets are displayed (excluding watchlist items)
      expect(find.text('BASF SE'), findsOneWidget);
      expect(find.text('SAP SE'), findsOneWidget);
      expect(find.text('Mercedes-Benz Group AG'), findsOneWidget);
      
      // Verify watchlist asset is not displayed
      expect(find.text('Apple Inc.'), findsNothing);
    });

    testWidgets('filters assets based on search query', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetSearchDialog(
              availableAssets: availableAssets,
              currentWatchlist: currentWatchlist,
              onAssetSelected: (asset) {},
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

    testWidgets('prevents duplicate asset selection', (WidgetTester tester) async {
      // Add BASF to watchlist to test duplicate prevention
      final watchlistWithBasf = [
        ...currentWatchlist,
        availableAssets[0].addToWatchlist(),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetSearchDialog(
              availableAssets: availableAssets,
              currentWatchlist: watchlistWithBasf,
              onAssetSelected: (asset) {},
            ),
          ),
        ),
      );

      // BASF should not be available for selection
      expect(find.text('BASF SE'), findsNothing);
      
      // Other assets should still be available
      expect(find.text('SAP SE'), findsOneWidget);
      expect(find.text('Mercedes-Benz Group AG'), findsOneWidget);
    });

    testWidgets('shows validation message for no results', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetSearchDialog(
              availableAssets: availableAssets,
              currentWatchlist: currentWatchlist,
              onAssetSelected: (asset) {},
            ),
          ),
        ),
      );

      // Enter search query that won't match anything
      await tester.enterText(find.byType(TextField), 'NONEXISTENT');
      await tester.pump();

      // Verify validation message appears
      expect(find.textContaining('No assets found matching'), findsOneWidget);
    });

    testWidgets('calls onAssetSelected when asset is tapped', (WidgetTester tester) async {
      bool assetSelected = false;
      AssetItem? selectedAsset;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetSearchDialog(
              availableAssets: availableAssets,
              currentWatchlist: currentWatchlist,
              onAssetSelected: (asset) {
                assetSelected = true;
                selectedAsset = asset;
              },
            ),
          ),
        ),
      );

      // Tap on BASF asset
      await tester.tap(find.text('BASF SE'));
      await tester.pump();

      // Verify callback was called with correct asset
      expect(assetSelected, isTrue);
      expect(selectedAsset?.id, equals('BASF11'));
      expect(selectedAsset?.name, equals('BASF SE'));
    });

    testWidgets('shows search hints when no query entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AssetSearchDialog(
              availableAssets: availableAssets,
              currentWatchlist: currentWatchlist,
              onAssetSelected: (asset) {},
            ),
          ),
        ),
      );

      // Verify search hints are shown
      expect(find.text('Search Tips:'), findsOneWidget);
      expect(find.textContaining('Company name'), findsOneWidget);
      expect(find.textContaining('Asset symbol'), findsOneWidget);
      expect(find.textContaining('ISIN code'), findsOneWidget);
    });
  });
}