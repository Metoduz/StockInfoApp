import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/transaction.dart';
import 'dart:math';

void main() {
  group('Trading History Properties', () {
    late Random random;

    setUp(() {
      random = Random();
    });

    test('Property 10: Transaction Display Completeness - For any transaction in the trading history, the display should include buy/sell action, quantity, price, and date',
        () async {
      // **Feature: enhanced-navigation, Property 10: Transaction Display Completeness**
      // **Validates: Requirements 6.2**
      
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a random transaction
        final transaction = _generateRandomTransaction(random);
        
        // Verify that all required fields are present and valid
        expect(transaction.type, isNotNull, 
            reason: 'Transaction type (buy/sell action) should be present');
        expect(transaction.quantity, greaterThan(0), 
            reason: 'Transaction quantity should be positive');
        expect(transaction.price, greaterThan(0), 
            reason: 'Transaction price should be positive');
        expect(transaction.date, isNotNull, 
            reason: 'Transaction date should be present');
        expect(transaction.stockId, isNotEmpty, 
            reason: 'Stock ID should be present');
        expect(transaction.stockName, isNotEmpty, 
            reason: 'Stock name should be present');
        expect(transaction.totalValue, greaterThan(0), 
            reason: 'Total value should be positive');
        
        // Verify that total value is calculated correctly
        final expectedTotalValue = transaction.quantity * transaction.price;
        expect(transaction.totalValue, closeTo(expectedTotalValue, 0.01),
            reason: 'Total value should equal quantity * price');
        
        // Verify that the transaction type is one of the valid types
        expect(TransactionType.values, contains(transaction.type),
            reason: 'Transaction type should be a valid enum value');
        
        // Verify date is not in the future
        expect(transaction.date.isBefore(DateTime.now().add(Duration(days: 1))), isTrue,
            reason: 'Transaction date should not be in the future');
      }
    });

    test('Property 11: Performance Metrics Calculation - For any set of transactions, the app should calculate and display accurate portfolio performance metrics',
        () async {
      // **Feature: enhanced-navigation, Property 11: Performance Metrics Calculation**
      // **Validates: Requirements 6.3, 6.4**
      
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a random set of transactions
        final transactions = _generateRandomTransactionSet(random);
        
        // Generate current prices for the stocks
        final currentPrices = <String, double>{};
        final stockIds = transactions.map((t) => t.stockId).toSet();
        for (final stockId in stockIds) {
          currentPrices[stockId] = 50.0 + random.nextDouble() * 400.0;
        }
        
        // Calculate performance metrics
        final metrics = PerformanceMetrics.fromTransactions(transactions, currentPrices);
        
        // Verify basic properties of performance metrics
        expect(metrics.totalTransactions, equals(transactions.length),
            reason: 'Total transactions count should match input');
        expect(metrics.totalFees, greaterThanOrEqualTo(0),
            reason: 'Total fees should be non-negative');
        expect(metrics.stockPerformance, isNotNull,
            reason: 'Stock performance map should be present');
        
        // Verify that total invested is calculated correctly for buy transactions
        final expectedTotalInvested = transactions
            .where((t) => t.type == TransactionType.buy)
            .fold(0.0, (sum, t) => sum + t.totalValue);
        expect(metrics.totalInvested, closeTo(expectedTotalInvested, 0.01),
            reason: 'Total invested should equal sum of buy transaction values');
        
        // Verify that total fees is calculated correctly
        final expectedTotalFees = transactions
            .fold(0.0, (sum, t) => sum + (t.fees ?? 0.0));
        expect(metrics.totalFees, closeTo(expectedTotalFees, 0.01),
            reason: 'Total fees should equal sum of all transaction fees');
        
        // Verify profit/loss calculation consistency
        final profitLoss = metrics.totalValue - metrics.totalInvested;
        expect(metrics.totalProfitLoss, closeTo(profitLoss, 0.01),
            reason: 'Profit/loss should equal current value minus invested amount');
        
        // Verify percentage return calculation
        if (metrics.totalInvested > 0) {
          final expectedPercentageReturn = (metrics.totalProfitLoss / metrics.totalInvested) * 100;
          expect(metrics.totalPercentageReturn, closeTo(expectedPercentageReturn, 0.01),
              reason: 'Percentage return should be calculated correctly');
        } else {
          expect(metrics.totalPercentageReturn, equals(0.0),
              reason: 'Percentage return should be 0 when no investment');
        }
        
        // Verify that stock performance is calculated for each stock
        for (final stockId in stockIds) {
          if (metrics.stockPerformance.containsKey(stockId)) {
            final performance = metrics.stockPerformance[stockId]!;
            expect(performance, isA<double>(),
                reason: 'Stock performance should be a valid number');
          }
        }
      }
    });

    test('Property 12: Trading History Filtering - For any valid filter criteria (date range or stock symbol), the trading history should display only matching transactions',
        () async {
      // **Feature: enhanced-navigation, Property 12: Trading History Filtering**
      // **Validates: Requirements 6.5**
      
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a diverse set of transactions with different dates and stocks
        final transactions = _generateDiverseTransactionSet(random);
        
        // Test 1: Stock symbol filtering
        if (transactions.isNotEmpty) {
          final randomTransaction = transactions[random.nextInt(transactions.length)];
          final stockSymbolFilter = randomTransaction.stockId;
          
          final filteredByStock = transactions.where((t) => 
              t.matchesFilter(stockSymbol: stockSymbolFilter)).toList();
          
          // Verify all filtered transactions match the stock symbol
          for (final transaction in filteredByStock) {
            expect(transaction.stockId.toLowerCase(), 
                contains(stockSymbolFilter.toLowerCase()),
                reason: 'Filtered transaction should contain the stock symbol');
          }
          
          // Verify that the original transaction is included
          expect(filteredByStock, contains(randomTransaction),
              reason: 'Original transaction should be included in filtered results');
        }
        
        // Test 2: Date range filtering
        if (transactions.isNotEmpty) {
          // Create a date range that includes some transactions
          final sortedDates = transactions.map((t) => t.date).toList()..sort();
          final startDate = sortedDates.first;
          final endDate = sortedDates.length > 1 
              ? sortedDates[sortedDates.length ~/ 2] 
              : sortedDates.first;
          
          final filteredByDate = transactions.where((t) => 
              t.matchesFilter(startDate: startDate, endDate: endDate)).toList();
          
          // Verify all filtered transactions are within the date range
          for (final transaction in filteredByDate) {
            expect(transaction.date.isAfter(startDate.subtract(Duration(days: 1))), isTrue,
                reason: 'Filtered transaction should be after start date');
            expect(transaction.date.isBefore(endDate.add(Duration(days: 1))), isTrue,
                reason: 'Filtered transaction should be before end date');
          }
        }
        
        // Test 3: Transaction type filtering
        if (transactions.isNotEmpty) {
          final transactionTypes = transactions.map((t) => t.type).toSet().toList();
          if (transactionTypes.isNotEmpty) {
            final typeFilter = transactionTypes[random.nextInt(transactionTypes.length)];
            
            final filteredByType = transactions.where((t) => 
                t.matchesFilter(transactionType: typeFilter)).toList();
            
            // Verify all filtered transactions match the type
            for (final transaction in filteredByType) {
              expect(transaction.type, equals(typeFilter),
                  reason: 'Filtered transaction should match the transaction type');
            }
          }
        }
        
        // Test 4: Combined filtering
        if (transactions.isNotEmpty) {
          final randomTransaction = transactions[random.nextInt(transactions.length)];
          final stockFilter = randomTransaction.stockId;
          final typeFilter = randomTransaction.type;
          final startDate = randomTransaction.date.subtract(Duration(days: 1));
          final endDate = randomTransaction.date.add(Duration(days: 1));
          
          final filteredCombined = transactions.where((t) => 
              t.matchesFilter(
                stockSymbol: stockFilter,
                transactionType: typeFilter,
                startDate: startDate,
                endDate: endDate,
              )).toList();
          
          // Verify the original transaction is included
          expect(filteredCombined, contains(randomTransaction),
              reason: 'Original transaction should match all its own criteria');
          
          // Verify all filtered transactions match all criteria
          for (final transaction in filteredCombined) {
            expect(transaction.stockId.toLowerCase(), 
                contains(stockFilter.toLowerCase()),
                reason: 'Combined filter: stock symbol should match');
            expect(transaction.type, equals(typeFilter),
                reason: 'Combined filter: transaction type should match');
            expect(transaction.date.isAfter(startDate.subtract(Duration(days: 1))), isTrue,
                reason: 'Combined filter: date should be after start date');
            expect(transaction.date.isBefore(endDate.add(Duration(days: 1))), isTrue,
                reason: 'Combined filter: date should be before end date');
          }
        }
        
        // Test 5: Empty filter results
        final impossibleStockFilter = 'NONEXISTENT_STOCK_${random.nextInt(10000)}';
        final emptyResults = transactions.where((t) => 
            t.matchesFilter(stockSymbol: impossibleStockFilter)).toList();
        
        expect(emptyResults.isEmpty, isTrue,
            reason: 'Filtering with non-existent stock should return empty results');
        
        // Test 6: No filter (should return all transactions)
        final unfiltered = transactions.where((t) => t.matchesFilter()).toList();
        expect(unfiltered.length, equals(transactions.length),
            reason: 'No filter criteria should return all transactions');
      }
    });

    test('Property 11 Extended: Performance Calculation Edge Cases - For any edge case scenarios (no transactions, only sells, only dividends), performance metrics should handle gracefully',
        () async {
      // **Feature: enhanced-navigation, Property 11: Performance Metrics Calculation**
      // **Validates: Requirements 6.3, 6.4**
      
      for (int iteration = 0; iteration < 50; iteration++) {
        // Test 1: Empty transaction list
        final emptyMetrics = PerformanceMetrics.fromTransactions([], {});
        expect(emptyMetrics.totalTransactions, equals(0));
        expect(emptyMetrics.totalInvested, equals(0.0));
        expect(emptyMetrics.totalValue, equals(0.0));
        expect(emptyMetrics.totalProfitLoss, equals(0.0));
        expect(emptyMetrics.totalPercentageReturn, equals(0.0));
        expect(emptyMetrics.totalFees, equals(0.0));
        expect(emptyMetrics.stockPerformance.isEmpty, isTrue);
        
        // Test 2: Only sell transactions (should handle gracefully)
        final sellOnlyTransactions = List.generate(3, (i) => Transaction(
          id: 'sell_$i',
          stockId: 'STOCK_$i',
          stockName: 'Stock $i',
          type: TransactionType.sell,
          quantity: 10.0 + random.nextDouble() * 90.0,
          price: 50.0 + random.nextDouble() * 400.0,
          totalValue: 0.0, // Will be calculated
          date: DateTime.now().subtract(Duration(days: i)),
        )).map((t) => t.copyWith(totalValue: t.quantity * t.price)).toList();
        
        final currentPrices = <String, double>{};
        for (final t in sellOnlyTransactions) {
          currentPrices[t.stockId] = 50.0 + random.nextDouble() * 400.0;
        }
        
        final sellOnlyMetrics = PerformanceMetrics.fromTransactions(sellOnlyTransactions, currentPrices);
        expect(sellOnlyMetrics.totalTransactions, equals(3));
        expect(sellOnlyMetrics.totalInvested, equals(0.0), 
            reason: 'Only sells should result in zero invested');
        
        // Test 3: Only dividend transactions
        final dividendOnlyTransactions = List.generate(2, (i) => Transaction(
          id: 'div_$i',
          stockId: 'STOCK_$i',
          stockName: 'Stock $i',
          type: TransactionType.dividend,
          quantity: 1.0,
          price: 5.0 + random.nextDouble() * 20.0,
          totalValue: 0.0, // Will be calculated
          date: DateTime.now().subtract(Duration(days: i * 30)),
        )).map((t) => t.copyWith(totalValue: t.quantity * t.price)).toList();
        
        final dividendMetrics = PerformanceMetrics.fromTransactions(dividendOnlyTransactions, {});
        expect(dividendMetrics.totalTransactions, equals(2));
        expect(dividendMetrics.totalInvested, equals(0.0),
            reason: 'Only dividends should result in zero invested');
        expect(dividendMetrics.totalValue, greaterThan(0.0),
            reason: 'Dividends should contribute to total value');
        
        // Test 4: Transactions with zero or negative prices (edge case)
        final edgeCaseTransaction = Transaction(
          id: 'edge_case',
          stockId: 'EDGE_STOCK',
          stockName: 'Edge Stock',
          type: TransactionType.buy,
          quantity: 10.0,
          price: 0.01, // Very small price
          totalValue: 0.1,
          date: DateTime.now(),
        );
        
        final edgeMetrics = PerformanceMetrics.fromTransactions([edgeCaseTransaction], {'EDGE_STOCK': 0.02});
        expect(edgeMetrics.totalInvested, equals(0.1));
        expect(edgeMetrics.totalValue, closeTo(0.2, 0.01)); // 10 * 0.02
        
        // Test 5: Very large numbers
        final largeTransaction = Transaction(
          id: 'large',
          stockId: 'LARGE_STOCK',
          stockName: 'Large Stock',
          type: TransactionType.buy,
          quantity: 1000000.0,
          price: 1000.0,
          totalValue: 1000000000.0, // 1 billion
          date: DateTime.now(),
        );
        
        final largeMetrics = PerformanceMetrics.fromTransactions([largeTransaction], {'LARGE_STOCK': 1001.0});
        expect(largeMetrics.totalInvested, equals(1000000000.0));
        expect(largeMetrics.totalValue, equals(1001000000.0)); // 1000000 * 1001
        expect(largeMetrics.totalProfitLoss, equals(1000000.0));
        expect(largeMetrics.totalPercentageReturn, closeTo(0.1, 0.01)); // 0.1%
      }
    });
  });
}

// Helper methods for generating test data
Transaction _generateRandomTransaction(Random random) {
  final types = [TransactionType.buy, TransactionType.sell, TransactionType.dividend];
  final stockIds = ['AAPL', 'GOOGL', 'MSFT', 'TSLA', 'AMZN', 'BAS', 'SAP', 'MBG'];
  final stockNames = [
    'Apple Inc.', 'Alphabet Inc.', 'Microsoft Corp.', 'Tesla Inc.', 'Amazon.com Inc.',
    'BASF SE', 'SAP SE', 'Mercedes-Benz Group AG'
  ];
  
  final stockIndex = random.nextInt(stockIds.length);
  final quantity = double.parse((1.0 + random.nextDouble() * 99.0).toStringAsFixed(2));
  final price = double.parse((10.0 + random.nextDouble() * 500.0).toStringAsFixed(2));
  final totalValue = double.parse((quantity * price).toStringAsFixed(2));
  final fees = random.nextBool() ? double.parse((random.nextDouble() * 20.0).toStringAsFixed(2)) : null;
  
  return Transaction(
    id: 'txn_${random.nextInt(100000)}',
    stockId: stockIds[stockIndex],
    stockName: stockNames[stockIndex],
    type: types[random.nextInt(types.length)],
    quantity: quantity,
    price: price,
    totalValue: totalValue,
    date: DateTime.now().subtract(Duration(
      days: random.nextInt(365),
      hours: random.nextInt(24),
      minutes: random.nextInt(60),
    )),
    notes: random.nextBool() ? 'Test note ${random.nextInt(1000)}' : null,
    brokerage: random.nextBool() ? 'Test Broker ${random.nextInt(10)}' : null,
    fees: fees,
  );
}

List<Transaction> _generateRandomTransactionSet(Random random) {
  final count = 1 + random.nextInt(10); // 1-10 transactions
  return List.generate(count, (index) => _generateRandomTransaction(random));
}

List<Transaction> _generateDiverseTransactionSet(Random random) {
  final transactions = <Transaction>[];
  
  // Ensure we have transactions with different characteristics for filtering tests
  final stockIds = ['AAPL', 'GOOGL', 'MSFT', 'TSLA'];
  final types = [TransactionType.buy, TransactionType.sell, TransactionType.dividend];
  
  // Generate transactions across different dates
  for (int i = 0; i < 15; i++) {
    final stockId = stockIds[random.nextInt(stockIds.length)];
    final type = types[random.nextInt(types.length)];
    final quantity = double.parse((1.0 + random.nextDouble() * 99.0).toStringAsFixed(2));
    final price = double.parse((10.0 + random.nextDouble() * 500.0).toStringAsFixed(2));
    final totalValue = double.parse((quantity * price).toStringAsFixed(2));
    
    transactions.add(Transaction(
      id: 'diverse_txn_$i',
      stockId: stockId,
      stockName: '$stockId Corp.',
      type: type,
      quantity: quantity,
      price: price,
      totalValue: totalValue,
      date: DateTime.now().subtract(Duration(
        days: random.nextInt(730), // Up to 2 years ago
        hours: random.nextInt(24),
      )),
      notes: random.nextBool() ? 'Diverse note $i' : null,
      brokerage: random.nextBool() ? 'Broker ${i % 3}' : null,
      fees: random.nextBool() ? double.parse((random.nextDouble() * 15.0).toStringAsFixed(2)) : null,
    ));
  }
  
  return transactions;
}