import 'package:flutter/material.dart';
import '../models/active_trade.dart';
import '../models/asset_item.dart';
import '../strategies/trading_strategy_base.dart';
import '../services/storage_service.dart';
import '../screens/trade_detail_screen.dart';
import 'trade_close_dialog.dart';

/// Widget that displays an individual active trade item
class ActiveTradeItemWidget extends StatelessWidget {
  final ActiveTradeItem trade;
  final AssetItem asset;
  final double currentPrice;
  final String currency;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onClose;
  final Function(ActiveTradeItem)? onTradeUpdated;

  const ActiveTradeItemWidget({
    super.key,
    required this.trade,
    required this.asset,
    required this.currentPrice,
    required this.currency,
    this.onTap,
    this.onDelete,
    this.onClose,
    this.onTradeUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate P&L
    final pnl = trade.calculatePnL(currentPrice);
    final pnlPercentage = trade.calculatePnLPercentage(currentPrice);
    final isProfitable = pnl >= 0;
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () => _navigateToTradeDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with direction and actions
              Row(
                children: [
                  // Trade direction indicator
                  _buildDirectionIndicator(context),
                  
                  const Spacer(),
                  
                  // Notice indicator
                  if (trade.hasNotice()) ...[
                    Icon(
                      Icons.note,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Stop loss alert indicator
                  if (trade.stopLoss?.alertEnabled == true) ...[
                    Icon(
                      Icons.alarm,
                      size: 18,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // Action buttons
                  _buildActionButtons(context),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Trade details row
              Row(
                children: [
                  // Left side - Trade details
                  Expanded(
                    flex: 2,
                    child: _buildTradeDetails(context),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Right side - P&L
                  Expanded(
                    flex: 1,
                    child: _buildPnLDisplay(context, pnl, pnlPercentage, isProfitable),
                  ),
                ],
              ),
              
              // Stop loss information (if configured)
              if (trade.stopLoss != null) ...[
                const SizedBox(height: 8),
                _buildStopLossInfo(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final isLong = trade.direction == TradeDirection.long;
    final color = isLong ? Colors.green : Colors.red;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLong ? Icons.trending_up : Icons.trending_down,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            trade.direction.displayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close trade button
        IconButton(
          onPressed: () => _showCloseTradeDialog(context),
          icon: const Icon(Icons.close),
          iconSize: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'Close Trade',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
            foregroundColor: colorScheme.onPrimaryContainer,
          ),
        ),
        
        const SizedBox(width: 4),
        
        // Delete trade button
        IconButton(
          onPressed: () => _showDeleteConfirmation(context),
          icon: const Icon(Icons.delete_outline),
          iconSize: 20,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          tooltip: 'Delete Trade',
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.5),
            foregroundColor: colorScheme.onErrorContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildTradeDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quantity
        Row(
          children: [
            Icon(
              Icons.numbers,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Qty: ${trade.quantity.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Buy price
        Row(
          children: [
            Icon(
              Icons.attach_money,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Buy: ${trade.buyPrice.toStringAsFixed(2)} $currency',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Total value
        Row(
          children: [
            Icon(
              Icons.calculate,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Value: ${trade.getTotalValue().toStringAsFixed(2)} $currency',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPnLDisplay(BuildContext context, double pnl, double pnlPercentage, bool isProfitable) {
    final theme = Theme.of(context);
    final color = isProfitable ? Colors.green : Colors.red;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Percentage P&L
        Text(
          '${isProfitable ? '+' : ''}${pnlPercentage.toStringAsFixed(2)}%',
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Absolute P&L
        Text(
          '${isProfitable ? '+' : ''}${pnl.toStringAsFixed(2)} $currency',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Current price
        Text(
          'Current: ${currentPrice.toStringAsFixed(2)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStopLossInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stopLoss = trade.stopLoss!;
    
    String stopLossText;
    if (stopLoss.type == StopLossType.fixed && stopLoss.fixedValue != null) {
      stopLossText = 'Stop Loss: ${stopLoss.fixedValue!.toStringAsFixed(2)} $currency';
    } else if (stopLoss.type == StopLossType.trailing && stopLoss.trailingAmount != null) {
      final unit = stopLoss.isPercentage ? '%' : currency;
      stopLossText = 'Trailing Stop: ${stopLoss.trailingAmount!.toStringAsFixed(2)} $unit';
    } else {
      stopLossText = 'Stop Loss: Configured';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stopLoss.alertEnabled ? Icons.alarm : Icons.alarm_off,
            size: 14,
            color: stopLoss.alertEnabled ? Colors.red : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            stopLossText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTradeDetail(BuildContext context) async {
    final result = await Navigator.of(context).push<ActiveTradeItem>(
      MaterialPageRoute(
        builder: (context) => TradeDetailScreen(
          trade: trade,
          asset: asset,
        ),
      ),
    );
    
    // If trade was updated, notify parent
    if (result != null && onTradeUpdated != null) {
      onTradeUpdated!(result);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
              ),
              const SizedBox(width: 8),
              const Text('Delete Trade'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to delete this trade?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trade Details:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Direction: ${trade.direction.displayName}'),
                    Text('Quantity: ${trade.quantity.toStringAsFixed(2)}'),
                    Text('Buy Price: ${trade.buyPrice.toStringAsFixed(2)} $currency'),
                    Text('Total Value: ${trade.getTotalValue().toStringAsFixed(2)} $currency'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showCloseTradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TradeCloseDialog(
          trade: trade,
          currentPrice: currentPrice,
          currency: currency,
          onConfirm: (sellPrice) async {
            try {
              final storageService = StorageService();
              await storageService.closeActiveTrade(
                trade.id,
                sellPrice,
                DateTime.now(),
              );
              
              // Call the callback to notify parent widget
              onClose?.call();
              
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