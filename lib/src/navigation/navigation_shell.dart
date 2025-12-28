import 'package:flutter/material.dart';
import '../screens/watchlist_screen.dart';
import '../screens/news_screen.dart';
import '../screens/alerts_screen.dart';
import 'drawer_menu.dart';

class NavigationShell extends StatefulWidget {
  final int initialIndex;
  
  const NavigationShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  late int _currentIndex;

  // List of screens for each tab
  final List<Widget> _screens = const [
    WatchlistScreen(),
    NewsScreen(),
    AlertsScreen(),
  ];

  // Tab names for deep linking
  final List<String> _tabNames = const [
    'main',
    'news',
    'alerts',
  ];

  @override
  void initState() {
    super.initState(); 
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Method to switch to a specific tab programmatically
  void switchToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Method to get current tab name for deep linking
  String get currentTabName => _tabNames[_currentIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Info'),
        leading: Builder(builder: (context){
          return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              }, 
              icon: const Icon(Icons.menu)
            );
        }),
      ),
      drawer: const DrawerMenu(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}