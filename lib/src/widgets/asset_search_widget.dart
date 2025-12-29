import 'package:flutter/material.dart';
import '../models/enhanced_asset_item.dart';
import '../services/tag_search_service.dart';

/// Widget for searching assets by name, tags, and asset type
class AssetSearchWidget extends StatefulWidget {
  final List<EnhancedAssetItem> assets;
  final Function(List<EnhancedAssetItem>) onSearchResults;
  final String? initialQuery;

  const AssetSearchWidget({
    super.key,
    required this.assets,
    required this.onSearchResults,
    this.initialQuery,
  });

  @override
  State<AssetSearchWidget> createState() => _AssetSearchWidgetState();
}

class _AssetSearchWidgetState extends State<AssetSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _selectedTags = [];
  final List<AssetType> _selectedAssetTypes = [];
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allTags = TagSearchService.getAllTags(widget.assets);
    final popularTags = TagSearchService.getMostPopularTags(widget.assets, limit: 8);

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main search field
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search by name or tags...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear search',
                        ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: Icon(
                          _showFilters ? Icons.filter_list_off : Icons.filter_list,
                          color: _hasActiveFilters() ? theme.colorScheme.primary : null,
                        ),
                        tooltip: 'Filters',
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => _performSearch(),
                onSubmitted: (_) => _performSearch(),
              ),

              // Filters section
              if (_showFilters) ...[
                const SizedBox(height: 16),
                _buildFiltersSection(theme, allTags, popularTags),
              ],
            ],
          ),
        ),

        // Active filters display
        if (_hasActiveFilters()) _buildActiveFilters(theme),
      ],
    );
  }

  Widget _buildFiltersSection(ThemeData theme, List<String> allTags, List<String> popularTags) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Asset type filters
          Text(
            'Asset Types',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: AssetType.values.map((type) {
              final isSelected = _selectedAssetTypes.contains(type);
              return FilterChip(
                label: Text(type.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAssetTypes.add(type);
                    } else {
                      _selectedAssetTypes.remove(type);
                    }
                  });
                  _performSearch();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Popular tags
          if (popularTags.isNotEmpty) ...[
            Text(
              'Popular Tags',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: popularTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                    _performSearch();
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFilters(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Active Filters:',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: Text(
                  'Clear All',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // Selected asset types
              ..._selectedAssetTypes.map((type) => Chip(
                label: Text(type.displayName),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedAssetTypes.remove(type);
                  });
                  _performSearch();
                },
                visualDensity: VisualDensity.compact,
              )),
              
              // Selected tags
              ..._selectedTags.map((tag) => Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                  _performSearch();
                },
                visualDensity: VisualDensity.compact,
              )),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedTags.isNotEmpty || _selectedAssetTypes.isNotEmpty;
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    
    List<EnhancedAssetItem> results = TagSearchService.filterAssets(
      widget.assets,
      tags: _selectedTags.isNotEmpty ? _selectedTags : null,
      assetTypes: _selectedAssetTypes.isNotEmpty ? _selectedAssetTypes : null,
      nameFilter: query.isNotEmpty ? query : null,
      caseSensitive: false,
    );

    widget.onSearchResults(results);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
    });
    _performSearch();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTags.clear();
      _selectedAssetTypes.clear();
      _searchController.clear();
    });
    _performSearch();
  }
}