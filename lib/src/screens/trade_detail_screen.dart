import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/active_trade.dart';
import '../models/asset_item.dart';
import '../strategies/trading_strategy_base.dart';
import '../services/storage_service.dart';

/// Screen for viewing and editing detailed information about an active trade
class TradeDetailScreen extends StatefulWidget {
  final ActiveTradeItem trade;
  final AssetItem asset;

  const TradeDetailScreen({
    super.key,
    required this.trade,
    required this.asset,
  });

  @override
  State<TradeDetailScreen> createState() => _TradeDetailScreenState();
}

class _TradeDetailScreenState extends State<TradeDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _feesController = TextEditingController();
  final _noticeController = TextEditingController();
  final _fixedStopLossController = TextEditingController();
  final _trailingStopLossController = TextEditingController();

  late TradeDirection _selectedDirection;
  StopLossType? _selectedStopLossType;
  bool _stopLossIsPercentage = false;
  bool _stopLossAlertEnabled = false;
  bool _isLoading = false;
  String? _feedbackMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadTradeData();
  }

  void _loadTradeData() {
    final trade = widget.trade;
    
    _quantityController.text = trade.quantity.toString();
    _buyPriceController.text = trade.buyPrice.toString();
    _feesController.text = trade.fees?.toString() ?? '';
    _noticeController.text = trade.notice ?? '';
    _selectedDirection = trade.direction;
    
    if (trade.stopLoss != null) {
      final stopLoss = trade.stopLoss!;
      _selectedStopLossType = stopLoss.type;
      _stopLossIsPercentage = stopLoss.isPercentage;
      _stopLossAlertEnabled = stopLoss.alertEnabled;
      
      if (stopLoss.type == StopLossType.fixed && stopLoss.fixedValue != null) {
        _fixedStopLossController.text = stopLoss.fixedValue!.toString();
      }
      
      if (stopLoss.type == StopLossType.trailing && stopLoss.trailingAmount != null) {
        _trailingStopLossController.text = stopLoss.trailingAmount!.toString();
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _buyPriceController.dispose();
    _feesController.dispose();
    _noticeController.dispose();
    _fixedStopLossController.dispose();
    _trailingStopLossController.dispose();
    super.dispose();
  }

  void _showFeedback(String message, bool isSuccess) {
    setState(() {
      _feedbackMessage = message;
      _isSuccess = isSuccess;
    });

    // Clear feedback after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _feedbackMessage = null;
        });
      }
    });
  }

  Future<void> _saveTrade() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = double.parse(_quantityController.text);
      final buyPrice = double.parse(_buyPriceController.text);
      final fees = _feesController.text.isEmpty ? null : double.parse(_feesController.text);
      final notice = _noticeController.text.trim().isEmpty ? null : _noticeController.text.trim();

      // Create stop loss configuration if selected
      StopLossConfig? stopLoss;
      if (_selectedStopLossType != null) {
        switch (_selectedStopLossType!) {
          case StopLossType.fixed:
            final fixedValue = _fixedStopLossController.text.isEmpty 
                ? null 
                : double.parse(_fixedStopLossController.text);
            if (fixedValue != null) {
              stopLoss = StopLossConfig(
                type: StopLossType.fixed,
                fixedValue: fixedValue,
                alertEnabled: _stopLossAlertEnabled,
              );
            }
            break;
          case StopLossType.trailing:
            final trailingAmount = _trailingStopLossController.text.isEmpty 
                ? null 
                : double.parse(_trailingStopLossController.text);
            if (trailingAmount != null) {
              stopLoss = StopLossConfig(
                type: StopLossType.trailing,
                trailingAmount: trailingAmount,
                isPercentage: _stopLossIsPercentage,
                alertEnabled: _stopLossAlertEnabled,
              );
            }
            break;
        }
      }

      // Create updated trade
      final updatedTrade = widget.trade.copyWith(
        direction: _selectedDirection,
        quantity: quantity,
        buyPrice: buyPrice,
        fees: fees,
        notice: notice,
        stopLoss: stopLoss,
      );

      // Save to storage
      final storageService = StorageService();
      await storageService.updateActiveTrade(updatedTrade);

      _showFeedback('Trade updated successfully!', true);
      
      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop(updatedTrade);
        }
      });
      
    } catch (e) {
      _showFeedback('Failed to save trade: ${e.toString()}', false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildFeedbackMessage() {
    if (_feedbackMessage == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSuccess 
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.error,
            color: _isSuccess 
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _feedbackMessage!,
              style: TextStyle(
                color: _isSuccess 
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeOverview() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Calculate current P&L
    final pnl = widget.trade.calculatePnL(widget.asset.currentValue);
    final pnlPercentage = widget.trade.calculatePnLPercentage(widget.asset.currentValue);
    final isProfitable = pnl >= 0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trade Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Asset information
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asset',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        widget.asset.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Current Price',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${widget.asset.currentValue.toStringAsFixed(2)} ${widget.asset.currency}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // P&L information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isProfitable 
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isProfitable 
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isProfitable ? Icons.trending_up : Icons.trending_down,
                    color: isProfitable ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current P&L',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isProfitable ? Colors.green : Colors.red,
                          ),
                        ),
                        Text(
                          '${isProfitable ? '+' : ''}${pnlPercentage.toStringAsFixed(2)}% (${isProfitable ? '+' : ''}${pnl.toStringAsFixed(2)} ${widget.asset.currency})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isProfitable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Trade dates
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Opened',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${widget.trade.openDate.day}/${widget.trade.openDate.month}/${widget.trade.openDate.year}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.trade.status.displayName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeDetailsForm() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trade Details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Trade direction
            DropdownButtonFormField<TradeDirection>(
              value: _selectedDirection,
              decoration: const InputDecoration(
                labelText: 'Trade Direction',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.swap_vert),
              ),
              items: TradeDirection.values.map((direction) {
                return DropdownMenuItem(
                  value: direction,
                  child: Row(
                    children: [
                      Icon(
                        direction == TradeDirection.long 
                            ? Icons.trending_up 
                            : Icons.trending_down,
                        color: direction == TradeDirection.long 
                            ? Colors.green 
                            : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(direction.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (TradeDirection? newDirection) {
                if (newDirection != null) {
                  setState(() {
                    _selectedDirection = newDirection;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // Quantity
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
                helperText: 'Number of shares/units',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid positive quantity';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Buy price
            TextFormField(
              controller: _buyPriceController,
              decoration: InputDecoration(
                labelText: 'Buy Price',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: widget.asset.currency,
                helperText: 'Price per share/unit',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter buy price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid positive price';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Fees (optional)
            TextFormField(
              controller: _feesController,
              decoration: InputDecoration(
                labelText: 'Fees (Optional)',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.receipt),
                suffixText: widget.asset.currency,
                helperText: 'Trading fees and commissions',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final fees = double.tryParse(value);
                  if (fees == null || fees < 0) {
                    return 'Please enter a valid non-negative fee amount';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopLossSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stop Loss Configuration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stop loss type selection
            DropdownButtonFormField<StopLossType?>(
              value: _selectedStopLossType,
              decoration: const InputDecoration(
                labelText: 'Stop Loss Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.security),
              ),
              items: [
                const DropdownMenuItem<StopLossType?>(
                  value: null,
                  child: Text('No Stop Loss'),
                ),
                ...StopLossType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          type == StopLossType.fixed 
                              ? Icons.horizontal_rule 
                              : Icons.trending_down,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (StopLossType? newType) {
                setState(() {
                  _selectedStopLossType = newType;
                  // Clear controllers when changing type
                  _fixedStopLossController.clear();
                  _trailingStopLossController.clear();
                });
              },
            ),
            
            if (_selectedStopLossType != null) ...[
              const SizedBox(height: 16),
              
              // Fixed stop loss value
              if (_selectedStopLossType == StopLossType.fixed)
                TextFormField(
                  controller: _fixedStopLossController,
                  decoration: InputDecoration(
                    labelText: 'Fixed Stop Loss Price',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.price_change),
                    suffixText: widget.asset.currency,
                    helperText: 'Absolute price to trigger stop loss',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (_selectedStopLossType == StopLossType.fixed) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter fixed stop loss price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid positive price';
                      }
                    }
                    return null;
                  },
                ),
              
              // Trailing stop loss value
              if (_selectedStopLossType == StopLossType.trailing) ...[
                TextFormField(
                  controller: _trailingStopLossController,
                  decoration: InputDecoration(
                    labelText: 'Trailing Stop Loss Amount',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.trending_down),
                    suffixText: _stopLossIsPercentage ? '%' : widget.asset.currency,
                    helperText: 'Amount to trail behind current price',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (_selectedStopLossType == StopLossType.trailing) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter trailing stop loss amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid positive amount';
                      }
                      if (_stopLossIsPercentage && amount >= 100) {
                        return 'Percentage must be less than 100%';
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Percentage toggle
                SwitchListTile(
                  title: const Text('Use Percentage'),
                  subtitle: Text(
                    _stopLossIsPercentage 
                        ? 'Trailing amount as percentage of current price'
                        : 'Trailing amount as absolute value',
                  ),
                  value: _stopLossIsPercentage,
                  onChanged: (bool value) {
                    setState(() {
                      _stopLossIsPercentage = value;
                    });
                  },
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Alert toggle
              SwitchListTile(
                title: const Text('Enable Stop Loss Alerts'),
                subtitle: const Text('Get notified when stop loss is triggered'),
                value: _stopLossAlertEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _stopLossAlertEnabled = value;
                  });
                },
                secondary: Icon(
                  _stopLossAlertEnabled ? Icons.alarm : Icons.alarm_off,
                  color: _stopLossAlertEnabled ? Colors.red : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trade Notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _noticeController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
                helperText: 'Add any notes or observations about this trade',
              ),
              maxLines: 4,
              textInputAction: TextInputAction.newline,
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'Notes cannot exceed 500 characters';
                }
                return null;
              },
            ),
            
            if (_noticeController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${_noticeController.text.length}/500 characters',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Details'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveTrade,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildFeedbackMessage(),
            _buildTradeOverview(),
            const SizedBox(height: 16),
            _buildTradeDetailsForm(),
            const SizedBox(height: 16),
            _buildStopLossSection(),
            const SizedBox(height: 16),
            _buildNoticeSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}