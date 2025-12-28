import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asset_item.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';
import '../models/transaction.dart';
import '../models/asset_alert.dart';

class StorageService {
  static const String _watchlistKey = 'watchlist';
  static const String _userProfileKey = 'user_profile';
  static const String _appSettingsKey = 'app_settings';
  static const String _transactionsKey = 'transactions';
  static const String _alertsKey = 'alerts';
  static const String _legalDocumentVersionsKey = 'legal_document_versions';
  static const String _legalDocumentNotificationsKey = 'legal_document_notifications';
  static const String _lastLegalNotificationTimeKey = 'last_legal_notification_time';

  Future<void> saveWatchlist(List<AssetItem> assets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assetJson = assets.map((asset) => _assetToJson(asset)).toList();
      await prefs.setString(_watchlistKey, jsonEncode(assetJson));
    } catch (e) {
      throw Exception('Failed to save watchlist: $e');
    }
  }

  Future<List<AssetItem>> loadWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final watchlistString = prefs.getString(_watchlistKey);
      
      if (watchlistString == null || watchlistString.isEmpty) {
        return [];
      }

      final List<dynamic> assetJson = jsonDecode(watchlistString);
      return assetJson.map((json) => _assetFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load watchlist: $e');
    }
  }

  // User Profile methods
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = _userProfileToJson(profile);
      await prefs.setString(_userProfileKey, jsonEncode(profileJson));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  Future<UserProfile?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileString = prefs.getString(_userProfileKey);
      
      if (profileString == null || profileString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> profileJson = jsonDecode(profileString);
      return _userProfileFromJson(profileJson);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }

  // App Settings methods
  Future<void> saveAppSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = _appSettingsToJson(settings);
      await prefs.setString(_appSettingsKey, jsonEncode(settingsJson));
    } catch (e) {
      throw Exception('Failed to save app settings: $e');
    }
  }

  Future<AppSettings?> loadAppSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsString = prefs.getString(_appSettingsKey);
      
      if (settingsString == null || settingsString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> settingsJson = jsonDecode(settingsString);
      return _appSettingsFromJson(settingsJson);
    } catch (e) {
      throw Exception('Failed to load app settings: $e');
    }
  }

  // Transactions methods
  Future<void> saveTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = transactions.map((transaction) => _transactionToJson(transaction)).toList();
      await prefs.setString(_transactionsKey, jsonEncode(transactionsJson));
    } catch (e) {
      throw Exception('Failed to save transactions: $e');
    }
  }

  Future<List<Transaction>> loadTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactionsString = prefs.getString(_transactionsKey);
      
      if (transactionsString == null || transactionsString.isEmpty) {
        return [];
      }

      final List<dynamic> transactionsJson = jsonDecode(transactionsString);
      return transactionsJson.map((json) => _transactionFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  // Asset Alerts methods
  Future<void> saveAlerts(List<AssetAlert> alerts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsJson = alerts.map((alert) => _alertToJson(alert)).toList();
      await prefs.setString(_alertsKey, jsonEncode(alertsJson));
    } catch (e) {
      throw Exception('Failed to save alerts: $e');
    }
  }

  Future<List<AssetAlert>> loadAlerts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alertsString = prefs.getString(_alertsKey);
      
      if (alertsString == null || alertsString.isEmpty) {
        return [];
      }

      final List<dynamic> alertsJson = jsonDecode(alertsString);
      return alertsJson.map((json) => _alertFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load alerts: $e');
    }
  }

  // Generic method to clear all data (for testing or reset purposes)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_watchlistKey);
      await prefs.remove(_userProfileKey);
      await prefs.remove(_appSettingsKey);
      await prefs.remove(_transactionsKey);
      await prefs.remove(_alertsKey);
      await prefs.remove(_legalDocumentVersionsKey);
      await prefs.remove(_legalDocumentNotificationsKey);
      await prefs.remove(_lastLegalNotificationTimeKey);
    } catch (e) {
      throw Exception('Failed to clear data: $e');
    }
  }

  // Legal Document methods
  Future<void> saveLegalDocumentVersion(String documentName, String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versionsString = prefs.getString(_legalDocumentVersionsKey) ?? '{}';
      final Map<String, dynamic> versions = jsonDecode(versionsString);
      versions[documentName] = version;
      await prefs.setString(_legalDocumentVersionsKey, jsonEncode(versions));
    } catch (e) {
      throw Exception('Failed to save legal document version: $e');
    }
  }

  Future<String?> getLegalDocumentVersion(String documentName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versionsString = prefs.getString(_legalDocumentVersionsKey);
      
      if (versionsString == null || versionsString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> versions = jsonDecode(versionsString);
      return versions[documentName];
    } catch (e) {
      throw Exception('Failed to get legal document version: $e');
    }
  }

  Future<bool> hasLegalDocumentUpdate(String documentName, String currentVersion) async {
    try {
      final storedVersion = await getLegalDocumentVersion(documentName);
      if (storedVersion == null) {
        return false;
      }
      // Simple string comparison - if stored version is different from current, there's an update
      // In a real implementation, you might want semantic version comparison
      return storedVersion != currentVersion && _isVersionNewer(storedVersion, currentVersion);
    } catch (e) {
      throw Exception('Failed to check legal document update: $e');
    }
  }

  bool _isVersionNewer(String storedVersion, String currentVersion) {
    // Simple version comparison - in a real app you might use a proper semver library
    // For now, just compare strings lexicographically
    // This assumes versions follow a pattern like "1.0.0", "1.1.0", etc.
    
    try {
      final storedParts = storedVersion.replaceAll(RegExp(r'[^0-9.]'), '').split('.');
      final currentParts = currentVersion.replaceAll(RegExp(r'[^0-9.]'), '').split('.');
      
      final maxLength = storedParts.length > currentParts.length ? storedParts.length : currentParts.length;
      
      for (int i = 0; i < maxLength; i++) {
        final storedPart = i < storedParts.length ? int.tryParse(storedParts[i]) ?? 0 : 0;
        final currentPart = i < currentParts.length ? int.tryParse(currentParts[i]) ?? 0 : 0;
        
        if (storedPart > currentPart) {
          return true;
        } else if (storedPart < currentPart) {
          return false;
        }
      }
      
      return false; // Versions are equal
    } catch (e) {
      // Fallback to string comparison if parsing fails
      return storedVersion.compareTo(currentVersion) > 0;
    }
  }

  Future<void> markLegalDocumentUpdateNotified(String documentName, String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString(_legalDocumentNotificationsKey) ?? '{}';
      final Map<String, dynamic> notifications = jsonDecode(notificationsString);
      notifications[documentName] = {
        'version': version,
        'notifiedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_legalDocumentNotificationsKey, jsonEncode(notifications));
    } catch (e) {
      throw Exception('Failed to mark legal document update as notified: $e');
    }
  }

  Future<bool> isLegalDocumentUpdateNotified(String documentName, String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsString = prefs.getString(_legalDocumentNotificationsKey);
      
      if (notificationsString == null || notificationsString.isEmpty) {
        return false;
      }

      final Map<String, dynamic> notifications = jsonDecode(notificationsString);
      final documentNotification = notifications[documentName];
      
      if (documentNotification == null) {
        return false;
      }

      return documentNotification['version'] == version;
    } catch (e) {
      throw Exception('Failed to check legal document notification status: $e');
    }
  }

  Future<void> clearLegalDocumentNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_legalDocumentNotificationsKey);
    } catch (e) {
      throw Exception('Failed to clear legal document notifications: $e');
    }
  }

  Future<List<String>> getPendingLegalDocumentNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final versionsString = prefs.getString(_legalDocumentVersionsKey);
      final notificationsString = prefs.getString(_legalDocumentNotificationsKey);
      
      if (versionsString == null || versionsString.isEmpty) {
        return [];
      }

      final Map<String, dynamic> versions = jsonDecode(versionsString);
      final Map<String, dynamic> notifications = notificationsString != null && notificationsString.isNotEmpty
          ? jsonDecode(notificationsString)
          : <String, dynamic>{};

      final List<String> pendingNotifications = [];

      for (final entry in versions.entries) {
        final documentName = entry.key;
        final currentVersion = entry.value;
        final notification = notifications[documentName];

        if (notification == null || notification['version'] != currentVersion) {
          pendingNotifications.add(documentName);
        }
      }

      return pendingNotifications;
    } catch (e) {
      throw Exception('Failed to get pending legal document notifications: $e');
    }
  }

  Future<void> setLastLegalNotificationTime(DateTime time) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLegalNotificationTimeKey, time.toIso8601String());
    } catch (e) {
      throw Exception('Failed to set last legal notification time: $e');
    }
  }

  Future<DateTime?> getLastLegalNotificationTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_lastLegalNotificationTimeKey);
      
      if (timeString == null || timeString.isEmpty) {
        return null;
      }

      return DateTime.parse(timeString);
    } catch (e) {
      throw Exception('Failed to get last legal notification time: $e');
    }
  }

  // Data Export functionality
  Future<Map<String, dynamic>> exportUserData() async {
    try {
      final exportData = <String, dynamic>{};
      
      // Export metadata
      exportData['exportedAt'] = DateTime.now().toIso8601String();
      exportData['appVersion'] = '1.0.0';
      exportData['dataVersion'] = '1.0';
      
      // Export watchlist
      try {
        final watchlist = await loadWatchlist();
        exportData['watchlist'] = watchlist.map((asset) => _assetToJson(asset)).toList();
      } catch (e) {
        exportData['watchlist'] = [];
        exportData['watchlistError'] = e.toString();
      }
      
      // Export user profile
      try {
        final profile = await loadUserProfile();
        if (profile != null) {
          final profileData = _userProfileToJson(profile);
          // Remove sensitive data for privacy
          profileData.remove('backendUserId');
          exportData['userProfile'] = profileData;
        } else {
          exportData['userProfile'] = null;
        }
      } catch (e) {
        exportData['userProfile'] = null;
        exportData['userProfileError'] = e.toString();
      }
      
      // Export app settings
      try {
        final settings = await loadAppSettings();
        if (settings != null) {
          final settingsData = _appSettingsToJson(settings);
          // Remove sensitive data for privacy
          settingsData.remove('backendApiUrl');
          exportData['appSettings'] = settingsData;
        } else {
          exportData['appSettings'] = null;
        }
      } catch (e) {
        exportData['appSettings'] = null;
        exportData['appSettingsError'] = e.toString();
      }
      
      // Export transactions
      try {
        final transactions = await loadTransactions();
        exportData['transactions'] = transactions.map((transaction) => _transactionToJson(transaction)).toList();
      } catch (e) {
        exportData['transactions'] = [];
        exportData['transactionsError'] = e.toString();
      }
      
      // Export alerts (with privacy considerations)
      try {
        final alerts = await loadAlerts();
        final alertsData = alerts.map((alert) {
          final alertJson = _alertToJson(alert);
          // Remove sensitive backend data for privacy
          alertJson.remove('backendAlertId');
          alertJson.remove('metadata');
          return alertJson;
        }).toList();
        exportData['alerts'] = alertsData;
      } catch (e) {
        exportData['alerts'] = [];
        exportData['alertsError'] = e.toString();
      }
      
      // Export legal document versions (for user reference)
      try {
        final prefs = await SharedPreferences.getInstance();
        final versionsString = prefs.getString(_legalDocumentVersionsKey);
        if (versionsString != null && versionsString.isNotEmpty) {
          exportData['legalDocumentVersions'] = jsonDecode(versionsString);
        } else {
          exportData['legalDocumentVersions'] = {};
        }
      } catch (e) {
        exportData['legalDocumentVersions'] = {};
        exportData['legalDocumentVersionsError'] = e.toString();
      }
      
      return exportData;
    } catch (e) {
      throw Exception('Failed to export user data: $e');
    }
  }

  Future<String> exportUserDataAsJson() async {
    try {
      final exportData = await exportUserData();
      return jsonEncode(exportData);
    } catch (e) {
      throw Exception('Failed to export user data as JSON: $e');
    }
  }

  Future<bool> importUserData(Map<String, dynamic> importData) async {
    try {
      // Validate import data structure
      if (!_validateImportData(importData)) {
        throw Exception('Invalid import data structure');
      }
      
      bool hasErrors = false;
      final errors = <String>[];
      
      // Import watchlist
      if (importData.containsKey('watchlist') && importData['watchlist'] is List) {
        try {
          final watchlistData = importData['watchlist'] as List<dynamic>;
          final watchlist = watchlistData.map((json) => _assetFromJson(json)).toList();
          await saveWatchlist(watchlist);
        } catch (e) {
          hasErrors = true;
          errors.add('Failed to import watchlist: $e');
        }
      }
      
      // Import user profile
      if (importData.containsKey('userProfile') && importData['userProfile'] != null) {
        try {
          final profileData = importData['userProfile'] as Map<String, dynamic>;
          final profile = _userProfileFromJson(profileData);
          await saveUserProfile(profile);
        } catch (e) {
          hasErrors = true;
          errors.add('Failed to import user profile: $e');
        }
      }
      
      // Import app settings
      if (importData.containsKey('appSettings') && importData['appSettings'] != null) {
        try {
          final settingsData = importData['appSettings'] as Map<String, dynamic>;
          final settings = _appSettingsFromJson(settingsData);
          await saveAppSettings(settings);
        } catch (e) {
          hasErrors = true;
          errors.add('Failed to import app settings: $e');
        }
      }
      
      // Import transactions
      if (importData.containsKey('transactions') && importData['transactions'] is List) {
        try {
          final transactionsData = importData['transactions'] as List<dynamic>;
          final transactions = transactionsData.map((json) => _transactionFromJson(json)).toList();
          await saveTransactions(transactions);
        } catch (e) {
          hasErrors = true;
          errors.add('Failed to import transactions: $e');
        }
      }
      
      // Import alerts
      if (importData.containsKey('alerts') && importData['alerts'] is List) {
        try {
          final alertsData = importData['alerts'] as List<dynamic>;
          final alerts = alertsData.map((json) => _alertFromJson(json)).toList();
          await saveAlerts(alerts);
        } catch (e) {
          hasErrors = true;
          errors.add('Failed to import alerts: $e');
        }
      }
      
      // Import legal document versions
      if (importData.containsKey('legalDocumentVersions') && importData['legalDocumentVersions'] is Map) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final versionsData = importData['legalDocumentVersions'] as Map<String, dynamic>;
          await prefs.setString(_legalDocumentVersionsKey, jsonEncode(versionsData));
        } catch (e) {
          hasErrors = true;
          errors.add('Failed to import legal document versions: $e');
        }
      }
      
      if (hasErrors) {
        throw Exception('Import completed with errors: ${errors.join(', ')}');
      }
      
      return true;
    } catch (e) {
      throw Exception('Failed to import user data: $e');
    }
  }

  Future<bool> importUserDataFromJson(String jsonData) async {
    try {
      final Map<String, dynamic> importData = jsonDecode(jsonData);
      return await importUserData(importData);
    } catch (e) {
      throw Exception('Failed to import user data from JSON: $e');
    }
  }

  bool _validateImportData(Map<String, dynamic> data) {
    // Basic validation of import data structure
    if (!data.containsKey('exportedAt') || !data.containsKey('dataVersion')) {
      return false;
    }
    
    // Check that at least one data section exists
    final dataSections = ['watchlist', 'userProfile', 'appSettings', 'transactions', 'alerts'];
    return dataSections.any((section) => data.containsKey(section));
  }

  // Check if storage is available
  Future<bool> isStorageAvailable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Try to write and read a test value
      await prefs.setString('_test_key', 'test_value');
      final testValue = prefs.getString('_test_key');
      await prefs.remove('_test_key');
      return testValue == 'test_value';
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic> _assetToJson(AssetItem asset) {
    return {
      'id': asset.id,
      'isin': asset.isin,
      'wkn': asset.wkn,
      'ticker': asset.ticker,
      'name': asset.name,
      'symbol': asset.symbol,
      'currentValue': asset.currentValue,
      'previousClose': asset.previousClose,
      'currency': asset.currency,
      'lastUpdated': asset.lastUpdated.toIso8601String(),
      'isInWatchlist': asset.isInWatchlist,
      'primaryIdentifierType': asset.primaryIdentifierType.name,
      'dayChange': asset.dayChange,
      'dayChangePercent': asset.dayChangePercent,
      'hints': asset.hints.map((hint) => {
        'type': hint.type,
        'description': hint.description,
        'value': hint.value,
        'timestamp': hint.timestamp?.toIso8601String(),
      }).toList(),
    };
  }

  AssetItem _assetFromJson(Map<String, dynamic> json) {
    return AssetItem(
      id: json['id'],
      isin: json['isin'],
      wkn: json['wkn'],
      ticker: json['ticker'],
      name: json['name'],
      symbol: json['symbol'],
      currentValue: json['currentValue'],
      previousClose: json['previousClose'],
      currency: json['currency'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      isInWatchlist: json['isInWatchlist'] ?? true,
      primaryIdentifierType: AssetIdentifierType.values.firstWhere(
        (e) => e.name == json['primaryIdentifierType'],
        orElse: () => AssetIdentifierType.isin,
      ),
      dayChange: json['dayChange'],
      dayChangePercent: json['dayChangePercent'],
      hints: (json['hints'] as List<dynamic>?)?.map((hintJson) {
        return AssetHint(
          type: hintJson['type'],
          description: hintJson['description'],
          value: hintJson['value'],
          timestamp: hintJson['timestamp'] != null 
              ? DateTime.parse(hintJson['timestamp'])
              : null,
        );
      }).toList() ?? [],
    );
  }

  // UserProfile serialization methods
  Map<String, dynamic> _userProfileToJson(UserProfile profile) {
    // This will be implemented when UserProfile model is created
    // For now, return a placeholder structure
    return {
      'name': profile.name,
      'email': profile.email,
      'profileImagePath': profile.profileImagePath,
      'preferredCurrency': profile.preferredCurrency,
      'createdAt': profile.createdAt.toIso8601String(),
      'lastUpdated': profile.lastUpdated.toIso8601String(),
      'backendUserId': profile.backendUserId,
    };
  }

  UserProfile _userProfileFromJson(Map<String, dynamic> json) {
    // This will be implemented when UserProfile model is created
    // For now, return a placeholder implementation
    return UserProfile(
      name: json['name'],
      email: json['email'],
      profileImagePath: json['profileImagePath'],
      preferredCurrency: json['preferredCurrency'] ?? 'EUR',
      createdAt: DateTime.parse(json['createdAt']),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      backendUserId: json['backendUserId'],
    );
  }

  // AppSettings serialization methods
  Map<String, dynamic> _appSettingsToJson(AppSettings settings) {
    // This will be implemented when AppSettings model is created
    // For now, return a placeholder structure
    return {
      'currency': settings.currency,
      'themeMode': settings.themeMode.name,
      'enableNotifications': settings.enableNotifications,
      'enableNewsNotifications': settings.enableNewsNotifications,
      'enablePriceAlerts': settings.enablePriceAlerts,
      'language': settings.language,
      'enableAnalytics': settings.enableAnalytics,
      'enableBackendSync': settings.enableBackendSync,
      'backendApiUrl': settings.backendApiUrl,
      'alertRefreshInterval': settings.alertRefreshInterval,
    };
  }

  AppSettings _appSettingsFromJson(Map<String, dynamic> json) {
    // This will be implemented when AppSettings model is created
    // For now, return a placeholder implementation
    return AppSettings(
      currency: json['currency'] ?? 'EUR',
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      enableNotifications: json['enableNotifications'] ?? true,
      enableNewsNotifications: json['enableNewsNotifications'] ?? true,
      enablePriceAlerts: json['enablePriceAlerts'] ?? true,
      language: json['language'] ?? 'en',
      enableAnalytics: json['enableAnalytics'] ?? false,
      enableBackendSync: json['enableBackendSync'] ?? false,
      backendApiUrl: json['backendApiUrl'],
      alertRefreshInterval: json['alertRefreshInterval'] ?? 15,
    );
  }

  // Transaction serialization methods
  Map<String, dynamic> _transactionToJson(Transaction transaction) {
    return transaction.toJson();
  }

  Transaction _transactionFromJson(Map<String, dynamic> json) {
    return Transaction.fromJson(json);
  }

  // AssertAlert serialization methods
  Map<String, dynamic> _alertToJson(AssetAlert alert) {
    // This will be implemented when AssertAlert model is created
    // For now, return a placeholder structure
    return {
      'id': alert.id,
      'assertId': alert.assetId,
      'assertName': alert.assetName,
      'type': alert.type.name,
      'threshold': alert.threshold,
      'isEnabled': alert.isEnabled,
      'createdAt': alert.createdAt.toIso8601String(),
      'triggeredAt': alert.triggeredAt?.toIso8601String(),
      'backendAlertId': alert.backendAlertId,
      'source': alert.source.name,
      'metadata': alert.metadata,
      'notifications': _notificationSettingsToJson(alert.notifications),
    };
  }

  AssetAlert _alertFromJson(Map<String, dynamic> json) {
    // This will be implemented when AsserAlert model is created
    // For now, return a placeholder implementation
    return AssetAlert(
      id: json['id'],
      assetId: json['assetId'],
      assetName: json['assetName'],
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.priceAbove,
      ),
      threshold: json['threshold'],
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      triggeredAt: json['triggeredAt'] != null 
          ? DateTime.parse(json['triggeredAt'])
          : null,
      backendAlertId: json['backendAlertId'],
      source: AlertSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => AlertSource.local,
      ),
      metadata: json['metadata'],
      notifications: _notificationSettingsFromJson(json['notifications']),
    );
  }

  // NotificationSettings helper methods
  Map<String, dynamic> _notificationSettingsToJson(NotificationSettings settings) {
    return {
      'enablePushNotifications': settings.enablePushNotifications,
      'enableEmailNotifications': settings.enableEmailNotifications,
      'enableInAppNotifications': settings.enableInAppNotifications,
      'notificationTimes': settings.notificationTimes,
      'enableWeekendNotifications': settings.enableWeekendNotifications,
    };
  }

  NotificationSettings _notificationSettingsFromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      enableEmailNotifications: json['enableEmailNotifications'] ?? false,
      enableInAppNotifications: json['enableInAppNotifications'] ?? true,
      notificationTimes: List<String>.from(json['notificationTimes'] ?? []),
      enableWeekendNotifications: json['enableWeekendNotifications'] ?? false,
    );
  }
}