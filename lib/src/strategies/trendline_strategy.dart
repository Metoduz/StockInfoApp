import 'trading_strategy_base.dart';

/// Trendline strategy implementation
class TrendlineStrategy extends TradingStrategy {
  @override
  final String id;
  
  @override
  final String name;
  
  final double supportLevel;
  final double resistanceLevel;
  final TrendDirection trendDirection;
  
  /// Static strategy name for consistent naming
  static const String strategyName = 'Trendline';
  
  TrendlineStrategy({
    required this.id,
    required this.name,
    required this.supportLevel,
    required this.resistanceLevel,
    required this.trendDirection,
  });

  @override
  StrategyType get type => StrategyType.trendline;

  @override
  Map<String, dynamic> get parameters => {
    'supportLevel': supportLevel,
    'resistanceLevel': resistanceLevel,
    'trendDirection': trendDirection.name,
  };

  @override
  bool checkTriggerCondition(Map<String, dynamic> assetData) {
    final currentPrice = assetData['currentPrice'] as double?;
    if (currentPrice == null) return false;

    switch (trendDirection) {
      case TrendDirection.upward:
        return currentPrice >= supportLevel && currentPrice <= resistanceLevel;
      case TrendDirection.downward:
        return currentPrice <= resistanceLevel && currentPrice >= supportLevel;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'supportLevel': supportLevel,
      'resistanceLevel': resistanceLevel,
      'trendDirection': trendDirection.name,
    };
  }

  factory TrendlineStrategy.fromJson(Map<String, dynamic> json) {
    return TrendlineStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      supportLevel: (json['supportLevel'] as num).toDouble(),
      resistanceLevel: (json['resistanceLevel'] as num).toDouble(),
      trendDirection: TrendDirection.values.firstWhere(
        (e) => e.name == json['trendDirection'],
        orElse: () => TrendDirection.upward,
      ),
    );
  }

  TrendlineStrategy copyWith({
    String? id,
    String? name,
    double? supportLevel,
    double? resistanceLevel,
    TrendDirection? trendDirection,
  }) {
    return TrendlineStrategy(
      id: id ?? this.id,
      name: name ?? this.name,
      supportLevel: supportLevel ?? this.supportLevel,
      resistanceLevel: resistanceLevel ?? this.resistanceLevel,
      trendDirection: trendDirection ?? this.trendDirection,
    );
  }

  @override
  String toString() {
    return 'TrendlineStrategy{id: $id, name: $name, support: $supportLevel, resistance: $resistanceLevel, trend: $trendDirection}';
  }
}