import '../models/asset_item.dart';

/// Service for searching assets by tags
class TagSearchService {
  /// Search assets by tag names
  /// Returns assets that contain any of the specified tags (OR operation)
  static List<AssetItem> searchByTags(
    List<AssetItem> assets,
    List<String> searchTags, {
    bool caseSensitive = false,
  }) {
    if (searchTags.isEmpty) return assets;

    final normalizedSearchTags = caseSensitive
        ? searchTags
        : searchTags.map((tag) => tag.toLowerCase()).toList();

    return assets.where((asset) {
      final assetTags = caseSensitive
          ? asset.tags
          : asset.tags.map((tag) => tag.toLowerCase()).toList();

      // Check if any search tag matches any asset tag
      return normalizedSearchTags.any((searchTag) =>
          assetTags.any((assetTag) => assetTag.contains(searchTag)));
    }).toList();
  }

  /// Search assets by a single tag
  static List<AssetItem> searchByTag(
    List<AssetItem> assets,
    String searchTag, {
    bool caseSensitive = false,
  }) {
    return searchByTags(assets, [searchTag], caseSensitive: caseSensitive);
  }

  /// Get all unique tags from a list of assets
  static List<String> getAllTags(List<AssetItem> assets) {
    final allTags = <String>{};
    for (final asset in assets) {
      allTags.addAll(asset.tags);
    }
    return allTags.toList()..sort();
  }

  /// Get tag suggestions based on partial input
  static List<String> getTagSuggestions(
    List<AssetItem> assets,
    String partialTag, {
    bool caseSensitive = false,
    int maxSuggestions = 10,
  }) {
    if (partialTag.isEmpty) return [];

    final allTags = getAllTags(assets);
    final normalizedPartial = caseSensitive ? partialTag : partialTag.toLowerCase();

    final suggestions = allTags.where((tag) {
      final normalizedTag = caseSensitive ? tag : tag.toLowerCase();
      return normalizedTag.contains(normalizedPartial);
    }).take(maxSuggestions).toList();

    return suggestions;
  }

  /// Filter assets by multiple criteria including tags
  static List<AssetItem> filterAssets(
    List<AssetItem> assets, {
    List<String>? tags,
    List<AssetType>? assetTypes,
    String? nameFilter,
    bool caseSensitive = false,
  }) {
    var filteredAssets = assets;

    // Filter by tags if provided
    if (tags != null && tags.isNotEmpty) {
      filteredAssets = searchByTags(filteredAssets, tags, caseSensitive: caseSensitive);
    }

    // Filter by asset types if provided
    if (assetTypes != null && assetTypes.isNotEmpty) {
      filteredAssets = filteredAssets.where((asset) =>
          assetTypes.contains(asset.assetType)).toList();
    }

    // Filter by name if provided
    if (nameFilter != null && nameFilter.isNotEmpty) {
      final normalizedNameFilter = caseSensitive ? nameFilter : nameFilter.toLowerCase();
      filteredAssets = filteredAssets.where((asset) {
        final normalizedName = caseSensitive ? asset.name : asset.name.toLowerCase();
        return normalizedName.contains(normalizedNameFilter);
      }).toList();
    }

    return filteredAssets;
  }

  /// Get assets that have no tags
  static List<AssetItem> getUntaggedAssets(List<AssetItem> assets) {
    return assets.where((asset) => asset.tags.isEmpty).toList();
  }

  /// Get tag usage statistics
  static Map<String, int> getTagUsageStats(List<AssetItem> assets) {
    final tagCounts = <String, int>{};
    
    for (final asset in assets) {
      for (final tag in asset.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
    
    return tagCounts;
  }

  /// Get most popular tags
  static List<String> getMostPopularTags(
    List<AssetItem> assets, {
    int limit = 10,
  }) {
    final tagStats = getTagUsageStats(assets);
    final sortedTags = tagStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTags.take(limit).map((entry) => entry.key).toList();
  }
}