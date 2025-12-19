import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../widgets/stock_card.dart';

class StockListView extends StatefulWidget {
  const StockListView({super.key});

  static const routeName = '/';

  @override
  State<StockListView> createState() => _StockListViewState();
}

class _StockListViewState extends State<StockListView> {
  final List<StockItem> _stocks = [
    StockItem(
      id: 'BASF11',
      isin: 'DE000BASF111',
      name: 'BASF SE',
      symbol: 'BAS',
      currentValue: 45.23,
      previousClose: 44.80,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: true,
      hints: [
        StockHint(
          type: 'buy_zone',
          description: 'Strong buy zone at 44.50',
          value: 44.50,
          timestamp: DateTime(2025, 9, 10),
        ),
        StockHint(
          type: 'trendline',
          description: 'Uptrend confirmed - breaking above 45.00 resistance',
          timestamp: DateTime(2025, 9, 11),
        ),
      ],
    ),
    StockItem(
      id: 'SAP',
      isin: 'DE0007164600',
      name: 'SAP SE',
      symbol: 'SAP',
      currentValue: 178.65,
      previousClose: 180.20,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: true,
      hints: [
        StockHint(
          type: 'support',
          description: 'Strong support level at 175.00',
          value: 175.00,
          timestamp: DateTime(2025, 9, 9),
        ),
      ],
    ),
    StockItem(
      id: 'MBG',
      isin: 'DE0007100000',
      name: 'Mercedes-Benz Group AG',
      symbol: 'MBG',
      currentValue: 68.91,
      previousClose: 67.50,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: true,
      hints: [
        StockHint(
          type: 'resistance',
          description: 'Key resistance level at 70.00',
          value: 70.00,
          timestamp: DateTime(2025, 9, 8),
        ),
        StockHint(
          type: 'trendline',
          description: 'Breaking above resistance - bullish momentum',
          timestamp: DateTime(2025, 9, 11),
        ),
      ],
    ),
    StockItem(
      id: 'MUV2',
      isin: 'DE0008430026',
      name: 'Munich Re',
      symbol: 'MUV2',
      currentValue: 412.80,
      previousClose: 410.25,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: true,
    ),
    StockItem(
      id: 'ADS',
      isin: 'DE000A1EWWW0',
      name: 'Adidas AG',
      symbol: 'ADS',
      currentValue: 215.40,
      previousClose: 218.75,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: true,
      hints: [
        StockHint(
          type: 'buy_zone',
          description: 'Good entry point below 220.00',
          value: 220.00,
          timestamp: DateTime(2025, 9, 10),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addStock,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStocks,
          ),
        ],
      ),
      body: _buildStockList(),
    );
  }

  Widget _buildStockList() {
    if (_stocks.isEmpty) {
      return const Center(
        child: Text(
          'No stocks added yet.\nTap the + button to add your first stock.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _stocks.length,
      itemBuilder: (context, index) {
        final stock = _stocks[index];
        return StockCard(
          stock: stock,
          onTap: () => _showStockDetails(stock),
        );
      },
    );
  }

  void _showStockDetails(StockItem stock) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(stock.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ISIN: ${stock.isin ?? stock.id}'),
              Text('Current: ${stock.currentValue} ${stock.currency}'),
              if (stock.previousClose != null)
                Text('Previous Close: ${stock.previousClose} ${stock.currency}'),
              Text('Change: ${stock.calculatedDayChange.toStringAsFixed(2)} '
                  '(${stock.calculatedDayChangePercent.toStringAsFixed(2)}%)'),
              if (stock.hints.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Hints:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...stock.hints.map((hint) => Text('• ${hint.description}')),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _addStock() {
    // Placeholder for adding new stocks
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add stock functionality coming soon!')),
    );
  }

  void _refreshStocks() {
    // Placeholder for refreshing stock data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing stock data...')),
    );
  }
}
