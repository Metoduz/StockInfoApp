import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/widgets/dynamic_strategy_form.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';

void main() {
  group('DynamicStrategyForm', () {
    late Map<String, dynamic> formData;
    late Map<String, String> validationErrors;
    late GlobalKey<FormState> formKey;

    setUp(() {
      formData = <String, dynamic>{};
      validationErrors = <String, String>{};
      formKey = GlobalKey<FormState>();
    });

    testWidgets('displays placeholder when no strategy type selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: null,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display placeholder message
      expect(find.text('Select a strategy to configure its parameters'), findsOneWidget);
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });

    testWidgets('displays strategy header with correct information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display strategy name and category
      expect(find.text(StrategyType.trendline.displayName), findsOneWidget);
      expect(find.text(StrategyType.trendline.category.displayName), findsOneWidget);
      expect(find.byIcon(StrategyType.trendline.category.icon), findsOneWidget);
    });

    testWidgets('generates form fields for trendline strategy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display all trendline strategy fields
      expect(find.text('Strategy Name'), findsOneWidget);
      expect(find.text('Support Level'), findsOneWidget);
      expect(find.text('Resistance Level'), findsOneWidget);
      expect(find.text('Trend Direction'), findsOneWidget);

      // Should have appropriate input widgets
      expect(find.byType(TextFormField), findsNWidgets(3)); // Name, Support, Resistance
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Trend Direction
    });

    testWidgets('generates form fields for buy area strategy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.buyArea,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display all buy area strategy fields
      expect(find.text('Strategy Name'), findsOneWidget);
      expect(find.text('Lower Bound'), findsOneWidget);
      expect(find.text('Ideal Price'), findsOneWidget);
      expect(find.text('Upper Bound'), findsOneWidget);

      // Should have text form fields for all inputs
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('generates form fields for elliott waves strategy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.elliotWaves,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display all elliott waves strategy fields
      expect(find.text('Strategy Name'), findsOneWidget);
      expect(find.text('Current Wave'), findsOneWidget);
      expect(find.text('Wave Target Price'), findsOneWidget);

      // Should have text form fields for all inputs
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('generates form fields for composite strategy', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.composite,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display all composite strategy fields
      expect(find.text('Strategy Name'), findsOneWidget);
      expect(find.text('Root Operator'), findsOneWidget);

      // Should have text field and dropdown
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('calls onFieldChanged when field values change', (WidgetTester tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                changedKey = key;
                changedValue = value;
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Enter text in strategy name field
      await tester.enterText(
        find.widgetWithText(TextFormField, '').first,
        'Test Strategy',
      );

      // Verify callback was called
      expect(changedKey, equals('name'));
      expect(changedValue, equals('Test Strategy'));
    });

    testWidgets('displays validation errors when present', (WidgetTester tester) async {
      validationErrors['name'] = 'Strategy name is required';
      validationErrors['supportLevel'] = 'Support level must be positive';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display validation summary
      expect(find.text('2 fields have validation errors'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays single validation error correctly', (WidgetTester tester) async {
      validationErrors['name'] = 'Strategy name is required';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should display singular validation message
      expect(find.text('1 field has validation errors'), findsOneWidget);
    });

    testWidgets('clears form data when strategy type changes', (WidgetTester tester) async {
      // Start with trendline strategy and some form data
      formData['name'] = 'Test Strategy';
      formData['supportLevel'] = 100.0;

      Widget buildForm(StrategyType? strategyType) {
        return MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: strategyType,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        );
      }

      await tester.pumpWidget(buildForm(StrategyType.trendline));

      // Verify initial data is present
      expect(formData['name'], equals('Test Strategy'));
      expect(formData['supportLevel'], equals(100.0));

      // Change to buy area strategy
      await tester.pumpWidget(buildForm(StrategyType.buyArea));
      await tester.pump();

      // Form data should be cleared (except for any default values)
      expect(formData.containsKey('supportLevel'), isFalse);
    });

    testWidgets('shows required field indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Should show star icons for required fields
      final requiredFieldsCount = StrategyType.trendline.fieldDefinitions
          .where((field) => field.required)
          .length;
      expect(find.byIcon(Icons.star), findsNWidgets(requiredFieldsCount));
    });

    testWidgets('handles dropdown field changes correctly', (WidgetTester tester) async {
      String? changedKey;
      dynamic changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                changedKey = key;
                changedValue = value;
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Tap on trend direction dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select an option
      await tester.tap(find.text('Upward').last);
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(changedKey, equals('trendDirection'));
      expect(changedValue, equals('upward'));
    });

    testWidgets('validates numeric fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicStrategyForm(
              strategyType: StrategyType.trendline,
              formData: formData,
              validationErrors: validationErrors,
              onFieldChanged: (key, value) {
                formData[key] = value;
              },
              formKey: formKey,
            ),
          ),
        ),
      );

      // Find support level field and enter invalid value
      final supportLevelField = find.widgetWithText(TextFormField, '').at(1); // Second text field
      await tester.enterText(supportLevelField, '-10');
      await tester.pump();

      // Trigger validation
      formKey.currentState?.validate();
      await tester.pump();

      // Should show validation error for negative value (may appear multiple times for different fields)
      expect(find.text('Must be positive'), findsAtLeastNWidgets(1));
    });
  });

  group('DynamicStrategyFormValidation Extension', () {
    testWidgets('isFormValid returns false for null strategy type', (WidgetTester tester) async {
      final isValid = DynamicStrategyFormValidation.isFormValid(
        strategyType: null,
        formData: {},
      );

      expect(isValid, isFalse);
    });

    testWidgets('isFormValid returns false for missing required fields', (WidgetTester tester) async {
      final isValid = DynamicStrategyFormValidation.isFormValid(
        strategyType: StrategyType.trendline,
        formData: {}, // Empty form data
      );

      expect(isValid, isFalse);
    });

    testWidgets('isFormValid returns true for complete valid form', (WidgetTester tester) async {
      final isValid = DynamicStrategyFormValidation.isFormValid(
        strategyType: StrategyType.trendline,
        formData: {
          'name': 'Test Strategy',
          'supportLevel': 100.0,
          'resistanceLevel': 120.0,
          'trendDirection': 'upward',
        },
      );

      expect(isValid, isTrue);
    });

    testWidgets('getValidationErrors returns errors for invalid fields', (WidgetTester tester) async {
      final errors = DynamicStrategyFormValidation.getValidationErrors(
        strategyType: StrategyType.trendline,
        formData: {
          'supportLevel': -10.0, // Invalid negative value
          'resistanceLevel': -5.0, // Invalid negative value
        },
      );

      expect(errors.isNotEmpty, isTrue);
      expect(errors.containsKey('supportLevel'), isTrue);
      expect(errors.containsKey('resistanceLevel'), isTrue);
    });

    testWidgets('clearAndResetForm returns empty map for null strategy', (WidgetTester tester) async {
      final result = DynamicStrategyFormValidation.clearAndResetForm(
        strategyType: null,
      );

      expect(result.isEmpty, isTrue);
    });

    testWidgets('clearAndResetForm returns default values for strategy', (WidgetTester tester) async {
      final result = DynamicStrategyFormValidation.clearAndResetForm(
        strategyType: StrategyType.trendline,
      );

      // Should return map with any default values defined in field definitions
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}