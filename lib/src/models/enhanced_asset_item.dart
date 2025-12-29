import 'asset_item.dart';
import '../strategies/trading_strategy_base.dart';
import 'active_trade.dart';
import 'closed_trade.dart';

/// Enhanced asset item that extends the base AssetItem with additional functionality
/// for tags, strategies, and trades management
class EnhancedAssetItem extends AssetItem {
  final List<String> tags;
  final List<TradingStrategyItem> strategies;
  final List<ActiveTradeItem> activeTrades;
  final List<ClosedTradeItem> closedTrades;
  final AssetType assetType;

  EnhancedAssetItem({
    required super.id,
    super.isin,
    super.wkn,
    super.ticker,
    required super.name,
    required super.symbol,
    required super.currentValue,
    super.previousClose,
    required super.currency,
    super.hints = const [],
    required super.lastUpdated,
    super.isInWatchlist = false,
    required super.primaryIdentifierType,
    super.dayChange,
    super.dayChangePercent,
    this.tags = const [],
    this.strategies = const [],
    this.activeTrades = const [],
    this.closedTrades = const [],
    this.assetType = AssetType.stock,
  });

  /// Get filtered tags for display with maximum rows and items per row constraints
  /// Reserves space for overflow indicator and edit button
  List<String> getFilteredTags({int maxRows = 2, int itemsPerRow = 4, bool reserveSpaceForEditButton = true}) {
    final maxItems = maxRows * itemsPerRow;
    final reservedSpaces = (reserveSpaceForEditButton ? 1 : 0) + (hasOverflowTags(maxRows: maxRows, itemsPerRow: itemsPerRow, reserveSpaceForEditButton: reserveSpaceForEditButton) ? 1 : 0);
    final availableSpaces = maxItems - reservedSpaces;
    
    if (tags.length <= availableSpaces) {
      return tags;
    }
    return tags.take(availableSpaces).toList();
  }

  /// Check if there are more tags than can be displayed
  /// Takes into account space reserved for edit button
  bool hasOverflowTags({int maxRows = 2, int itemsPerRow = 4, bool reserveSpaceForEditButton = true}) {
    final maxItems = maxRows * itemsPerRow;
    final reservedSpaces = reserveSpaceForEditButton ? 1 : 0; // Reserve space for edit button
    final availableSpaces = maxItems - reservedSpaces;
    return tags.length > availableSpaces;
  }

  /// Check if any strategies have active alerts
  bool hasActiveAlerts() {
    return strategies.any((strategy) => strategy.alertEnabled) ||
           activeTrades.any((trade) => trade.stopLoss?.alertEnabled ?? false);
  }

  /// Calculate total position value of all active trades
  double getTotalPositionValue() {
    return activeTrades.fold(0.0, (sum, trade) => sum + trade.getTotalValue());
  }

  /// Calculate total profit/loss of all active trades
  double getTotalPnL() {
    return activeTrades.fold(0.0, (sum, trade) => sum + trade.calculatePnL(currentValue));
  }

  /// Get daily performance percentage (inherited from base class)
  double getDailyPerformancePercent() {
    return calculatedDayChangePercent;
  }

  /// Calculate performance of open trades only
  double getOpenTradesPerformance() {
    if (activeTrades.isEmpty) return 0.0;
    
    final totalInvested = activeTrades.fold(0.0, (sum, trade) => sum + trade.getTotalValue());
    if (totalInvested == 0) return 0.0;
    
    final totalPnL = getTotalPnL();
    return (totalPnL / totalInvested) * 100;
  }

  /// Calculate performance of all trades (open + closed)
  double getAllTradesPerformance() {
    double totalInvested = 0.0;
    double totalPnL = 0.0;

    // Add active trades
    for (final trade in activeTrades) {
      totalInvested += trade.getTotalValue();
      totalPnL += trade.calculatePnL(currentValue);
    }

    // Add closed trades
    for (final trade in closedTrades) {
      totalInvested += trade.buyValue;
      totalPnL += trade.profitLoss;
    }

    if (totalInvested == 0) return 0.0;
    return (totalPnL / totalInvested) * 100;
  }

  /// Add a new tag to the asset
  EnhancedAssetItem addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// Remove a tag from the asset
  EnhancedAssetItem removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// Add a new strategy to the asset
  EnhancedAssetItem addStrategy(TradingStrategyItem strategy) {
    return copyWith(strategies: [...strategies, strategy]);
  }

  /// Remove a strategy from the asset
  EnhancedAssetItem removeStrategy(String strategyId) {
    return copyWith(strategies: strategies.where((s) => s.id != strategyId).toList());
  }

  /// Add a new active trade to the asset
  EnhancedAssetItem addActiveTrade(ActiveTradeItem trade) {
    return copyWith(activeTrades: [...activeTrades, trade]);
  }

  /// Remove an active trade from the asset
  EnhancedAssetItem removeActiveTrade(String tradeId) {
    return copyWith(activeTrades: activeTrades.where((t) => t.id != tradeId).toList());
  }

  /// Close an active trade and move it to closed trades
  EnhancedAssetItem closeTrade(String tradeId, double sellPrice, DateTime closeDate) {
    final trade = activeTrades.firstWhere((t) => t.id == tradeId);
    final closedTrade = ClosedTradeItem.fromActiveTrade(trade, sellPrice, closeDate);
    
    return copyWith(
      activeTrades: activeTrades.where((t) => t.id != tradeId).toList(),
      closedTrades: [...closedTrades, closedTrade],
    );
  }

  @override
  EnhancedAssetItem copyWith({
    String? id,
    String? isin,
    String? wkn,
    String? ticker,
    String? name,
    String? symbol,
    double? currentValue,
    double? previousClose,
    String? currency,
    List<AssetHint>? hints,
    DateTime? lastUpdated,
    bool? isInWatchlist,
    AssetIdentifierType? primaryIdentifierType,
    double? dayChange,
    double? dayChangePercent,
    List<String>? tags,
    List<TradingStrategyItem>? strategies,
    List<ActiveTradeItem>? activeTrades,
    List<ClosedTradeItem>? closedTrades,
    AssetType? assetType,
  }) {
    return EnhancedAssetItem(
      id: id ?? this.id,
      isin: isin ?? this.isin,
      wkn: wkn ?? this.wkn,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      currentValue: currentValue ?? this.currentValue,
      previousClose: previousClose ?? this.previousClose,
      currency: currency ?? this.currency,
      hints: hints ?? this.hints,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      primaryIdentifierType: primaryIdentifierType ?? this.primaryIdentifierType,
      dayChange: dayChange ?? this.dayChange,
      dayChangePercent: dayChangePercent ?? this.dayChangePercent,
      tags: tags ?? this.tags,
      strategies: strategies ?? this.strategies,
      activeTrades: activeTrades ?? this.activeTrades,
      closedTrades: closedTrades ?? this.closedTrades,
      assetType: assetType ?? this.assetType,
    );
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isin': isin,
      'wkn': wkn,
      'ticker': ticker,
      'name': name,
      'symbol': symbol,
      'currentValue': currentValue,
      'previousClose': previousClose,
      'currency': currency,
      'hints': hints.map((h) => {
        'type': h.type,
        'description': h.description,
        'value': h.value,
        'timestamp': h.timestamp?.toIso8601String(),
      }).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'isInWatchlist': isInWatchlist,
      'primaryIdentifierType': primaryIdentifierType.name,
      'dayChange': dayChange,
      'dayChangePercent': dayChangePercent,
      'tags': tags,
      'strategies': strategies.map((s) => s.toJson()).toList(),
      'activeTrades': activeTrades.map((t) => t.toJson()).toList(),
      'closedTrades': closedTrades.map((t) => t.toJson()).toList(),
      'assetType': assetType.name,
    };
  }

  /// Create from JSON for deserialization
  factory EnhancedAssetItem.fromJson(Map<String, dynamic> json) {
    return EnhancedAssetItem(
      id: json['id'] as String,
      isin: json['isin'] as String?,
      wkn: json['wkn'] as String?,
      ticker: json['ticker'] as String?,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      currentValue: (json['currentValue'] as num).toDouble(),
      previousClose: json['previousClose'] != null ? (json['previousClose'] as num).toDouble() : null,
      currency: json['currency'] as String,
      hints: (json['hints'] as List<dynamic>?)?.map((h) => AssetHint(
        type: h['type'] as String,
        description: h['description'] as String,
        value: h['value'] != null ? (h['value'] as num).toDouble() : null,
        timestamp: h['timestamp'] != null ? DateTime.parse(h['timestamp'] as String) : null,
      )).toList() ?? [],
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isInWatchlist: json['isInWatchlist'] as bool? ?? false,
      primaryIdentifierType: AssetIdentifierType.values.firstWhere(
        (e) => e.name == json['primaryIdentifierType'],
        orElse: () => AssetIdentifierType.internal,
      ),
      dayChange: json['dayChange'] != null ? (json['dayChange'] as num).toDouble() : null,
      dayChangePercent: json['dayChangePercent'] != null ? (json['dayChangePercent'] as num).toDouble() : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      strategies: (json['strategies'] as List<dynamic>?)?.map((s) => TradingStrategyItem.fromJson(s)).toList() ?? [],
      activeTrades: (json['activeTrades'] as List<dynamic>?)?.map((t) => ActiveTradeItem.fromJson(t)).toList() ?? [],
      closedTrades: (json['closedTrades'] as List<dynamic>?)?.map((t) => ClosedTradeItem.fromJson(t)).toList() ?? [],
      assetType: AssetType.values.firstWhere(
        (e) => e.name == json['assetType'],
        orElse: () => AssetType.stock,
      ),
    );
  }

  @override
  String toString() {
    return 'EnhancedAssetItem{id: $id, name: $name, assetType: $assetType, tags: ${tags.length}, strategies: ${strategies.length}, activeTrades: ${activeTrades.length}}';
  }
}

/// Enum for different asset types supported by the system
enum AssetType {
  stock,
  resource,
  cfd,
  crypto,
  other;

  /// Get display name for the asset type
  String get displayName {
    switch (this) {
      case AssetType.stock:
        return 'Stock';
      case AssetType.resource:
        return 'Resource';
      case AssetType.cfd:
        return 'CFD';
      case AssetType.crypto:
        return 'Crypto';
      case AssetType.other:
        return 'Other';
    }
  }

  /// Get icon name for the asset type
  String get iconName {
    switch (this) {
      case AssetType.stock:
        return 'trending_up';
      case AssetType.resource:
        return 'eco';
      case AssetType.cfd:
        return 'swap_horiz';
      case AssetType.crypto:
        return 'currency_bitcoin';
      case AssetType.other:
        return 'help_outline';
    }
  }
}