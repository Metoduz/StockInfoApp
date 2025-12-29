import 'package:flutter/material.dart';
import '../models/strategy_template.dart';
import '../widgets/template_card.dart';
import '../widgets/template_creation_dialog.dart';

/// Screen for managing strategy templates
class TemplateManagementScreen extends StatefulWidget {
  const TemplateManagementScreen({super.key});

  @override
  State<TemplateManagementScreen> createState() => _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<StrategyTemplate> _allTemplates = [];
  List<StrategyTemplate> _filteredTemplates = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTemplates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await TemplateManager.initialize();
      _allTemplates = TemplateManager.getAvailableTemplates();
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load templates: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<StrategyTemplate> filtered = _allTemplates;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((template) => template.matchesSearch(_searchQuery)).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered.where((template) => template.getCategory() == _selectedCategory).toList();
    }

    // Sort based on current tab
    switch (_tabController.index) {
      case 0: // All templates - sort by name
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 1: // Most used - sort by usage count
        filtered.sort((a, b) => b.usageCount.compareTo(a.usageCount));
        break;
      case 2: // Recent - sort by creation date
        filtered.sort((a, b) => b.created.compareTo(a.created));
        break;
    }

    setState(() {
      _filteredTemplates = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  List<String> _getAvailableCategories() {
    final categories = _allTemplates.map((t) => t.getCategory()).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  Future<void> _createNewTemplate() async {
    final result = await showDialog<StrategyTemplate>(
      context: context,
      builder: (context) => const TemplateCreationDialog(),
    );

    if (result != null) {
      try {
        await TemplateManager.saveTemplate(result);
        await _loadTemplates();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create template: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _applyTemplate(StrategyTemplate template) async {
    try {
      // For now, just show a success message
      // In a real implementation, this would navigate to asset selection
      // or apply the template to a specific asset
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template "${template.name}" ready to apply'),
          backgroundColor: Colors.blue,
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to apply template: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTemplate(StrategyTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TemplateManager.deleteTemplate(template.id);
        await _loadTemplates();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Template deleted successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete template: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy Templates'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => _applyFilters(),
          tabs: const [
            Tab(text: 'All Templates'),
            Tab(text: 'Most Used'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                // Category filter
                Row(
                  children: [
                    const Text('Category: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: _getAvailableCategories()
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _onCategoryChanged(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Templates list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTemplates.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filteredTemplates.length,
                        itemBuilder: (context, index) {
                          final template = _filteredTemplates[index];
                          return TemplateCard(
                            template: template,
                            onApply: () => _applyTemplate(template),
                            onDelete: () => _deleteTemplate(template),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTemplate,
        tooltip: 'Create New Template',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'No templates match your filters'
                : 'No templates available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'All'
                ? 'Try adjusting your search or filters'
                : 'Create your first template to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          if (_searchQuery.isEmpty && _selectedCategory == 'All') ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _createNewTemplate,
              icon: const Icon(Icons.add),
              label: const Text('Create Template'),
            ),
          ],
        ],
      ),
    );
  }
}