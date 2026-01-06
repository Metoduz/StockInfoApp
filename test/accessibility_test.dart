import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_item.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';
import 'package:stockinfoapp/src/widgets/strategy_creation_dialog.dart';

void main() {
  group('Accessibility Features Tests', () {
    late AssetItem testAsset;

    setUp(() {
      testAsset = AssetItem(
        id: 'test-1',
        name: 'Test Asset',
        symbol: 'TEST',
        currentValue: 100.0,
        currency: 'USD',
        dayChange: 5.0,
        dayChangePercent: 5.0,
        lastUpdated: DateTime.now(),
        primaryIdentifierType: AssetIdentifierType.ticker,
        strategies: [],
        tags: [],
      );
    });

    testWidgets('Strategy creation dialog has proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  StrategyCreationDialog.show(
                    context: context,
                    asset: testAsset,
                    onStrategyCreated: (strategy) {},
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check for accessibility labels
      expect(find.bySemanticsLabel(RegExp(r'Strategy creation dialog for.*')), findsOneWidget);
      expect(find.bySemanticsLabel('Close dialog'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Asset context:.*')), findsOneWidget);
    });

    testWidgets('Form fields have proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  StrategyCreationDialog.show(
                    context: context,
                    asset: testAsset,
                    onStrategyCreated: (strategy) {},
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check for strategy selector accessibility
      expect(find.bySemanticsLabel(RegExp(r'Strategy selector.*')), findsOneWidget);
    });

    testWidgets('Buttons have proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  StrategyCreationDialog.show(
                    context: context,
                    asset: testAsset,
                    onStrategyCreated: (strategy) {},
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Check for button accessibility labels
      expect(find.bySemanticsLabel('Cancel strategy creation'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Create strategy.*')), findsOneWidget);
    });
  });
}