# Design Document: Strategy Creation Dialog

## Overview

The Strategy Creation Dialog is a modal interface that enables users to create new trading strategies for their assets through an intuitive, category-based selection system. The dialog features a two-panel dropdown for strategy selection and dynamic form generation based on the chosen strategy type.

## Architecture

### Component Hierarchy

```
StrategyCreationDialog (StatefulWidget)
├── DialogHeader
│   ├── AssetContext
│   └── CloseButton
├── CategorySelector (Custom Dropdown)
│   ├── DropdownTrigger
│   └── DropdownPanel
│       ├── CategoryList (Left Panel)
│       │   └── CategoryItem[]
│       └── StrategyList (Right Panel)
│           └── StrategyItem[]
├── DynamicStrategyForm
│   ├── FormFieldGenerator
│   ├── ValidationHandler
│   └── FormSubmissionHandler
└── DialogActions
    ├── CancelButton
    └── CreateButton
```

### State Management

The dialog uses local state management with the following key state variables:

- `selectedCategory`: Currently selected strategy category
- `selectedStrategyType`: Currently selected strategy type
- `formData`: Map containing form field values
- `validationErrors`: Map containing field validation errors
- `isLoading`: Boolean indicating form submission state

## Components and Interfaces

### StrategyCreationDialog

**Purpose**: Main dialog component that orchestrates the strategy creation flow

**Key Properties**:
```dart
class StrategyCreationDialog extends StatefulWidget {
  final AssetItem asset;
  final Function(TradingStrategy) onStrategyCreated;
  
  const StrategyCreationDialog({
    super.key,
    required this.asset,
    required this.onStrategyCreated,
  });
}
```

**State Variables**:
```dart
class _StrategyCreationDialogState extends State<StrategyCreationDialog> {
  StrategyCategory? _selectedCategory;
  StrategyType? _selectedStrategyType;
  final Map<String, dynamic> _formData = {};
  final Map<String, String> _validationErrors = {};
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
}
```

### CategorySelector

**Purpose**: Custom dropdown component for category-based strategy selection

**Interface**:
```dart
class CategorySelector extends StatefulWidget {
  final StrategyCategory? selectedCategory;
  final StrategyType? selectedStrategy;
  final Function(StrategyCategory) onCategoryChanged;
  final Function(StrategyType) onStrategyChanged;
  
  const CategorySelector({
    super.key,
    this.selectedCategory,
    this.selectedStrategy,
    required this.onCategoryChanged,
    required this.onStrategyChanged,
  });
}
```

**Behavior**:
- Displays current selection or "Strategy" placeholder
- Expands to show two-panel interface on tap
- Left panel shows category icons and names
- Right panel shows strategies for selected category
- Closes and updates selection when strategy is chosen

### DynamicStrategyForm

**Purpose**: Generates form fields based on selected strategy type

**Interface**:
```dart
class DynamicStrategyForm extends StatelessWidget {
  final StrategyType? strategyType;
  final Map<String, dynamic> formData;
  final Map<String, String> validationErrors;
  final Function(String, dynamic) onFieldChanged;
  final GlobalKey<FormState> formKey;
  
  const DynamicStrategyForm({
    super.key,
    this.strategyType,
    required this.formData,
    required this.validationErrors,
    required this.onFieldChanged,
    required this.formKey,
  });
}
```

**Field Generation Logic**:
- Uses strategy type metadata to determine required fields
- Generates appropriate input widgets (TextFormField, DropdownButton, etc.)
- Applies validation rules based on field types
- Handles real-time validation and error display

## Data Models

### StrategyCategory

```dart
enum StrategyCategory {
  technicalAnalysis,
  priceLevels,
  advanced;

  String get displayName {
    switch (this) {
      case StrategyCategory.technicalAnalysis:
        return 'Technical Analysis';
      case StrategyCategory.priceLevels:
        return 'Price Levels';
      case StrategyCategory.advanced:
        return 'Advanced';
    }
  }

  IconData get icon {
    switch (this) {
      case StrategyCategory.technicalAnalysis:
        return Icons.trending_up;
      case StrategyCategory.priceLevels:
        return Icons.horizontal_rule;
      case StrategyCategory.advanced:
        return Icons.settings;
    }
  }

  List<StrategyType> get strategies {
    switch (this) {
      case StrategyCategory.technicalAnalysis:
        return [StrategyType.trendline, StrategyType.elliotWaves];
      case StrategyCategory.priceLevels:
        return [StrategyType.buyArea];
      case StrategyCategory.advanced:
        return [StrategyType.composite];
    }
  }
}
```

### StrategyFieldDefinition

```dart
class StrategyFieldDefinition {
  final String key;
  final String label;
  final FieldType type;
  final bool required;
  final String? hint;
  final dynamic defaultValue;
  final List<ValidationRule> validationRules;

  const StrategyFieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.required = false,
    this.hint,
    this.defaultValue,
    this.validationRules = const [],
  });
}

enum FieldType {
  text,
  number,
  decimal,
  dropdown,
  toggle,
}

class ValidationRule {
  final String Function(dynamic value) validator;
  final String errorMessage;

  const ValidationRule({
    required this.validator,
    required this.errorMessage,
  });
}
```

### Strategy Type Extensions

Each strategy type will be extended with metadata for form generation:

```dart
extension StrategyTypeMetadata on StrategyType {
  StrategyCategory get category {
    switch (this) {
      case StrategyType.trendline:
      case StrategyType.elliotWaves:
        return StrategyCategory.technicalAnalysis;
      case StrategyType.buyArea:
        return StrategyCategory.priceLevels;
      case StrategyType.composite:
        return StrategyCategory.advanced;
    }
  }

  List<StrategyFieldDefinition> get fieldDefinitions {
    switch (this) {
      case StrategyType.trendline:
        return [
          StrategyFieldDefinition(
            key: 'name',
            label: 'Strategy Name',
            type: FieldType.text,
            required: true,
            hint: 'Enter a descriptive name',
          ),
          StrategyFieldDefinition(
            key: 'supportLevel',
            label: 'Support Level',
            type: FieldType.decimal,
            required: true,
            hint: 'Price level that acts as support',
            validationRules: [
              ValidationRule(
                validator: (value) => value > 0 ? null : 'Must be positive',
                errorMessage: 'Support level must be greater than 0',
              ),
            ],
          ),
          // ... more fields
        ];
      // ... other strategy types
    }
  }
}

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, I identified several areas where properties can be consolidated:

- Dialog interaction properties (1.1-1.5) can be combined into comprehensive dialog behavior properties
- Category selection properties (2.2-2.5) can be consolidated into category selector behavior
- Form validation properties (3.4, 3.5, 6.1-6.4) can be combined into form validation state management
- Strategy creation properties (5.1-5.3) can be consolidated into strategy persistence behavior

### Core Properties

**Property 1: Dialog Modal Behavior**
*For any* asset and user interaction, when the "Add Strategy" button is clicked, the dialog should open as a modal, display asset context, prevent background interaction, and properly handle dismissal without saving when closed via escape or outside click.
**Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**

**Property 2: Category Selection Updates Strategy List**
*For any* category selection in the dropdown, the right panel should display only strategies that belong to the selected category, and selecting a strategy should close the dropdown and update the label.
**Validates: Requirements 2.2, 2.3, 2.4, 2.5**

**Property 3: Dynamic Form Generation**
*For any* strategy type selection, the form should display input fields that match the strategy's field definitions, clear previous inputs when strategy type changes, and include appropriate labels and validation hints.
**Validates: Requirements 3.1, 3.2, 3.3**

**Property 4: Form Validation State Management**
*For any* form state, when required fields are empty or contain invalid values, the save button should be disabled and validation errors should be shown; when all validations pass, the save button should be enabled and errors should be cleared.
**Validates: Requirements 3.4, 3.5, 6.1, 6.2, 6.3, 6.4**

**Property 5: Strategy Category Organization**
*For any* strategy type in the system, it should have an associated category with an icon, and strategies should be automatically grouped by their category attribute in the UI.
**Validates: Requirements 4.1, 4.2, 4.3, 4.4**

**Property 6: Strategy Creation and Persistence**
*For any* valid form submission, a strategy instance should be created using existing factory methods, added to the asset's strategy list, persisted to local storage, and the dialog should close with success indication.
**Validates: Requirements 5.1, 5.2, 5.3, 5.4**

**Property 7: Error Handling and Recovery**
*For any* form submission failure or validation error, appropriate error messages should be displayed, the dialog should remain open, and the user should be able to correct errors and retry.
**Validates: Requirements 5.5, 6.5**

**Property 8: System Integration and Extensibility**
*For any* existing or newly added strategy type, the dialog should automatically discover it, generate appropriate form fields based on its metadata, and maintain compatibility with the TradingStrategy interface.
**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

## Error Handling

### Validation Errors
- **Field Validation**: Real-time validation with immediate feedback
- **Form Validation**: Comprehensive validation before submission
- **Cross-Field Validation**: Validation rules that depend on multiple fields

### Network/Storage Errors
- **Storage Failures**: Graceful handling of local storage errors
- **Concurrent Modifications**: Handle cases where asset data changes during dialog use
- **Memory Constraints**: Handle large numbers of strategies gracefully

### User Experience Errors
- **Invalid Selections**: Prevent invalid category/strategy combinations
- **Navigation Errors**: Handle browser back/forward during dialog use
- **Focus Management**: Maintain proper focus for accessibility

## Testing Strategy

### Unit Tests
- **Component Rendering**: Test individual component rendering with various props
- **Form Field Generation**: Test field generation for each strategy type
- **Validation Logic**: Test validation rules for different input scenarios
- **State Management**: Test state transitions and updates
- **Error Scenarios**: Test error handling and recovery flows

### Property-Based Tests
Property-based tests will validate universal behaviors across all possible inputs using Flutter's test framework with the `test` package and custom property testing utilities.

**Configuration**:
- Minimum 100 iterations per property test
- Each test tagged with feature name and property reference
- Tag format: **Feature: strategy-creation-dialog, Property {number}: {property_text}**

**Test Data Generation**:
- **Asset Generation**: Random asset items with various properties
- **Strategy Type Generation**: All available strategy types
- **Form Data Generation**: Valid and invalid form inputs
- **Category Generation**: All strategy categories
- **User Interaction Generation**: Various UI interaction sequences

### Integration Tests
- **End-to-End Flows**: Complete strategy creation workflows
- **Asset Integration**: Integration with asset card components
- **Storage Integration**: Integration with local storage systems
- **Navigation Integration**: Integration with app navigation

### Accessibility Tests
- **Focus Management**: Test focus behavior during dialog lifecycle
- **Screen Reader Support**: Test screen reader announcements
- **Keyboard Navigation**: Test keyboard-only navigation
- **Color Contrast**: Test visual accessibility requirements
```

Now I'll use the prework tool to analyze the acceptance criteria before writing correctness properties.

<function_calls>
<invoke name="prework">
<parameter name="featureName">strategy-creation-dialog