import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/strategies/trendline_strategy.dart';
import 'package:stockinfoapp/src/widgets/enhanced_asset_card.dart';

void main() {
  group('Asset Card Integration Tests', () {
    late AssetItem testAsset;

    setUp(() {
      testAsset = AssetItem(
        id: 'TEST001',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.internal,
        strategies: [],
      );
    });

    testWidgets('should call onAddStrategy callback when Add Strategy button is tapped', (WidgetTester tester) async {
      bool addStrategyCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: testAsset,
              onAddStrategy: () {
                addStrategyCalled = true;
              },
            ),
          ),
        ),
      );

      // Expand the strategies section to see the Add Strategy button
      await tester.tap(find.text('Strategies'));
      await tester.pumpAndSettle();

      // Find and tap the Add Strategy button
      expect(find.text('Add Strategy'), findsOneWidget);
      await tester.tap(find.text('Add Strategy'));
      await tester.pumpAndSettle();

      expect(addStrategyCalled, isTrue);
    });

    testWidgets('should display existing strategies in the asset card', (WidgetTester tester) async {
      // Create an asset with a strategy
      final strategy = TradingStrategyItem(
        id: 'strategy1',
        strategy: TrendlineStrategy(
          id: 'trendline1',
          name: 'Test Strategy',
          supportLevel: 95.0,
          resistanceLevel: 105.0,
          trendDirection: TrendDirection.upward,
        ),
        direction: TradeDirection.long,
        alertEnabled: false,
        created: DateTime.now(),
      );

      final assetWithStrategy = testAsset.copyWith(strategies: [strategy]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: assetWithStrategy,
              onAddStrategy: () {},
            ),
          ),
        ),
      );

      // Expand the strategies section
      await tester.tap(find.text('Strategies'));
      await tester.pumpAndSettle();

      // Verify the strategy is displayed
      expect(find.text('Test Strategy'), findsOneWidget);
      expect(find.text('Add Strategy'), findsOneWidget); // Should still show add button
    });

    testWidgets('should show strategies count badge when strategies exist', (WidgetTester tester) async {
      // Create an asset with multiple strategies
      final strategies = [
        TradingStrategyItem(
          id: 'strategy1',
          strategy: TrendlineStrategy(
            id: 'trendline1',
            name: 'Strategy 1',
            supportLevel: 95.0,
            resistanceLevel: 105.0,
            trendDirection: TrendDirection.upward,
          ),
          direction: TradeDirection.long,
          alertEnabled: false,
          created: DateTime.now(),
        ),
        TradingStrategyItem(
          id: 'strategy2',
          strategy: TrendlineStrategy(
            id: 'trendline2',
            name: 'Strategy 2',
            supportLevel: 90.0,
            resistanceLevel: 110.0,
            trendDirection: TrendDirection.downward,
          ),
          direction: TradeDirection.short,
          alertEnabled: true,
          created: DateTime.now(),
        ),
      ];

      final assetWithStrategies = testAsset.copyWith(strategies: strategies);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedAssetCard(
              asset: assetWithStrategies,
              onAddStrategy: () {},
            ),
          ),
        ),
      );

      // Verify the strategies count badge is displayed
      expect(find.text('2'), findsOneWidget); // Count badge
      expect(find.text('Strategies'), findsOneWidget); // Section title
    });

    test('should update asset with new strategy using copyWith method', () {
      // Create a new strategy
      final strategy = TradingStrategyItem(
        id: 'new_strategy',
        strategy: TrendlineStrategy(
          id: 'trendline_new',
          name: 'New Strategy',
          supportLevel: 98.0,
          resistanceLevel: 102.0,
          trendDirection: TrendDirection.upward,
        ),
        direction: TradeDirection.long,
        alertEnabled: false,
        created: DateTime.now(),
      );

      // Update asset with new strategy
      final updatedAsset = testAsset.copyWith(
        strategies: [...testAsset.strategies, strategy],
      );

      // Verify the strategy was added
      expect(updatedAsset.strategies.length, equals(1));
      expect(updatedAsset.strategies.first.id, equals('new_strategy'));
      expect(updatedAsset.strategies.first.strategy.name, equals('New Strategy'));
      
      // Verify original asset is unchanged
      expect(testAsset.strategies.length, equals(0));
    });
  });
}