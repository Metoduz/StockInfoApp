import 'package:flutter/material.dart';
import '../models/asset_item.dart';
import 'hint_card.dart';

class AssetCard extends StatefulWidget {
  final AssetItem asset;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.asset,
    this.onTap,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard> {
  bool _hintsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositiveChange = widget.asset.calculatedDayChange >= 0;
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
              // Asset name and ISIN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.asset.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    widget.asset.isin ?? widget.asset.id,
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
                    '${widget.asset.currentValue.toStringAsFixed(2)} ${widget.asset.currency}',
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
                        '${widget.asset.calculatedDayChange.abs().toStringAsFixed(2)} '
                        '(${widget.asset.calculatedDayChangePercent.abs().toStringAsFixed(2)}%)',
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
              if (widget.asset.hints.isNotEmpty) ...[
                Divider(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 8),
                // Original chip markers
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.asset.hints.map((hint) {
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
                    children: widget.asset.hints.map((hint) {
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
