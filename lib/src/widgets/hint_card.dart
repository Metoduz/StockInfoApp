import 'package:flutter/material.dart';
import '../models/stock_item.dart';

class HintCard extends StatelessWidget {
  final StockHint hint;

  const HintCard({
    super.key,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = _getHintColor(hint.type, theme);
    final icon = _getHintIcon(hint.type);
    final title = _getHintTitle(hint.type);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Icon(icon, size: 16, color: _getIconColor(hint.type, theme)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(hint.type, theme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              hint.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getTextColor(hint.type, theme),
              ),
            ),

            // Value and timestamp if available
            if (hint.value != null || hint.timestamp != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (hint.value != null)
                    Text(
                      'Value: ${hint.value!.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor(hint.type, theme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (hint.value != null && hint.timestamp != null)
                    const SizedBox(width: 16),
                  if (hint.timestamp != null)
                    Text(
                      _formatTimestamp(hint.timestamp!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor(hint.type, theme)?.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getHintColor(String hintType, ThemeData theme) {
    switch (hintType) {
      case 'buy_zone':
        return Colors.green.withOpacity(0.15);
      case 'trendline':
        return Colors.blue.withOpacity(0.15);
      case 'support':
        return Colors.orange.withOpacity(0.15);
      case 'resistance':
        return Colors.red.withOpacity(0.15);
      default:
        return theme.colorScheme.surfaceContainerHighest.withOpacity(0.8);
    }
  }

  IconData _getHintIcon(String hintType) {
    switch (hintType) {
      case 'buy_zone':
        return Icons.shopping_cart;
      case 'trendline':
        return Icons.trending_up;
      case 'support':
        return Icons.support;
      case 'resistance':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  String _getHintTitle(String hintType) {
    switch (hintType) {
      case 'buy_zone':
        return 'Buy Zone';
      case 'trendline':
        return 'Trend Analysis';
      case 'support':
        return 'Support Level';
      case 'resistance':
        return 'Resistance Level';
      default:
        return 'Hint';
    }
  }

  Color? _getIconColor(String hintType, ThemeData theme) {
    switch (hintType) {
      case 'buy_zone':
        return Colors.green[700];
      case 'trendline':
        return Colors.blue[700];
      case 'support':
        return Colors.orange[700];
      case 'resistance':
        return Colors.red[700];
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Color? _getTextColor(String hintType, ThemeData theme) {
    switch (hintType) {
      case 'buy_zone':
        return Colors.green[800];
      case 'trendline':
        return Colors.blue[800];
      case 'support':
        return Colors.orange[800];
      case 'resistance':
        return Colors.red[800];
      default:
        return theme.colorScheme.onSurface;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
  }
}
