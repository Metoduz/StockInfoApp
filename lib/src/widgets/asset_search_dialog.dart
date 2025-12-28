import 'package:flutter/material.dart';
import '../models/asset_item.dart';

class AssetSearchDialog extends StatefulWidget {
  final List<AssetItem> availableAssets;
  final List<AssetItem> currentWatchlist;
  final Function(AssetItem) onAssetSelected;

  const AssetSearchDialog({
    super.key,
    required this.availableAssets,
    required this.currentWatchlist,
    required this.onAssetSelected,
  });

  @override
  State<AssetSearchDialog> createState() => _AssetSearchDialogState();
}

class _AssetSearchDialogState extends State<AssetSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<AssetItem> _filteredAssets = [];
  String _validationMessage = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredAssets = _getAvailableAssets();
    _searchController.addListener(_filterAssets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Get assets that are not already in the watchlist
  List<AssetItem> _getAvailableAssets() {
    final watchlistIds = widget.currentWatchlist.map((asset) => asset.id).toSet();
    final watchlistIsins = widget.currentWatchlist
        .where((asset) => asset.isin != null)
        .map((asset) => asset.isin!)
        .toSet();
    final watchlistSymbols = widget.currentWatchlist.map((asset) => asset.symbol).toSet();

    return widget.availableAssets.where((asset) {
      // Check for duplicate by ID
      if (watchlistIds.contains(asset.id)) return false;
      
      // Check for duplicate by ISIN if available
      if (asset.isin != null && watchlistIsins.contains(asset.isin!)) return false;
      
      // Check for duplicate by symbol (less reliable but useful)
      if (watchlistSymbols.contains(asset.symbol)) return false;
      
      return true;
    }).toList();
  }

  void _filterAssets() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _isSearching = query.isNotEmpty;
      _validationMessage = '';
      
      if (query.isEmpty) {
        _filteredAssets = _getAvailableAssets();
      } else {
        _filteredAssets = _getAvailableAssets().where((asset) {
          return _matchesSearchQuery(asset, query);
        }).toList();
        
        // Validate search results
        if (_filteredAssets.isEmpty && query.length >= 2) {
          _validationMessage = _getValidationMessage(query);
        }
      }
    });
  }

  /// Check if a asset matches the search query
  bool _matchesSearchQuery(AssetItem asset, String query) {
    // Match by name (case insensitive)
    if (asset.name.toLowerCase().contains(query)) return true;
    
    // Match by symbol (case insensitive)
    if (asset.symbol.toLowerCase().contains(query)) return true;
    
    // Match by ISIN (case insensitive)
    if (asset.isin?.toLowerCase().contains(query) ?? false) return true;
    
    // Match by WKN (case insensitive)
    if (asset.wkn?.toLowerCase().contains(query) ?? false) return true;
    
    // Match by ticker (case insensitive)
    if (asset.ticker?.toLowerCase().contains(query) ?? false) return true;
    
    return false;
  }

  /// Generate appropriate validation message based on search query
  String _getValidationMessage(String query) {
    // Check if the query looks like an ISIN (12 characters, alphanumeric)
    if (query.length == 12 && RegExp(r'^[A-Z0-9]+$', caseSensitive: false).hasMatch(query)) {
      return 'ISIN "$query" not found in available assets';
    }
    
    // Check if the query looks like a asset symbol (2-5 characters, letters)
    if (query.length >= 2 && query.length <= 5 && RegExp(r'^[A-Z]+$', caseSensitive: false).hasMatch(query)) {
      return 'Symbol "$query" not found in available assets';
    }
    
    // Check if it might be a duplicate
    final isDuplicate = widget.currentWatchlist.any((asset) =>
        asset.name.toLowerCase().contains(query) ||
        asset.symbol.toLowerCase().contains(query) ||
        (asset.isin?.toLowerCase().contains(query) ?? false));
    
    if (isDuplicate) {
      return 'Asset matching "$query" is already in your watchlist';
    }
    
    return 'No assets found matching "$query"';
  }

  /// Validate if a asset can be added (additional validation beyond filtering)
  bool _canAddAsset(AssetItem asset) {
    // Check for exact ID match
    if (widget.currentWatchlist.any((item) => item.id == asset.id)) {
      return false;
    }
    
    // Check for ISIN match if available
    if (asset.isin != null && 
        widget.currentWatchlist.any((item) => item.isin == asset.isin)) {
      return false;
    }
    
    // Check for symbol match (less strict, but useful for preventing obvious duplicates)
    if (widget.currentWatchlist.any((item) => 
        item.symbol == asset.symbol && item.name == asset.name)) {
      return false;
    }
    
    return true;
  }

  void _selectAsset(AssetItem asset) {
    if (!_canAddAsset(asset)) {
      setState(() {
        _validationMessage = '${asset.name} is already in your watchlist';
      });
      return;
    }
    
    widget.onAssetSelected(asset);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Asset to Watchlist'),
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
            Expanded(child: _buildAssetList()),
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
        labelText: 'Search assets',
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
            '• Asset symbol (e.g., "BAS", "MBG")\n'
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

  Widget _buildAssetList() {
    if (_filteredAssets.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: _filteredAssets.length,
      itemBuilder: (context, index) {
        final asset = _filteredAssets[index];
        return _buildAssetListItem(asset);
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
              'Start typing to search for assets',
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
            'No assets found',
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

  Widget _buildAssetListItem(AssetItem asset) {
    final canAdd = _canAddAsset(asset);
    
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
        asset.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: canAdd ? null : Colors.grey.shade600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${asset.symbol} • ${asset.isin ?? asset.id}'),
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
            '${asset.currentValue.toStringAsFixed(2)} ${asset.currency}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (asset.previousClose != null)
            Text(
              '${asset.calculatedDayChange >= 0 ? '+' : ''}${asset.calculatedDayChange.toStringAsFixed(2)}',
              style: TextStyle(
                color: asset.calculatedDayChange >= 0 ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
        ],
      ),
      enabled: canAdd,
      onTap: canAdd ? () => _selectAsset(asset) : null,
    );
  }
}