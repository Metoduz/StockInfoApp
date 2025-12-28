import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/navigation/navigation_shell.dart';
import 'package:stockinfoapp/src/navigation/drawer_menu.dart';
import 'package:stockinfoapp/src/screens/asset_list.dart';
import 'package:stockinfoapp/src/screens/news_screen.dart';
import 'package:stockinfoapp/src/screens/alerts_screen.dart';
import 'package:stockinfoapp/src/screens/user_profile_screen.dart';
import 'package:stockinfoapp/src/screens/settings_screen.dart';
import 'package:stockinfoapp/src/screens/trading_history_screen.dart';
import 'package:stockinfoapp/src/screens/legal_info_screen.dart';
import 'package:stockinfoapp/src/widgets/asset_card.dart';

void main() {
  group('Navigation Properties', () {
    testWidgets('Property 1: Tab Navigation Consistency - For any tab selection in the bottom navigation, the app should display the corresponding screen and highlight the selected tab',
        (WidgetTester tester) async {
      // **Feature: enhanced-navigation, Property 1: Tab Navigation Consistency**
      // **Validates: Requirements 1.2, 1.3, 1.4, 1.6**
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 3; iteration++) {
        // Build the NavigationShell widget
        await tester.pumpWidget(
          const MaterialApp(
            home: NavigationShell(),
          ),
        );

        // Test each tab (0: Main, 1: News, 2: Alerts)
        for (int tabIndex = 0; tabIndex < 3; tabIndex++) {
          // Tap the tab
          await tester.tap(find.byIcon(_getTabIcon(tabIndex)));
          await tester.pumpAndSettle();

          // Verify the correct tab is highlighted
          final BottomNavigationBar bottomNav = tester.widget(find.byType(BottomNavigationBar));
          expect(bottomNav.currentIndex, equals(tabIndex),
              reason: 'Tab $tabIndex should be highlighted when selected');

          // Verify the corresponding screen is displayed by checking for specific screen widgets
          expect(find.byType(_getExpectedScreenType(tabIndex)), findsOneWidget,
              reason: 'Screen for tab $tabIndex should be displayed');
        }

        // Reset for next iteration
        await tester.binding.reassembleApplication();
      }
    });

    testWidgets('Property 2: State Preservation Across Navigation - For any tab with established state, switching to another tab and back should preserve the original state',
        (WidgetTester tester) async {
      // **Feature: enhanced-navigation, Property 2: State Preservation Across Navigation**
      // **Validates: Requirements 1.5**
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Build the NavigationShell widget
        await tester.pumpWidget(
          const MaterialApp(
            home: NavigationShell(),
          ),
        );

        // Start on Main tab (index 0) - this should be the default
        expect(find.byType(AssetList), findsOneWidget);
        
        // Create some state by opening a stock detail dialog
        // Find the first asset card and tap it to open details
        final assetCards = find.byType(AssetCard);
        if (assetCards.evaluate().isNotEmpty) {
          await tester.tap(assetCards.first);
          await tester.pumpAndSettle();
          
          // Verify dialog is open
          expect(find.byType(AlertDialog), findsOneWidget);
          
          // Close the dialog to establish a known state
          await tester.tap(find.text('Close'));
          await tester.pumpAndSettle();
        }
        
        // Record the current scroll position and any other state indicators
        final listView = find.byType(ListView);
        ScrollController? scrollController;
        if (listView.evaluate().isNotEmpty) {
          final listViewWidget = tester.widget<ListView>(listView);
          scrollController = listViewWidget.controller;
        }
        
        // Switch to News tab (index 1)
        await tester.tap(find.byIcon(Icons.newspaper));
        await tester.pumpAndSettle();
        
        // Verify we're on News tab
        expect(find.byType(NewsScreen), findsOneWidget);
        expect(find.text('Financial News'), findsOneWidget);
        
        // Switch to Alerts tab (index 2)
        await tester.tap(find.byIcon(Icons.notifications));
        await tester.pumpAndSettle();
        
        // Verify we're on Alerts tab
        expect(find.byType(AlertsScreen), findsOneWidget);
        expect(find.text('Asset Alerts'), findsOneWidget);
        
        // Switch back to Main tab (index 0)
        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
        
        // Verify we're back on Main tab and state is preserved
        expect(find.byType(AssetList), findsOneWidget);
        
        // Verify the asset list is still there (state preserved)
        expect(find.byType(AssetCard), findsWidgets);
        
        // Verify specific asset items are still present (content preserved)
        expect(find.text('BASF SE'), findsOneWidget);
        expect(find.text('SAP SE'), findsOneWidget);
        expect(find.text('Mercedes-Benz Group AG'), findsOneWidget);
        
        // Verify no dialog is open (UI state preserved)
        expect(find.byType(AlertDialog), findsNothing);
        
        // Test that we can still interact with the preserved state
        if (assetCards.evaluate().isNotEmpty) {
          await tester.tap(assetCards.first);
          await tester.pumpAndSettle();
          
          // Verify dialog opens (functionality preserved)
          expect(find.byType(AlertDialog), findsOneWidget);
          
          // Close dialog for next iteration
          await tester.tap(find.text('Close'));
          await tester.pumpAndSettle();
        }
        
        // Reset for next iteration
        await tester.binding.reassembleApplication();
      }
    });

    testWidgets('Property 5: Menu Navigation Consistency - For any menu option in the side drawer, tapping it should navigate to the corresponding screen',
        (WidgetTester tester) async {
      // **Feature: enhanced-navigation, Property 5: Menu Navigation Consistency**
      // **Validates: Requirements 3.3**
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Build the NavigationShell widget with drawer
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Test')),
              drawer: const DrawerMenu(),
              body: const Center(child: Text('Main Content')),
            ),
          ),
        );

        // Open the drawer
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        // Verify drawer is open
        expect(find.byType(DrawerMenu), findsOneWidget);
        expect(find.byType(UserAccountsDrawerHeader), findsOneWidget);

        // Test each menu option
        final menuOptions = [
          {'title': 'User Profile', 'icon': Icons.person, 'screen': UserProfileScreen},
          {'title': 'Settings', 'icon': Icons.settings, 'screen': SettingsScreen},
          {'title': 'Trading History', 'icon': Icons.history, 'screen': TradingHistoryScreen},
          {'title': 'Legal Information', 'icon': Icons.info, 'screen': LegalInfoScreen},
        ];

        for (final option in menuOptions) {
          // Re-open drawer if needed
          if (find.byType(DrawerMenu).evaluate().isEmpty) {
            await tester.tap(find.byIcon(Icons.menu));
            await tester.pumpAndSettle();
          }

          // Tap the menu option
          await tester.tap(find.text(option['title'] as String));
          await tester.pumpAndSettle();

          // Verify navigation occurred - the corresponding screen should be present
          expect(find.byType(option['screen'] as Type), findsOneWidget,
              reason: 'Tapping ${option['title']} should navigate to ${option['screen']}');

          // Verify the screen has the correct title in the app bar
          expect(find.text(option['title'] as String), findsOneWidget,
              reason: 'Screen should display the correct title: ${option['title']}');

          // Go back to the main screen for next iteration
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        }

        // Reset for next iteration
        await tester.binding.reassembleApplication();
      }
    });
  });
}

IconData _getTabIcon(int tabIndex) {
  switch (tabIndex) {
    case 0:
      return Icons.home;
    case 1:
      return Icons.newspaper;
    case 2:
      return Icons.notifications;
    default:
      throw ArgumentError('Invalid tab index: $tabIndex');
  }
}

Type _getExpectedScreenType(int tabIndex) {
  switch (tabIndex) {
    case 0:
      return AssetList;
    case 1:
      return NewsScreen;
    case 2:
      return AlertsScreen;
    default:
      throw ArgumentError('Invalid tab index: $tabIndex');
  }
}