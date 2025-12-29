import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/screens/template_management_screen.dart';
import 'package:stockinfoapp/src/models/strategy_template.dart';

void main() {
  group('TemplateManagementScreen', () {
    testWidgets('should display template management screen', (WidgetTester tester) async {
      // Initialize template manager
      await TemplateManager.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: const TemplateManagementScreen(),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify the screen displays correctly
      expect(find.text('Strategy Templates'), findsOneWidget);
      expect(find.text('All Templates'), findsOneWidget);
      expect(find.text('Most Used'), findsOneWidget);
      expect(find.text('Recent'), findsOneWidget);
      
      // Verify search functionality is present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search templates...'), findsOneWidget);
      
      // Verify floating action button is present
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should display empty state when no templates exist', (WidgetTester tester) async {
      // Clear templates to ensure empty state
      await TemplateManager.clearTemplates();
      
      await tester.pumpWidget(
        MaterialApp(
          home: const TemplateManagementScreen(),
        ),
      );

      // Wait for the screen to load
      await tester.pumpAndSettle();

      // Verify empty state is displayed
      expect(find.text('No templates available'), findsOneWidget);
      expect(find.text('Create your first template to get started'), findsOneWidget);
      expect(find.text('Create Template'), findsOneWidget);
    });

    testWidgets('should open template creation dialog when FAB is tapped', (WidgetTester tester) async {
      await TemplateManager.initialize();
      
      await tester.pumpWidget(
        MaterialApp(
          home: const TemplateManagementScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify the creation dialog opens
      expect(find.text('Create Template'), findsOneWidget);
      expect(find.text('Template Name *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });
  });
}