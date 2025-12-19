enum TransactionType {
  buy,
  sell,
  dividend,
  split,
  merger
}

class Transaction {
  final String id;
  final String stockId;
  final String stockName;
  final TransactionType type;
  final double quantity;
  final double price;
  final double totalValue;
  final DateTime date;
  final String? notes;
  final String? brokerage;
  final double? fees;

  const Transaction({
    required this.id,
    required this.stockId,
    required this.stockName,
    required this.type,
    required this.quantity,
    required this.price,
    required this.totalValue,
    required this.date,
    this.notes,
    this.brokerage,
    this.fees,
  });

  /// Calculate the net value of the transaction (total value minus fees)
  double get netValue {
    return totalValue - (fees ?? 0.0);
  }

  /// Calculate profit/loss for a sell transaction given the original buy price
  double calculateProfitLoss(double buyPrice) {
    if (type != TransactionType.sell) return 0.0;
    return (price - buyPrice) * quantity - (fees ?? 0.0);
  }

  /// Calculate the percentage return for a sell transaction given the original buy price
  double calculatePercentageReturn(double buyPrice) {
    if (type != TransactionType.sell || buyPrice == 0) return 0.0;
    final profitLoss = calculateProfitLoss(buyPrice);
    final originalValue = buyPrice * quantity;
    return (profitLoss / originalValue) * 100;
  }

  /// Check if this transaction matches the given filter criteria
  bool matchesFilter({
    String? stockSymbol,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? transactionType,
  }) {
    if (stockSymbol != null && !stockId.toLowerCase().contains(stockSymbol.toLowerCase())) {
      return false;
    }
    if (startDate != null && date.isBefore(startDate)) {
      return false;
    }
    if (endDate != null && date.isAfter(endDate)) {
      return false;
    }
    if (transactionType != null && type != transactionType) {
      return false;
    }
    return true;
  }

  Transaction copyWith({
    String? id,
    String? stockId,
    String? stockName,
    TransactionType? type,
    double? quantity,
    double? price,
    double? totalValue,
    DateTime? date,
    String? notes,
    String? brokerage,
    double? fees,
  }) {
    return Transaction(
      id: id ?? this.id,
      stockId: stockId ?? this.stockId,
      stockName: stockName ?? this.stockName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalValue: totalValue ?? this.totalValue,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      brokerage: brokerage ?? this.brokerage,
      fees: fees ?? this.fees,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stockId': stockId,
      'stockName': stockName,
      'type': type.name,
      'quantity': quantity,
      'price': price,
      'totalValue': totalValue,
      'date': date.toIso8601String(),
      'notes': notes,
      'brokerage': brokerage,
      'fees': fees,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      stockId: json['stockId'] as String,
      stockName: json['stockName'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.buy,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
      brokerage: json['brokerage'] as String?,
      fees: json['fees'] != null ? (json['fees'] as num).toDouble() : null,
    );
  }
}

/// Performance metrics for a portfolio or set of transactions
class PerformanceMetrics {
  final double totalInvested;
  final double totalValue;
  final double totalProfitLoss;
  final double totalPercentageReturn;
  final double totalFees;
  final int totalTransactions;
  final Map<String, double> stockPerformance;

  const PerformanceMetrics({
    required this.totalInvested,
    required this.totalValue,
    required this.totalProfitLoss,
    required this.totalPercentageReturn,
    required this.totalFees,
    required this.totalTransactions,
    required this.stockPerformance,
  });

  /// Calculate performance metrics from a list of transactions
  static PerformanceMetrics fromTransactions(
    List<Transaction> transactions,
    Map<String, double> currentPrices,
  ) {
    double totalInvested = 0.0;
    double totalValue = 0.0;
    double totalFees = 0.0;
    Map<String, double> stockHoldings = {};
    Map<String, double> stockCosts = {};
    Map<String, double> stockPerformance = {};

    // Process all transactions
    for (final transaction in transactions) {
      totalFees += transaction.fees ?? 0.0;

      switch (transaction.type) {
        case TransactionType.buy:
          totalInvested += transaction.totalValue;
          stockHoldings[transaction.stockId] = 
              (stockHoldings[transaction.stockId] ?? 0.0) + transaction.quantity;
          stockCosts[transaction.stockId] = 
              (stockCosts[transaction.stockId] ?? 0.0) + transaction.totalValue;
          break;
        case TransactionType.sell:
          stockHoldings[transaction.stockId] = 
              (stockHoldings[transaction.stockId] ?? 0.0) - transaction.quantity;
          // For sells, we reduce the cost basis proportionally
          final currentHolding = stockHoldings[transaction.stockId] ?? 0.0;
          if (currentHolding >= 0) {
            final costReduction = (stockCosts[transaction.stockId] ?? 0.0) * 
                (transaction.quantity / (currentHolding + transaction.quantity));
            stockCosts[transaction.stockId] = 
                (stockCosts[transaction.stockId] ?? 0.0) - costReduction;
          }
          break;
        case TransactionType.dividend:
          // Dividends add to total value but don't affect holdings
          totalValue += transaction.totalValue;
          break;
        case TransactionType.split:
        case TransactionType.merger:
          // These would require more complex handling
          break;
      }
    }

    // Calculate current value based on holdings and current prices
    for (final entry in stockHoldings.entries) {
      final stockId = entry.key;
      final quantity = entry.value;
      final currentPrice = currentPrices[stockId] ?? 0.0;
      final currentValue = quantity * currentPrice;
      totalValue += currentValue;

      // Calculate individual stock performance
      final costBasis = stockCosts[stockId] ?? 0.0;
      if (costBasis > 0) {
        stockPerformance[stockId] = ((currentValue - costBasis) / costBasis) * 100;
      }
    }

    final totalProfitLoss = totalValue - totalInvested;
    final totalPercentageReturn = totalInvested > 0 
        ? (totalProfitLoss / totalInvested) * 100 
        : 0.0;

    return PerformanceMetrics(
      totalInvested: totalInvested,
      totalValue: totalValue,
      totalProfitLoss: totalProfitLoss,
      totalPercentageReturn: totalPercentageReturn,
      totalFees: totalFees,
      totalTransactions: transactions.length,
      stockPerformance: stockPerformance,
    );
  }
}