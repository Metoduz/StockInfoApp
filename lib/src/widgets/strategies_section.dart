import 'package:flutter/material.dart';
import '../models/asset_item.dart';
import '../strategies/trading_strategy_base.dart' as strategy_base;
import 'trading_strategy_item.dart' as widgets;
import 'composite_strategy_item.dart';

/// Widget that displays trading strategies in a simple list format
/// without expand/collapse functionality (controlled by parent)
class StrategiesSection extends StatelessWidget {
  final AssetItem asset;
  final Function(AssetItem)? onAssetUpdated;
  final VoidCallback? onAddStrategy;
  final Function(strategy_base.TradingStrategyItem)? onStrategyTap;
  final Function(String)? onStrategyDelete;
  final Function(String, bool)? onAlertToggle;
  final bool isExpanded;

  const StrategiesSection({
    super.key,
    required this.asset,
    this.onAssetUpdated,
    this.onAddStrategy,
    this.onStrategyTap,
    this.onStrategyDelete,
    this.onAlertToggle,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isExpanded) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Strategy button
          _buildAddStrategyButton(theme),
          
          const SizedBox(height: 12),
          
          // Strategies list
          if (asset.strategies.isEmpty)
            _buildEmptyState(theme)
          else
            _buildStrategiesList(theme),
        ],
      ),
    );
  }

  Widget _buildAddStrategyButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onAddStrategy,
        icon: Icon(
          Icons.add,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        label: Text(
          'Add Strategy',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.trending_up,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            'No strategies added yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add trading strategies to track your investment approach',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesList(ThemeData theme) {
    return Column(
      children: asset.strategies.asMap().entries.map((entry) {
        final index = entry.key;
        final strategy = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < asset.strategies.length - 1 ? 8 : 0,
          ),
          child: _buildStrategyItem(strategy, theme),
        );
      }).toList(),
    );
  }

  Widget _buildStrategyItem(strategy_base.TradingStrategyItem strategy, ThemeData theme) {
    // Check if this is a composite strategy
    if (strategy.strategy.type == strategy_base.StrategyType.composite) {
      return CompositeStrategyItem(
        strategyItem: strategy,
        onTap: () => onStrategyTap?.call(strategy),
        onDelete: () => onStrategyDelete?.call(strategy.id),
        onAlertToggle: (enabled) => onAlertToggle?.call(strategy.id, enabled),
      );
    } else {
      return widgets.TradingStrategyItem(
        strategyItem: strategy,
        onTap: () => onStrategyTap?.call(strategy),
        onDelete: () => onStrategyDelete?.call(strategy.id),
        onAlertToggle: (enabled) => onAlertToggle?.call(strategy.id, enabled),
      );
    }
  }
}