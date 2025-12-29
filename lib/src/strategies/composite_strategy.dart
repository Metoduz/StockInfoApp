import 'trading_strategy_base.dart';

/// Composite strategy that combines multiple strategies with logical operators
class CompositeStrategy extends TradingStrategy {
  @override
  final String id;
  
  @override
  final String name;
  
  final List<StrategyCondition> conditions;
  final LogicalOperator rootOperator;
  
  /// Static strategy name for consistent naming
  static const String strategyName = 'Composite';
  
  CompositeStrategy({
    required this.id,
    required this.name,
    required this.conditions,
    required this.rootOperator,
  });

  @override
  StrategyType get type => StrategyType.composite;

  @override
  Map<String, dynamic> get parameters => {
    'conditions': conditions.map((c) => c.toJson()).toList(),
    'rootOperator': rootOperator.name,
  };

  @override
  bool checkTriggerCondition(Map<String, dynamic> assetData) {
    if (conditions.isEmpty) return false;

    bool result = conditions.first.strategy.checkTriggerCondition(assetData);
    
    for (int i = 1; i < conditions.length; i++) {
      final condition = conditions[i];
      final conditionResult = condition.strategy.checkTriggerCondition(assetData);
      
      final operator = condition.operator ?? rootOperator;
      switch (operator) {
        case LogicalOperator.and:
          result = result && conditionResult;
          break;
        case LogicalOperator.or:
          result = result || conditionResult;
          break;
      }
    }
    
    return result;
  }

  /// Get a human-readable description of the composite strategy
  String getDescription() {
    if (conditions.isEmpty) return 'Empty composite strategy';
    
    final parts = <String>[];
    for (int i = 0; i < conditions.length; i++) {
      final condition = conditions[i];
      final strategyName = condition.strategy.type.displayName;
      
      if (i == 0) {
        parts.add(strategyName);
      } else {
        final operator = condition.operator ?? rootOperator;
        parts.add('${operator.displayName} $strategyName');
      }
    }
    
    return parts.join(' ');
  }

  /// Get the complexity score based on number of conditions and operators
  int getComplexityScore() {
    int score = conditions.length;
    
    // Add complexity for mixed operators
    final operators = conditions
        .skip(1)
        .map((c) => c.operator ?? rootOperator)
        .toSet();
    if (operators.length > 1) {
      score += 2; // Mixed operators add complexity
    }
    
    return score;
  }

  /// Check if all conditions use the same operator
  bool hasConsistentOperators() {
    if (conditions.length <= 1) return true;
    
    final firstOperator = conditions[1].operator ?? rootOperator;
    return conditions.skip(2).every((c) => 
        (c.operator ?? rootOperator) == firstOperator);
  }

  /// Get all unique strategy types used in this composite
  Set<StrategyType> getUsedStrategyTypes() {
    return conditions.map((c) => c.strategy.type).toSet();
  }

  /// Add a new condition to the composite strategy
  CompositeStrategy addCondition(TradingStrategy strategy, LogicalOperator? operator) {
    final newCondition = StrategyCondition(
      strategy: strategy,
      operator: operator,
    );
    
    return copyWith(conditions: [...conditions, newCondition]);
  }

  /// Remove a condition by strategy ID
  CompositeStrategy removeCondition(String strategyId) {
    final newConditions = conditions
        .where((c) => c.strategy.id != strategyId)
        .toList();
    
    return copyWith(conditions: newConditions);
  }

  /// Update the root operator
  CompositeStrategy updateRootOperator(LogicalOperator newOperator) {
    return copyWith(rootOperator: newOperator);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'rootOperator': rootOperator.name,
    };
  }

  factory CompositeStrategy.fromJson(Map<String, dynamic> json) {
    return CompositeStrategy(
      id: json['id'] as String,
      name: json['name'] as String,
      conditions: (json['conditions'] as List<dynamic>)
          .map((c) => StrategyCondition.fromJson(c))
          .toList(),
      rootOperator: LogicalOperator.values.firstWhere(
        (e) => e.name == json['rootOperator'],
        orElse: () => LogicalOperator.and,
      ),
    );
  }

  CompositeStrategy copyWith({
    String? id,
    String? name,
    List<StrategyCondition>? conditions,
    LogicalOperator? rootOperator,
  }) {
    return CompositeStrategy(
      id: id ?? this.id,
      name: name ?? this.name,
      conditions: conditions ?? this.conditions,
      rootOperator: rootOperator ?? this.rootOperator,
    );
  }

  @override
  String toString() {
    return 'CompositeStrategy{id: $id, name: $name, conditions: ${conditions.length}, operator: $rootOperator}';
  }
}