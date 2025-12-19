class StockItem {
  final String id; // Unique identifier (can be ISIN, WKN, ticker, or internal ID)
  final String? isin; // International Securities Identification Number
  final String? wkn; // Wertpapierkennnummer (German securities ID)
  final String? ticker; // Stock ticker symbol
  final String name;
  final String symbol;
  final double currentValue;
  final double? previousClose;
  final String currency;
  final List<StockHint> hints;
  final DateTime lastUpdated;
  final bool isInWatchlist;
  final StockIdentifierType primaryIdentifierType;
  final double? dayChange;
  final double? dayChangePercent;

  StockItem({
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
  StockItem addToWatchlist() {
    return copyWith(isInWatchlist: true);
  }

  StockItem removeFromWatchlist() {
    return copyWith(isInWatchlist: false);
  }

  // Helper methods for identifier management
  String getPrimaryIdentifier() {
    switch (primaryIdentifierType) {
      case StockIdentifierType.isin:
        return isin ?? id;
      case StockIdentifierType.wkn:
        return wkn ?? id;
      case StockIdentifierType.ticker:
        return ticker ?? id;
      case StockIdentifierType.internal:
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

  // Copy with method for immutability
  StockItem copyWith({
    String? id,
    String? isin,
    String? wkn,
    String? ticker,
    String? name,
    String? symbol,
    double? currentValue,
    double? previousClose,
    String? currency,
    List<StockHint>? hints,
    DateTime? lastUpdated,
    bool? isInWatchlist,
    StockIdentifierType? primaryIdentifierType,
    double? dayChange,
    double? dayChangePercent,
  }) {
    return StockItem(
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
    );
  }

  @override
  String toString() {
    return 'StockItem{id: $id, name: $name, currentValue: $currentValue, currency: $currency, isInWatchlist: $isInWatchlist}';
  }
}

class StockHint {
  final String type; // e.g., 'buy_zone', 'trendline', 'support', 'resistance'
  final String description;
  final double? value;
  final DateTime? timestamp;

  StockHint({
    required this.type,
    required this.description,
    this.value,
    this.timestamp,
  });

  @override
  String toString() {
    return 'StockHint{type: $type, description: $description, value: $value}';
  }
}

enum StockIdentifierType {
  isin,
  wkn,
  ticker,
  internal
}
