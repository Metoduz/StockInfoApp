import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import 'hint_card.dart';

class StockCard extends StatefulWidget {
  final StockItem stock;
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.stock,
    this.onTap,
  });

  @override
  State<StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<StockCard> {
  bool _hintsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositiveChange = widget.stock.calculatedDayChange >= 0;
    final changeColor = isPositiveChange ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock name and ISIN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.stock.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    widget.stock.isin ?? widget.stock.id,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Current value and change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.stock.currentValue.toStringAsFixed(2)} ${widget.stock.currency}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPositiveChange ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                        color: changeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.stock.calculatedDayChange.abs().toStringAsFixed(2)} '
                        '(${widget.stock.calculatedDayChangePercent.abs().toStringAsFixed(2)}%)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: changeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Hints section (if any)
              if (widget.stock.hints.isNotEmpty) ...[
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                // Original chip markers
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.stock.hints.map((hint) {
                    return Chip(
                      label: Text(
                        hint.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      backgroundColor: _getHintColor(hint.type, theme),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      labelPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                // Expand/collapse button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hintsExpanded = !_hintsExpanded;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _hintsExpanded ? 'Hide Details' : 'Show Details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _hintsExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                // Detailed hint cards (collapsible)
                if (_hintsExpanded) ...[
                  const SizedBox(height: 12),
                  Column(
                    children: widget.stock.hints.map((hint) {
                      return HintCard(hint: hint);
                    }).toList(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getHintColor(String hintType, ThemeData theme) {
    switch (hintType) {
      case 'buy_zone':
        return Colors.green.withValues(alpha: 0.2);
      case 'trendline':
        return Colors.blue.withValues(alpha: 0.2);
      case 'support':
        return Colors.orange.withValues(alpha: 0.2);
      case 'resistance':
        return Colors.red.withValues(alpha: 0.2);
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }
}
