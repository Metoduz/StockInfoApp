/// News article model for financial news feed
class NewsArticle {
  /// Unique identifier for the article
  final String id;
  
  /// Article title
  final String title;
  
  /// Brief summary of the article
  final String summary;
  
  /// Full article content
  final String content;
  
  /// News source (e.g., "Reuters", "Bloomberg")
  final String source;
  
  /// When the article was published
  final DateTime publishedAt;
  
  /// Optional image URL for the article
  final String? imageUrl;
  
  /// List of asset IDs that this article relates to
  final List<String> relatedAssetIds;
  
  /// Article category (e.g., "market", "earnings", "analysis")
  final String category;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
    required this.relatedAssetIds,
    required this.category,
  });

  /// Creates a copy of this article with updated fields
  NewsArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? source,
    DateTime? publishedAt,
    String? imageUrl,
    List<String>? relatedAssetIds,
    String? category,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      relatedAssetIds: relatedAssetIds ?? this.relatedAssetIds,
      category: category ?? this.category,
    );
  }

  /// Checks if this article is related to any of the given asset IDs
  bool isRelatedToAssets(List<String> assetIds) {
    if (assetIds.isEmpty || relatedAssetIds.isEmpty) {
      return false;
    }
    return relatedAssetIds.any((assetId) => assetIds.contains(assetId));
  }

  /// Checks if this article is related to a specific asset ID
  bool isRelatedToAsset(String assetId) {
    return relatedAssetIds.contains(assetId);
  }

  /// Gets the number of related assets from a watchlist
  int getRelatedAssetCount(List<String> watchlistAssetIds) {
    return relatedAssetIds.where((assetId) => watchlistAssetIds.contains(assetId)).length;
  }

  /// Creates a NewsArticle from JSON data
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      source: json['source'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
      relatedAssetIds: List<String>.from(json['relatedAssetIds'] as List),
      category: json['category'] as String,
    );
  }

  /// Converts this NewsArticle to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'relatedAssetIds': relatedAssetIds,
      'category': category,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsArticle &&
        other.id == id &&
        other.title == title &&
        other.summary == summary &&
        other.content == content &&
        other.source == source &&
        other.publishedAt == publishedAt &&
        other.imageUrl == imageUrl &&
        _listEquals(other.relatedAssetIds, relatedAssetIds) &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      summary,
      content,
      source,
      publishedAt,
      imageUrl,
      Object.hashAll(relatedAssetIds),
      category,
    );
  }

  @override
  String toString() {
    return 'NewsArticle(id: $id, title: $title, source: $source, publishedAt: $publishedAt, relatedAssetIds: $relatedAssetIds)';
  }
}

/// Helper function to compare lists for equality
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}