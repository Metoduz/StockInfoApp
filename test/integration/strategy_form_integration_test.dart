import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/widgets/category_selector.dart';
import 'package:stockinfoapp/src/widgets/dynamic_strategy_form.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';

void main() {
  group('Strategy Form Integration Tests', () {
    late Map<String, dynamic> formData;
    late Map<String, String> validationErrors;
    late GlobalKey<FormState> formKey;

    setUp(() {
      formData = <String, dynamic>{};
      validationErrors = <String, String>{};
      formKey = GlobalKey<FormState>();
    });

    group('Form field generation for all strategy types', () {
      testWidgets('generates correct fields for Trendline strategy', (WidgetTester tester) async {
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

        // Verify all expected fields are present
        expect(find.text('Strategy Name'), findsOneWidget);
        expect(find.text('Support Level'), findsOneWidget);
        expect(find.text('Resistance Level'), findsOneWidget);
        expect(find.text('Trend Direction'), findsOneWidget);

        // Verify field types
        expect(find.byType(TextFormField), findsNWidgets(3)); // Name, Support, Resistance
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Trend Direction
      });

      testWidgets('generates correct fields for Buy Area strategy', (WidgetTester tester) async {
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

        // Verify all expected fields are present
        expect(find.text('Strategy Name'), findsOneWidget);
        expect(find.text('Lower Bound'), findsOneWidget);
        expect(find.text('Ideal Price'), findsOneWidget);
        expect(find.text('Upper Bound'), findsOneWidget);

        // Verify field types
        expect(find.byType(TextFormField), findsNWidgets(4)); // All text fields
      });

      testWidgets('generates correct fields for Elliott Waves strategy', (WidgetTester tester) async {
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

        // Verify all expected fields are present
        expect(find.text('Strategy Name'), findsOneWidget);
        expect(find.text('Current Wave'), findsOneWidget);
        expect(find.text('Wave Target Price'), findsOneWidget);

        // Verify field types
        expect(find.byType(TextFormField), findsNWidgets(3)); // All text fields
      });

      testWidgets('generates correct fields for Composite strategy', (WidgetTester tester) async {
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

        // Verify all expected fields are present
        expect(find.text('Strategy Name'), findsOneWidget);
        expect(find.text('Root Operator'), findsOneWidget);

        // Verify field types
        expect(find.byType(TextFormField), findsOneWidget); // Name
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget); // Root Operator
      });
    });

    group('Validation logic testing', () {
      testWidgets('validates numeric field constraints', (WidgetTester tester) async {
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

        // Enter invalid negative values
        final supportLevelField = find.widgetWithText(TextFormField, '').at(1);
        await tester.enterText(supportLevelField, '-10');
        await tester.pump();

        // Trigger validation
        formKey.currentState?.validate();
        await tester.pump();

        // Should show validation error for negative value
        expect(find.text('Must be positive'), findsAtLeastNWidgets(1));
      });

      testWidgets('validates Elliott Waves wave number constraints', (WidgetTester tester) async {
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

        // Enter invalid wave number (outside 1-5 range)
        final waveField = find.widgetWithText(TextFormField, '').at(1); // Current Wave field
        await tester.enterText(waveField, '10');
        await tester.pump();

        // Trigger validation
        formKey.currentState?.validate();
        await tester.pump();

        // Should show validation error for out-of-range value
        expect(find.text('Must be between 1 and 5'), findsOneWidget);
      });
    });

    group('Category and strategy organization', () {
      testWidgets('strategy types have correct category associations', (WidgetTester tester) async {
        // Test that each strategy type belongs to the expected category
        expect(StrategyType.trendline.category, equals(StrategyCategory.technicalAnalysis));
        expect(StrategyType.elliotWaves.category, equals(StrategyCategory.technicalAnalysis));
        expect(StrategyType.buyArea.category, equals(StrategyCategory.priceLevels));
        expect(StrategyType.composite.category, equals(StrategyCategory.advanced));
      });

      testWidgets('all strategy types have field definitions', (WidgetTester tester) async {
        // Test that each strategy type has field definitions
        for (final strategyType in StrategyType.values) {
          final fieldDefinitions = strategyType.fieldDefinitions;
          expect(fieldDefinitions.isNotEmpty, isTrue, 
                 reason: 'Strategy type ${strategyType.displayName} should have field definitions');
          
          // All strategies should have at least a name field
          final hasNameField = fieldDefinitions.any((field) => field.key == 'name');
          expect(hasNameField, isTrue, 
                 reason: 'Strategy type ${strategyType.displayName} should have a name field');
        }
      });

      testWidgets('category selector shows all categories', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategorySelector(
                selectedCategory: null,
                selectedStrategy: null,
                onCategoryChanged: (category) {},
                onStrategyChanged: (strategy) {},
              ),
            ),
          ),
        );

        // Open dropdown
        await tester.tap(find.byType(CategorySelector));
        await tester.pumpAndSettle();

        // Should show all categories
        for (final category in StrategyCategory.values) {
          expect(find.text(category.displayName), findsOneWidget);
        }
      });

      testWidgets('each category has associated strategies', (WidgetTester tester) async {
        // Test that each category has strategies
        for (final category in StrategyCategory.values) {
          final strategies = category.strategies;
          expect(strategies.isNotEmpty, isTrue, 
                 reason: 'Category ${category.displayName} should have strategies');
        }
      });
    });
  });
}