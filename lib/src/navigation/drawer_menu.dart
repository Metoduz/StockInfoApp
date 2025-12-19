import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final userProfile = appState.userProfile;
        
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // User profile header section
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                accountName: Text(
                  userProfile?.name ?? 'User Name',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(userProfile?.email ?? 'user@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: userProfile?.profileImagePath != null
                      ? AssetImage(userProfile!.profileImagePath!)
                      : null,
                  child: userProfile?.profileImagePath == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 40,
                        )
                      : null,
                ),
              ),
              
              // Navigation menu items
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('User Profile'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Trading History'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushNamed(context, '/trading-history');
                },
              ),
              
              const Divider(),
              
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Legal Information'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.pushNamed(context, '/legal');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}