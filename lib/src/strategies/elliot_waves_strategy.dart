import 'trading_strategy_base.dart';

/// Elliott Waves strategy implementation
class ElliotWavesStrategy extends TradingStrategy {
  @override
  final String id;
  
  @override
  final String name;
  
  final int currentWave;
  final double waveTarget;
  final List<double> waveLevels;
  
  /// Static strategy name for consistent naming
  static const String strategyName = 'Elliott Waves';
  
  ElliotWavesStrategy({
    required this.id,
    required this.name,
    required this.currentWave,
    required this.waveTarget,
    required this.waveLevels,
  });

  @override
  StrategyType get type => StrategyType.elliotWaves;

  @override
  Map<String, dynamic> get parameters => {
    'currentWave': currentWave,
    'waveTarget': waveTarget,
    'waveLevels': waveLevels,
  };

  @override
  bool checkTriggerCondition(Map<String, dynamic> assetData) {
    final currentPrice = assetData['currentPrice'] as double?;
    if (currentPrice == null) return false;

    // Check if current price is near the target for the current wave
    final tolerance = waveTarget * 0.02; // 2% tolerance
    return (currentPrice - waveTarget).abs() <= tolerance;
  }

  /// Get the current wave description
  String getCurrentWaveDescription() {
    switch (currentWave) {
      case 1:
        return 'Wave 1 - Initial impulse';
      case 2:
        return 'Wave 2 - Corrective retracement';
      case 3:
        return 'Wave 3 - Strong impulse';
      case 4:
        return 'Wave 4 - Corrective retracement';
      case 5:
        return 'Wave 5 - Final impulse';
      default:
        return 'Wave $currentWave';
    }
  }

  /// Check if the current wave is an impulse wave (1, 3, 5)
  bool isImpulseWave() {
    return currentWave % 2 == 1;
  }

  /// Check if the current wave is a corrective wave (2, 4)
  bool isCorrectiveWave() {
    return currentWave % 2 == 0;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'currentWave': currentWave,
      'waveTarget': waveTarget,
      'waveLevels': waveLevels,
    };
  }

  factory ElliotWavesStrategy.fromJson(Map<String, dynamic> json) {
    return ElliotWavesStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      currentWave: json['currentWave'] as int,
      waveTarget: (json['waveTarget'] as num).toDouble(),
      waveLevels: (json['waveLevels'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
    );
  }

  ElliotWavesStrategy copyWith({
    String? id,
    String? name,
    int? currentWave,
    double? waveTarget,
    List<double>? waveLevels,
  }) {
    return ElliotWavesStrategy(
      id: id ?? this.id,
      name: name ?? this.name,
      currentWave: currentWave ?? this.currentWave,
      waveTarget: waveTarget ?? this.waveTarget,
      waveLevels: waveLevels ?? this.waveLevels,
    );
  }

  @override
  String toString() {
    return 'ElliotWavesStrategy{id: $id, name: $name, currentWave: $currentWave, target: $waveTarget}';
  }
}