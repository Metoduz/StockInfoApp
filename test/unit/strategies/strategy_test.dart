import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/strategies/trendline_strategy.dart';
import 'package:stockinfoapp/src/strategies/buy_area_strategy.dart';
import 'package:stockinfoapp/src/strategies/elliot_waves_strategy.dart';
import 'package:stockinfoapp/src/strategies/composite_strategy.dart';

void main() {
  group('StrategyType', () {
    test('should have correct display names from strategy classes', () {
      expect(StrategyType.trendline.displayName, equals('Trendline'));
      expect(StrategyType.elliotWaves.displayName, equals('Elliott Waves'));
      expect(StrategyType.buyArea.displayName, equals('Buy Area'));
      expect(StrategyType.composite.displayName, equals('Composite'));
    });
  });

  group('TrendlineStrategy', () {
    test('should create trendline strategy correctly', () {
      final strategy = TrendlineStrategy(
        id: 'trend-1',
        name: 'Test Trendline',
        supportLevel: 90.0,
        resistanceLevel: 110.0,
        trendDirection: TrendDirection.upward,
      );

      expect(strategy.id, equals('trend-1'));
      expect(strategy.name, equals('Test Trendline'));
      expect(strategy.type, equals(StrategyType.trendline));
      expect(strategy.supportLevel, equals(90.0));
      expect(strategy.resistanceLevel, equals(110.0));
    });

    test('should check trigger condition correctly for upward trend', () {
      final strategy = TrendlineStrategy(
        id: 'trend-1',
        name: 'Test Trendline',
        supportLevel: 90.0,
        resistanceLevel: 110.0,
        trendDirection: TrendDirection.upward,
      );

      expect(strategy.checkTriggerCondition({'currentPrice': 100.0}), isTrue);
      expect(strategy.checkTriggerCondition({'currentPrice': 85.0}), isFalse);
      expect(strategy.checkTriggerCondition({'currentPrice': 115.0}), isFalse);
    });

    test('should serialize and deserialize correctly', () {
      final originalStrategy = TrendlineStrategy(
        id: 'trend-1',
        name: 'Test Trendline',
        supportLevel: 90.0,
        resistanceLevel: 110.0,
        trendDirection: TrendDirection.upward,
      );

      final json = originalStrategy.toJson();
      final deserializedStrategy = TrendlineStrategy.fromJson(json);

      expect(deserializedStrategy.id, equals(originalStrategy.id));
      expect(deserializedStrategy.name, equals(originalStrategy.name));
      expect(deserializedStrategy.supportLevel, equals(originalStrategy.supportLevel));
      expect(deserializedStrategy.resistanceLevel, equals(originalStrategy.resistanceLevel));
      expect(deserializedStrategy.trendDirection, equals(originalStrategy.trendDirection));
    });
  });

  group('BuyAreaStrategy', () {
    test('should create buy area strategy correctly', () {
      final strategy = BuyAreaStrategy(
        id: 'buy-1',
        name: 'Test Buy Area',
        upperBound: 105.0,
        idealArea: 100.0,
        lowerBound: 95.0,
      );

      expect(strategy.id, equals('buy-1'));
      expect(strategy.name, equals('Test Buy Area'));
      expect(strategy.type, equals(StrategyType.buyArea));
      expect(strategy.upperBound, equals(105.0));
      expect(strategy.idealArea, equals(100.0));
      expect(strategy.lowerBound, equals(95.0));
    });

    test('should check trigger condition correctly', () {
      final strategy = BuyAreaStrategy(
        id: 'buy-1',
        name: 'Test Buy Area',
        upperBound: 105.0,
        idealArea: 100.0,
        lowerBound: 95.0,
      );

      expect(strategy.checkTriggerCondition({'currentPrice': 100.0}), isTrue);
      expect(strategy.checkTriggerCondition({'currentPrice': 90.0}), isFalse);
      expect(strategy.checkTriggerCondition({'currentPrice': 110.0}), isFalse);
    });

    test('should provide buy recommendations', () {
      final strategy = BuyAreaStrategy(
        id: 'buy-1',
        name: 'Test Buy Area',
        upperBound: 105.0,
        idealArea: 100.0,
        lowerBound: 95.0,
      );

      expect(strategy.getBuyRecommendation(100.0), contains('ideal'));
      expect(strategy.getBuyRecommendation(90.0), contains('Below buy area'));
      expect(strategy.getBuyRecommendation(110.0), contains('Above buy area'));
    });
  });

  group('CompositeStrategy', () {
    test('should create composite strategy correctly', () {
      final trendStrategy = TrendlineStrategy(
        id: 'trend-1',
        name: 'Test Trendline',
        supportLevel: 90.0,
        resistanceLevel: 110.0,
        trendDirection: TrendDirection.upward,
      );

      final buyStrategy = BuyAreaStrategy(
        id: 'buy-1',
        name: 'Test Buy Area',
        upperBound: 105.0,
        idealArea: 100.0,
        lowerBound: 95.0,
      );

      final composite = CompositeStrategy(
        id: 'comp-1',
        name: 'Test Composite',
        conditions: [
          StrategyCondition(strategy: trendStrategy),
          StrategyCondition(strategy: buyStrategy, operator: LogicalOperator.and),
        ],
        rootOperator: LogicalOperator.and,
      );

      expect(composite.id, equals('comp-1'));
      expect(composite.name, equals('Test Composite'));
      expect(composite.type, equals(StrategyType.composite));
      expect(composite.conditions.length, equals(2));
    });

    test('should evaluate AND conditions correctly', () {
      final trendStrategy = TrendlineStrategy(
        id: 'trend-1',
        name: 'Test Trendline',
        supportLevel: 90.0,
        resistanceLevel: 110.0,
        trendDirection: TrendDirection.upward,
      );

      final buyStrategy = BuyAreaStrategy(
        id: 'buy-1',
        name: 'Test Buy Area',
        upperBound: 105.0,
        idealArea: 100.0,
        lowerBound: 95.0,
      );

      final composite = CompositeStrategy(
        id: 'comp-1',
        name: 'Test Composite',
        conditions: [
          StrategyCondition(strategy: trendStrategy),
          StrategyCondition(strategy: buyStrategy, operator: LogicalOperator.and),
        ],
        rootOperator: LogicalOperator.and,
      );

      // Both conditions should be true
      expect(composite.checkTriggerCondition({'currentPrice': 100.0}), isTrue);
      
      // Only one condition true
      expect(composite.checkTriggerCondition({'currentPrice': 85.0}), isFalse);
    });

    test('should get description correctly', () {
      final trendStrategy = TrendlineStrategy(
        id: 'trend-1',
        name: 'Test Trendline',
        supportLevel: 90.0,
        resistanceLevel: 110.0,
        trendDirection: TrendDirection.upward,
      );

      final buyStrategy = BuyAreaStrategy(
        id: 'buy-1',
        name: 'Test Buy Area',
        upperBound: 105.0,
        idealArea: 100.0,
        lowerBound: 95.0,
      );

      final composite = CompositeStrategy(
        id: 'comp-1',
        name: 'Test Composite',
        conditions: [
          StrategyCondition(strategy: trendStrategy),
          StrategyCondition(strategy: buyStrategy, operator: LogicalOperator.and),
        ],
        rootOperator: LogicalOperator.and,
      );

      final description = composite.getDescription();
      expect(description, contains('Trendline'));
      expect(description, contains('AND'));
      expect(description, contains('Buy Area'));
    });
  });
}