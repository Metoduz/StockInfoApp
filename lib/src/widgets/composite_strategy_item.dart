import 'package:flutter/material.dart';
import '../strategies/trading_strategy_base.dart' as strategy_base;
import '../strategies/composite_strategy.dart';

/// Widget that displays a composite strategy item with logical operators
/// Shows alert indicator, trade direction, and strategy composition details
class CompositeStrategyItem extends StatelessWidget {
  final strategy_base.TradingStrategyItem strategyItem;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Function(bool)? onAlertToggle;
  final bool showDeleteButton;

  const CompositeStrategyItem({
    super.key,
    required this.strategyItem,
    this.onTap,
    this.onDelete,
    this.onAlertToggle,
    this.showDeleteButton = true,
  });

  CompositeStrategy get _compositeStrategy => strategyItem.strategy as CompositeStrategy;

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
              
              // Composite strategy conditions display
              _buildConditionsDisplay(theme),
              
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
        
        // Composite strategy icon
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            Icons.account_tree,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
        
        const SizedBox(width: 4),
        
        // Complexity indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getComplexityColor(theme),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${_compositeStrategy.conditions.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
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
          _compositeStrategy.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              'Composite Strategy',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _compositeStrategy.rootOperator.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConditionsDisplay(ThemeData theme) {
    if (_compositeStrategy.conditions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'No conditions defined',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Strategy description
          Text(
            _compositeStrategy.getDescription(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Individual conditions
          ..._buildConditionsList(theme),
        ],
      ),
    );
  }

  List<Widget> _buildConditionsList(ThemeData theme) {
    final conditions = _compositeStrategy.conditions;
    final widgets = <Widget>[];
    
    for (int i = 0; i < conditions.length; i++) {
      final condition = conditions[i];
      
      // Add operator indicator for non-first conditions
      if (i > 0) {
        final operator = condition.operator ?? _compositeStrategy.rootOperator;
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 1,
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: operator == strategy_base.LogicalOperator.and
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                        : theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    operator.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: operator == strategy_base.LogicalOperator.and
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    height: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      
      // Add condition item
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              // Strategy type icon
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  _getStrategyTypeIcon(condition.strategy.type),
                  size: 12,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              
              const SizedBox(width: 6),
              
              // Strategy name
              Expanded(
                child: Text(
                  condition.strategy.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Strategy type
              Text(
                condition.strategy.type.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return widgets;
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
          
          // Complexity score indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text(
                  '${_compositeStrategy.getComplexityScore()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
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

  IconData _getStrategyTypeIcon(strategy_base.StrategyType type) {
    switch (type) {
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

  Color _getComplexityColor(ThemeData theme) {
    final complexity = _compositeStrategy.getComplexityScore();
    if (complexity <= 2) {
      return theme.colorScheme.primaryContainer.withValues(alpha: 0.5);
    } else if (complexity <= 4) {
      return theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5);
    } else {
      return theme.colorScheme.errorContainer.withValues(alpha: 0.5);
    }
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
          title: const Text('Delete Composite Strategy'),
          content: Text(
            'Are you sure you want to delete the composite strategy "${_compositeStrategy.name}"? This action cannot be undone.',
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