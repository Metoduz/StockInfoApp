import 'package:flutter/material.dart';
import '../models/enhanced_asset_item.dart';

/// Widget that displays an icon representing the asset type
/// Supports different asset types: Stocks, Resources, CFD, Crypto, and Other
class AssetTypeIcon extends StatelessWidget {
  final AssetType assetType;
  final double size;
  final Color? color;

  const AssetTypeIcon({
    super.key,
    required this.assetType,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;

    return Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        color: _getBackgroundColor(assetType, theme),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        _getIconData(assetType),
        size: size,
        color: iconColor,
      ),
    );
  }

  /// Get the appropriate icon for each asset type
  IconData _getIconData(AssetType type) {
    switch (type) {
      case AssetType.stock:
        return Icons.trending_up;
      case AssetType.resource:
        return Icons.eco;
      case AssetType.cfd:
        return Icons.swap_horiz;
      case AssetType.crypto:
        return Icons.currency_bitcoin;
      case AssetType.other:
        return Icons.help_outline;
    }
  }

  /// Get background color for the icon container based on asset type
  Color _getBackgroundColor(AssetType type, ThemeData theme) {
    switch (type) {
      case AssetType.stock:
        return Colors.blue.withValues(alpha: 0.1);
      case AssetType.resource:
        return Colors.green.withValues(alpha: 0.1);
      case AssetType.cfd:
        return Colors.orange.withValues(alpha: 0.1);
      case AssetType.crypto:
        return Colors.purple.withValues(alpha: 0.1);
      case AssetType.other:
        return theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    }
  }
}