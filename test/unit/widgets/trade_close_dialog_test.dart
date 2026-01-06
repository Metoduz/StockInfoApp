import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/widgets/trade_close_dialog.dart';
import 'package:stockinfoapp/src/models/active_trade.dart';
import 'package:stockinfoapp/src/strategies/trading_strategy_base.dart';

void main() {
  group('TradeCloseDialog', () {
    late ActiveTradeItem testTrade;

    setUp(() {
      testTrade = ActiveTradeItem(
        id: 'test-trade-1',
        assetId: 'AAPL',
        direction: TradeDirection.long,
        quantity: 10.0,
        buyPrice: 150.0,
        openDate: DateTime.now().subtract(const Duration(days: 5)),
      );
    });

    testWidgets('displays trade information correctly', (WidgetTester tester) async {
      bool confirmCalled = false;
      double? receivedSellPrice;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeCloseDialog(
              trade: testTrade,
              currentPrice: 160.0,
              currency: 'USD',
              onConfirm: (sellPrice) {
                confirmCalled = true;
                receivedSellPrice = sellPrice;
              },
            ),
          ),
        ),
      );

      // Verify dialog title
      expect(find.text('Close Trade'), findsNWidgets(2)); // Title and button

      // Verify trade direction is displayed
      expect(find.text('Long'), findsOneWidget);

      // Verify quantity is displayed
      expect(find.text('Qty: 10.00'), findsOneWidget);

      // Verify buy price is displayed
      expect(find.text('Buy Price: 150.00 USD'), findsOneWidget);

      // Verify current price is displayed
      expect(find.text('Current Price: 160.00 USD'), findsOneWidget);

      // Verify sell price field is pre-filled with current price
      final sellPriceField = find.byType(TextFormField);
      expect(sellPriceField, findsOneWidget);
      
      final textField = tester.widget<TextFormField>(sellPriceField);
      expect(textField.controller?.text, '160.00');
    });

    testWidgets('calculates P&L correctly for profitable trade', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeCloseDialog(
              trade: testTrade,
              currentPrice: 160.0,
              currency: 'USD',
              onConfirm: (sellPrice) {},
            ),
          ),
        ),
      );

      // Should show positive P&L
      expect(find.textContaining('+6.67%'), findsOneWidget);
      expect(find.textContaining('+100.00 USD'), findsOneWidget);
    });

    testWidgets('calculates P&L correctly for losing trade', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeCloseDialog(
              trade: testTrade,
              currentPrice: 140.0,
              currency: 'USD',
              onConfirm: (sellPrice) {},
            ),
          ),
        ),
      );

      // Enter losing sell price
      await tester.enterText(find.byType(TextFormField), '140.00');
      await tester.pump();

      // Should show negative P&L
      expect(find.textContaining('-6.67%'), findsOneWidget);
      expect(find.textContaining('-100.00 USD'), findsOneWidget);
      
      // Should show warning for losses
      expect(find.text('This trade will result in a loss'), findsOneWidget);
    });

    testWidgets('validates sell price input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeCloseDialog(
              trade: testTrade,
              currentPrice: 160.0,
              currency: 'USD',
              onConfirm: (sellPrice) {},
            ),
          ),
        ),
      );

      // Enter valid price and verify no validation errors
      await tester.enterText(find.byType(TextFormField), '165.50');
      await tester.pump();

      // Should not show any validation errors
      expect(find.textContaining('Please enter'), findsNothing);
      expect(find.textContaining('valid price'), findsNothing);
      expect(find.textContaining('greater than 0'), findsNothing);
    });

    testWidgets('calls onConfirm with correct sell price', (WidgetTester tester) async {
      bool confirmCalled = false;
      double? receivedSellPrice;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeCloseDialog(
              trade: testTrade,
              currentPrice: 160.0,
              currency: 'USD',
              onConfirm: (sellPrice) {
                confirmCalled = true;
                receivedSellPrice = sellPrice;
              },
            ),
          ),
        ),
      );

      // Enter custom sell price
      await tester.enterText(find.byType(TextFormField), '165.50');
      await tester.pump();

      // Tap close trade button
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      // Verify callback was called with correct price
      expect(confirmCalled, isTrue);
      expect(receivedSellPrice, 165.50);
    });

    testWidgets('can be cancelled', (WidgetTester tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TradeCloseDialog(
              trade: testTrade,
              currentPrice: 160.0,
              currency: 'USD',
              onConfirm: (sellPrice) {
                confirmCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap cancel button
      await tester.tap(find.byType(TextButton));
      await tester.pump();

      // Verify callback was not called
      expect(confirmCalled, isFalse);
    });
  });
}