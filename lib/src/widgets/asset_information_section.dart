import 'package:flutter/material.dart';
import '../models/enhanced_asset_item.dart';
import 'asset_type_icon.dart';
import 'asset_identifiers.dart';
import 'performance_metrics.dart';

/// The AssetInformation section that is always visible in the enhanced asset card
/// Contains asset type icon, identifiers, and performance metrics
class AssetInformationSection extends StatelessWidget {
  final EnhancedAssetItem asset;

  const AssetInformationSection({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asset type icon in upper left corner
          AssetTypeIcon(
            assetType: asset.assetType,
            size: 20,
          ),
          const SizedBox(width: 12),
          
          // Asset identifiers on the left side
          AssetIdentifiers(asset: asset),
          const SizedBox(width: 16),
          
          // Performance metrics on the right side
          PerformanceMetrics(asset: asset),
        ],
      ),
    );
  }
}