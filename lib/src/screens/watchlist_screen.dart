import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/stock_item.dart';
import '../widgets/stock_card.dart';
import '../widgets/stock_search_dialog.dart';
import '../providers/app_state_provider.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  // Sample stock data for demonstration
  final List<StockItem> _availableStocks = [
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
      isInWatchlist: false,
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
      isInWatchlist: false,
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
      isInWatchlist: false,
      hints: [
        StockHint(
          type: 'buy_zone',
          description: 'Good entry point below 220.00',
          value: 220.00,
          timestamp: DateTime(2025, 9, 10),
        ),
      ],
    ),
    StockItem(
      id: 'BMW',
      isin: 'DE0005190003',
      name: 'Bayerische Motoren Werke AG',
      symbol: 'BMW',
      currentValue: 89.45,
      previousClose: 88.20,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: false,
      hints: [
        StockHint(
          type: 'support',
          description: 'Strong support at 85.00',
          value: 85.00,
          timestamp: DateTime(2025, 9, 10),
        ),
      ],
    ),
    StockItem(
      id: 'SIE',
      isin: 'DE0007236101',
      name: 'Siemens AG',
      symbol: 'SIE',
      currentValue: 165.30,
      previousClose: 163.80,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: false,
    ),
    StockItem(
      id: 'ALV',
      isin: 'DE0008404005',
      name: 'Allianz SE',
      symbol: 'ALV',
      currentValue: 245.60,
      previousClose: 244.10,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: StockIdentifierType.isin,
      isInWatchlist: false,
      hints: [
        StockHint(
          type: 'resistance',
          description: 'Testing resistance at 250.00',
          value: 250.00,
          timestamp: DateTime(2025, 9, 11),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final watchlist = appState.watchlist;
        final isLoading = appState.isLoadingWatchlist;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Watchlist'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddStockDialog(appState),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshStocks,
              ),
            ],
          ),
          body: isLoading ? _buildLoadingIndicator() : _buildWatchlistContent(appState, watchlist),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildWatchlistContent(AppStateProvider appState, List<StockItem> watchlist) {
    if (watchlist.isEmpty) {
      return _buildEmptyWatchlist(appState);
    }

    return ReorderableListView.builder(
      itemCount: watchlist.length,
      onReorder: (oldIndex, newIndex) => appState.reorderWatchlist(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final stock = watchlist[index];
        return Dismissible(
          key: Key(stock.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            return await _showRemoveConfirmation(stock);
          },
          onDismissed: (direction) {
            _removeStock(appState, stock);
          },
          child: StockCard(
            stock: stock,
            onTap: () => _showStockDetails(stock),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWatchlist(AppStateProvider appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your watchlist is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add stocks to track your investments',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddStockDialog(appState),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Stock'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showRemoveConfirmation(StockItem stock) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Stock'),
          content: Text('Remove ${stock.name} from your watchlist?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _removeStock(AppStateProvider appState, StockItem stock) {
    appState.removeFromWatchlist(stock.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${stock.name} removed from watchlist'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _undoRemoveStock(appState, stock),
        ),
      ),
    );
  }

  void _undoRemoveStock(AppStateProvider appState, StockItem stock) {
    appState.addToWatchlist(stock);
  }

  void _showAddStockDialog(AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) => StockSearchDialog(
        availableStocks: _availableStocks,
        currentWatchlist: appState.watchlist,
        onStockSelected: (stock) => _addStock(appState, stock),
      ),
    );
  }

  void _addStock(AppStateProvider appState, StockItem stock) {
    // Enhanced duplicate prevention with multiple checks
    final watchlist = appState.watchlist;
    final isDuplicateById = watchlist.any((item) => item.id == stock.id);
    final isDuplicateByIsin = stock.isin != null && 
        watchlist.any((item) => item.isin == stock.isin);
    final isDuplicateBySymbolAndName = watchlist.any((item) => 
        item.symbol == stock.symbol && item.name == stock.name);
    
    if (isDuplicateById || isDuplicateByIsin || isDuplicateBySymbolAndName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${stock.name} is already in your watchlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    appState.addToWatchlist(stock.addToWatchlist());
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${stock.name} added to watchlist'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => _undoAddStock(appState, stock),
        ),
      ),
    );
  }

  void _undoAddStock(AppStateProvider appState, StockItem stock) {
    appState.removeFromWatchlist(stock.id);
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

  void _refreshStocks() {
    // Placeholder for refreshing stock data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing stock data...')),
    );
  }
}