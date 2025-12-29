import 'package:flutter/material.dart';
import '../models/asset_item.dart';
import 'tag_management_dialog.dart';

/// Widget that displays tags in a horizontal flow layout with wrapping
/// Supports maximum 2 rows with overflow indicator
class TagsSection extends StatelessWidget {
  final AssetItem asset;
  final Function(AssetItem)? onAssetUpdated;
  final VoidCallback? onTagTap;
  final int maxRows;
  final int itemsPerRow;
  final bool enableManagement;

  const TagsSection({
    super.key,
    required this.asset,
    this.onAssetUpdated,
    this.onTagTap,
    this.maxRows = 2,
    this.itemsPerRow = 4,
    this.enableManagement = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // If no tags and management is disabled, don't show the section
    if (asset.tags.isEmpty && !enableManagement) {
      return const SizedBox.shrink();
    }

    final filteredTags = asset.getFilteredTags(
      maxRows: maxRows,
      itemsPerRow: itemsPerRow,
      reserveSpaceForEditButton: enableManagement,
    );
    final hasOverflow = asset.hasOverflowTags(
      maxRows: maxRows,
      itemsPerRow: itemsPerRow,
      reserveSpaceForEditButton: enableManagement,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags flow layout or empty state (no header)
          if (asset.tags.isEmpty)
            _buildEmptyState(context, theme)
          else
            _buildTagsFlow(context, theme, filteredTags, hasOverflow),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: enableManagement ? () => _showTagManagement(context) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Text(
                enableManagement ? 'Tap to add tags' : 'No tags added yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (enableManagement) ...[
          const SizedBox(width: 8),
          _buildEditButtonForEmptyState(context, theme),
        ],
      ],
    );
  }

  Widget _buildEditButtonForEmptyState(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showTagManagement(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 12,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.edit,
              size: 10,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showTagManagement(BuildContext context) {
    if (onAssetUpdated == null) return;
    
    TagManagement.showTagManagementDialog(
      context: context,
      asset: asset,
      onAssetUpdated: onAssetUpdated!,
    );
  }

  Widget _buildTagsFlow(
    BuildContext context,
    ThemeData theme,
    List<String> tags,
    bool hasOverflow,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _TagFlowLayout(
          tags: tags,
          hasOverflow: hasOverflow,
          maxRows: maxRows,
          onTagTap: onTagTap,
          onEditTap: enableManagement ? () => _showTagManagement(context) : null,
          theme: theme,
          availableWidth: constraints.maxWidth,
        );
      },
    );
  }
}

/// Custom widget that handles the flow layout logic for tags
class _TagFlowLayout extends StatelessWidget {
  final List<String> tags;
  final bool hasOverflow;
  final int maxRows;
  final VoidCallback? onTagTap;
  final VoidCallback? onEditTap;
  final ThemeData theme;
  final double availableWidth;

  const _TagFlowLayout({
    required this.tags,
    required this.hasOverflow,
    required this.maxRows,
    required this.onTagTap,
    required this.onEditTap,
    required this.theme,
    required this.availableWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        // Display filtered tags
        ...tags.map((tag) => _buildTagChip(tag)),
        
        // Show overflow indicator if needed
        if (hasOverflow) _buildOverflowIndicator(),
        
        // Always show edit button at the end if editing is enabled
        if (onEditTap != null) _buildEditButton(),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return GestureDetector(
      onTap: onTagTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          tag,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildOverflowIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return GestureDetector(
      onTap: onEditTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 12,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.edit,
              size: 10,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}