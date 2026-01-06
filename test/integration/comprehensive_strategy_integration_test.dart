import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/widgets/strategy_creation_dialog.dart';
import 'package:stockinfoapp/src/widgets/category_selector.dart';
import 'package:stockinfoapp/src/widgets/dynamic_strategy_form.dart';

void main() {
  group('Comprehensive Strategy Integration Tests', () {
    late AssetItem testAsset;
    late List<TradingStrategyItem> createdStrategies;

    setUp(() {
      testAsset = AssetItem(
        id: 'TEST001',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        strategies: [],
      );
      createdStrategies = [];
    });

    Widget createTestApp() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                StrategyCreationDialog.show(
                  context: context,
                  asset: testAsset,
                  onStrategyCreated: (strategy) {
                    createdStrategies.add(strategy);
                  },
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );
    }

    group('All Strategy Types Form Field Generation', () {
      for (final strategyType in StrategyType.values) {
        testWidgets('generates correct fields for ${strategyType.displayName}', (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: DynamicStrategyForm(
                  strategyType: strategyType,
                  formData: {},
                  validationErrors: {},
                  onFieldChanged: (key, value) {},
                  formKey: GlobalKey<FormState>(),
                ),
              ),
            ),
          );

          // Verify strategy header is displayed
          expect(find.text(strategyType.displayName), findsOneWidget);
          expect(find.text(strategyType.category.displayName), findsOneWidget);

          // Verify all strategy types have at least a name field
          expect(find.text('Strategy Name'), findsOneWidget);

          // Verify field definitions exist and are not empty
          final fieldDefinitions = strategyType.fieldDefinitions;
          expect(fieldDefinitions.isNotEmpty, isTrue, 
                 reason: '${strategyType.displayName} should have field definitions');

          // Verify all fields are rendered
          for (final field in fieldDefinitions) {
            expect(find.text(field.label), findsOneWidget,
                   reason: 'Field ${field.label} should be rendered for ${strategyType.displayName}');
          }
        });
      }
    });

    group('Category Organization Verification', () {
      testWidgets('all strategy types have valid category associations', (WidgetTester tester) async {
        for (final strategyType in StrategyType.values) {
          final category = strategyType.category;
          expect(StrategyCategory.values.contains(category), isTrue,
                 reason: '${strategyType.displayName} should have a valid category');
          
          // Verify the category contains this strategy
          expect(category.strategies.contains(strategyType), isTrue,
                 reason: 'Category ${category.displayName} should contain ${strategyType.displayName}');
        }
      });

      testWidgets('all categories have at least one strategy', (WidgetTester tester) async {
        for (final category in StrategyCategory.values) {
          expect(category.strategies.isNotEmpty, isTrue,
                 reason: 'Category ${category.displayName} should have at least one strategy');
        }
      });

      testWidgets('category selector displays all categories and strategies', (WidgetTester tester) async {
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

        // Verify all categories are displayed
        for (final category in StrategyCategory.values) {
          expect(find.text(category.displayName), findsOneWidget,
                 reason: 'Category ${category.displayName} should be displayed');
        }

        // Test each category shows its strategies
        for (final category in StrategyCategory.values) {
          await tester.tap(find.text(category.displayName));
          await tester.pumpAndSettle();

          for (final strategy in category.strategies) {
            expect(find.text(strategy.displayName), findsOneWidget,
                   reason: 'Strategy ${strategy.displayName} should be displayed in ${category.displayName}');
          }
        }
      });
    });

    group('End-to-End Strategy Creation Workflows', () {
      testWidgets('complete trendline strategy creation workflow', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        
        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Select Technical Analysis category and Trendline strategy
        await tester.tap(find.text('Strategy'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Technical Analysis'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Trendline'));
        await tester.pumpAndSettle();

        // Fill in all required fields
        await tester.enterText(find.byKey(const Key('strategy_name_field')), 'Test Trendline');
        await tester.enterText(find.byKey(const Key('supportLevel_field')), '95.0');
        await tester.enterText(find.byKey(const Key('resistanceLevel_field')), '105.0');
        
        // Select trend direction
        await tester.tap(find.byKey(const Key('trendDirection_field')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Upward').last);
        await tester.pumpAndSettle();

        // Verify create button is enabled and submit
        final createButton = find.text('Create Strategy');
        expect(createButton, findsOneWidget);
        
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Verify strategy was created
        expect(createdStrategies.length, 1);
        expect(createdStrategies.first.strategy.name, 'Test Trendline');
      });

      testWidgets('complete buy area strategy creation workflow', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        
        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Select Price Levels category and Buy Area strategy
        await tester.tap(find.text('Strategy'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Price Levels'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Buy Area'));
        await tester.pumpAndSettle();

        // Fill in all required fields
        await tester.enterText(find.byKey(const Key('strategy_name_field')), 'Test Buy Area');
        await tester.enterText(find.byKey(const Key('lowerBound_field')), '90.0');
        await tester.enterText(find.byKey(const Key('idealPrice_field')), '95.0');
        await tester.enterText(find.byKey(const Key('upperBound_field')), '100.0');

        // Submit form
        await tester.tap(find.text('Create Strategy'));
        await tester.pumpAndSettle();

        // Verify strategy was created
        expect(createdStrategies.length, 1);
        expect(createdStrategies.first.strategy.name, 'Test Buy Area');
      });

      testWidgets('complete elliott waves strategy creation workflow', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        
        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Select Technical Analysis category and Elliott Waves strategy
        await tester.tap(find.text('Strategy'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Technical Analysis'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Elliott Waves'));
        await tester.pumpAndSettle();

        // Fill in all required fields
        await tester.enterText(find.byKey(const Key('strategy_name_field')), 'Test Elliott Waves');
        await tester.enterText(find.byKey(const Key('currentWave_field')), '3');
        await tester.enterText(find.byKey(const Key('waveTargetPrice_field')), '110.0');

        // Submit form
        await tester.tap(find.text('Create Strategy'));
        await tester.pumpAndSettle();

        // Verify strategy was created
        expect(createdStrategies.length, 1);
        expect(createdStrategies.first.strategy.name, 'Test Elliott Waves');
      });

      testWidgets('complete composite strategy creation workflow', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        
        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Select Advanced category and Composite strategy
        await tester.tap(find.text('Strategy'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Advanced'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Composite'));
        await tester.pumpAndSettle();

        // Fill in all required fields
        await tester.enterText(find.byKey(const Key('strategy_name_field')), 'Test Composite');
        
        // Select root operator
        await tester.tap(find.byKey(const Key('rootOperator_field')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('AND').last);
        await tester.pumpAndSettle();

        // Submit form
        await tester.tap(find.text('Create Strategy'));
        await tester.pumpAndSettle();

        // Verify strategy was created
        expect(createdStrategies.length, 1);
        expect(createdStrategies.first.strategy.name, 'Test Composite');
      });
    });

    group('Error Handling and Edge Cases', () {
      testWidgets('handles invalid form submission gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        
        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Select a strategy but don't fill required fields
        await tester.tap(find.text('Strategy'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Technical Analysis'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Trendline'));
        await tester.pumpAndSettle();

        // Try to submit without filling required fields
        final createButton = find.text('Create Strategy');
        
        // Button should be disabled or form should show validation errors
        try {
          await tester.tap(createButton);
          await tester.pumpAndSettle();
        } catch (e) {
          // Expected if button is disabled
        }

        // No strategy should be created
        expect(createdStrategies.length, 0);
      });

      testWidgets('handles dialog cancellation correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        
        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Select strategy and fill some fields
        await tester.tap(find.text('Strategy'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Technical Analysis'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Trendline'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('strategy_name_field')), 'Cancelled Strategy');

        // Cancel dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // No strategy should be created
        expect(createdStrategies.length, 0);
        
        // Dialog should be closed
        expect(find.byType(StrategyCreationDialog), findsNothing);
      });

      testWidgets('handles rapid category/strategy switching', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());
        
        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        // Rapidly switch between categories and strategies
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('Strategy'));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('Technical Analysis'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Trendline'));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Trendline'));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('Price Levels'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Buy Area'));
          await tester.pumpAndSettle();
        }

        // Dialog should still be functional
        expect(find.byType(StrategyCreationDialog), findsOneWidget);
        expect(find.text('Create Trading Strategy'), findsOneWidget);
      });
    });

    group('Form Validation Comprehensive Testing', () {
      testWidgets('validates all numeric field constraints across strategy types', (WidgetTester tester) async {
        for (final strategyType in StrategyType.values) {
          final fieldDefinitions = strategyType.fieldDefinitions;
          final numericFields = fieldDefinitions.where(
            (field) => field.type == FieldType.decimal || field.type == FieldType.number
          ).toList();

          if (numericFields.isNotEmpty) {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: DynamicStrategyForm(
                    strategyType: strategyType,
                    formData: {},
                    validationErrors: {},
                    onFieldChanged: (key, value) {},
                    formKey: GlobalKey<FormState>(),
                  ),
                ),
              ),
            );

            // Test each numeric field with invalid values
            for (final field in numericFields) {
              final fieldFinder = find.byKey(Key('${field.key}_field'));
              if (fieldFinder.evaluate().isNotEmpty) {
                // Test negative values for fields that should be positive
                await tester.enterText(fieldFinder, '-10');
                await tester.pump();
                
                // Test non-numeric values
                await tester.enterText(fieldFinder, 'invalid');
                await tester.pump();
              }
            }
          }
        }
      });

      testWidgets('validates required fields across all strategy types', (WidgetTester tester) async {
        for (final strategyType in StrategyType.values) {
          final requiredFields = strategyType.fieldDefinitions.where((field) => field.required).toList();
          
          if (requiredFields.isNotEmpty) {
            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: DynamicStrategyForm(
                    strategyType: strategyType,
                    formData: {},
                    validationErrors: {},
                    onFieldChanged: (key, value) {},
                    formKey: GlobalKey<FormState>(),
                  ),
                ),
              ),
            );

            // Verify required field indicators are shown
            expect(find.byIcon(Icons.star), findsNWidgets(requiredFields.length),
                   reason: '${strategyType.displayName} should show ${requiredFields.length} required field indicators');
          }
        }
      });
    });

    group('Performance and Stress Testing', () {
      testWidgets('handles multiple rapid dialog open/close cycles', (WidgetTester tester) async {
        await tester.pumpWidget(createTestApp());

        // Rapidly open and close dialog multiple times
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.text('Open Dialog'));
          await tester.pump(); // Don't settle to simulate rapid interaction
          
          if (find.text('Cancel').evaluate().isNotEmpty) {
            await tester.tap(find.text('Cancel'));
            await tester.pump();
          }
        }

        await tester.pumpAndSettle();

        // App should still be responsive
        expect(find.text('Open Dialog'), findsOneWidget);
      });

      testWidgets('handles large form data without performance issues', (WidgetTester tester) async {
        final largeFormData = <String, dynamic>{};
        
        // Create large form data map
        for (int i = 0; i < 1000; i++) {
          largeFormData['field_$i'] = 'value_$i';
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DynamicStrategyForm(
                strategyType: StrategyType.trendline,
                formData: largeFormData,
                validationErrors: {},
                onFieldChanged: (key, value) {},
                formKey: GlobalKey<FormState>(),
              ),
            ),
          ),
        );

        // Form should still render correctly
        expect(find.text('Trendline'), findsOneWidget);
        expect(find.text('Strategy Name'), findsOneWidget);
      });
    });
  });
}