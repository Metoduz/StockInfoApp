import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation/navigation_shell.dart';
import 'screens/user_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/trading_history_screen.dart';
import 'screens/legal_info_screen.dart';
import 'providers/app_state_provider.dart';

/// The main application widget.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize app data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppStateProvider>().initializeAppData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Stock Info App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: appState.appSettings?.themeMode ?? ThemeMode.system,
          home: const NavigationShell(),
          // Define named routes for deep linking support
          routes: {
            '/': (context) => const NavigationShell(),
            '/main': (context) => const NavigationShell(initialIndex: 0),
            '/news': (context) => const NavigationShell(initialIndex: 1),
            '/alerts': (context) => const NavigationShell(initialIndex: 2),
            '/profile': (context) => const UserProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/trading-history': (context) => const TradingHistoryScreen(),
            '/legal': (context) => const LegalInfoScreen(),
          },
          // Handle unknown routes
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const NavigationShell(),
            );
          },
        );
      },
    );
  }
}
