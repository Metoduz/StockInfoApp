import 'trading_strategy_base.dart';

/// Buy Area strategy implementation
class BuyAreaStrategy extends TradingStrategy {
  @override
  final String id;
  
  @override
  final String name;
  
  final double upperBound;
  final double idealArea;
  final double lowerBound;
  
  /// Static strategy name for consistent naming
  static const String strategyName = 'Buy Area';
  
  BuyAreaStrategy({
    required this.id,
    required this.name,
    required this.upperBound,
    required this.idealArea,
    required this.lowerBound,
  });

  @override
  StrategyType get type => StrategyType.buyArea;

  @override
  Map<String, dynamic> get parameters => {
    'upperBound': upperBound,
    'idealArea': idealArea,
    'lowerBound': lowerBound,
  };

  @override
  bool checkTriggerCondition(Map<String, dynamic> assetData) {
    final currentPrice = assetData['currentPrice'] as double?;
    if (currentPrice == null) return false;

    // Check if current price is within the buy area
    return currentPrice >= lowerBound && currentPrice <= upperBound;
  }

  /// Check if current price is in the ideal buy area
  bool isInIdealArea(double currentPrice) {
    final tolerance = (upperBound - lowerBound) * 0.1; // 10% tolerance around ideal area
    return (currentPrice - idealArea).abs() <= tolerance;
  }

  /// Get the distance from ideal area as a percentage
  double getDistanceFromIdeal(double currentPrice) {
    if (idealArea == 0) return 0.0;
    return ((currentPrice - idealArea) / idealArea) * 100;
  }

  /// Get buy recommendation based on current price
  String getBuyRecommendation(double currentPrice) {
    if (currentPrice < lowerBound) {
      return 'Below buy area - Wait for entry';
    } else if (currentPrice > upperBound) {
      return 'Above buy area - Consider waiting';
    } else if (isInIdealArea(currentPrice)) {
      return 'In ideal buy area - Strong buy signal';
    } else if (currentPrice < idealArea) {
      return 'Below ideal area - Good buy opportunity';
    } else {
      return 'Above ideal area - Moderate buy signal';
    }
  }

  /// Calculate the buy area range as a percentage
  double getBuyAreaRangePercent() {
    if (lowerBound == 0) return 0.0;
    return ((upperBound - lowerBound) / lowerBound) * 100;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'upperBound': upperBound,
      'idealArea': idealArea,
      'lowerBound': lowerBound,
    };
  }

  factory BuyAreaStrategy.fromJson(Map<String, dynamic> json) {
    return BuyAreaStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      upperBound: (json['upperBound'] as num).toDouble(),
      idealArea: (json['idealArea'] as num).toDouble(),
      lowerBound: (json['lowerBound'] as num).toDouble(),
    );
  }

  BuyAreaStrategy copyWith({
    String? id,
    String? name,
    double? upperBound,
    double? idealArea,
    double? lowerBound,
  }) {
    return BuyAreaStrategy(
      id: id ?? this.id,
      name: name ?? this.name,
      upperBound: upperBound ?? this.upperBound,
      idealArea: idealArea ?? this.idealArea,
      lowerBound: lowerBound ?? this.lowerBound,
    );
  }

  @override
  String toString() {
    return 'BuyAreaStrategy{id: $id, name: $name, range: $lowerBound-$upperBound, ideal: $idealArea}';
  }
}