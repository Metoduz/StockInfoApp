import 'package:flutter/material.dart';
import '../models/active_trade.dart';
import '../models/asset_item.dart';
import '../strategies/trading_strategy_base.dart';
import '../services/storage_service.dart';
import '../screens/trade_detail_screen.dart';
import 'trade_close_dialog.dart';

/// Widget that displays the active trades section in a simple list format
/// without expand/collapse functionality (controlled by parent)
class ActiveTradesSection extends StatelessWidget {
  final AssetItem asset;
  final List<ActiveTradeItem> activeTrades;
  final VoidCallback? onAddTrade;
  final Function(ActiveTradeItem)? onTradeEdit;
  final Function(ActiveTradeItem)? onTradeDelete;
  final Function(ActiveTradeItem)? onTradeClose;
  final bool isExpanded;

  const ActiveTradesSection({
    super.key,
    required this.asset,
    required this.activeTrades,
    this.onAddTrade,
    this.onTradeEdit,
    this.onTradeDelete,
    this.onTradeClose,
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
          // Add Trade button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddTrade,
              icon: const Icon(Icons.add),
              label: const Text('Add Trade'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          if (activeTrades.isNotEmpty) ...[
            const SizedBox(height: 16),
            
            // Active trades list
            ...activeTrades.map((trade) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildTradeItem(context, trade, theme),
            )),
          ] else ...[
            const SizedBox(height: 16),
            _buildEmptyState(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.trending_flat,
            size: 48,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'No active trades',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeItem(BuildContext context, ActiveTradeItem trade, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
    // Calculate P&L
    final pnl = trade.calculatePnL(asset.currentValue);
    final pnlPercentage = trade.calculatePnLPercentage(asset.currentValue);
    final isProfitable = pnl >= 0;
    
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToTradeDetail(context, trade),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Trade direction indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: trade.direction == TradeDirection.long
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trade.direction == TradeDirection.long
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 16,
                          color: trade.direction == TradeDirection.long
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trade.direction.displayName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: trade.direction == TradeDirection.long
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Notice indicator
                  if (trade.hasNotice())
                    Icon(
                      Icons.note,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  
                  const SizedBox(width: 8),
                  
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _showCloseTradeDialog(context, trade),
                        icon: const Icon(Icons.close),
                        iconSize: 18,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Close Trade',
                      ),
                      IconButton(
                        onPressed: () => _showDeleteConfirmation(context, trade),
                        icon: const Icon(Icons.delete_outline),
                        iconSize: 18,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Delete Trade',
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Trade details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity: ${trade.quantity.toStringAsFixed(2)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Buy Price: ${trade.buyPrice.toStringAsFixed(2)} ${asset.currency}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // P&L display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isProfitable ? '+' : ''}${pnlPercentage.toStringAsFixed(2)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isProfitable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${isProfitable ? '+' : ''}${pnl.toStringAsFixed(2)} ${asset.currency}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isProfitable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTradeDetail(BuildContext context, ActiveTradeItem trade) async {
    final result = await Navigator.of(context).push<ActiveTradeItem>(
      MaterialPageRoute(
        builder: (context) => TradeDetailScreen(
          trade: trade,
          asset: asset,
        ),
      ),
    );
    
    // If trade was updated, notify parent
    if (result != null && onTradeEdit != null) {
      onTradeEdit!(result);
    }
  }

  void _showDeleteConfirmation(BuildContext context, ActiveTradeItem trade) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Trade'),
          content: Text(
            'Are you sure you want to delete this ${trade.direction.displayName.toLowerCase()} trade?\n\n'
            'Quantity: ${trade.quantity.toStringAsFixed(2)}\n'
            'Buy Price: ${trade.buyPrice.toStringAsFixed(2)} ${asset.currency}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onTradeDelete?.call(trade);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showCloseTradeDialog(BuildContext context, ActiveTradeItem trade) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TradeCloseDialog(
          trade: trade,
          currentPrice: asset.currentValue,
          currency: asset.currency,
          onConfirm: (sellPrice) async {
            try {
              final storageService = StorageService();
              await storageService.closeActiveTrade(
                trade.id,
                sellPrice,
                DateTime.now(),
              );
              
              // Call the callback to notify parent widget
              onTradeClose?.call(trade);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Trade closed successfully'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to close trade: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}