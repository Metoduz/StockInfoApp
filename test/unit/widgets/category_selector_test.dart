import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/widgets/category_selector.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';

void main() {
  group('CategorySelector', () {
    testWidgets('displays default "Strategy" text when no strategy selected', (WidgetTester tester) async {
      StrategyCategory? selectedCategory;
      StrategyType? selectedStrategy;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: selectedCategory,
              selectedStrategy: selectedStrategy,
              onCategoryChanged: (category) {
                selectedCategory = category;
              },
              onStrategyChanged: (strategy) {
                selectedStrategy = strategy;
              },
            ),
          ),
        ),
      );

      // Should display default "Strategy" text
      expect(find.text('Strategy'), findsOneWidget);
    });

    testWidgets('displays selected strategy name when strategy is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: StrategyCategory.technicalAnalysis,
              selectedStrategy: StrategyType.trendline,
              onCategoryChanged: (category) {},
              onStrategyChanged: (strategy) {},
            ),
          ),
        ),
      );

      // Should display the selected strategy name
      expect(find.text(StrategyType.trendline.displayName), findsOneWidget);
    });

    testWidgets('opens dropdown when tapped', (WidgetTester tester) async {
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

      // Tap the dropdown trigger
      await tester.tap(find.byType(CategorySelector));
      await tester.pumpAndSettle();

      // Should show category panel headers
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Strategies'), findsOneWidget);
    });

    testWidgets('displays all strategy categories in left panel', (WidgetTester tester) async {
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

      // Should display all categories
      for (final category in StrategyCategory.values) {
        expect(find.text(category.displayName), findsOneWidget);
      }
    });

    testWidgets('displays strategies for selected category in right panel', (WidgetTester tester) async {
      StrategyCategory? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: selectedCategory,
              selectedStrategy: null,
              onCategoryChanged: (category) {
                selectedCategory = category;
              },
              onStrategyChanged: (strategy) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(CategorySelector));
      await tester.pumpAndSettle();

      // Tap on Technical Analysis category
      await tester.tap(find.text('Technical Analysis'));
      await tester.pumpAndSettle();

      // Should display strategies for Technical Analysis category
      final technicalStrategies = StrategyCategory.technicalAnalysis.strategies;
      for (final strategy in technicalStrategies) {
        expect(find.text(strategy.displayName), findsOneWidget);
      }
    });

    testWidgets('calls onCategoryChanged when category is selected', (WidgetTester tester) async {
      StrategyCategory? selectedCategory;
      bool categoryChangedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: selectedCategory,
              selectedStrategy: null,
              onCategoryChanged: (category) {
                selectedCategory = category;
                categoryChangedCalled = true;
              },
              onStrategyChanged: (strategy) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(CategorySelector));
      await tester.pumpAndSettle();

      // Tap on Price Levels category
      await tester.tap(find.text('Price Levels'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(categoryChangedCalled, isTrue);
      expect(selectedCategory, equals(StrategyCategory.priceLevels));
    });

    testWidgets('calls onStrategyChanged and closes dropdown when strategy is selected', (WidgetTester tester) async {
      StrategyType? selectedStrategy;
      bool strategyChangedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: StrategyCategory.technicalAnalysis,
              selectedStrategy: selectedStrategy,
              onCategoryChanged: (category) {},
              onStrategyChanged: (strategy) {
                selectedStrategy = strategy;
                strategyChangedCalled = true;
              },
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(CategorySelector));
      await tester.pumpAndSettle();

      // Tap on Trendline strategy
      await tester.tap(find.text(StrategyType.trendline.displayName));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(strategyChangedCalled, isTrue);
      expect(selectedStrategy, equals(StrategyType.trendline));

      // Verify dropdown is closed (categories panel should not be visible)
      expect(find.text('Categories'), findsNothing);
    });

    testWidgets('shows category icons correctly', (WidgetTester tester) async {
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

      // Should display category icons
      for (final category in StrategyCategory.values) {
        expect(find.byIcon(category.icon), findsOneWidget);
      }
    });

    testWidgets('highlights selected category', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: StrategyCategory.technicalAnalysis,
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

      // Find the Technical Analysis category item
      final categoryItem = find.ancestor(
        of: find.text('Technical Analysis'),
        matching: find.byType(Container),
      ).first;

      // Get the container widget
      final container = tester.widget<Container>(categoryItem);
      final decoration = container.decoration as BoxDecoration?;

      // Should have primary container color for selected category
      expect(decoration?.color, isNotNull);
    });

    testWidgets('defaults to first category when none selected', (WidgetTester tester) async {
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

      // Should show strategies for the first category (Technical Analysis)
      final firstCategoryStrategies = StrategyCategory.values.first.strategies;
      for (final strategy in firstCategoryStrategies) {
        expect(find.text(strategy.displayName), findsOneWidget);
      }
    });

    testWidgets('shows arrow icons correctly', (WidgetTester tester) async {
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

      // Should show down arrow when closed
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Open dropdown
      await tester.tap(find.byType(CategorySelector));
      await tester.pumpAndSettle();

      // Should show up arrow when open
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('shows strategy items without arrows for cleaner layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategorySelector(
              selectedCategory: StrategyCategory.technicalAnalysis,
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

      // Should not show forward arrows for strategy items (removed for cleaner layout)
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
      
      // But should still show strategy names
      final strategies = StrategyCategory.technicalAnalysis.strategies;
      for (final strategy in strategies) {
        expect(find.text(strategy.displayName), findsOneWidget);
      }
    });

    testWidgets('closes dropdown when clicking outside', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CategorySelector(
                  selectedCategory: StrategyCategory.technicalAnalysis,
                  selectedStrategy: null,
                  onCategoryChanged: (category) {},
                  onStrategyChanged: (strategy) {},
                ),
                const SizedBox(height: 50),
                const Text('Outside area'),
              ],
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(CategorySelector));
      await tester.pumpAndSettle();

      // Verify dropdown is open
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Strategies'), findsOneWidget);

      // Click outside the dropdown and trigger button areas
      await tester.tapAt(const Offset(50, 400));
      await tester.pumpAndSettle();

      // Verify dropdown is closed
      expect(find.text('Categories'), findsNothing);
      expect(find.text('Strategies'), findsNothing);
    });
  });
}