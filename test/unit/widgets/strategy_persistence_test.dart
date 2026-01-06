import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/models/asset_item.dart';
import '../../../lib/src/strategies/trading_strategy_base.dart';
import '../../../lib/src/strategies/trendline_strategy.dart';
import '../../../lib/src/strategies/buy_area_strategy.dart';

void main() {
  group('Strategy Creation and Persistence', () {
    late AssetItem testAsset;

    setUp(() {
      testAsset = AssetItem(
        id: 'TEST001',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
      );
    });

    test('asset addStrategy method works correctly', () {
      // Create a test strategy
      final strategy = TradingStrategyItem(
        id: 'test-strategy-1',
        strategy: TrendlineStrategy(
          id: 'trendline-1',
          name: 'Test Strategy',
          supportLevel: 95.0,
          resistanceLevel: 105.0,
          trendDirection: TrendDirection.upward,
        ),
        direction: TradeDirection.long,
        alertEnabled: false,
        created: DateTime.now(),
      );

      // Add strategy to asset
      final updatedAsset = testAsset.addStrategy(strategy);

      // Verify strategy was added
      expect(updatedAsset.strategies.length, 1);
      expect(updatedAsset.strategies.first.id, 'test-strategy-1');
      expect(updatedAsset.strategies.first.strategy.name, 'Test Strategy');

      // Verify original asset is unchanged (immutability)
      expect(testAsset.strategies.length, 0);
    });

    test('strategy creation factory methods work correctly', () {
      // Test Trendline Strategy creation
      final trendlineStrategy = TrendlineStrategy(
        id: 'trendline-1',
        name: 'Test Trendline',
        supportLevel: 95.0,
        resistanceLevel: 105.0,
        trendDirection: TrendDirection.upward,
      );

      expect(trendlineStrategy.name, 'Test Trendline');
      expect(trendlineStrategy.type, StrategyType.trendline);
      expect(trendlineStrategy.supportLevel, 95.0);
      expect(trendlineStrategy.resistanceLevel, 105.0);

      // Test Buy Area Strategy creation
      final buyAreaStrategy = BuyAreaStrategy(
        id: 'buyarea-1',
        name: 'Test Buy Area',
        lowerBound: 90.0,
        idealArea: 95.0,
        upperBound: 100.0,
      );

      expect(buyAreaStrategy.name, 'Test Buy Area');
      expect(buyAreaStrategy.type, StrategyType.buyArea);
      expect(buyAreaStrategy.lowerBound, 90.0);
      expect(buyAreaStrategy.idealArea, 95.0);
      expect(buyAreaStrategy.upperBound, 100.0);
    });

    test('multiple strategies can be added to asset', () {
      // Create multiple strategies
      final strategy1 = TradingStrategyItem(
        id: 'strategy-1',
        strategy: TrendlineStrategy(
          id: 'trendline-1',
          name: 'Trendline Strategy',
          supportLevel: 95.0,
          resistanceLevel: 105.0,
          trendDirection: TrendDirection.upward,
        ),
        direction: TradeDirection.long,
        alertEnabled: false,
        created: DateTime.now(),
      );

      final strategy2 = TradingStrategyItem(
        id: 'strategy-2',
        strategy: BuyAreaStrategy(
          id: 'buyarea-1',
          name: 'Buy Area Strategy',
          lowerBound: 90.0,
          idealArea: 95.0,
          upperBound: 100.0,
        ),
        direction: TradeDirection.long,
        alertEnabled: true,
        created: DateTime.now(),
      );

      // Add strategies sequentially
      final assetWithStrategy1 = testAsset.addStrategy(strategy1);
      final assetWithBothStrategies = assetWithStrategy1.addStrategy(strategy2);

      // Verify both strategies are present
      expect(assetWithBothStrategies.strategies.length, 2);
      expect(assetWithBothStrategies.strategies[0].id, 'strategy-1');
      expect(assetWithBothStrategies.strategies[1].id, 'strategy-2');
      expect(assetWithBothStrategies.strategies[1].alertEnabled, true);

      // Verify original asset is unchanged
      expect(testAsset.strategies.length, 0);
    });

    test('asset serialization includes strategies', () {
      // Create asset with strategy
      final strategy = TradingStrategyItem(
        id: 'test-strategy',
        strategy: TrendlineStrategy(
          id: 'trendline-1',
          name: 'Test Strategy',
          supportLevel: 95.0,
          resistanceLevel: 105.0,
          trendDirection: TrendDirection.upward,
        ),
        direction: TradeDirection.long,
        alertEnabled: false,
        created: DateTime.now(),
      );

      final assetWithStrategy = testAsset.addStrategy(strategy);

      // Serialize to JSON
      final json = assetWithStrategy.toJson();

      // Verify strategies are included in JSON
      expect(json['strategies'], isA<List>());
      expect(json['strategies'].length, 1);
      expect(json['strategies'][0]['id'], 'test-strategy');

      // Deserialize from JSON
      final deserializedAsset = AssetItem.fromJson(json);

      // Verify strategies are preserved
      expect(deserializedAsset.strategies.length, 1);
      expect(deserializedAsset.strategies.first.id, 'test-strategy');
      expect(deserializedAsset.strategies.first.strategy.name, 'Test Strategy');
    });
  });
}