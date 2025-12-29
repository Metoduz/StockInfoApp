import 'package:flutter/material.dart';
import '../models/asset_item.dart';
import '../widgets/enhanced_asset_card.dart';

class AssetList extends StatefulWidget {
  const AssetList({super.key});

  static const routeName = '/';

  @override
  State<AssetList> createState() => _AssetListState();
}

class _AssetListState extends State<AssetList> {
  final List<AssetItem> _assets = [
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
      assetType: AssetType.stock,
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
      assetType: AssetType.stock,
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
      isInWatchlist: true,
      assetType: AssetType.stock,
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
      isInWatchlist: true,
      assetType: AssetType.stock,
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
      isInWatchlist: true,
      assetType: AssetType.stock,
      hints: [
        AssetHint(
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
        title: const Text('Asset Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addAsset,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAssets,
          ),
        ],
      ),
      body: _buildAssetList(),
    );
  }

  Widget _buildAssetList() {
    if (_assets.isEmpty) {
      return const Center(
        child: Text(
          'No assets added yet.\nTap the + button to add your first asset.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _assets.length,
      itemBuilder: (context, index) {
        final asset = _assets[index];
        return EnhancedAssetCard(
          asset: asset,
          onTap: () => _showAssetDetails(asset),
          // Enhanced features callbacks can be added here when needed
          onAssetUpdated: (updatedAsset) {
            setState(() {
              _assets[index] = updatedAsset;
            });
          },
        );
      },
    );
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

  void _addAsset() {
    // Placeholder for adding new assets
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add asset functionality coming soon!')),
    );
  }

  void _refreshAssets() {
    // Placeholder for refreshing asset data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refreshing asset data...')),
    );
  }
}
