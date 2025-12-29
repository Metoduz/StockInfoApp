import 'package:flutter/material.dart';
import '../models/enhanced_asset_item.dart';

/// Dialog for managing tags on an asset
/// Allows adding and removing tags during asset creation or editing
class TagManagementDialog extends StatefulWidget {
  final EnhancedAssetItem asset;
  final Function(EnhancedAssetItem) onAssetUpdated;

  const TagManagementDialog({
    super.key,
    required this.asset,
    required this.onAssetUpdated,
  });

  @override
  State<TagManagementDialog> createState() => _TagManagementDialogState();
}

class _TagManagementDialogState extends State<TagManagementDialog> {
  late EnhancedAssetItem _currentAsset;
  final TextEditingController _tagController = TextEditingController();
  final FocusNode _tagFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentAsset = widget.asset;
  }

  @override
  void dispose() {
    _tagController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Manage Tags',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add new tag section
            Text(
              'Add New Tag',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    focusNode: _tagFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter tag name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Tag',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current tags section
            Text(
              'Current Tags (${_currentAsset.tags.length})',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Tags display
            if (_currentAsset.tags.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No tags added yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _currentAsset.tags.map((tag) {
                      return _buildRemovableTagChip(tag, theme);
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            widget.onAssetUpdated(_currentAsset);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildRemovableTagChip(String tag, ThemeData theme) {
    return Chip(
      label: Text(
        tag,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
        width: 1,
      ),
      deleteIcon: Icon(
        Icons.close,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onDeleted: () => _removeTag(tag),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _addTag() {
    final tagText = _tagController.text.trim();
    if (tagText.isEmpty) return;

    // Check if tag already exists (case-insensitive)
    final existingTags = _currentAsset.tags.map((t) => t.toLowerCase()).toList();
    if (existingTags.contains(tagText.toLowerCase())) {
      _showErrorSnackBar('Tag already exists');
      return;
    }

    setState(() {
      _currentAsset = _currentAsset.addTag(tagText);
      _tagController.clear();
    });

    // Keep focus on the text field for easy multiple additions
    _tagFocusNode.requestFocus();
  }

  void _removeTag(String tag) {
    setState(() {
      _currentAsset = _currentAsset.removeTag(tag);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Static method to show the tag management dialog
class TagManagement {
  static Future<void> showTagManagementDialog({
    required BuildContext context,
    required EnhancedAssetItem asset,
    required Function(EnhancedAssetItem) onAssetUpdated,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => TagManagementDialog(
        asset: asset,
        onAssetUpdated: onAssetUpdated,
      ),
    );
  }
}