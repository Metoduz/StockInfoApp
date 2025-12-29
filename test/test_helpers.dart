import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockinfoapp/src/providers/app_state_provider.dart';

/// Helper function to create a test app with proper provider setup
Widget createTestApp({required Widget child}) {
  return ChangeNotifierProvider(
    create: (_) => AppStateProvider(),
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Helper function to create a test app with navigation
Widget createTestAppWithNavigation({required Widget child}) {
  return ChangeNotifierProvider(
    create: (_) => AppStateProvider(),
    child: MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

/// Helper function to pump a widget with provider setup
Future<void> pumpWidgetWithProvider(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(createTestApp(child: widget));
}

/// Helper function to pump a widget with navigation and provider setup
Future<void> pumpWidgetWithNavigation(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(createTestAppWithNavigation(child: widget));
}

/// Helper function to set up SharedPreferences for testing
Future<void> setupSharedPreferences() async {
  SharedPreferences.setMockInitialValues({});
}