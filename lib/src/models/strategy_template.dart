import '../strategies/trading_strategy_base.dart';
import '../strategies/composite_strategy.dart';
import '../services/storage_service.dart';

/// Template for saving and reusing composite strategy configurations
class StrategyTemplate {
  final String id;
  final String name;
  final String description;
  final List<StrategyCondition> conditions;
  final LogicalOperator rootOperator;
  final DateTime created;
  final DateTime lastModified;
  final int usageCount;
  final List<String> tags;

  StrategyTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.conditions,
    required this.rootOperator,
    required this.created,
    required this.lastModified,
    this.usageCount = 0,
    this.tags = const [],
  });

  /// Create template from a composite strategy
  factory StrategyTemplate.fromCompositeStrategy(
    CompositeStrategy strategy, {
    required String name,
    required String description,
    List<String> tags = const [],
  }) {
    final now = DateTime.now();
    return StrategyTemplate(
      id: strategy.id,
      name: name,
      description: description,
      conditions: strategy.conditions,
      rootOperator: strategy.rootOperator,
      created: now,
      lastModified: now,
      usageCount: 0,
      tags: tags,
    );
  }

  /// Create a composite strategy from this template
  CompositeStrategy toCompositeStrategy(String newId, String assetId) {
    return CompositeStrategy(
      id: newId,
      name: '$name (from template)',
      conditions: conditions,
      rootOperator: rootOperator,
    );
  }

  /// Increment usage count
  StrategyTemplate incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      lastModified: DateTime.now(),
    );
  }

  /// Update template with new strategy configuration
  StrategyTemplate updateFromStrategy(CompositeStrategy strategy) {
    return copyWith(
      conditions: strategy.conditions,
      rootOperator: strategy.rootOperator,
      lastModified: DateTime.now(),
    );
  }

  /// Check if template matches search criteria
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
           description.toLowerCase().contains(lowerQuery) ||
           tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }

  /// Get template complexity score based on number of conditions
  int getComplexityScore() {
    return conditions.length;
  }

  /// Get template category based on strategy types used
  String getCategory() {
    final strategyTypes = conditions.map((c) => c.strategy.type).toSet();
    
    if (strategyTypes.length == 1) {
      return strategyTypes.first.displayName;
    } else if (strategyTypes.contains(StrategyType.trendline) && 
               strategyTypes.contains(StrategyType.buyArea)) {
      return 'Technical Analysis';
    } else if (strategyTypes.contains(StrategyType.elliotWaves)) {
      return 'Wave Analysis';
    } else {
      return 'Mixed Strategy';
    }
  }

  StrategyTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<StrategyCondition>? conditions,
    LogicalOperator? rootOperator,
    DateTime? created,
    DateTime? lastModified,
    int? usageCount,
    List<String>? tags,
  }) {
    return StrategyTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      conditions: conditions ?? this.conditions,
      rootOperator: rootOperator ?? this.rootOperator,
      created: created ?? this.created,
      lastModified: lastModified ?? this.lastModified,
      usageCount: usageCount ?? this.usageCount,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'rootOperator': rootOperator.name,
      'created': created.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
      'usageCount': usageCount,
      'tags': tags,
    };
  }

  factory StrategyTemplate.fromJson(Map<String, dynamic> json) {
    return StrategyTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      conditions: (json['conditions'] as List<dynamic>)
          .map((c) => StrategyCondition.fromJson(c))
          .toList(),
      rootOperator: LogicalOperator.values.firstWhere(
        (e) => e.name == json['rootOperator'],
        orElse: () => LogicalOperator.and,
      ),
      created: DateTime.parse(json['created'] as String),
      lastModified: DateTime.parse(json['lastModified'] as String),
      usageCount: json['usageCount'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  String toString() {
    return 'StrategyTemplate{id: $id, name: $name, usageCount: $usageCount, complexity: ${getComplexityScore()}}';
  }
}

/// Manager class for handling strategy templates
class TemplateManager {
  static final List<StrategyTemplate> _templates = [];
  static final StorageService _storageService = StorageService();

  /// Initialize template manager by loading templates from storage
  static Future<void> initialize() async {
    try {
      await _loadTemplatesFromStorage();
    } catch (e) {
      // If loading fails, start with empty templates list
      _templates.clear();
    }
  }

  /// Load templates from persistent storage
  static Future<void> _loadTemplatesFromStorage() async {
    try {
      final templatesJson = await _storageService.loadStrategyTemplates();
      _templates.clear();
      _templates.addAll(templatesJson.map((json) => StrategyTemplate.fromJson(json)));
    } catch (e) {
      // Handle loading errors gracefully
      _templates.clear();
    }
  }

  /// Save templates to persistent storage
  static Future<void> _saveTemplatesToStorage() async {
    try {
      final templatesJson = _templates.map((t) => t.toJson()).toList();
      await _storageService.saveStrategyTemplates(templatesJson);
    } catch (e) {
      // Handle save errors - could throw or log depending on requirements
      throw Exception('Failed to save templates: $e');
    }
  }

  /// Get all available templates
  static List<StrategyTemplate> getAvailableTemplates() {
    return List.unmodifiable(_templates);
  }

  /// Get templates filtered by category
  static List<StrategyTemplate> getTemplatesByCategory(String category) {
    return _templates.where((t) => t.getCategory() == category).toList();
  }

  /// Search templates by query
  static List<StrategyTemplate> searchTemplates(String query) {
    if (query.isEmpty) return getAvailableTemplates();
    return _templates.where((t) => t.matchesSearch(query)).toList();
  }

  /// Get most used templates
  static List<StrategyTemplate> getMostUsedTemplates({int limit = 10}) {
    final sorted = List<StrategyTemplate>.from(_templates);
    sorted.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(limit).toList();
  }

  /// Get recently created templates
  static List<StrategyTemplate> getRecentTemplates({int limit = 10}) {
    final sorted = List<StrategyTemplate>.from(_templates);
    sorted.sort((a, b) => b.created.compareTo(a.created));
    return sorted.take(limit).toList();
  }

  /// Save a new template
  static Future<void> saveTemplate(StrategyTemplate template) async {
    // Remove existing template with same ID if it exists
    _templates.removeWhere((t) => t.id == template.id);
    _templates.add(template);
    await _saveTemplatesToStorage();
  }

  /// Save composite strategy as template
  static Future<StrategyTemplate> saveCompositeStrategyAsTemplate(
    CompositeStrategy strategy, {
    required String name,
    required String description,
    List<String> tags = const [],
  }) async {
    final template = StrategyTemplate.fromCompositeStrategy(
      strategy,
      name: name,
      description: description,
      tags: tags,
    );
    await saveTemplate(template);
    return template;
  }

  /// Apply template to create new composite strategy
  static Future<CompositeStrategy> applyTemplate(String templateId, String assetId) async {
    final template = _templates.firstWhere(
      (t) => t.id == templateId,
      orElse: () => throw ArgumentError('Template not found: $templateId'),
    );

    // Increment usage count
    final updatedTemplate = template.incrementUsage();
    await saveTemplate(updatedTemplate);

    // Generate new ID for the strategy
    final newId = '${assetId}_strategy_${DateTime.now().millisecondsSinceEpoch}';
    return template.toCompositeStrategy(newId, assetId);
  }

  /// Update existing template
  static Future<void> updateTemplate(StrategyTemplate template) async {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      _templates[index] = template;
      await _saveTemplatesToStorage();
    }
  }

  /// Delete template
  static Future<bool> deleteTemplate(String templateId) async {
    final initialLength = _templates.length;
    _templates.removeWhere((t) => t.id == templateId);
    final wasDeleted = _templates.length < initialLength;
    
    if (wasDeleted) {
      await _saveTemplatesToStorage();
    }
    
    return wasDeleted;
  }

  /// Get template by ID
  static StrategyTemplate? getTemplate(String templateId) {
    try {
      return _templates.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return null;
    }
  }

  /// Get template statistics
  static Map<String, dynamic> getTemplateStatistics() {
    final totalTemplates = _templates.length;
    final totalUsage = _templates.fold(0, (sum, t) => sum + t.usageCount);
    final categories = _templates.map((t) => t.getCategory()).toSet().toList();
    final averageComplexity = totalTemplates > 0 
        ? _templates.fold(0, (sum, t) => sum + t.getComplexityScore()) / totalTemplates
        : 0.0;

    return {
      'totalTemplates': totalTemplates,
      'totalUsage': totalUsage,
      'categories': categories,
      'averageComplexity': averageComplexity,
      'mostUsedTemplate': getMostUsedTemplates(limit: 1).firstOrNull?.name,
    };
  }

  /// Load templates from JSON data (for import functionality)
  static Future<void> loadTemplatesFromJson(List<Map<String, dynamic>> jsonData) async {
    _templates.clear();
    for (final json in jsonData) {
      try {
        final template = StrategyTemplate.fromJson(json);
        _templates.add(template);
      } catch (e) {
        // Skip invalid templates - could log this in production
      }
    }
    await _saveTemplatesToStorage();
  }

  /// Export templates to JSON (for export functionality)
  static List<Map<String, dynamic>> exportTemplatesToJson() {
    return _templates.map((t) => t.toJson()).toList();
  }

  /// Clear all templates (for testing)
  static Future<void> clearTemplates() async {
    _templates.clear();
    await _saveTemplatesToStorage();
  }

  /// Refresh templates from storage (useful after external changes)
  static Future<void> refreshTemplates() async {
    await _loadTemplatesFromStorage();
  }
}