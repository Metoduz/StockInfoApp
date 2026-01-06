import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../strategies/trading_strategy_base.dart';

/// Utility class for generating form fields based on strategy field definitions
class FormFieldGenerator {
  /// Generate a form field widget based on the field definition
  static Widget generateFormField({
    required StrategyFieldDefinition fieldDef,
    required dynamic value,
    required Function(dynamic) onChanged,
    String? errorText,
  }) {
    switch (fieldDef.type) {
      case FieldType.text:
        return _generateTextField(
          fieldDef: fieldDef,
          value: value as String?,
          onChanged: onChanged,
          errorText: errorText,
        );
      
      case FieldType.number:
        return _generateNumberField(
          fieldDef: fieldDef,
          value: value as int?,
          onChanged: onChanged,
          errorText: errorText,
        );
      
      case FieldType.decimal:
        return _generateDecimalField(
          fieldDef: fieldDef,
          value: value as double?,
          onChanged: onChanged,
          errorText: errorText,
        );
      
      case FieldType.dropdown:
        return _generateDropdownField(
          fieldDef: fieldDef,
          value: value as String?,
          onChanged: onChanged,
          errorText: errorText,
        );
      
      case FieldType.toggle:
        return _generateToggleField(
          fieldDef: fieldDef,
          value: value as bool?,
          onChanged: onChanged,
          errorText: errorText,
        );
    }
  }

  /// Generate a text input field
  static Widget _generateTextField({
    required StrategyFieldDefinition fieldDef,
    required String? value,
    required Function(dynamic) onChanged,
    String? errorText,
  }) {
    return Semantics(
      label: '${fieldDef.label} text input field${fieldDef.required ? ', required' : ''}${fieldDef.hint != null ? '. ${fieldDef.hint}' : ''}',
      textField: true,
      child: TextFormField(
        initialValue: value ?? fieldDef.defaultValue?.toString() ?? '',
        decoration: InputDecoration(
          labelText: fieldDef.label,
          hintText: fieldDef.hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: fieldDef.required 
              ? Icon(
                  Icons.star, 
                  size: 8, 
                  color: Colors.red,
                  semanticLabel: 'Required field indicator',
                )
              : null,
          helperText: fieldDef.required ? 'Required field' : null,
          errorMaxLines: 2,
        ),
        keyboardType: fieldDef.keyboardType,
        onChanged: onChanged,
        validator: (value) {
          final error = fieldDef.validateValue(value);
          return error;
        },
      ),
    );
  }

  /// Generate a number input field
  static Widget _generateNumberField({
    required StrategyFieldDefinition fieldDef,
    required int? value,
    required Function(dynamic) onChanged,
    String? errorText,
  }) {
    return Semantics(
      label: '${fieldDef.label} number input field${fieldDef.required ? ', required' : ''}${fieldDef.hint != null ? '. ${fieldDef.hint}' : ''}',
      textField: true,
      child: TextFormField(
        initialValue: value?.toString() ?? fieldDef.defaultValue?.toString() ?? '',
        decoration: InputDecoration(
          labelText: fieldDef.label,
          hintText: fieldDef.hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: fieldDef.required 
              ? Icon(
                  Icons.star, 
                  size: 8, 
                  color: Colors.red,
                  semanticLabel: 'Required field indicator',
                )
              : null,
          helperText: fieldDef.required ? 'Required field (numbers only)' : 'Numbers only',
          errorMaxLines: 2,
        ),
        keyboardType: fieldDef.keyboardType,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          final intValue = int.tryParse(value);
          onChanged(intValue);
        },
        validator: (value) {
          if (fieldDef.required && (value == null || value.trim().isEmpty)) {
            return '${fieldDef.label} is required';
          }
          final intValue = int.tryParse(value ?? '');
          if (value != null && value.trim().isNotEmpty && intValue == null) {
            return 'Please enter a valid number';
          }
          return fieldDef.validateValue(intValue);
        },
      ),
    );
  }

  /// Generate a decimal input field
  static Widget _generateDecimalField({
    required StrategyFieldDefinition fieldDef,
    required double? value,
    required Function(dynamic) onChanged,
    String? errorText,
  }) {
    return Semantics(
      label: '${fieldDef.label} decimal number input field${fieldDef.required ? ', required' : ''}${fieldDef.hint != null ? '. ${fieldDef.hint}' : ''}',
      textField: true,
      child: TextFormField(
        initialValue: value?.toString() ?? fieldDef.defaultValue?.toString() ?? '',
        decoration: InputDecoration(
          labelText: fieldDef.label,
          hintText: fieldDef.hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: fieldDef.required 
              ? Icon(
                  Icons.star, 
                  size: 8, 
                  color: Colors.red,
                  semanticLabel: 'Required field indicator',
                )
              : null,
          helperText: fieldDef.required ? 'Required field (decimal numbers)' : 'Decimal numbers allowed',
          errorMaxLines: 2,
        ),
        keyboardType: fieldDef.keyboardType,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        onChanged: (value) {
          final doubleValue = double.tryParse(value);
          onChanged(doubleValue);
        },
        validator: (value) {
          if (fieldDef.required && (value == null || value.trim().isEmpty)) {
            return '${fieldDef.label} is required';
          }
          final doubleValue = double.tryParse(value ?? '');
          if (value != null && value.trim().isNotEmpty && doubleValue == null) {
            return 'Please enter a valid decimal number';
          }
          return fieldDef.validateValue(doubleValue);
        },
      ),
    );
  }

  /// Generate a dropdown field
  static Widget _generateDropdownField({
    required StrategyFieldDefinition fieldDef,
    required String? value,
    required Function(dynamic) onChanged,
    String? errorText,
  }) {
    final options = fieldDef.dropdownOptions ?? [];
    
    return Semantics(
      label: '${fieldDef.label} dropdown selection${fieldDef.required ? ', required' : ''}${fieldDef.hint != null ? '. ${fieldDef.hint}' : ''}. ${options.length} options available.',
      child: DropdownButtonFormField<String>(
        value: value ?? fieldDef.defaultValue?.toString(),
        decoration: InputDecoration(
          labelText: fieldDef.label,
          hintText: fieldDef.hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
          suffixIcon: fieldDef.required 
              ? Icon(
                  Icons.star, 
                  size: 8, 
                  color: Colors.red,
                  semanticLabel: 'Required field indicator',
                )
              : null,
          helperText: fieldDef.required ? 'Required selection' : null,
          errorMaxLines: 2,
        ),
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option.value,
            child: Semantics(
              label: option.label,
              child: Text(option.label),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (fieldDef.required && (value == null || value.trim().isEmpty)) {
            return 'Please select a ${fieldDef.label.toLowerCase()}';
          }
          return fieldDef.validateValue(value);
        },
      ),
    );
  }

  /// Generate a toggle/switch field
  static Widget _generateToggleField({
    required StrategyFieldDefinition fieldDef,
    required bool? value,
    required Function(dynamic) onChanged,
    String? errorText,
  }) {
    return FormField<bool>(
      initialValue: value ?? fieldDef.defaultValue as bool? ?? false,
      validator: (value) {
        if (fieldDef.required && value != true) {
          return '${fieldDef.label} must be enabled';
        }
        return fieldDef.validateValue(value);
      },
      builder: (FormFieldState<bool> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: '${fieldDef.label} toggle switch${fieldDef.required ? ', required' : ''}${fieldDef.hint != null ? '. ${fieldDef.hint}' : ''}. Currently ${state.value == true ? 'enabled' : 'disabled'}.',
              toggled: state.value == true,
              child: SwitchListTile(
                title: Text(fieldDef.label),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (fieldDef.hint != null) Text(fieldDef.hint!),
                    if (fieldDef.required) 
                      const Text(
                        'Required setting',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
                value: state.value ?? false,
                onChanged: (newValue) {
                  state.didChange(newValue);
                  onChanged(newValue);
                },
                secondary: fieldDef.required 
                    ? Icon(
                        Icons.star, 
                        size: 8, 
                        color: Colors.red,
                        semanticLabel: 'Required field indicator',
                      )
                    : null,
              ),
            ),
            if (state.hasError || errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  state.errorText ?? errorText ?? '',
                  style: TextStyle(
                    color: Theme.of(state.context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Generate all form fields for a strategy type
  static List<Widget> generateFormFields({
    required StrategyType strategyType,
    required Map<String, dynamic> formData,
    required Map<String, String> validationErrors,
    required Function(String, dynamic) onFieldChanged,
  }) {
    final fieldDefinitions = strategyType.fieldDefinitions;
    
    return fieldDefinitions.map((fieldDef) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: generateFormField(
          fieldDef: fieldDef,
          value: formData[fieldDef.key],
          onChanged: (value) => onFieldChanged(fieldDef.key, value),
          errorText: validationErrors[fieldDef.key],
        ),
      );
    }).toList();
  }

  /// Validate all fields for a strategy type
  static Map<String, String> validateAllFields({
    required StrategyType strategyType,
    required Map<String, dynamic> formData,
  }) {
    final errors = <String, String>{};
    final fieldDefinitions = strategyType.fieldDefinitions;
    
    for (final fieldDef in fieldDefinitions) {
      final value = formData[fieldDef.key];
      final error = fieldDef.validateValue(value);
      
      if (error != null) {
        errors[fieldDef.key] = error;
      }
    }
    
    return errors;
  }

  /// Check if all required fields are filled and valid
  static bool isFormValid({
    required StrategyType strategyType,
    required Map<String, dynamic> formData,
  }) {
    final fieldDefinitions = strategyType.fieldDefinitions;
    
    for (final fieldDef in fieldDefinitions) {
      final value = formData[fieldDef.key];
      
      // Check required fields
      if (fieldDef.required && (value == null || value.toString().trim().isEmpty)) {
        return false;
      }
      
      // Check validation rules
      final error = fieldDef.validateValue(value);
      if (error != null) {
        return false;
      }
    }
    
    return true;
  }

  /// Get default form data for a strategy type
  static Map<String, dynamic> getDefaultFormData(StrategyType strategyType) {
    final formData = <String, dynamic>{};
    final fieldDefinitions = strategyType.fieldDefinitions;
    
    for (final fieldDef in fieldDefinitions) {
      if (fieldDef.defaultValue != null) {
        formData[fieldDef.key] = fieldDef.defaultValue;
      }
    }
    
    return formData;
  }

  /// Clear form data for fields that are no longer relevant
  static Map<String, dynamic> clearIrrelevantFields({
    required StrategyType strategyType,
    required Map<String, dynamic> currentFormData,
  }) {
    final relevantKeys = strategyType.fieldDefinitions.map((f) => f.key).toSet();
    final clearedData = <String, dynamic>{};
    
    // Keep only fields that are relevant to the current strategy type
    for (final entry in currentFormData.entries) {
      if (relevantKeys.contains(entry.key)) {
        clearedData[entry.key] = entry.value;
      }
    }
    
    return clearedData;
  }
}