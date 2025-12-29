import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/strategies/trendline_strategy.dart';
import 'package:stockinfoapp/src/models/active_trade.dart';

void main() {
  group('AssetItem', () {
    test('should create asset item with basic properties', () {
      final asset = AssetItem(
        id: 'test-id',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        assetType: AssetType.stock,
        tags: ['tech', 'growth'],
      );

      expect(asset.id, equals('test-id'));
      expect(asset.name, equals('Test Asset'));
      expect(asset.assetType, equals(AssetType.stock));
      expect(asset.tags, equals(['tech', 'growth']));
    });

    test('should filter tags correctly with overflow', () {
      final asset = AssetItem(
        id: 'test-id',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        tags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5', 'tag6', 'tag7', 'tag8', 'tag9'],
      );

      final filteredTags = asset.getFilteredTags(maxRows: 2, itemsPerRow: 4);
      expect(filteredTags.length, equals(7)); // 8 - 1 for overflow indicator
      expect(asset.hasOverflowTags(maxRows: 2, itemsPerRow: 4), isTrue);
    });

    test('should calculate performance metrics correctly', () {
      final activeTrade = ActiveTradeItem(
        id: 'trade-1',
        assetId: 'test-id',
        direction: TradeDirection.long,
        quantity: 10,
        buyPrice: 90.0,
        openDate: DateTime.now(),
      );

      final asset = AssetItem(
        id: 'test-id',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        activeTrades: [activeTrade],
      );

      expect(asset.getTotalPositionValue(), equals(900.0)); // 10 * 90
      expect(asset.getTotalPnL(), equals(100.0)); // (100 - 90) * 10
      expect(asset.getOpenTradesPerformance(), closeTo(11.11, 0.01)); // 100/900 * 100
    });

    test('should add and remove tags correctly', () {
      final asset = AssetItem(
        id: 'test-id',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        tags: ['tech'],
      );

      final withNewTag = asset.addTag('growth');
      expect(withNewTag.tags, equals(['tech', 'growth']));

      final withRemovedTag = withNewTag.removeTag('tech');
      expect(withRemovedTag.tags, equals(['growth']));
    });

    test('should serialize and deserialize correctly', () {
      final originalAsset = AssetItem(
        id: 'test-id',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        assetType: AssetType.crypto,
        tags: ['crypto', 'volatile'],
      );

      final json = originalAsset.toJson();
      final deserializedAsset = AssetItem.fromJson(json);

      expect(deserializedAsset.id, equals(originalAsset.id));
      expect(deserializedAsset.name, equals(originalAsset.name));
      expect(deserializedAsset.assetType, equals(originalAsset.assetType));
      expect(deserializedAsset.tags, equals(originalAsset.tags));
    });
  });

  group('AssetType', () {
    test('should have correct display names', () {
      expect(AssetType.stock.displayName, equals('Stock'));
      expect(AssetType.crypto.displayName, equals('Crypto'));
      expect(AssetType.cfd.displayName, equals('CFD'));
      expect(AssetType.resource.displayName, equals('Resource'));
      expect(AssetType.other.displayName, equals('Other'));
    });

    test('should have appropriate icon names', () {
      expect(AssetType.stock.iconName, equals('trending_up'));
      expect(AssetType.crypto.iconName, equals('currency_bitcoin'));
      expect(AssetType.cfd.iconName, equals('swap_horiz'));
      expect(AssetType.resource.iconName, equals('eco'));
      expect(AssetType.other.iconName, equals('help_outline'));
    });
  });
}