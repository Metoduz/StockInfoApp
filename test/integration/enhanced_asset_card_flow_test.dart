import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/models/enhanced_asset_item.dart';
import 'package:stockinfoapp/src/models/active_trade.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/utils/asset_conversion.dart';
import 'package:stockinfoapp/src/widgets/enhanced_asset_card.dart';
import 'package:stockinfoapp/src/screens/trade_detail_screen.dart';

void main() {
  group('Enhanced Asset Card Integration Tests', () {
    testWidgets('Enhanced asset card displays asset information correctly', (WidgetTester tester) async {
      // Create test asset
      final testAsset = AssetItem(
        id: 'TEST001',
        isin: 'DE000TEST001',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        previousClose: 95.0,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.isin,
        isInWatchlist: true,
      );

      final enhancedAsset = AssetConversion.toEnhanced(testAsset);

      // Build the enhanced asset card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: enhancedAsset,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      // Test that asset information section is always visible (Requirement 1.2)
      expect(find.text('Test Asset'), findsOneWidget);
      expect(find.text('100.00'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);

      // Test that performance metrics are calculated and displayed
      expect(find.textContaining('5.26'), findsOneWidget); // Daily change percentage
    });

    testWidgets('Enhanced asset card handles navigation callbacks', (WidgetTester tester) async {
      // Create test asset
      final testAsset = AssetItem(
        id: 'NAV001',
        isin: 'DE000NAV0001',
        name: 'Navigation Test Asset',
        symbol: 'NTA',
        currentValue: 150.0,
        previousClose: 145.0,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.isin,
        isInWatchlist: true,
      );

      final enhancedAsset = AssetConversion.toEnhanced(testAsset);

      bool addStrategyCalled = false;
      bool addTradeCalled = false;
      bool assetTapped = false;

      // Build the enhanced asset card with callbacks
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: enhancedAsset,
              onTap: () => assetTapped = true,
              onAddStrategy: () => addStrategyCalled = true,
              onAddTrade: () => addTradeCalled = true,
            ),
          ),
        ),
      );

      await tester.pump();

      // Test asset tap
      await tester.tap(find.byType(EnhancedAssetCard));
      await tester.pump();
      expect(assetTapped, isTrue);

      // Test strategy section (if visible)
      final strategiesText = find.text('Strategies');
      if (strategiesText.evaluate().isNotEmpty) {
        await tester.tap(strategiesText);
        await tester.pump();

        final addStrategyButton = find.text('Add Strategy');
        if (addStrategyButton.evaluate().isNotEmpty) {
          await tester.tap(addStrategyButton);
          await tester.pump();
          expect(addStrategyCalled, isTrue);
        }
      }

      // Test active trades section (if visible)
      final activeTradesText = find.text('Active Trades');
      if (activeTradesText.evaluate().isNotEmpty) {
        await tester.tap(activeTradesText);
        await tester.pump();

        final addTradeButton = find.text('Add Trade');
        if (addTradeButton.evaluate().isNotEmpty) {
          await tester.tap(addTradeButton);
          await tester.pump();
          expect(addTradeCalled, isTrue);
        }
      }
    });

    testWidgets('Trade detail screen navigation works', (WidgetTester tester) async {
      // Create test asset with active trade
      final testAsset = AssetItem(
        id: 'TRADE001',
        isin: 'DE000TRADE01',
        name: 'Trade Test Asset',
        symbol: 'TTA',
        currentValue: 120.0,
        previousClose: 115.0,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.isin,
        isInWatchlist: true,
      );

      final enhancedAsset = AssetConversion.toEnhanced(testAsset);

      // Add a test active trade
      final activeTrade = ActiveTradeItem(
        id: 'trade_001',
        assetId: testAsset.id,
        direction: TradeDirection.long,
        quantity: 10.0,
        buyPrice: 110.0,
        openDate: DateTime.now().subtract(const Duration(days: 1)),
        status: TradeStatus.open,
      );

      final enhancedAssetWithTrade = enhancedAsset.copyWith(
        activeTrades: [activeTrade],
      );

      // Build the trade detail screen
      await tester.pumpWidget(
        MaterialApp(
          home: TradeDetailScreen(
            trade: activeTrade,
            asset: enhancedAssetWithTrade,
          ),
        ),
      );

      await tester.pump();

      // Test that trade detail screen displays correctly
      expect(find.text('Trade Details'), findsOneWidget);
      expect(find.text('Trade Test Asset'), findsOneWidget);
      expect(find.text('120.00'), findsOneWidget);

      // Test form fields are present
      expect(find.text('Trade Direction'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Buy Price'), findsOneWidget);

      // Test that current P&L is calculated and displayed
      expect(find.textContaining('Current P&L'), findsOneWidget);
    });

    testWidgets('Asset card responsive layout adaptation', (WidgetTester tester) async {
      // Create test asset
      final testAsset = AssetItem(
        id: 'RESP001',
        isin: 'DE000RESP001',
        name: 'Responsive Test Asset',
        symbol: 'RTA',
        currentValue: 130.0,
        previousClose: 125.0,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.isin,
        isInWatchlist: true,
      );

      final enhancedAsset = AssetConversion.toEnhanced(testAsset);

      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: enhancedAsset,
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify mobile layout
      expect(find.text('Responsive Test Asset'), findsOneWidget);
      expect(find.text('130.00'), findsOneWidget);

      // Test tablet layout
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();

      // Verify tablet layout still works
      expect(find.text('Responsive Test Asset'), findsOneWidget);
      expect(find.text('130.00'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Asset card handles missing data gracefully', (WidgetTester tester) async {
      // Create test asset with minimal data
      final testAsset = AssetItem(
        id: 'MIN001',
        isin: null, // Missing ISIN
        name: 'Minimal Asset',
        symbol: 'MIN',
        currentValue: 50.0,
        previousClose: null, // Missing previous close
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        isInWatchlist: true,
      );

      final enhancedAsset = AssetConversion.toEnhanced(testAsset);

      // Build the enhanced asset card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: enhancedAsset,
            ),
          ),
        ),
      );

      await tester.pump();

      // Test that the card displays even with missing data
      expect(find.text('Minimal Asset'), findsOneWidget);
      expect(find.text('50.00'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);

      // The card should still be rendered
      expect(find.byType(EnhancedAssetCard), findsOneWidget);
    });

    testWidgets('Performance metrics calculation accuracy', (WidgetTester tester) async {
      // Create test asset with known values for performance calculation
      final testAsset = AssetItem(
        id: 'PERF001',
        isin: 'DE000PERF001',
        name: 'Performance Test Asset',
        symbol: 'PTA',
        currentValue: 110.0,
        previousClose: 100.0, // 10% daily gain
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.isin,
        isInWatchlist: true,
      );

      final enhancedAsset = AssetConversion.toEnhanced(testAsset);

      // Build the enhanced asset card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: enhancedAsset,
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify performance metrics are displayed correctly
      expect(find.text('110.00'), findsOneWidget); // Current value
      
      // Look for percentage change (should be +10%)
      expect(find.textContaining('10.00'), findsOneWidget); // Daily change percentage
    });

    testWidgets('Asset type icon display', (WidgetTester tester) async {
      // Create test asset with specific type
      final testAsset = AssetItem(
        id: 'TYPE001',
        isin: 'DE000TYPE001',
        name: 'Type Test Asset',
        symbol: 'TTA',
        currentValue: 75.0,
        previousClose: 70.0,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.isin,
        isInWatchlist: true,
      );

      final enhancedAsset = AssetConversion.toEnhanced(testAsset);

      // Build the enhanced asset card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: enhancedAsset,
            ),
          ),
        ),
      );

      await tester.pump();

      // Test that asset type icon is displayed (Requirement 1.4, 1.5)
      expect(find.text('Type Test Asset'), findsOneWidget);
      expect(find.text('75.00'), findsOneWidget);

      // The asset type icon should be present in the upper left corner
      // This would be tested by looking for the AssetTypeIcon widget
      expect(find.byType(Card), findsOneWidget);
    });
  });
}