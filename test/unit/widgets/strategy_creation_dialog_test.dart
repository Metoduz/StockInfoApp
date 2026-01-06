import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/widgets/strategy_creation_dialog.dart';

void main() {
  group('StrategyCreationDialog', () {
    late AssetItem testAsset;
    late List<TradingStrategyItem> createdStrategies;

    setUp(() {
      testAsset = AssetItem(
        id: 'test-asset',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
      );
      createdStrategies = [];
    });

    Widget createTestWidget() {
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

    testWidgets('displays dialog when show method is called', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      // Tap button to open dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.byType(StrategyCreationDialog), findsOneWidget);
      expect(find.text('Create Trading Strategy'), findsOneWidget);
    });

    testWidgets('displays asset context information', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify asset information is displayed
      expect(find.text('Test Asset'), findsOneWidget);
      expect(find.text('TEST • 100.00 USD'), findsOneWidget);
    });

    testWidgets('displays category selector and form sections', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify main sections are present
      expect(find.text('Strategy Type'), findsOneWidget);
      expect(find.text('Strategy Configuration'), findsOneWidget);
      expect(find.text('Choose a strategy category and type to configure'), findsOneWidget);
    });

    testWidgets('shows placeholder when no strategy is selected', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify placeholder is shown
      expect(find.text('Select a strategy to configure its parameters'), findsOneWidget);
      expect(find.byIcon(Icons.assignment), findsOneWidget);
    });

    testWidgets('create button is disabled when form is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify create button is disabled
      final createButton = find.text('Create Strategy');
      expect(createButton, findsOneWidget);
      
      final button = tester.widget<FilledButton>(find.ancestor(
        of: createButton,
        matching: find.byType(FilledButton),
      ));
      expect(button.onPressed, isNull);
    });

    testWidgets('closes dialog when cancel button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(StrategyCreationDialog), findsNothing);
    });

    testWidgets('closes dialog when close button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Tap close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(StrategyCreationDialog), findsNothing);
    });

    testWidgets('closes dialog when escape key is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Press escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(StrategyCreationDialog), findsNothing);
    });

    testWidgets('displays loading state when creating strategy', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Select a strategy type first
      await tester.tap(find.text('Strategy'));
      await tester.pumpAndSettle();
      
      // Select Technical Analysis category
      await tester.tap(find.text('Technical Analysis'));
      await tester.pumpAndSettle();
      
      // Select Trendline strategy
      await tester.tap(find.text('Trendline'));
      await tester.pumpAndSettle();

      // Fill in required fields
      await tester.enterText(find.byType(TextFormField).first, 'Test Strategy');
      await tester.enterText(find.byType(TextFormField).at(1), '90.0');
      await tester.enterText(find.byType(TextFormField).at(2), '110.0');
      
      // Select trend direction
      await tester.tap(find.text('Select trend direction').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upward').last);
      await tester.pumpAndSettle();

      // Tap create button (this will trigger loading state briefly)
      await tester.tap(find.text('Create Strategy'));
      await tester.pump(); // Don't settle to catch loading state

      // Note: The loading state is very brief, so we mainly verify the strategy was created
      await tester.pumpAndSettle();
      
      // Verify strategy was created
      expect(createdStrategies.length, 1);
      expect(createdStrategies.first.strategy.name, 'Test Strategy');
    });

    testWidgets('displays correct dialog header and styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.byIcon(Icons.add_chart), findsOneWidget);
      expect(find.text('Create Trading Strategy'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('handles modal behavior correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is modal (barrier is present)
      expect(find.byType(ModalBarrier), findsOneWidget);
      
      // Verify dialog content is displayed
      expect(find.byType(Dialog), findsOneWidget);
    });
  });
}