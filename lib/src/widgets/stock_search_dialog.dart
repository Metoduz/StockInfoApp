import 'package:flutter/material.dart';
import '../models/stock_item.dart';

class StockSearchDialog extends StatefulWidget {
  final List<StockItem> availableStocks;
  final List<StockItem> currentWatchlist;
  final Function(StockItem) onStockSelected;

  const StockSearchDialog({
    super.key,
    required this.availableStocks,
    required this.currentWatchlist,
    required this.onStockSelected,
  });

  @override
  State<StockSearchDialog> createState() => _StockSearchDialogState();
}

class _StockSearchDialogState extends State<StockSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<StockItem> _filteredStocks = [];
  String _validationMessage = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredStocks = _getAvailableStocks();
    _searchController.addListener(_filterStocks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get stocks that are not already in the watchlist
  List<StockItem> _getAvailableStocks() {
    final watchlistIds = widget.currentWatchlist.map((stock) => stock.id).toSet();
    final watchlistIsins = widget.currentWatchlist
        .where((stock) => stock.isin != null)
        .map((stock) => stock.isin!)
        .toSet();
    final watchlistSymbols = widget.currentWatchlist.map((stock) => stock.symbol).toSet();

    return widget.availableStocks.where((stock) {
      // Check for duplicate by ID
      if (watchlistIds.contains(stock.id)) return false;
      
      // Check for duplicate by ISIN if available
      if (stock.isin != null && watchlistIsins.contains(stock.isin!)) return false;
      
      // Check for duplicate by symbol (less reliable but useful)
      if (watchlistSymbols.contains(stock.symbol)) return false;
      
      return true;
    }).toList();
  }

  void _filterStocks() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      _validationMessage = '';
      
      if (query.isEmpty) {
        _filteredStocks = _getAvailableStocks();
      } else {
        _filteredStocks = _getAvailableStocks().where((stock) {
          return _matchesSearchQuery(stock, query);
        }).toList();
        
        // Validate search results
        if (_filteredStocks.isEmpty && query.length >= 2) {
          _validationMessage = _getValidationMessage(query);
        }
      }
    });
  }

  /// Check if a stock matches the search query
  bool _matchesSearchQuery(StockItem stock, String query) {
    // Match by name (case insensitive)
    if (stock.name.toLowerCase().contains(query)) return true;
    
    // Match by symbol (case insensitive)
    if (stock.symbol.toLowerCase().contains(query)) return true;
    
    // Match by ISIN (case insensitive)
    if (stock.isin?.toLowerCase().contains(query) ?? false) return true;
    
    // Match by WKN (case insensitive)
    if (stock.wkn?.toLowerCase().contains(query) ?? false) return true;
    
    // Match by ticker (case insensitive)
    if (stock.ticker?.toLowerCase().contains(query) ?? false) return true;
    
    return false;
  }

  /// Generate appropriate validation message based on search query
  String _getValidationMessage(String query) {
    // Check if the query looks like an ISIN (12 characters, alphanumeric)
    if (query.length == 12 && RegExp(r'^[A-Z0-9]+$', caseSensitive: false).hasMatch(query)) {
      return 'ISIN "$query" not found in available stocks';
    }
    
    // Check if the query looks like a stock symbol (2-5 characters, letters)
    if (query.length >= 2 && query.length <= 5 && RegExp(r'^[A-Z]+$', caseSensitive: false).hasMatch(query)) {
      return 'Symbol "$query" not found in available stocks';
    }
    
    // Check if it might be a duplicate
    final isDuplicate = widget.currentWatchlist.any((stock) =>
        stock.name.toLowerCase().contains(query) ||
        stock.symbol.toLowerCase().contains(query) ||
        (stock.isin?.toLowerCase().contains(query) ?? false));
    
    if (isDuplicate) {
      return 'Stock matching "$query" is already in your watchlist';
    }
    
    return 'No stocks found matching "$query"';
  }

  /// Validate if a stock can be added (additional validation beyond filtering)
  bool _canAddStock(StockItem stock) {
    // Check for exact ID match
    if (widget.currentWatchlist.any((item) => item.id == stock.id)) {
      return false;
    }
    
    // Check for ISIN match if available
    if (stock.isin != null && 
        widget.currentWatchlist.any((item) => item.isin == stock.isin)) {
      return false;
    }
    
    // Check for symbol match (less strict, but useful for preventing obvious duplicates)
    if (widget.currentWatchlist.any((item) => 
        item.symbol == stock.symbol && item.name == stock.name)) {
      return false;
    }
    
    return true;
  }

  void _selectStock(StockItem stock) {
    if (!_canAddStock(stock)) {
      setState(() {
        _validationMessage = '${stock.name} is already in your watchlist';
      });
      return;
    }
    
    widget.onStockSelected(stock);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Stock to Watchlist'),
      content: SizedBox(
        width: double.maxFinite,
        height: 450,
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 8),
            _buildValidationMessage(),
            const SizedBox(height: 8),
            _buildSearchHints(),
            const SizedBox(height: 16),
            Expanded(child: _buildStockList()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Search stocks',
        hintText: 'Enter name, symbol, ISIN, or WKN',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                },
              )
            : null,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.search,
    );
  }

  Widget _buildValidationMessage() {
    if (_validationMessage.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _validationMessage,
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHints() {
    if (_isSearching || _searchController.text.isNotEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'Search Tips:',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '• Company name (e.g., "BASF", "Mercedes")\n'
            '• Stock symbol (e.g., "BAS", "MBG")\n'
            '• ISIN code (e.g., "DE000BASF111")',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    if (_filteredStocks.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _filteredStocks.length,
      itemBuilder: (context, index) {
        final stock = _filteredStocks[index];
        return _buildStockListItem(stock);
      },
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Start typing to search for stocks',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No stocks found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStockListItem(StockItem stock) {
    final canAdd = _canAddStock(stock);
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: canAdd ? Colors.green.shade100 : Colors.grey.shade200,
        child: Icon(
          canAdd ? Icons.add : Icons.check,
          color: canAdd ? Colors.green.shade700 : Colors.grey.shade600,
          size: 20,
        ),
      ),
      title: Text(
        stock.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: canAdd ? null : Colors.grey.shade600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${stock.symbol} • ${stock.isin ?? stock.id}'),
          if (!canAdd)
            Text(
              'Already in watchlist',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${stock.currentValue.toStringAsFixed(2)} ${stock.currency}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (stock.previousClose != null)
            Text(
              '${stock.calculatedDayChange >= 0 ? '+' : ''}${stock.calculatedDayChange.toStringAsFixed(2)}',
              style: TextStyle(
                color: stock.calculatedDayChange >= 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
        ],
      ),
      enabled: canAdd,
      onTap: canAdd ? () => _selectStock(stock) : null,
    );
  }
}