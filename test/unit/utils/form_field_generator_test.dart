import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/utils/form_field_generator.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';

void main() {
  group('FormFieldGenerator', () {
    group('generateFormField', () {
      testWidgets('generates text field correctly', (WidgetTester tester) async {
        final fieldDef = StrategyFieldDefinition(
          key: 'name',
          label: 'Strategy Name',
          type: FieldType.text,
          required: true,
          hint: 'Enter strategy name',
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: 'Test Value',
          onChanged: (value) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Should create TextFormField with correct properties
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Strategy Name'), findsOneWidget);
        expect(find.text('Enter strategy name'), findsOneWidget);

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.initialValue, equals('Test Value'));
      });

      testWidgets('generates number field correctly', (WidgetTester tester) async {
        final fieldDef = StrategyFieldDefinition(
          key: 'wave',
          label: 'Wave Number',
          type: FieldType.number,
          required: true,
          hint: 'Enter wave number',
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: 3,
          onChanged: (value) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Should create TextFormField with number keyboard
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Wave Number'), findsOneWidget);

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.initialValue, equals('3'));
        // Note: keyboardType is not directly accessible on TextFormField widget
      });

      testWidgets('generates decimal field correctly', (WidgetTester tester) async {
        final fieldDef = StrategyFieldDefinition(
          key: 'price',
          label: 'Price Level',
          type: FieldType.decimal,
          required: true,
          hint: 'Enter price',
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: 123.45,
          onChanged: (value) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Should create TextFormField with decimal keyboard
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Price Level'), findsOneWidget);

        final textField = tester.widget<TextFormField>(find.byType(TextFormField));
        expect(textField.initialValue, equals('123.45'));
        // Note: keyboardType is not directly accessible on TextFormField widget
      });

      testWidgets('generates dropdown field correctly', (WidgetTester tester) async {
        final fieldDef = StrategyFieldDefinition(
          key: 'direction',
          label: 'Trend Direction',
          type: FieldType.dropdown,
          required: true,
          hint: 'Select direction',
          dropdownOptions: [
            const DropdownOption(value: 'up', label: 'Upward'),
            const DropdownOption(value: 'down', label: 'Downward'),
          ],
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: 'up',
          onChanged: (value) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Should create DropdownButtonFormField
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        expect(find.text('Trend Direction'), findsOneWidget);

        // Tap dropdown to open it
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Should show dropdown options
        expect(find.text('Upward'), findsAtLeastNWidgets(1));
        expect(find.text('Downward'), findsAtLeastNWidgets(1));
      });

      testWidgets('generates toggle field correctly', (WidgetTester tester) async {
        final fieldDef = StrategyFieldDefinition(
          key: 'enabled',
          label: 'Enable Alerts',
          type: FieldType.toggle,
          required: false,
          hint: 'Enable alert notifications',
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: true,
          onChanged: (value) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Should create SwitchListTile
        expect(find.byType(SwitchListTile), findsOneWidget);
        expect(find.text('Enable Alerts'), findsOneWidget);
        expect(find.text('Enable alert notifications'), findsOneWidget);

        final switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
        expect(switchTile.value, isTrue);
      });

      testWidgets('shows required field indicator', (WidgetTester tester) async {
        final fieldDef = StrategyFieldDefinition(
          key: 'name',
          label: 'Strategy Name',
          type: FieldType.text,
          required: true,
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: '',
          onChanged: (value) {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Should show star icon for required field
        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('displays error text when provided', (WidgetTester tester) async {
        final fieldDef = StrategyFieldDefinition(
          key: 'name',
          label: 'Strategy Name',
          type: FieldType.text,
          required: true,
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: '',
          onChanged: (value) {},
          errorText: 'This field is required',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        // Should display error text
        expect(find.text('This field is required'), findsOneWidget);
      });
    });

    group('field value changes', () {
      testWidgets('text field calls onChanged with string value', (WidgetTester tester) async {
        dynamic changedValue;
        final fieldDef = StrategyFieldDefinition(
          key: 'name',
          label: 'Strategy Name',
          type: FieldType.text,
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: '',
          onChanged: (value) {
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'New Value');

        expect(changedValue, equals('New Value'));
      });

      testWidgets('number field calls onChanged with int value', (WidgetTester tester) async {
        dynamic changedValue;
        final fieldDef = StrategyFieldDefinition(
          key: 'wave',
          label: 'Wave Number',
          type: FieldType.number,
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: null,
          onChanged: (value) {
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '42');

        expect(changedValue, equals(42));
      });

      testWidgets('decimal field calls onChanged with double value', (WidgetTester tester) async {
        dynamic changedValue;
        final fieldDef = StrategyFieldDefinition(
          key: 'price',
          label: 'Price Level',
          type: FieldType.decimal,
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: null,
          onChanged: (value) {
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), '123.45');

        expect(changedValue, equals(123.45));
      });

      testWidgets('toggle field calls onChanged with bool value', (WidgetTester tester) async {
        dynamic changedValue;
        final fieldDef = StrategyFieldDefinition(
          key: 'enabled',
          label: 'Enable Alerts',
          type: FieldType.toggle,
        );

        final widget = FormFieldGenerator.generateFormField(
          fieldDef: fieldDef,
          value: false,
          onChanged: (value) {
            changedValue = value;
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: widget,
            ),
          ),
        );

        await tester.tap(find.byType(Switch));

        expect(changedValue, isTrue);
      });
    });

    group('utility methods', () {
      test('validateAllFields returns errors for invalid data', () {
        final errors = FormFieldGenerator.validateAllFields(
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

      test('validateAllFields returns empty map for valid data', () {
        final errors = FormFieldGenerator.validateAllFields(
          strategyType: StrategyType.trendline,
          formData: {
            'name': 'Test Strategy',
            'supportLevel': 100.0,
            'resistanceLevel': 120.0,
            'trendDirection': 'upward',
          },
        );

        expect(errors.isEmpty, isTrue);
      });

      test('isFormValid returns false for missing required fields', () {
        final isValid = FormFieldGenerator.isFormValid(
          strategyType: StrategyType.trendline,
          formData: {
            'supportLevel': 100.0,
            // Missing required 'name' field
          },
        );

        expect(isValid, isFalse);
      });

      test('isFormValid returns false for invalid field values', () {
        final isValid = FormFieldGenerator.isFormValid(
          strategyType: StrategyType.trendline,
          formData: {
            'name': 'Test Strategy',
            'supportLevel': -10.0, // Invalid negative value
            'resistanceLevel': 120.0,
            'trendDirection': 'upward',
          },
        );

        expect(isValid, isFalse);
      });

      test('isFormValid returns true for complete valid form', () {
        final isValid = FormFieldGenerator.isFormValid(
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

      test('getDefaultFormData returns default values', () {
        final defaultData = FormFieldGenerator.getDefaultFormData(StrategyType.trendline);

        // Should return map with any default values defined in field definitions
        expect(defaultData, isA<Map<String, dynamic>>());
      });

      test('clearIrrelevantFields removes fields not relevant to strategy', () {
        final currentData = {
          'name': 'Test Strategy',
          'supportLevel': 100.0,
          'irrelevantField': 'should be removed',
        };

        final clearedData = FormFieldGenerator.clearIrrelevantFields(
          strategyType: StrategyType.trendline,
          currentFormData: currentData,
        );

        expect(clearedData.containsKey('name'), isTrue);
        expect(clearedData.containsKey('supportLevel'), isTrue);
        expect(clearedData.containsKey('irrelevantField'), isFalse);
      });
    });
  });
}