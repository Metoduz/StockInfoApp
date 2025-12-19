import 'package:flutter/material.dart';

class AppSettings {
  final String currency;
  final ThemeMode themeMode;
  final bool enableNotifications;
  final bool enableNewsNotifications;
  final bool enablePriceAlerts;
  final String language;
  final bool enableAnalytics;
  final bool enableBackendSync;
  final String? backendApiUrl;
  final int alertRefreshInterval;

  const AppSettings({
    this.currency = 'EUR',
    this.themeMode = ThemeMode.system,
    this.enableNotifications = true,
    this.enableNewsNotifications = true,
    this.enablePriceAlerts = true,
    this.language = 'en',
    this.enableAnalytics = false,
    this.enableBackendSync = false,
    this.backendApiUrl,
    this.alertRefreshInterval = 15,
  });

  /// List of supported currencies
  static const List<String> supportedCurrencies = ['EUR', 'USD', 'GBP', 'CAD'];

  /// List of supported languages
  static const List<String> supportedLanguages = ['en', 'de', 'fr', 'es'];

  /// Validates if the currency is supported
  bool isValidCurrency() {
    return supportedCurrencies.contains(currency);
  }

  /// Validates if the language is supported
  bool isValidLanguage() {
    return supportedLanguages.contains(language);
  }

  /// Validates if the alert refresh interval is within acceptable range
  bool isValidAlertRefreshInterval() {
    return alertRefreshInterval >= 1 && alertRefreshInterval <= 1440; // 1 minute to 24 hours
  }

  /// Validates if the backend API URL is properly formatted (if provided)
  bool isValidBackendApiUrl() {
    if (backendApiUrl == null || backendApiUrl!.isEmpty) {
      return true; // null/empty is valid
    }
    try {
      final uri = Uri.parse(backendApiUrl!);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Validates all settings values
  bool isValid() {
    return isValidCurrency() &&
           isValidLanguage() &&
           isValidAlertRefreshInterval() &&
           isValidBackendApiUrl();
  }

  /// Returns validation errors as a list of strings
  List<String> getValidationErrors() {
    final errors = <String>[];
    
    if (!isValidCurrency()) {
      errors.add('Currency "$currency" is not supported. Supported currencies: ${supportedCurrencies.join(", ")}');
    }
    
    if (!isValidLanguage()) {
      errors.add('Language "$language" is not supported. Supported languages: ${supportedLanguages.join(", ")}');
    }
    
    if (!isValidAlertRefreshInterval()) {
      errors.add('Alert refresh interval must be between 1 and 1440 minutes');
    }
    
    if (!isValidBackendApiUrl()) {
      errors.add('Backend API URL is not properly formatted');
    }
    
    return errors;
  }

  AppSettings copyWith({
    String? currency,
    ThemeMode? themeMode,
    bool? enableNotifications,
    bool? enableNewsNotifications,
    bool? enablePriceAlerts,
    String? language,
    bool? enableAnalytics,
    bool? enableBackendSync,
    String? backendApiUrl,
    int? alertRefreshInterval,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableNewsNotifications: enableNewsNotifications ?? this.enableNewsNotifications,
      enablePriceAlerts: enablePriceAlerts ?? this.enablePriceAlerts,
      language: language ?? this.language,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableBackendSync: enableBackendSync ?? this.enableBackendSync,
      backendApiUrl: backendApiUrl ?? this.backendApiUrl,
      alertRefreshInterval: alertRefreshInterval ?? this.alertRefreshInterval,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
           other.currency == currency &&
           other.themeMode == themeMode &&
           other.enableNotifications == enableNotifications &&
           other.enableNewsNotifications == enableNewsNotifications &&
           other.enablePriceAlerts == enablePriceAlerts &&
           other.language == language &&
           other.enableAnalytics == enableAnalytics &&
           other.enableBackendSync == enableBackendSync &&
           other.backendApiUrl == backendApiUrl &&
           other.alertRefreshInterval == alertRefreshInterval;
  }

  @override
  int get hashCode {
    return Object.hash(
      currency,
      themeMode,
      enableNotifications,
      enableNewsNotifications,
      enablePriceAlerts,
      language,
      enableAnalytics,
      enableBackendSync,
      backendApiUrl,
      alertRefreshInterval,
    );
  }

  @override
  String toString() {
    return 'AppSettings(currency: $currency, themeMode: $themeMode, enableNotifications: $enableNotifications, enableNewsNotifications: $enableNewsNotifications, enablePriceAlerts: $enablePriceAlerts, language: $language, enableAnalytics: $enableAnalytics, enableBackendSync: $enableBackendSync, backendApiUrl: $backendApiUrl, alertRefreshInterval: $alertRefreshInterval)';
  }
}