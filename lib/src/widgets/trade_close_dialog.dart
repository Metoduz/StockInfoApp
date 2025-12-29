import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/active_trade.dart';
import '../strategies/trading_strategy_base.dart';

/// Dialog for closing an active trade by entering sell price
class TradeCloseDialog extends StatefulWidget {
  final ActiveTradeItem trade;
  final double currentPrice;
  final String currency;
  final Function(double sellPrice) onConfirm;

  const TradeCloseDialog({
    super.key,
    required this.trade,
    required this.currentPrice,
    required this.currency,
    required this.onConfirm,
  });

  @override
  State<TradeCloseDialog> createState() => _TradeCloseDialogState();
}

class _TradeCloseDialogState extends State<TradeCloseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sellPriceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with current market price
    _sellPriceController.text = widget.currentPrice.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _sellPriceController.dispose();
    super.dispose();
  }

  double? get _sellPrice {
    final text = _sellPriceController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  double? get _estimatedPnL {
    final sellPrice = _sellPrice;
    if (sellPrice == null) return null;
    return widget.trade.calculatePnL(sellPrice);
  }

  double? get _estimatedPnLPercentage {
    final sellPrice = _sellPrice;
    if (sellPrice == null) return null;
    return widget.trade.calculatePnLPercentage(sellPrice);
  }

  bool get _isProfitable {
    final pnl = _estimatedPnL;
    return pnl != null && pnl >= 0;
  }

  void _handleConfirm() async {
    if (!_formKey.currentState!.validate()) return;

    final sellPrice = _sellPrice!;
    
    setState(() {
      _isLoading = true;
    });

    try {
      widget.onConfirm(sellPrice);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to close trade: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.close,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Close Trade'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trade summary
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
                    'Trade Summary',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.trade.direction == TradeDirection.long
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.trade.direction == TradeDirection.long
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 14,
                              color: widget.trade.direction == TradeDirection.long
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.trade.direction.displayName,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: widget.trade.direction == TradeDirection.long
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Qty: ${widget.trade.quantity.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buy Price: ${widget.trade.buyPrice.toStringAsFixed(2)} ${widget.currency}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Total Value: ${widget.trade.getTotalValue().toStringAsFixed(2)} ${widget.currency}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Current Price: ${widget.currentPrice.toStringAsFixed(2)} ${widget.currency}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sell price input
            TextFormField(
              controller: _sellPriceController,
              decoration: InputDecoration(
                labelText: 'Sell Price',
                suffixText: widget.currency,
                helperText: 'Enter the price at which you want to close this trade',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a sell price';
                }
                final price = double.tryParse(value.trim());
                if (price == null) {
                  return 'Please enter a valid price';
                }
                if (price <= 0) {
                  return 'Price must be greater than 0';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  // Trigger rebuild to update P&L calculation
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // P&L estimation
            if (_sellPrice != null && _estimatedPnL != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isProfitable 
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isProfitable 
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isProfitable ? Icons.trending_up : Icons.trending_down,
                          color: _isProfitable ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Estimated P&L',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _isProfitable ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_isProfitable ? '+' : ''}${_estimatedPnLPercentage!.toStringAsFixed(2)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _isProfitable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_isProfitable ? '+' : ''}${_estimatedPnL!.toStringAsFixed(2)} ${widget.currency}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _isProfitable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Warning for losses
            if (_sellPrice != null && _estimatedPnL != null && !_isProfitable) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: colorScheme.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This trade will result in a loss',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleConfirm,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Close Trade'),
        ),
      ],
    );
  }
}