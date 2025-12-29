import 'package:flutter/material.dart';
import '../models/strategy_template.dart';
import '../strategies/composite_strategy.dart';
import '../strategies/trading_strategy_base.dart';
import '../strategies/trendline_strategy.dart';

/// Dialog for creating new strategy templates
class TemplateCreationDialog extends StatefulWidget {
  final CompositeStrategy? existingStrategy;

  const TemplateCreationDialog({
    super.key,
    this.existingStrategy,
  });

  @override
  State<TemplateCreationDialog> createState() => _TemplateCreationDialogState();
}

class _TemplateCreationDialogState extends State<TemplateCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  
  LogicalOperator _rootOperator = LogicalOperator.and;
  final List<StrategyCondition> _conditions = [];

  @override
  void initState() {
    super.initState();
    
    // If editing an existing strategy, populate the form
    if (widget.existingStrategy != null) {
      _nameController.text = widget.existingStrategy!.name;
      _rootOperator = widget.existingStrategy!.rootOperator;
      _conditions.addAll(widget.existingStrategy!.conditions);
    } else {
      // Add a default condition to start with
      _addCondition();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addCondition() {
    setState(() {
      // Create a simple trendline strategy as default
      final strategy = TrendlineStrategy(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        name: 'New Strategy',
        supportLevel: 100.0,
        resistanceLevel: 120.0,
        trendDirection: TrendDirection.upward,
      );
      
      _conditions.add(StrategyCondition(
        strategy: strategy,
        operator: _conditions.isNotEmpty ? _rootOperator : null,
      ));
    });
  }

  void _removeCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
    });
  }

  void _updateConditionOperator(int index, LogicalOperator? operator) {
    setState(() {
      _conditions[index] = StrategyCondition(
        strategy: _conditions[index].strategy,
        operator: operator,
      );
    });
  }

  List<String> _parseTags(String tagsText) {
    return tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _saveTemplate() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_conditions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one strategy condition'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final template = StrategyTemplate(
      id: 'template_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      conditions: _conditions,
      rootOperator: _rootOperator,
      created: DateTime.now(),
      lastModified: DateTime.now(),
      usageCount: 0,
      tags: _parseTags(_tagsController.text),
    );

    Navigator.of(context).pop(template);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  widget.existingStrategy != null 
                      ? 'Edit Template' 
                      : 'Create Template',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Template Name *',
                          hintText: 'Enter a descriptive name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a template name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Describe when to use this template',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Enter tags separated by commas',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Root operator selection
                      Text(
                        'Logical Operator',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<LogicalOperator>(
                        segments: const [
                          ButtonSegment(
                            value: LogicalOperator.and,
                            label: Text('AND'),
                            tooltip: 'All conditions must be true',
                          ),
                          ButtonSegment(
                            value: LogicalOperator.or,
                            label: Text('OR'),
                            tooltip: 'At least one condition must be true',
                          ),
                        ],
                        selected: {_rootOperator},
                        onSelectionChanged: (Set<LogicalOperator> selection) {
                          setState(() {
                            _rootOperator = selection.first;
                            // Update all condition operators
                            for (int i = 1; i < _conditions.length; i++) {
                              _updateConditionOperator(i, _rootOperator);
                            }
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Strategy conditions
                      Row(
                        children: [
                          Text(
                            'Strategy Conditions',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _addCondition,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Condition'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Conditions list
                      ..._conditions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final condition = entry.value;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Condition number
                                CircleAvatar(
                                  radius: 12,
                                  child: Text('${index + 1}'),
                                ),
                                
                                const SizedBox(width: 12),
                                
                                // Strategy type
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        condition.strategy.type.displayName,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        condition.strategy.name,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Operator (for conditions after the first)
                                if (index > 0) ...[
                                  Text(
                                    _rootOperator.displayName,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                
                                // Remove button
                                IconButton(
                                  onPressed: _conditions.length > 1 
                                      ? () => _removeCondition(index)
                                      : null,
                                  icon: const Icon(Icons.remove_circle_outline),
                                  tooltip: 'Remove condition',
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      
                      if (_conditions.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No conditions added yet',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _addCondition,
                                    child: const Text('Add First Condition'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveTemplate,
                  child: Text(widget.existingStrategy != null ? 'Update' : 'Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}