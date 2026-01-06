import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../strategies/trading_strategy_base.dart';
import '../utils/form_field_generator.dart';

/// Dynamic form widget that generates fields based on selected strategy type
class DynamicStrategyForm extends StatefulWidget {
  final StrategyType? strategyType;
  final Map<String, dynamic> formData;
  final Map<String, String> validationErrors;
  final Function(String, dynamic) onFieldChanged;
  final GlobalKey<FormState> formKey;
  final VoidCallback? onFormChanged;

  const DynamicStrategyForm({
    super.key,
    this.strategyType,
    required this.formData,
    required this.validationErrors,
    required this.onFieldChanged,
    required this.formKey,
    this.onFormChanged,
  });

  @override
  State<DynamicStrategyForm> createState() => _DynamicStrategyFormState();
}

class _DynamicStrategyFormState extends State<DynamicStrategyForm> {
  StrategyType? _previousStrategyType;

  @override
  void initState() {
    super.initState();
    _previousStrategyType = widget.strategyType;
  }

  @override
  void didUpdateWidget(DynamicStrategyForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if strategy type changed
    if (widget.strategyType != _previousStrategyType) {
      _handleStrategyTypeChange();
      _previousStrategyType = widget.strategyType;
    }
  }

  /// Handle strategy type change by clearing form and setting defaults
  void _handleStrategyTypeChange() {
    if (widget.strategyType != null) {
      // Clear previous form data
      widget.formData.clear();
      
      // Set default values for new strategy type
      final defaultData = FormFieldGenerator.getDefaultFormData(widget.strategyType!);
      widget.formData.addAll(defaultData);
      
      // Notify parent of form change
      widget.onFormChanged?.call();
      
      // Announce form change for screen readers
      SemanticsService.announce(
        'Form updated for ${widget.strategyType!.displayName} strategy. ${widget.strategyType!.fieldDefinitions.length} fields available.',
        TextDirection.ltr,
      );
    }
  }

  /// Handle field value changes with validation
  void _handleFieldChanged(String key, dynamic value) {
    // Update form data
    widget.onFieldChanged(key, value);
    
    // Trigger form validation
    if (widget.formKey.currentState != null) {
      widget.formKey.currentState!.validate();
    }
    
    // Notify parent of form change
    widget.onFormChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if no strategy type is selected
    if (widget.strategyType == null) {
      return Semantics(
        label: 'No strategy selected. Please select a strategy to configure its parameters.',
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.assignment,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
                semanticLabel: 'Form placeholder',
              ),
              const SizedBox(height: 16),
              Text(
                'Select a strategy to configure its parameters',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: 'Strategy configuration form for ${widget.strategyType!.displayName}',
      child: Form(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Strategy type header
            _buildStrategyTypeHeader(),
            
            const SizedBox(height: 16),
            
            // Form fields
            ..._buildFormFields(),
            
            // Form validation summary
            if (widget.validationErrors.isNotEmpty)
              _buildValidationSummary(),
          ],
        ),
      ),
    );
  }

  /// Build strategy type header with icon and name
  Widget _buildStrategyTypeHeader() {
    final strategyType = widget.strategyType!;
    final category = strategyType.category;
    
    return Semantics(
      label: 'Selected strategy: ${strategyType.displayName} from ${category.displayName} category',
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Icon(
              category.icon,
              color: Theme.of(context).colorScheme.primary,
              semanticLabel: '${category.displayName} category icon',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strategyType.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build form fields based on strategy type
  List<Widget> _buildFormFields() {
    final strategyType = widget.strategyType!;
    final fieldDefinitions = strategyType.fieldDefinitions;
    
    if (fieldDefinitions.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No configuration required for this strategy type.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return fieldDefinitions.map((fieldDef) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _buildFormField(fieldDef),
      );
    }).toList();
  }

  /// Build individual form field
  Widget _buildFormField(StrategyFieldDefinition fieldDef) {
    return FormFieldGenerator.generateFormField(
      fieldDef: fieldDef,
      value: widget.formData[fieldDef.key],
      onChanged: (value) => _handleFieldChanged(fieldDef.key, value),
      errorText: widget.validationErrors[fieldDef.key],
    );
  }

  /// Build validation summary for form errors
  Widget _buildValidationSummary() {
    final errorCount = widget.validationErrors.length;
    final errorMessages = widget.validationErrors.values.toList();
    
    return Semantics(
      label: 'Form validation errors: $errorCount ${errorCount == 1 ? 'field has' : 'fields have'} validation errors',
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(top: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 20,
                  semanticLabel: 'Error indicator',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorCount == 1 
                        ? '1 field has validation errors'
                        : '$errorCount fields have validation errors',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (errorMessages.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...errorMessages.take(3).map((error) => Padding(
                padding: const EdgeInsets.only(left: 28.0, bottom: 2.0),
                child: Text(
                  '• $error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontSize: 11,
                  ),
                ),
              )),
              if (errorMessages.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 28.0),
                  child: Text(
                    '• ... and ${errorMessages.length - 3} more errors',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Extension to provide form validation utilities
extension DynamicStrategyFormValidation on DynamicStrategyForm {
  /// Check if the current form is valid
  static bool isFormValid({
    required StrategyType? strategyType,
    required Map<String, dynamic> formData,
  }) {
    if (strategyType == null) return false;
    
    return FormFieldGenerator.isFormValid(
      strategyType: strategyType,
      formData: formData,
    );
  }

  /// Get validation errors for the current form
  static Map<String, String> getValidationErrors({
    required StrategyType? strategyType,
    required Map<String, dynamic> formData,
  }) {
    if (strategyType == null) return {};
    
    return FormFieldGenerator.validateAllFields(
      strategyType: strategyType,
      formData: formData,
    );
  }

  /// Clear form data and reset to defaults
  static Map<String, dynamic> clearAndResetForm({
    required StrategyType? strategyType,
  }) {
    if (strategyType == null) return {};
    
    return FormFieldGenerator.getDefaultFormData(strategyType);
  }
}