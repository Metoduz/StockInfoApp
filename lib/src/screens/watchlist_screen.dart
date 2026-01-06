import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/asset_item.dart';
import '../models/active_trade.dart';
import '../strategies/trading_strategy_base.dart' as strategy_base;
import '../widgets/enhanced_asset_card.dart';
import '../widgets/asset_search_dialog.dart';
import '../widgets/strategy_creation_dialog.dart';
import '../screens/trade_detail_screen.dart';
import '../providers/app_state_provider.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  // Sample asset data for demonstration
  final List<AssetItem> _availableAssets = [
    AssetItem(
      id: 'BASF11',
      isin: 'DE000BASF111',
      name: 'BASF SE',
      symbol: 'BAS',
      currentValue: 45.23,
      previousClose: 44.80,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: true,
      hints: [
        AssetHint(
          type: 'buy_zone',
          description: 'Strong buy zone at 44.50',
          value: 44.50,
          timestamp: DateTime(2025, 9, 10),
        ),
        AssetHint(
          type: 'trendline',
          description: 'Uptrend confirmed - breaking above 45.00 resistance',
          timestamp: DateTime(2025, 9, 11),
        ),
      ],
    ),
    AssetItem(
      id: 'SAP',
      isin: 'DE0007164600',
      name: 'SAP SE',
      symbol: 'SAP',
      currentValue: 178.65,
      previousClose: 180.20,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: true,
      hints: [
        AssetHint(
          type: 'support',
          description: 'Strong support level at 175.00',
          value: 175.00,
          timestamp: DateTime(2025, 9, 9),
        ),
      ],
    ),
    AssetItem(
      id: 'MBG',
      isin: 'DE0007100000',
      name: 'Mercedes-Benz Group AG',
      symbol: 'MBG',
      currentValue: 68.91,
      previousClose: 67.50,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: false,
      hints: [
        AssetHint(
          type: 'resistance',
          description: 'Key resistance level at 70.00',
          value: 70.00,
          timestamp: DateTime(2025, 9, 8),
        ),
        AssetHint(
          type: 'trendline',
          description: 'Breaking above resistance - bullish momentum',
          timestamp: DateTime(2025, 9, 11),
        ),
      ],
    ),
    AssetItem(
      id: 'MUV2',
      isin: 'DE0008430026',
      name: 'Munich Re',
      symbol: 'MUV2',
      currentValue: 412.80,
      previousClose: 410.25,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: false,
    ),
    AssetItem(
      id: 'ADS',
      isin: 'DE000A1EWWW0',
      name: 'Adidas AG',
      symbol: 'ADS',
      currentValue: 215.40,
      previousClose: 218.75,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: false,
      hints: [
        AssetHint(
          type: 'buy_zone',
          description: 'Good entry point below 220.00',
          value: 220.00,
          timestamp: DateTime(2025, 9, 10),
        ),
      ],
    ),
    AssetItem(
      id: 'BMW',
      isin: 'DE0005190003',
      name: 'Bayerische Motoren Werke AG',
      symbol: 'BMW',
      currentValue: 89.45,
      previousClose: 88.20,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: false,
      hints: [
        AssetHint(
          type: 'support',
          description: 'Strong support at 85.00',
          value: 85.00,
          timestamp: DateTime(2025, 9, 10),
        ),
      ],
    ),
    AssetItem(
      id: 'SIE',
      isin: 'DE0007236101',
      name: 'Siemens AG',
      symbol: 'SIE',
      currentValue: 165.30,
      previousClose: 163.80,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: false,
    ),
    AssetItem(
      id: 'ALV',
      isin: 'DE0008404005',
      name: 'Allianz SE',
      symbol: 'ALV',
      currentValue: 245.60,
      previousClose: 244.10,
      currency: 'EUR',
      lastUpdated: DateTime.now(),
      primaryIdentifierType: AssetIdentifierType.isin,
      isInWatchlist: false,
      hints: [
        AssetHint(
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
                onPressed: () => _showAddAssetDialog(appState),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshAssets,
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

  Widget _buildWatchlistContent(AppStateProvider appState, List<AssetItem> watchlist) {
    if (watchlist.isEmpty) {
      return _buildEmptyWatchlist(appState);
    }

    return ReorderableListView.builder(
      itemCount: watchlist.length,
      onReorder: (oldIndex, newIndex) => appState.reorderWatchlist(oldIndex, newIndex),
      itemBuilder: (context, index) {
        final asset = watchlist[index];
        return Dismissible(
          key: Key(asset.id),
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
            return await _showRemoveConfirmation(asset);
          },
          onDismissed: (direction) {
            _removeAsset(appState, asset);
          },
          child: EnhancedAssetCard(
            asset: asset,
            onTap: () => _showAssetDetails(asset),
            onAssetUpdated: (updatedAsset) {
              // Now we can directly update the enhanced asset
              appState.updateEnhancedAsset(updatedAsset);
            },
            // Strategy management callbacks
            onAddStrategy: () => _showAddStrategyDialog(asset),
            onStrategyTap: (strategy) => _navigateToStrategyEdit(strategy, asset),
            onStrategyDelete: (strategyId) => _deleteStrategy(appState, asset, strategyId),
            onAlertToggle: (strategyId, enabled) => _toggleStrategyAlert(appState, asset, strategyId, enabled),
            // Trade management callbacks
            onAddTrade: () => _showAddTradeDialog(asset),
            onTradeEdit: (trade) => _navigateToTradeEdit(trade, asset),
            onTradeDelete: (trade) => _deleteTrade(appState, asset, trade),
            onTradeClose: (trade) => _closeTrade(appState, asset, trade),
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
            'Add assets to track your investments',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAssetDialog(appState),
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Asset'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showRemoveConfirmation(AssetItem asset) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Asset'),
          content: Text('Remove ${asset.name} from your watchlist?'),
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

  void _removeAsset(AppStateProvider appState, AssetItem asset) {
    appState.removeFromWatchlist(asset.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${asset.name} removed from watchlist'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => _undoRemoveAsset(appState, asset),
        ),
      ),
    );
  }

  void _undoRemoveAsset(AppStateProvider appState, AssetItem asset) {
    appState.addEnhancedToWatchlist(asset);
  }

  void _showAddAssetDialog(AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (context) => AssetSearchDialog(
        availableAssets: _availableAssets,
        currentWatchlist: appState.watchlist,
        onAssetSelected: (asset) => _addAsset(appState, asset),
      ),
    );
  }

  void _addAsset(AppStateProvider appState, AssetItem asset) {
    // Enhanced duplicate prevention with multiple checks
    final watchlist = appState.watchlist;
    final isDuplicateById = watchlist.any((item) => item.id == asset.id);
    final isDuplicateByIsin = asset.isin != null && 
        watchlist.any((item) => item.isin == asset.isin);
    final isDuplicateBySymbolAndName = watchlist.any((item) => 
        item.symbol == asset.symbol && item.name == asset.name);
    
    if (isDuplicateById || isDuplicateByIsin || isDuplicateBySymbolAndName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${asset.name} is already in your watchlist'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    appState.addToWatchlist(asset.addToWatchlist());
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${asset.name} added to watchlist'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => _undoAddAsset(appState, asset),
        ),
      ),
    );
  }

  void _undoAddAsset(AppStateProvider appState, AssetItem asset) {
    appState.removeFromWatchlist(asset.id);
  }

  void _showAssetDetails(AssetItem asset) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(asset.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ISIN: ${asset.isin ?? asset.id}'),
              Text('Current: ${asset.currentValue} ${asset.currency}'),
              if (asset.previousClose != null)
                Text('Previous Close: ${asset.previousClose} ${asset.currency}'),
              Text('Change: ${asset.calculatedDayChange.toStringAsFixed(2)} '
                  '(${asset.calculatedDayChangePercent.toStringAsFixed(2)}%)'),
              if (asset.hints.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Hints:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...asset.hints.map((hint) => Text('• ${hint.description}')),
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

  void _refreshAssets() {
    // Placeholder for refreshing asset data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing asset data...')),
    );
  }

  // Strategy management methods
  void _showAddStrategyDialog(AssetItem asset) {
    StrategyCreationDialog.show(
      context: context,
      asset: asset,
      onStrategyCreated: (strategyItem) {
        // Update the asset with the new strategy
        final updatedAsset = asset.addStrategy(strategyItem);
        
        // Update the asset in the app state provider (which handles persistence)
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.updateEnhancedAsset(updatedAsset);
      },
    );
  }

  void _navigateToStrategyEdit(strategy_base.TradingStrategyItem strategy, AssetItem asset) {
    // TODO: Navigate to strategy edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit strategy ${strategy.strategy.name} - Coming soon!')),
    );
  }

  void _deleteStrategy(AppStateProvider appState, AssetItem asset, String strategyId) {
    // TODO: Implement strategy deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete strategy from ${asset.name} - Coming soon!')),
    );
  }

  void _toggleStrategyAlert(AppStateProvider appState, AssetItem asset, String strategyId, bool enabled) {
    // TODO: Implement alert toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${enabled ? 'Enabled' : 'Disabled'} alerts for strategy in ${asset.name}'),
      ),
    );
  }

  // Trade management methods
  void _showAddTradeDialog(AssetItem asset) {
    // TODO: Implement trade creation dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add trade for ${asset.name} - Coming soon!')),
    );
  }

  void _navigateToTradeEdit(ActiveTradeItem trade, AssetItem asset) async {
    final result = await Navigator.of(context).push<ActiveTradeItem>(
      MaterialPageRoute(
        builder: (context) => TradeDetailScreen(
          trade: trade,
          asset: asset,
        ),
      ),
    );
    
    if (result != null && mounted) {
      // Trade was updated, refresh the asset data
      // TODO: Update the asset with the modified trade
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trade updated successfully')),
      );
    }
  }

  void _deleteTrade(AppStateProvider appState, AssetItem asset, ActiveTradeItem trade) {
    // TODO: Implement trade deletion
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Delete trade from ${asset.name} - Coming soon!')),
    );
  }

  void _closeTrade(AppStateProvider appState, AssetItem asset, ActiveTradeItem trade) {
    // TODO: Implement trade closing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Close trade from ${asset.name} - Coming soon!')),
    );
  }
}