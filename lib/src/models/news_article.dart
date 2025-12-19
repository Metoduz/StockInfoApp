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
  
  /// List of stock IDs that this article relates to
  final List<String> relatedStockIds;
  
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
    required this.relatedStockIds,
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
    List<String>? relatedStockIds,
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
      relatedStockIds: relatedStockIds ?? this.relatedStockIds,
      category: category ?? this.category,
    );
  }

  /// Checks if this article is related to any of the given stock IDs
  bool isRelatedToStocks(List<String> stockIds) {
    if (stockIds.isEmpty || relatedStockIds.isEmpty) {
      return false;
    }
    return relatedStockIds.any((stockId) => stockIds.contains(stockId));
  }

  /// Checks if this article is related to a specific stock ID
  bool isRelatedToStock(String stockId) {
    return relatedStockIds.contains(stockId);
  }

  /// Gets the number of related stocks from a watchlist
  int getRelatedStockCount(List<String> watchlistStockIds) {
    return relatedStockIds.where((stockId) => watchlistStockIds.contains(stockId)).length;
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
      relatedStockIds: List<String>.from(json['relatedStockIds'] as List),
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
      'relatedStockIds': relatedStockIds,
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
        _listEquals(other.relatedStockIds, relatedStockIds) &&
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
      Object.hashAll(relatedStockIds),
      category,
    );
  }

  @override
  String toString() {
    return 'NewsArticle(id: $id, title: $title, source: $source, publishedAt: $publishedAt, relatedStockIds: $relatedStockIds)';
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