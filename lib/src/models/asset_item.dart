import '../strategies/trading_strategy_base.dart';
import 'active_trade.dart';
import 'closed_trade.dart';

/// Enhanced asset item with additional functionality for tags, strategies, and trades management
class AssetItem {
  final String id; // Unique identifier (can be ISIN, WKN, ticker, or internal ID)
  final String? isin; // International Securities Identification Number
  final String? wkn; // Wertpapierkennnummer (German securities ID)
  final String? ticker; // Asset ticker symbol
  final String name;
  final String symbol;
  final double currentValue;
  final double? previousClose;
  final String currency;
  final List<AssetHint> hints;
  final DateTime lastUpdated;
  final bool isInWatchlist;
  final AssetIdentifierType primaryIdentifierType;
  final double? dayChange;
  final double? dayChangePercent;
  final List<String> tags;
  final List<TradingStrategyItem> strategies;
  final List<ActiveTradeItem> activeTrades;
  final List<ClosedTradeItem> closedTrades;
  final AssetType assetType;

  AssetItem({
    required this.id,
    this.isin,
    this.wkn,
    this.ticker,
    required this.name,
    required this.symbol,
    required this.currentValue,
    this.previousClose,
    required this.currency,
    this.hints = const [],
    required this.lastUpdated,
    this.isInWatchlist = false,
    required this.primaryIdentifierType,
    this.dayChange,
    this.dayChangePercent,
    this.tags = const [],
    this.strategies = const [],
    this.activeTrades = const [],
    this.closedTrades = const [],
    this.assetType = AssetType.stock,
  });

  // Helper method to calculate day change if not provided
  double get calculatedDayChange {
    if (dayChange != null) return dayChange!;
    if (previousClose != null) return currentValue - previousClose!;
    return 0.0;
  }

  // Helper method to calculate day change percentage if not provided
  double get calculatedDayChangePercent {
    if (dayChangePercent != null) return dayChangePercent!;
    if (previousClose != null && previousClose! > 0) {
      return ((currentValue - previousClose!) / previousClose!) * 100;
    }
    return 0.0;
  }

  // New methods for watchlist management
  AssetItem addToWatchlist() {
    return copyWith(isInWatchlist: true);
  }

  AssetItem removeFromWatchlist() {
    return copyWith(isInWatchlist: false);
  }

  // Helper methods for identifier management
  String getPrimaryIdentifier() {
    switch (primaryIdentifierType) {
      case AssetIdentifierType.isin:
        return isin ?? id;
      case AssetIdentifierType.wkn:
        return wkn ?? id;
      case AssetIdentifierType.ticker:
        return ticker ?? id;
      case AssetIdentifierType.internal:
        return id;
    }
  }

  Map<String, String> getAllIdentifiers() {
    final Map<String, String> identifiers = {'id': id};
    if (isin != null) identifiers['isin'] = isin!;
    if (wkn != null) identifiers['wkn'] = wkn!;
    if (ticker != null) identifiers['ticker'] = ticker!;
    return identifiers;
  }

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
  AssetItem addTag(String tag) {
    if (tags.contains(tag)) return this;
    return copyWith(tags: [...tags, tag]);
  }

  /// Remove a tag from the asset
  AssetItem removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  /// Add a new strategy to the asset
  AssetItem addStrategy(TradingStrategyItem strategy) {
    return copyWith(strategies: [...strategies, strategy]);
  }

  /// Remove a strategy from the asset
  AssetItem removeStrategy(String strategyId) {
    return copyWith(strategies: strategies.where((s) => s.id != strategyId).toList());
  }

  /// Add a new active trade to the asset
  AssetItem addActiveTrade(ActiveTradeItem trade) {
    return copyWith(activeTrades: [...activeTrades, trade]);
  }

  /// Remove an active trade from the asset
  AssetItem removeActiveTrade(String tradeId) {
    return copyWith(activeTrades: activeTrades.where((t) => t.id != tradeId).toList());
  }

  /// Close an active trade and move it to closed trades
  AssetItem closeTrade(String tradeId, double sellPrice, DateTime closeDate) {
    final trade = activeTrades.firstWhere((t) => t.id == tradeId);
    final closedTrade = ClosedTradeItem.fromActiveTrade(trade, sellPrice, closeDate);
    
    return copyWith(
      activeTrades: activeTrades.where((t) => t.id != tradeId).toList(),
      closedTrades: [...closedTrades, closedTrade],
    );
  }

  // Copy with method for immutability
  AssetItem copyWith({
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
    return AssetItem(
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
  factory AssetItem.fromJson(Map<String, dynamic> json) {
    return AssetItem(
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
    return 'AssetItem{id: $id, name: $name, assetType: $assetType, tags: ${tags.length}, strategies: ${strategies.length}, activeTrades: ${activeTrades.length}}';
  }
}

class AssetHint {
  final String type; // e.g., 'buy_zone', 'trendline', 'support', 'resistance'
  final String description;
  final double? value;
  final DateTime? timestamp;

  AssetHint({
    required this.type,
    required this.description,
    this.value,
    this.timestamp,
  });

  @override
  String toString() {
    return 'AssetHint{type: $type, description: $description, value: $value}';
  }
}

enum AssetIdentifierType {
  isin,
  wkn,
  ticker,
  internal
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