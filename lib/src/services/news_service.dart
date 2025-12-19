import 'dart:math';
import '../models/news_article.dart';

/// Service for fetching and caching financial news articles
class NewsService {
  static const Duration _cacheExpiration = Duration(minutes: 15);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  List<NewsArticle> _cachedArticles = [];
  DateTime? _lastCacheTime;
  bool _isLoading = false;

  /// Fetches the latest financial news articles
  /// Returns cached articles if they're still fresh, otherwise fetches new ones
  Future<List<NewsArticle>> fetchNews() async {
    // Return cached articles if they're still fresh
    if (_isCacheValid()) {
      return List.from(_cachedArticles);
    }

    // Prevent multiple simultaneous requests
    if (_isLoading) {
      // Wait for ongoing request to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return List.from(_cachedArticles);
    }

    _isLoading = true;
    
    try {
      final articles = await _fetchNewsWithRetry();
      cacheNews(articles);
      return List.from(articles);
    } catch (e) {
      // If fetch fails and we have cached articles, return them
      if (_cachedArticles.isNotEmpty) {
        return List.from(_cachedArticles);
      }
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Fetches news articles related to specific stock symbols
  Future<List<NewsArticle>> fetchNewsForStocks(List<String> stockIds) async {
    final allArticles = await fetchNews();
    return allArticles.where((article) => article.isRelatedToStocks(stockIds)).toList();
  }

  /// Caches news articles with timestamp
  void cacheNews(List<NewsArticle> articles) {
    _cachedArticles = List.from(articles);
    _lastCacheTime = DateTime.now();
  }

  /// Gets cached articles without fetching new ones
  List<NewsArticle> getCachedNews() {
    return List.from(_cachedArticles);
  }

  /// Checks if cached articles are still valid
  bool _isCacheValid() {
    if (_lastCacheTime == null || _cachedArticles.isEmpty) {
      return false;
    }
    return DateTime.now().difference(_lastCacheTime!) < _cacheExpiration;
  }

  /// Fetches news with retry logic
  Future<List<NewsArticle>> _fetchNewsWithRetry() async {
    Exception? lastException;
    
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await _fetchNewsFromApi();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        // Don't retry on the last attempt
        if (attempt < _maxRetries - 1) {
          await Future.delayed(_retryDelay * (attempt + 1));
        }
      }
    }
    
    throw NewsServiceException(
      'Failed to fetch news after $_maxRetries attempts',
      lastException,
    );
  }

  /// Simulates fetching news from an external API
  /// In a real implementation, this would make HTTP requests to a news API
  Future<List<NewsArticle>> _fetchNewsFromApi() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
    
    // Simulate occasional network failures for testing
    if (Random().nextDouble() < 0.1) {
      throw Exception('Network error: Unable to connect to news service');
    }

    // Generate mock news articles for demonstration
    return _generateMockNews();
  }

  /// Generates mock news articles for demonstration purposes
  /// In a real implementation, this would parse API response data
  List<NewsArticle> _generateMockNews() {
    final now = DateTime.now();
    final random = Random();
    
    final mockArticles = [
      NewsArticle(
        id: 'news_1',
        title: 'DAX Reaches New Heights as Tech Stocks Surge',
        summary: 'German stock index DAX climbed to record levels driven by strong performance in technology sector.',
        content: 'The German DAX index reached new record highs today as technology stocks led a broad market rally. SAP AG was among the top performers, gaining 3.2% on strong quarterly earnings...',
        source: 'Financial Times',
        publishedAt: now.subtract(Duration(hours: random.nextInt(24))),
        imageUrl: 'https://example.com/images/dax-surge.jpg',
        relatedStockIds: ['SAP', 'BASF'],
        category: 'market',
      ),
      NewsArticle(
        id: 'news_2',
        title: 'BASF Reports Strong Q4 Earnings',
        summary: 'Chemical giant BASF exceeded analyst expectations with robust fourth-quarter results.',
        content: 'BASF SE reported fourth-quarter earnings that beat analyst estimates, driven by strong demand in the automotive and construction sectors...',
        source: 'Reuters',
        publishedAt: now.subtract(Duration(hours: random.nextInt(48))),
        imageUrl: 'https://example.com/images/basf-earnings.jpg',
        relatedStockIds: ['BASF'],
        category: 'earnings',
      ),
      NewsArticle(
        id: 'news_3',
        title: 'Mercedes-Benz Unveils New Electric Vehicle Strategy',
        summary: 'Luxury automaker announces ambitious plans for electric vehicle expansion.',
        content: 'Mercedes-Benz Group AG unveiled its comprehensive strategy for electric vehicle development, targeting 50% of sales to be electric by 2025...',
        source: 'Bloomberg',
        publishedAt: now.subtract(Duration(hours: random.nextInt(72))),
        imageUrl: 'https://example.com/images/mercedes-ev.jpg',
        relatedStockIds: ['MBG'],
        category: 'analysis',
      ),
      NewsArticle(
        id: 'news_4',
        title: 'European Markets Show Resilience Amid Global Uncertainty',
        summary: 'European stock markets demonstrate stability despite ongoing global economic challenges.',
        content: 'European equity markets showed remarkable resilience today, with the DAX, CAC 40, and FTSE 100 all posting gains despite concerns about global economic growth...',
        source: 'MarketWatch',
        publishedAt: now.subtract(Duration(hours: random.nextInt(96))),
        relatedStockIds: ['SAP', 'BASF', 'MBG'],
        category: 'market',
      ),
      NewsArticle(
        id: 'news_5',
        title: 'Sustainability Focus Drives Investment in German Industrials',
        summary: 'ESG considerations increasingly influence investment decisions in German industrial sector.',
        content: 'Environmental, social, and governance (ESG) factors are becoming increasingly important for investors in German industrial companies...',
        source: 'Financial News',
        publishedAt: now.subtract(Duration(hours: random.nextInt(120))),
        relatedStockIds: ['BASF', 'MBG'],
        category: 'analysis',
      ),
    ];

    // Randomize the order and return a subset
    mockArticles.shuffle(random);
    return mockArticles.take(3 + random.nextInt(3)).toList();
  }

  /// Clears the news cache
  void clearCache() {
    _cachedArticles.clear();
    _lastCacheTime = null;
  }

  /// Gets the age of cached articles
  Duration? getCacheAge() {
    if (_lastCacheTime == null) return null;
    return DateTime.now().difference(_lastCacheTime!);
  }

  /// Checks if the service is currently loading
  bool get isLoading => _isLoading;

  /// Checks if there are cached articles available
  bool get hasCachedArticles => _cachedArticles.isNotEmpty;
}

/// Exception thrown by NewsService operations
class NewsServiceException implements Exception {
  final String message;
  final Exception? cause;

  const NewsServiceException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'NewsServiceException: $message\nCaused by: $cause';
    }
    return 'NewsServiceException: $message';
  }
}