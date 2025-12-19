import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_settings.dart';
import '../providers/app_state_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          final settings = appState.appSettings ?? const AppSettings();
          
          if (appState.isLoadingSettings) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildCurrencySection(context, appState, settings),
              const SizedBox(height: 24),
              _buildThemeSection(context, appState, settings),
              const SizedBox(height: 24),
              _buildNotificationSection(context, appState, settings),
              const SizedBox(height: 24),
              _buildAdvancedSection(context, appState, settings),
              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrencySection(BuildContext context, AppStateProvider appState, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select your preferred currency for displaying stock prices',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: settings.currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
              items: AppSettings.supportedCurrencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Row(
                    children: [
                      Text(_getCurrencySymbol(currency)),
                      const SizedBox(width: 8),
                      Text(currency),
                      const SizedBox(width: 8),
                      Text(
                        '(${_getCurrencyName(currency)})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newCurrency) {
                if (newCurrency != null && newCurrency != settings.currency) {
                  _updateCurrency(appState, settings, newCurrency);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, AppStateProvider appState, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred app theme',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ThemeMode>(
              value: settings.themeMode,
              decoration: const InputDecoration(
                labelText: 'Theme',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      Icon(Icons.brightness_auto),
                      SizedBox(width: 8),
                      Text('System'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      Icon(Icons.brightness_high),
                      SizedBox(width: 8),
                      Text('Light'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      Icon(Icons.brightness_low),
                      SizedBox(width: 8),
                      Text('Dark'),
                    ],
                  ),
                ),
              ],
              onChanged: (ThemeMode? newTheme) {
                if (newTheme != null && newTheme != settings.themeMode) {
                  _updateTheme(appState, settings, newTheme);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, AppStateProvider appState, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your notification preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive app notifications'),
              value: settings.enableNotifications,
              onChanged: (bool value) {
                _updateNotificationSetting(appState, settings, 'enableNotifications', value);
              },
            ),
            SwitchListTile(
              title: const Text('News Notifications'),
              subtitle: const Text('Get notified about relevant financial news'),
              value: settings.enableNewsNotifications,
              onChanged: settings.enableNotifications
                  ? (bool value) {
                      _updateNotificationSetting(appState, settings, 'enableNewsNotifications', value);
                    }
                  : null,
            ),
            SwitchListTile(
              title: const Text('Price Alerts'),
              subtitle: const Text('Receive notifications for stock price alerts'),
              value: settings.enablePriceAlerts,
              onChanged: settings.enableNotifications
                  ? (bool value) {
                      _updateNotificationSetting(appState, settings, 'enablePriceAlerts', value);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(BuildContext context, AppStateProvider appState, AppSettings settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Advanced settings and preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: settings.language,
              decoration: const InputDecoration(
                labelText: 'Language',
                border: OutlineInputBorder(),
              ),
              items: AppSettings.supportedLanguages.map((language) {
                return DropdownMenuItem(
                  value: language,
                  child: Text(_getLanguageName(language)),
                );
              }).toList(),
              onChanged: (String? newLanguage) {
                if (newLanguage != null && newLanguage != settings.language) {
                  _updateLanguage(appState, settings, newLanguage);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Help improve the app by sharing usage data'),
              value: settings.enableAnalytics,
              onChanged: (bool value) {
                _updateAdvancedSetting(appState, settings, 'enableAnalytics', value);
              },
            ),
            SwitchListTile(
              title: const Text('Backend Sync'),
              subtitle: const Text('Sync data with backend services'),
              value: settings.enableBackendSync,
              onChanged: (bool value) {
                _updateAdvancedSetting(appState, settings, 'enableBackendSync', value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: settings.alertRefreshInterval.toString(),
              decoration: const InputDecoration(
                labelText: 'Alert Refresh Interval (minutes)',
                border: OutlineInputBorder(),
                helperText: 'How often to check for new alerts (1-1440 minutes)',
              ),
              keyboardType: TextInputType.number,
              onFieldSubmitted: (String value) {
                final interval = int.tryParse(value);
                if (interval != null && interval >= 1 && interval <= 1440) {
                  _updateAlertInterval(appState, settings, interval);
                } else {
                  _showValidationError('Alert refresh interval must be between 1 and 1440 minutes');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      case 'CAD':
        return 'C\$';
      default:
        return currency;
    }
  }

  String _getCurrencyName(String currency) {
    switch (currency) {
      case 'EUR':
        return 'Euro';
      case 'USD':
        return 'US Dollar';
      case 'GBP':
        return 'British Pound';
      case 'CAD':
        return 'Canadian Dollar';
      default:
        return currency;
    }
  }

  String _getLanguageName(String language) {
    switch (language) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      default:
        return language;
    }
  }

  Future<void> _updateCurrency(AppStateProvider appState, AppSettings settings, String newCurrency) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSettings = settings.copyWith(currency: newCurrency);
      await appState.updateAppSettings(updatedSettings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Currency updated to $newCurrency'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update currency: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateTheme(AppStateProvider appState, AppSettings settings, ThemeMode newTheme) async {
    try {
      final updatedSettings = settings.copyWith(themeMode: newTheme);
      await appState.updateAppSettings(updatedSettings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme updated to ${newTheme.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update theme: $e');
      }
    }
  }

  Future<void> _updateNotificationSetting(AppStateProvider appState, AppSettings settings, String setting, bool value) async {
    try {
      AppSettings updatedSettings;
      switch (setting) {
        case 'enableNotifications':
          updatedSettings = settings.copyWith(enableNotifications: value);
          break;
        case 'enableNewsNotifications':
          updatedSettings = settings.copyWith(enableNewsNotifications: value);
          break;
        case 'enablePriceAlerts':
          updatedSettings = settings.copyWith(enablePriceAlerts: value);
          break;
        default:
          return;
      }
      
      await appState.updateAppSettings(updatedSettings);
    } catch (e) {
      if (mounted) {
        _showError('Failed to update notification setting: $e');
      }
    }
  }

  Future<void> _updateAdvancedSetting(AppStateProvider appState, AppSettings settings, String setting, bool value) async {
    try {
      AppSettings updatedSettings;
      switch (setting) {
        case 'enableAnalytics':
          updatedSettings = settings.copyWith(enableAnalytics: value);
          break;
        case 'enableBackendSync':
          updatedSettings = settings.copyWith(enableBackendSync: value);
          break;
        default:
          return;
      }
      
      await appState.updateAppSettings(updatedSettings);
    } catch (e) {
      if (mounted) {
        _showError('Failed to update advanced setting: $e');
      }
    }
  }

  Future<void> _updateLanguage(AppStateProvider appState, AppSettings settings, String newLanguage) async {
    try {
      final updatedSettings = settings.copyWith(language: newLanguage);
      await appState.updateAppSettings(updatedSettings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language updated to ${_getLanguageName(newLanguage)}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update language: $e');
      }
    }
  }

  Future<void> _updateAlertInterval(AppStateProvider appState, AppSettings settings, int interval) async {
    try {
      final updatedSettings = settings.copyWith(alertRefreshInterval: interval);
      await appState.updateAppSettings(updatedSettings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alert refresh interval updated to $interval minutes'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update alert interval: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}