// Import strategy implementations
import 'trendline_strategy.dart';
import 'elliot_waves_strategy.dart';
import 'buy_area_strategy.dart';
import 'composite_strategy.dart';

/// Enum for different types of trading strategies
enum StrategyType {
  trendline,
  elliotWaves,
  buyArea,
  composite;

  /// Get display name for the strategy type from the actual strategy class
  String get displayName {
    switch (this) {
      case StrategyType.trendline:
        return TrendlineStrategy.strategyName;
      case StrategyType.elliotWaves:
        return ElliotWavesStrategy.strategyName;
      case StrategyType.buyArea:
        return BuyAreaStrategy.strategyName;
      case StrategyType.composite:
        return CompositeStrategy.strategyName;
    }
  }
}

/// Enum for trade direction
enum TradeDirection {
  long,
  short;

  /// Get display name for the trade direction
  String get displayName {
    switch (this) {
      case TradeDirection.long:
        return 'Long';
      case TradeDirection.short:
        return 'Short';
    }
  }

  /// Get icon name for the trade direction
  String get iconName {
    switch (this) {
      case TradeDirection.long:
        return 'trending_up';
      case TradeDirection.short:
        return 'trending_down';
    }
  }
}

/// Enum for logical operators used in composite strategies
enum LogicalOperator {
  and,
  or;

  /// Get display name for the logical operator
  String get displayName {
    switch (this) {
      case LogicalOperator.and:
        return 'AND';
      case LogicalOperator.or:
        return 'OR';
    }
  }
}

/// Enum for trend direction used in trendline strategies
enum TrendDirection {
  upward,
  downward;

  String get displayName {
    switch (this) {
      case TrendDirection.upward:
        return 'Upward';
      case TrendDirection.downward:
        return 'Downward';
    }
  }
}

/// Base class for all trading strategies
abstract class TradingStrategy {
  String get id;
  String get name;
  StrategyType get type;
  Map<String, dynamic> get parameters;
  
  /// Static strategy name - to be overridden by each strategy
  static String get strategyName => 'Base Strategy';
  
  /// Check if the strategy trigger condition is met for the given asset
  bool checkTriggerCondition(Map<String, dynamic> assetData);
  
  /// Convert strategy to JSON for serialization
  Map<String, dynamic> toJson();
  
  /// Create strategy from JSON
  static TradingStrategy fromJson(Map<String, dynamic> json) {
    final type = StrategyType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => StrategyType.trendline,
    );
    
    switch (type) {
      case StrategyType.trendline:
        return TrendlineStrategy.fromJson(json);
      case StrategyType.elliotWaves:
        return ElliotWavesStrategy.fromJson(json);
      case StrategyType.buyArea:
        return BuyAreaStrategy.fromJson(json);
      case StrategyType.composite:
        return CompositeStrategy.fromJson(json);
    }
  }
}

/// Represents a condition in a composite strategy
class StrategyCondition {
  final TradingStrategy strategy;
  final LogicalOperator? operator; // null for first condition

  StrategyCondition({
    required this.strategy,
    this.operator,
  });

  Map<String, dynamic> toJson() {
    return {
      'strategy': strategy.toJson(),
      'operator': operator?.name,
    };
  }

  factory StrategyCondition.fromJson(Map<String, dynamic> json) {
    return StrategyCondition(
      strategy: TradingStrategy.fromJson(json['strategy']),
      operator: json['operator'] != null 
          ? LogicalOperator.values.firstWhere((e) => e.name == json['operator'])
          : null,
    );
  }
}

/// Trading strategy item that wraps a strategy with additional metadata
class TradingStrategyItem {
  final String id;
  final TradingStrategy strategy;
  final TradeDirection direction;
  final bool alertEnabled;
  final DateTime created;
  final DateTime? lastTriggered;

  TradingStrategyItem({
    required this.id,
    required this.strategy,
    required this.direction,
    this.alertEnabled = false,
    required this.created,
    this.lastTriggered,
  });

  /// Toggle alert enabled state
  TradingStrategyItem toggleAlert() {
    return copyWith(alertEnabled: !alertEnabled);
  }

  /// Mark strategy as triggered
  TradingStrategyItem markTriggered() {
    return copyWith(lastTriggered: DateTime.now());
  }

  /// Check if strategy conditions are met
  bool checkTriggerCondition(Map<String, dynamic> assetData) {
    return strategy.checkTriggerCondition(assetData);
  }

  TradingStrategyItem copyWith({
    String? id,
    TradingStrategy? strategy,
    TradeDirection? direction,
    bool? alertEnabled,
    DateTime? created,
    DateTime? lastTriggered,
  }) {
    return TradingStrategyItem(
      id: id ?? this.id,
      strategy: strategy ?? this.strategy,
      direction: direction ?? this.direction,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      created: created ?? this.created,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'strategy': strategy.toJson(),
      'direction': direction.name,
      'alertEnabled': alertEnabled,
      'created': created.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
    };
  }

  factory TradingStrategyItem.fromJson(Map<String, dynamic> json) {
    return TradingStrategyItem(
      id: json['id'] as String,
      strategy: TradingStrategy.fromJson(json['strategy']),
      direction: TradeDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => TradeDirection.long,
      ),
      alertEnabled: json['alertEnabled'] as bool? ?? false,
      created: DateTime.parse(json['created'] as String),
      lastTriggered: json['lastTriggered'] != null 
          ? DateTime.parse(json['lastTriggered'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'TradingStrategyItem{id: $id, type: ${strategy.type}, direction: $direction, alertEnabled: $alertEnabled}';
  }
}