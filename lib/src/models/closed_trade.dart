import 'active_trade.dart';
import '../strategies/trading_strategy_base.dart';

/// Represents a closed trading position
class ClosedTradeItem {
  final String id;
  final String assetId;
  final TradeDirection direction;
  final double quantity;
  final double buyPrice;
  final double sellPrice;
  final DateTime openDate;
  final DateTime closeDate;
  final double profitLoss;
  final double profitLossPercentage;
  final String? notice;
  final double? fees;
  final double buyValue;
  final double sellValue;

  ClosedTradeItem({
    required this.id,
    required this.assetId,
    required this.direction,
    required this.quantity,
    required this.buyPrice,
    required this.sellPrice,
    required this.openDate,
    required this.closeDate,
    required this.profitLoss,
    required this.profitLossPercentage,
    this.notice,
    this.fees,
    required this.buyValue,
    required this.sellValue,
  });

  /// Create a closed trade from an active trade
  factory ClosedTradeItem.fromActiveTrade(
    ActiveTradeItem activeTrade,
    double sellPrice,
    DateTime closeDate,
  ) {
    final buyValue = activeTrade.getTotalValue();
    final sellValue = activeTrade.quantity * sellPrice;
    final fees = activeTrade.fees ?? 0.0;
    
    double profitLoss;
    switch (activeTrade.direction) {
      case TradeDirection.long:
        profitLoss = sellValue - buyValue - fees;
        break;
      case TradeDirection.short:
        profitLoss = buyValue - sellValue - fees;
        break;
    }
    
    final profitLossPercentage = buyValue > 0 ? (profitLoss / buyValue) * 100 : 0.0;

    return ClosedTradeItem(
      id: activeTrade.id,
      assetId: activeTrade.assetId,
      direction: activeTrade.direction,
      quantity: activeTrade.quantity,
      buyPrice: activeTrade.buyPrice,
      sellPrice: sellPrice,
      openDate: activeTrade.openDate,
      closeDate: closeDate,
      profitLoss: profitLoss,
      profitLossPercentage: profitLossPercentage,
      notice: activeTrade.notice,
      fees: fees,
      buyValue: buyValue,
      sellValue: sellValue,
    );
  }

  /// Calculate the holding period in days
  int getHoldingPeriodDays() {
    return closeDate.difference(openDate).inDays;
  }

  /// Check if the trade was profitable
  bool isProfitable() {
    return profitLoss > 0;
  }

  /// Get the absolute profit/loss value
  double getAbsoluteProfitLoss() {
    return profitLoss.abs();
  }

  /// Calculate annualized return
  double getAnnualizedReturn() {
    final holdingDays = getHoldingPeriodDays();
    if (holdingDays <= 0) return 0.0;
    
    final dailyReturn = profitLossPercentage / holdingDays;
    return dailyReturn * 365;
  }

  /// Get trade summary for display
  Map<String, dynamic> getTradeSummary() {
    return {
      'direction': direction.displayName,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'profitLoss': profitLoss,
      'profitLossPercentage': profitLossPercentage,
      'holdingDays': getHoldingPeriodDays(),
      'annualizedReturn': getAnnualizedReturn(),
      'isProfitable': isProfitable(),
    };
  }

  ClosedTradeItem copyWith({
    String? id,
    String? assetId,
    TradeDirection? direction,
    double? quantity,
    double? buyPrice,
    double? sellPrice,
    DateTime? openDate,
    DateTime? closeDate,
    double? profitLoss,
    double? profitLossPercentage,
    String? notice,
    double? fees,
    double? buyValue,
    double? sellValue,
  }) {
    return ClosedTradeItem(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      direction: direction ?? this.direction,
      quantity: quantity ?? this.quantity,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      openDate: openDate ?? this.openDate,
      closeDate: closeDate ?? this.closeDate,
      profitLoss: profitLoss ?? this.profitLoss,
      profitLossPercentage: profitLossPercentage ?? this.profitLossPercentage,
      notice: notice ?? this.notice,
      fees: fees ?? this.fees,
      buyValue: buyValue ?? this.buyValue,
      sellValue: sellValue ?? this.sellValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'direction': direction.name,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'openDate': openDate.toIso8601String(),
      'closeDate': closeDate.toIso8601String(),
      'profitLoss': profitLoss,
      'profitLossPercentage': profitLossPercentage,
      'notice': notice,
      'fees': fees,
      'buyValue': buyValue,
      'sellValue': sellValue,
    };
  }

  factory ClosedTradeItem.fromJson(Map<String, dynamic> json) {
    return ClosedTradeItem(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      direction: TradeDirection.values.firstWhere(
        (e) => e.name == json['direction'],
        orElse: () => TradeDirection.long,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      buyPrice: (json['buyPrice'] as num).toDouble(),
      sellPrice: (json['sellPrice'] as num).toDouble(),
      openDate: DateTime.parse(json['openDate'] as String),
      closeDate: DateTime.parse(json['closeDate'] as String),
      profitLoss: (json['profitLoss'] as num).toDouble(),
      profitLossPercentage: (json['profitLossPercentage'] as num).toDouble(),
      notice: json['notice'] as String?,
      fees: json['fees'] != null ? (json['fees'] as num).toDouble() : null,
      buyValue: (json['buyValue'] as num).toDouble(),
      sellValue: (json['sellValue'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'ClosedTradeItem{id: $id, direction: $direction, profitLoss: $profitLoss, profitLossPercentage: $profitLossPercentage}';
  }
}

/// Statistics for a collection of closed trades
class TradeStatistics {
  final int totalTrades;
  final int profitableTrades;
  final int losingTrades;
  final double totalProfitLoss;
  final double totalProfitLossPercentage;
  final double averageProfitLoss;
  final double averageHoldingDays;
  final double winRate;
  final double largestWin;
  final double largestLoss;
  final double averageWin;
  final double averageLoss;

  TradeStatistics({
    required this.totalTrades,
    required this.profitableTrades,
    required this.losingTrades,
    required this.totalProfitLoss,
    required this.totalProfitLossPercentage,
    required this.averageProfitLoss,
    required this.averageHoldingDays,
    required this.winRate,
    required this.largestWin,
    required this.largestLoss,
    required this.averageWin,
    required this.averageLoss,
  });

  /// Calculate statistics from a list of closed trades
  factory TradeStatistics.fromTrades(List<ClosedTradeItem> trades) {
    if (trades.isEmpty) {
      return TradeStatistics(
        totalTrades: 0,
        profitableTrades: 0,
        losingTrades: 0,
        totalProfitLoss: 0.0,
        totalProfitLossPercentage: 0.0,
        averageProfitLoss: 0.0,
        averageHoldingDays: 0.0,
        winRate: 0.0,
        largestWin: 0.0,
        largestLoss: 0.0,
        averageWin: 0.0,
        averageLoss: 0.0,
      );
    }

    final totalTrades = trades.length;
    final profitableTrades = trades.where((t) => t.isProfitable()).length;
    final losingTrades = totalTrades - profitableTrades;
    
    final totalProfitLoss = trades.fold(0.0, (sum, trade) => sum + trade.profitLoss);
    final totalProfitLossPercentage = trades.fold(0.0, (sum, trade) => sum + trade.profitLossPercentage);
    
    final averageProfitLoss = totalProfitLoss / totalTrades;
    final averageHoldingDays = trades.fold(0.0, (sum, trade) => sum + trade.getHoldingPeriodDays()) / totalTrades;
    final winRate = (profitableTrades / totalTrades) * 100;
    
    final wins = trades.where((t) => t.isProfitable()).toList();
    final losses = trades.where((t) => !t.isProfitable()).toList();
    
    final largestWin = wins.isNotEmpty ? wins.map((t) => t.profitLoss).reduce((a, b) => a > b ? a : b) : 0.0;
    final largestLoss = losses.isNotEmpty ? losses.map((t) => t.profitLoss).reduce((a, b) => a < b ? a : b) : 0.0;
    
    final averageWin = wins.isNotEmpty ? wins.fold(0.0, (sum, trade) => sum + trade.profitLoss) / wins.length : 0.0;
    final averageLoss = losses.isNotEmpty ? losses.fold(0.0, (sum, trade) => sum + trade.profitLoss) / losses.length : 0.0;

    return TradeStatistics(
      totalTrades: totalTrades,
      profitableTrades: profitableTrades,
      losingTrades: losingTrades,
      totalProfitLoss: totalProfitLoss,
      totalProfitLossPercentage: totalProfitLossPercentage,
      averageProfitLoss: averageProfitLoss,
      averageHoldingDays: averageHoldingDays,
      winRate: winRate,
      largestWin: largestWin,
      largestLoss: largestLoss,
      averageWin: averageWin,
      averageLoss: averageLoss,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalTrades': totalTrades,
      'profitableTrades': profitableTrades,
      'losingTrades': losingTrades,
      'totalProfitLoss': totalProfitLoss,
      'totalProfitLossPercentage': totalProfitLossPercentage,
      'averageProfitLoss': averageProfitLoss,
      'averageHoldingDays': averageHoldingDays,
      'winRate': winRate,
      'largestWin': largestWin,
      'largestLoss': largestLoss,
      'averageWin': averageWin,
      'averageLoss': averageLoss,
    };
  }

  @override
  String toString() {
    return 'TradeStatistics{totalTrades: $totalTrades, winRate: ${winRate.toStringAsFixed(1)}%, totalPnL: ${totalProfitLoss.toStringAsFixed(2)}}';
  }
}