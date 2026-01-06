// Import strategy implementations
import 'trendline_strategy.dart';
import 'elliot_waves_strategy.dart';
import 'buy_area_strategy.dart';
import 'composite_strategy.dart';
import 'package:flutter/material.dart';

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

/// Enum for strategy categories with display names and icons
enum StrategyCategory {
  technicalAnalysis,
  priceLevels,
  advanced;

  String get displayName {
    switch (this) {
      case StrategyCategory.technicalAnalysis:
        return 'Technical Analysis';
      case StrategyCategory.priceLevels:
        return 'Price Levels';
      case StrategyCategory.advanced:
        return 'Advanced';
    }
  }

  IconData get icon {
    switch (this) {
      case StrategyCategory.technicalAnalysis:
        return Icons.trending_up;
      case StrategyCategory.priceLevels:
        return Icons.horizontal_rule;
      case StrategyCategory.advanced:
        return Icons.settings;
    }
  }

  List<StrategyType> get strategies {
    switch (this) {
      case StrategyCategory.technicalAnalysis:
        return [StrategyType.trendline, StrategyType.elliotWaves];
      case StrategyCategory.priceLevels:
        return [StrategyType.buyArea];
      case StrategyCategory.advanced:
        return [StrategyType.composite];
    }
  }
}

/// Extension to add category metadata to StrategyType
extension StrategyTypeMetadata on StrategyType {
  StrategyCategory get category {
    switch (this) {
      case StrategyType.trendline:
      case StrategyType.elliotWaves:
        return StrategyCategory.technicalAnalysis;
      case StrategyType.buyArea:
        return StrategyCategory.priceLevels;
      case StrategyType.composite:
        return StrategyCategory.advanced;
    }
  }

  List<StrategyFieldDefinition> get fieldDefinitions {
    switch (this) {
      case StrategyType.trendline:
        return [
          StrategyFieldDefinition(
            key: 'name',
            label: 'Strategy Name',
            type: FieldType.text,
            required: true,
            hint: 'Enter a descriptive name for this trendline strategy',
          ),
          StrategyFieldDefinition(
            key: 'supportLevel',
            label: 'Support Level',
            type: FieldType.decimal,
            required: true,
            hint: 'Price level that acts as support',
            validationRules: [
              ValidationRule(
                validator: (value) => value != null && value > 0 ? null : 'Must be positive',
                errorMessage: 'Support level must be greater than 0',
              ),
            ],
          ),
          StrategyFieldDefinition(
            key: 'resistanceLevel',
            label: 'Resistance Level',
            type: FieldType.decimal,
            required: true,
            hint: 'Price level that acts as resistance',
            validationRules: [
              ValidationRule(
                validator: (value) => value != null && value > 0 ? null : 'Must be positive',
                errorMessage: 'Resistance level must be greater than 0',
              ),
            ],
          ),
          StrategyFieldDefinition(
            key: 'trendDirection',
            label: 'Trend Direction',
            type: FieldType.dropdown,
            required: true,
            hint: 'Select the expected trend direction',
            dropdownOptions: TrendDirection.values.map((e) => DropdownOption(
              value: e.name,
              label: e.displayName,
            )).toList(),
          ),
        ];
      case StrategyType.buyArea:
        return [
          StrategyFieldDefinition(
            key: 'name',
            label: 'Strategy Name',
            type: FieldType.text,
            required: true,
            hint: 'Enter a descriptive name for this buy area strategy',
          ),
          StrategyFieldDefinition(
            key: 'lowerBound',
            label: 'Lower Bound',
            type: FieldType.decimal,
            required: true,
            hint: 'Lowest price in the buy area',
            validationRules: [
              ValidationRule(
                validator: (value) => value != null && value > 0 ? null : 'Must be positive',
                errorMessage: 'Lower bound must be greater than 0',
              ),
            ],
          ),
          StrategyFieldDefinition(
            key: 'idealArea',
            label: 'Ideal Price',
            type: FieldType.decimal,
            required: true,
            hint: 'Ideal price within the buy area',
            validationRules: [
              ValidationRule(
                validator: (value) => value != null && value > 0 ? null : 'Must be positive',
                errorMessage: 'Ideal price must be greater than 0',
              ),
            ],
          ),
          StrategyFieldDefinition(
            key: 'upperBound',
            label: 'Upper Bound',
            type: FieldType.decimal,
            required: true,
            hint: 'Highest price in the buy area',
            validationRules: [
              ValidationRule(
                validator: (value) => value != null && value > 0 ? null : 'Must be positive',
                errorMessage: 'Upper bound must be greater than 0',
              ),
            ],
          ),
        ];
      case StrategyType.elliotWaves:
        return [
          StrategyFieldDefinition(
            key: 'name',
            label: 'Strategy Name',
            type: FieldType.text,
            required: true,
            hint: 'Enter a descriptive name for this Elliott Waves strategy',
          ),
          StrategyFieldDefinition(
            key: 'currentWave',
            label: 'Current Wave',
            type: FieldType.number,
            required: true,
            hint: 'Current wave number (1-5)',
            validationRules: [
              ValidationRule(
                validator: (value) => value != null && value >= 1 && value <= 5 ? null : 'Must be between 1 and 5',
                errorMessage: 'Wave number must be between 1 and 5',
              ),
            ],
          ),
          StrategyFieldDefinition(
            key: 'waveTarget',
            label: 'Wave Target Price',
            type: FieldType.decimal,
            required: true,
            hint: 'Target price for the current wave',
            validationRules: [
              ValidationRule(
                validator: (value) => value != null && value > 0 ? null : 'Must be positive',
                errorMessage: 'Wave target must be greater than 0',
              ),
            ],
          ),
        ];
      case StrategyType.composite:
        return [
          StrategyFieldDefinition(
            key: 'name',
            label: 'Strategy Name',
            type: FieldType.text,
            required: true,
            hint: 'Enter a descriptive name for this composite strategy',
          ),
          StrategyFieldDefinition(
            key: 'rootOperator',
            label: 'Root Operator',
            type: FieldType.dropdown,
            required: true,
            hint: 'Logical operator to combine conditions',
            dropdownOptions: LogicalOperator.values.map((e) => DropdownOption(
              value: e.name,
              label: e.displayName,
            )).toList(),
          ),
        ];
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

/// Enum for form field types
enum FieldType {
  text,
  number,
  decimal,
  dropdown,
  toggle,
}

/// Represents a validation rule for form fields
class ValidationRule {
  final String? Function(dynamic value) validator;
  final String errorMessage;

  const ValidationRule({
    required this.validator,
    required this.errorMessage,
  });
}

/// Represents a dropdown option
class DropdownOption {
  final String value;
  final String label;

  const DropdownOption({
    required this.value,
    required this.label,
  });
}

/// Defines the structure and validation for a strategy form field
class StrategyFieldDefinition {
  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final String? hint;
  final dynamic defaultValue;
  final List<ValidationRule> validationRules;
  final List<DropdownOption>? dropdownOptions;

  const StrategyFieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.hint,
    this.defaultValue,
    this.validationRules = const [],
    this.dropdownOptions,
  });

  /// Validate a field value against all validation rules
  String? validateValue(dynamic value) {
    for (final rule in validationRules) {
      final error = rule.validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  /// Check if this field is a dropdown type
  bool get isDropdown => type == FieldType.dropdown;

  /// Check if this field accepts numeric input
  bool get isNumeric => type == FieldType.number || type == FieldType.decimal;

  /// Check if this field is a toggle/boolean type
  bool get isToggle => type == FieldType.toggle;

  /// Get the appropriate keyboard type for this field
  TextInputType get keyboardType {
    switch (type) {
      case FieldType.number:
        return TextInputType.number;
      case FieldType.decimal:
        return const TextInputType.numberWithOptions(decimal: true);
      case FieldType.text:
      case FieldType.dropdown:
      case FieldType.toggle:
        return TextInputType.text;
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