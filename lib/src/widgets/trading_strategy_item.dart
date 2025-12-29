import 'package:flutter/material.dart';
import '../strategies/trading_strategy_base.dart' as strategy_base;

/// Widget that displays an individual trading strategy item
/// Shows alert indicator, trade direction, and strategy details
class TradingStrategyItem extends StatelessWidget {
  final strategy_base.TradingStrategyItem strategyItem;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(bool)? onAlertToggle;
  final bool showDeleteButton;

  const TradingStrategyItem({
    super.key,
    required this.strategyItem,
    this.onTap,
    this.onDelete,
    this.onAlertToggle,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with alert and direction indicators
              _buildHeaderRow(theme),
              
              const SizedBox(height: 8),
              
              // Strategy name and type
              _buildStrategyInfo(theme),
              
              const SizedBox(height: 8),
              
              // Strategy parameters summary
              _buildParametersSummary(theme),
              
              // Action buttons row
              if (showDeleteButton || onAlertToggle != null)
                _buildActionButtons(theme, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Row(
      children: [
        // Alert indicator (alarm clock)
        GestureDetector(
          onTap: () => onAlertToggle?.call(!strategyItem.alertEnabled),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: strategyItem.alertEnabled
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.alarm,
              size: 16,
              color: strategyItem.alertEnabled
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Trade direction indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: strategyItem.direction == strategy_base.TradeDirection.long
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                strategyItem.direction == strategy_base.TradeDirection.long
                    ? Icons.trending_up
                    : Icons.trending_down,
                size: 14,
                color: strategyItem.direction == strategy_base.TradeDirection.long
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 4),
              Text(
                strategyItem.direction.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: strategyItem.direction == strategy_base.TradeDirection.long
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Strategy type icon
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            _getStrategyTypeIcon(),
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strategyItem.strategy.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          strategyItem.strategy.type.displayName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildParametersSummary(ThemeData theme) {
    final parameters = strategyItem.strategy.parameters;
    if (parameters.isEmpty) {
      return const SizedBox.shrink();
    }

    // Create a summary of key parameters based on strategy type
    final summary = _getParametersSummary(parameters);
    if (summary.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        summary,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          // Last triggered info
          if (strategyItem.lastTriggered != null) ...[
            Icon(
              Icons.check_circle_outline,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              'Last triggered: ${_formatDate(strategyItem.lastTriggered!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ] else ...[
            Icon(
              Icons.schedule,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Not triggered yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
          
          const Spacer(),
          
          // Delete button
          if (showDeleteButton && onDelete != null)
            IconButton(
              onPressed: () => _showDeleteConfirmation(context),
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: theme.colorScheme.error,
              ),
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(4),
                minimumSize: const Size(32, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStrategyTypeIcon() {
    switch (strategyItem.strategy.type) {
      case strategy_base.StrategyType.trendline:
        return Icons.show_chart;
      case strategy_base.StrategyType.elliotWaves:
        return Icons.waves;
      case strategy_base.StrategyType.buyArea:
        return Icons.location_on;
      case strategy_base.StrategyType.composite:
        return Icons.account_tree;
    }
  }

  String _getParametersSummary(Map<String, dynamic> parameters) {
    switch (strategyItem.strategy.type) {
      case strategy_base.StrategyType.trendline:
        final support = parameters['supportLevel'];
        final resistance = parameters['resistanceLevel'];
        if (support != null && resistance != null) {
          return 'Support: ${support.toStringAsFixed(2)} | Resistance: ${resistance.toStringAsFixed(2)}';
        }
        break;
      case strategy_base.StrategyType.buyArea:
        final lower = parameters['lowerBound'];
        final upper = parameters['upperBound'];
        if (lower != null && upper != null) {
          return 'Buy Area: ${lower.toStringAsFixed(2)} - ${upper.toStringAsFixed(2)}';
        }
        break;
      case strategy_base.StrategyType.elliotWaves:
        final wave = parameters['currentWave'];
        final target = parameters['targetLevel'];
        if (wave != null) {
          String summary = 'Wave: $wave';
          if (target != null) {
            summary += ' | Target: ${target.toStringAsFixed(2)}';
          }
          return summary;
        }
        break;
      case strategy_base.StrategyType.composite:
        // Composite strategies are handled by CompositeStrategyItem
        break;
    }
    return '';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Strategy'),
          content: Text(
            'Are you sure you want to delete the strategy "${strategyItem.strategy.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}