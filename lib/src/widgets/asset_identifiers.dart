import 'package:flutter/material.dart';
import '../models/enhanced_asset_item.dart';

/// Widget that displays asset identifiers (Name, ISIN, WKN, Short Name) on the left side
/// Implements responsive text layout for different screen sizes
class AssetIdentifiers extends StatelessWidget {
  final EnhancedAssetItem asset;

  const AssetIdentifiers({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Asset name (primary)
          Text(
            asset.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const SizedBox(height: 4),
          
          // Secondary identifiers
          _buildIdentifierRow(context),
        ],
      ),
    );
  }

  /// Build the row of secondary identifiers (ISIN, WKN, Short Name)
  Widget _buildIdentifierRow(BuildContext context) {
    final theme = Theme.of(context);
    final identifiers = <Widget>[];
    
    // Add ISIN if available
    if (asset.isin != null && asset.isin!.isNotEmpty) {
      identifiers.add(_buildIdentifierChip(
        context,
        'ISIN',
        asset.isin!,
        theme,
      ));
    }
    
    // Add WKN if available
    if (asset.wkn != null && asset.wkn!.isNotEmpty) {
      identifiers.add(_buildIdentifierChip(
        context,
        'WKN',
        asset.wkn!,
        theme,
      ));
    }
    
    // Add ticker/symbol as short name if available
    if (asset.ticker != null && asset.ticker!.isNotEmpty) {
      identifiers.add(_buildIdentifierChip(
        context,
        'Ticker',
        asset.ticker!,
        theme,
      ));
    } else if (asset.symbol.isNotEmpty && asset.symbol != asset.name) {
      identifiers.add(_buildIdentifierChip(
        context,
        'Symbol',
        asset.symbol,
        theme,
      ));
    }
    
    // If no secondary identifiers, show the primary ID
    if (identifiers.isEmpty) {
      identifiers.add(_buildIdentifierChip(
        context,
        'ID',
        asset.id,
        theme,
      ));
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // For narrow screens, show identifiers vertically
        if (constraints.maxWidth < 200) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: identifiers
                .map((widget) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: widget,
                    ))
                .toList(),
          );
        }
        
        // For wider screens, show identifiers horizontally with wrapping
        return Wrap(
          spacing: 8,
          runSpacing: 2,
          children: identifiers,
        );
      },
    );
  }

  /// Build a small chip-like widget for displaying identifier information
  Widget _buildIdentifierChip(
    BuildContext context,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 11,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}