import 'package:flutter/material.dart';
import '../models/enhanced_asset_item.dart';

/// Widget that displays performance metrics with three key values:
/// - Daily performance percentage
/// - Open trades total performance for this asset
/// - All trades (open + closed) total performance
class PerformanceMetrics extends StatelessWidget {
  final EnhancedAssetItem asset;

  const PerformanceMetrics({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current price
        Text(
          '${asset.currentValue.toStringAsFixed(2)} ${asset.currency}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        // Daily performance
        _buildPerformanceRow(
          context,
          'Daily',
          asset.getDailyPerformancePercent(),
          theme,
          showAbsoluteValue: true,
          absoluteValue: asset.calculatedDayChange,
          currency: asset.currency,
        ),
        const SizedBox(height: 4),
        
        // Open trades performance
        _buildPerformanceRow(
          context,
          'Open Trades',
          asset.getOpenTradesPerformance(),
          theme,
        ),
        const SizedBox(height: 4),
        
        // All trades performance
        _buildPerformanceRow(
          context,
          'All Trades',
          asset.getAllTradesPerformance(),
          theme,
        ),
      ],
    );
  }

  /// Build a row showing performance metric with label and value
  Widget _buildPerformanceRow(
    BuildContext context,
    String label,
    double percentage,
    ThemeData theme, {
    bool showAbsoluteValue = false,
    double? absoluteValue,
    String? currency,
  }) {
    final isPositive = percentage >= 0;
    final color = _getPerformanceColor(percentage, theme);
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 4),
        
        // Performance icon
        Icon(
          icon,
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        
        // Performance percentage
        Text(
          '${percentage.abs().toStringAsFixed(2)}%',
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        
        // Absolute value (for daily performance)
        if (showAbsoluteValue && absoluteValue != null && currency != null) ...[
          const SizedBox(width: 4),
          Text(
            '(${absoluteValue.abs().toStringAsFixed(2)} $currency)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  /// Get color for performance value based on positive/negative
  Color _getPerformanceColor(double value, ThemeData theme) {
    if (value > 0) {
      return Colors.green.shade600;
    } else if (value < 0) {
      return Colors.red.shade600;
    } else {
      return theme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }
}