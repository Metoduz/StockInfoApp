import '../strategies/trading_strategy_base.dart';

/// Enum for trade status
enum TradeStatus {
  open,
  closed,
  pending;

  String get displayName {
    switch (this) {
      case TradeStatus.open:
        return 'Open';
      case TradeStatus.closed:
        return 'Closed';
      case TradeStatus.pending:
        return 'Pending';
    }
  }
}

/// Enum for stop loss types
enum StopLossType {
  fixed,
  trailing;

  String get displayName {
    switch (this) {
      case StopLossType.fixed:
        return 'Fixed';
      case StopLossType.trailing:
        return 'Trailing';
    }
  }
}

/// Configuration for stop loss settings
class StopLossConfig {
  final StopLossType type;
  final double? fixedValue;
  final double? trailingAmount;
  final bool isPercentage;
  final bool alertEnabled;

  StopLossConfig({
    required this.type,
    this.fixedValue,
    this.trailingAmount,
    this.isPercentage = false,
    this.alertEnabled = false,
  });

  /// Validate stop loss configuration
  bool isValid() {
    switch (type) {
      case StopLossType.fixed:
        return fixedValue != null && fixedValue! > 0;
      case StopLossType.trailing:
        return trailingAmount != null && trailingAmount! > 0;
    }
  }

  /// Calculate stop loss trigger price for a given current price and trade direction
  double? calculateTriggerPrice(double currentPrice, TradeDirection direction) {
    switch (type) {
      case StopLossType.fixed:
        if (fixedValue == null) return null;
        return fixedValue!;
        
      case StopLossType.trailing:
        if (trailingAmount == null) return null;
        
        if (isPercentage) {
          final percentage = trailingAmount! / 100;
          switch (direction) {
            case TradeDirection.long:
              return currentPrice * (1 - percentage);
            case TradeDirection.short:
              return currentPrice * (1 + percentage);
          }
        } else {
          switch (direction) {
            case TradeDirection.long:
              return currentPrice - trailingAmount!;
            case TradeDirection.short:
              return currentPrice + trailingAmount!;
          }
        }
    }
  }

  /// Check if stop loss should be triggered
  bool shouldTrigger(double currentPrice, TradeDirection direction) {
    final triggerPrice = calculateTriggerPrice(currentPrice, direction);
    if (triggerPrice == null) return false;

    switch (direction) {
      case TradeDirection.long:
        return currentPrice <= triggerPrice;
      case TradeDirection.short:
        return currentPrice >= triggerPrice;
    }
  }

  StopLossConfig copyWith({
    StopLossType? type,
    double? fixedValue,
    double? trailingAmount,
    bool? isPercentage,
    bool? alertEnabled,
  }) {
    return StopLossConfig(
      type: type ?? this.type,
      fixedValue: fixedValue ?? this.fixedValue,
      trailingAmount: trailingAmount ?? this.trailingAmount,
      isPercentage: isPercentage ?? this.isPercentage,
      alertEnabled: alertEnabled ?? this.alertEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'fixedValue': fixedValue,
      'trailingAmount': trailingAmount,
      'isPercentage': isPercentage,
      'alertEnabled': alertEnabled,
    };
  }

  factory StopLossConfig.fromJson(Map<String, dynamic> json) {
    return StopLossConfig(
      type: StopLossType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StopLossType.fixed,
      ),
      fixedValue: json['fixedValue'] != null ? (json['fixedValue'] as num).toDouble() : null,
      trailingAmount: json['trailingAmount'] != null ? (json['trailingAmount'] as num).toDouble() : null,
      isPercentage: json['isPercentage'] as bool? ?? false,
      alertEnabled: json['alertEnabled'] as bool? ?? false,
    );
  }

  @override
  String toString() {
    return 'StopLossConfig{type: $type, fixedValue: $fixedValue, trailingAmount: $trailingAmount, isPercentage: $isPercentage, alertEnabled: $alertEnabled}';
  }
}

/// Represents an active trading position
class ActiveTradeItem {
  final String id;
  final String assetId;
  final TradeDirection direction;
  final double quantity;
  final double buyPrice;
  final DateTime openDate;
  final StopLossConfig? stopLoss;
  final String? notice;
  final TradeStatus status;
  final double? fees;

  ActiveTradeItem({
    required this.id,
    required this.assetId,
    required this.direction,
    required this.quantity,
    required this.buyPrice,
    required this.openDate,
    this.stopLoss,
    this.notice,
    this.status = TradeStatus.open,
    this.fees,
  });

  /// Calculate total value of the trade (quantity * buy price)
  double getTotalValue() {
    return quantity * buyPrice;
  }

  /// Calculate current profit/loss based on current market price
  double calculatePnL(double currentPrice) {
    final currentValue = quantity * currentPrice;
    final originalValue = getTotalValue();
    
    switch (direction) {
      case TradeDirection.long:
        return currentValue - originalValue - (fees ?? 0.0);
      case TradeDirection.short:
        return originalValue - currentValue - (fees ?? 0.0);
    }
  }

  /// Calculate profit/loss percentage
  double calculatePnLPercentage(double currentPrice) {
    final pnl = calculatePnL(currentPrice);
    final originalValue = getTotalValue();
    if (originalValue == 0) return 0.0;
    return (pnl / originalValue) * 100;
  }

  /// Check if stop loss should be triggered
  bool shouldTriggerStopLoss(double currentPrice) {
    return stopLoss?.shouldTrigger(currentPrice, direction) ?? false;
  }

  /// Check if trade has a notice
  bool hasNotice() {
    return notice != null && notice!.isNotEmpty;
  }

  /// Update stop loss configuration
  ActiveTradeItem updateStopLoss(StopLossConfig? newStopLoss) {
    return copyWith(stopLoss: newStopLoss);
  }

  /// Update notice text
  ActiveTradeItem updateNotice(String? newNotice) {
    return copyWith(notice: newNotice);
  }

  /// Toggle stop loss alert
  ActiveTradeItem toggleStopLossAlert() {
    if (stopLoss == null) return this;
    return copyWith(stopLoss: stopLoss!.copyWith(alertEnabled: !stopLoss!.alertEnabled));
  }

  ActiveTradeItem copyWith({
    String? id,
    String? assetId,
    TradeDirection? direction,
    double? quantity,
    double? buyPrice,
    DateTime? openDate,
    StopLossConfig? stopLoss,
    String? notice,
    TradeStatus? status,
    double? fees,
    bool clearNotice = false,
  }) {
    return ActiveTradeItem(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      direction: direction ?? this.direction,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      openDate: openDate ?? this.openDate,
      stopLoss: stopLoss ?? this.stopLoss,
      notice: clearNotice ? null : (notice ?? this.notice),
      status: status ?? this.status,
      fees: fees ?? this.fees,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'direction': direction.name,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'openDate': openDate.toIso8601String(),
      'stopLoss': stopLoss?.toJson(),
      'notice': notice,
      'status': status.name,
      'fees': fees,
    };
  }

  factory ActiveTradeItem.fromJson(Map<String, dynamic> json) {
    return ActiveTradeItem(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      direction: TradeDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => TradeDirection.long,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      buyPrice: (json['buyPrice'] as num).toDouble(),
      openDate: DateTime.parse(json['openDate'] as String),
      stopLoss: json['stopLoss'] != null ? StopLossConfig.fromJson(json['stopLoss']) : null,
      notice: json['notice'] as String?,
      status: TradeStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TradeStatus.open,
      ),
      fees: json['fees'] != null ? (json['fees'] as num).toDouble() : null,
    );
  }

  @override
  String toString() {
    return 'ActiveTradeItem{id: $id, direction: $direction, quantity: $quantity, buyPrice: $buyPrice, status: $status}';
  }
}