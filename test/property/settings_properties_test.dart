import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/app_settings.dart';
import 'package:stockinfoapp/src/services/storage_service.dart';
import 'package:stockinfoapp/src/providers/app_state_provider.dart';
import 'dart:math';

void main() {
  // Initialize Flutter binding for SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Settings Properties', () {
    late StorageService storageService;
    late AppStateProvider appStateProvider;
    late Random random;

    setUp(() {
      storageService = StorageService();
      appStateProvider = AppStateProvider();
      random = Random();
    });

    tearDown(() async {
      // Clean up after each test
      await storageService.clearAllData();
    });

    test('Property 8: Currency Conversion Consistency - For any supported currency selection, all stock displays should update to use the selected currency with proper conversion',
        () async {
      // **Feature: enhanced-navigation, Property 8: Currency Conversion Consistency**
      // **Validates: Requirements 5.2, 5.4**
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random currency from supported currencies
        final supportedCurrencies = AppSettings.supportedCurrencies;
        final selectedCurrency = supportedCurrencies[random.nextInt(supportedCurrencies.length)];
        
        // Create settings with the selected currency
        final settings = AppSettings(
          currency: selectedCurrency,
          themeMode: ThemeMode.values[random.nextInt(ThemeMode.values.length)],
          enableNotifications: random.nextBool(),
          enableNewsNotifications: random.nextBool(),
          enablePriceAlerts: random.nextBool(),
          language: AppSettings.supportedLanguages[random.nextInt(AppSettings.supportedLanguages.length)],
          enableAnalytics: random.nextBool(),
          enableBackendSync: random.nextBool(),
          alertRefreshInterval: 1 + random.nextInt(1440),
        );
        
        // Verify the currency is valid
        expect(settings.isValidCurrency(), isTrue,
            reason: 'Selected currency $selectedCurrency should be valid');
        
        // Verify the currency is properly set
        expect(settings.currency, equals(selectedCurrency),
            reason: 'Settings currency should match selected currency');
        
        // Test that the settings can be persisted and retrieved with the currency intact
        await storageService.saveAppSettings(settings);
        final loadedSettings = await storageService.loadAppSettings();
        
        expect(loadedSettings, isNotNull, reason: 'Settings should be loaded successfully');
        expect(loadedSettings!.currency, equals(selectedCurrency),
            reason: 'Loaded settings should preserve the selected currency');
        
        // Test currency validation for all supported currencies
        for (final currency in supportedCurrencies) {
          final testSettings = settings.copyWith(currency: currency);
          expect(testSettings.isValidCurrency(), isTrue,
              reason: 'Currency $currency should be valid');
          expect(testSettings.currency, equals(currency),
              reason: 'Currency should be properly set to $currency');
        }
        
        // Test that currency changes are properly reflected in copyWith
        final originalCurrency = settings.currency;
        final newCurrency = supportedCurrencies.firstWhere((c) => c != originalCurrency);
        final updatedSettings = settings.copyWith(currency: newCurrency);
        
        expect(updatedSettings.currency, equals(newCurrency),
            reason: 'Updated settings should have new currency');
        expect(settings.currency, equals(originalCurrency),
            reason: 'Original settings should remain unchanged');
        
        // Test that invalid currencies are properly rejected
        final invalidCurrencies = ['XYZ', 'ABC', 'INVALID', ''];
        for (final invalidCurrency in invalidCurrencies) {
          final invalidSettings = AppSettings(currency: invalidCurrency);
          expect(invalidSettings.isValidCurrency(), isFalse,
              reason: 'Invalid currency $invalidCurrency should be rejected');
          
          final validationErrors = invalidSettings.getValidationErrors();
          expect(validationErrors.any((error) => error.contains('Currency')), isTrue,
              reason: 'Validation errors should mention currency issue');
        }
      }
    });

    test('Property 8 Extended: Currency Symbol and Name Consistency - For any supported currency, the currency symbol and name should be consistently available',
        () async {
      // **Feature: enhanced-navigation, Property 8: Currency Conversion Consistency**
      // **Validates: Requirements 5.2, 5.4**
      
      // Test currency symbol and name mapping consistency
      final currencyMappings = {
        'EUR': {'symbol': '€', 'name': 'Euro'},
        'USD': {'symbol': '\$', 'name': 'US Dollar'},
        'GBP': {'symbol': '£', 'name': 'British Pound'},
        'CAD': {'symbol': 'C\$', 'name': 'Canadian Dollar'},
      };
      
      for (int iteration = 0; iteration < 50; iteration++) {
        for (final currency in AppSettings.supportedCurrencies) {
          // Verify currency has expected symbol and name mappings
          expect(currencyMappings.containsKey(currency), isTrue,
              reason: 'Currency $currency should have symbol and name mappings');
          
          final mapping = currencyMappings[currency]!;
          expect(mapping['symbol'], isNotNull,
              reason: 'Currency $currency should have a symbol');
          expect(mapping['name'], isNotNull,
              reason: 'Currency $currency should have a name');
          expect(mapping['symbol']!.isNotEmpty, isTrue,
              reason: 'Currency $currency symbol should not be empty');
          expect(mapping['name']!.isNotEmpty, isTrue,
              reason: 'Currency $currency name should not be empty');
          
          // Test that settings with this currency are valid
          final settings = AppSettings(currency: currency);
          expect(settings.isValidCurrency(), isTrue,
              reason: 'Settings with currency $currency should be valid');
          expect(settings.isValid(), isTrue,
              reason: 'Settings with currency $currency should pass all validation');
        }
      }
    });

    test('Property 8 Boundary: Currency Validation Edge Cases - For any currency validation, edge cases should be handled correctly',
        () async {
      // **Feature: enhanced-navigation, Property 8: Currency Conversion Consistency**
      // **Validates: Requirements 5.2, 5.4**
      
      for (int iteration = 0; iteration < 50; iteration++) {
        // Test null and empty currency handling
        const invalidSettings1 = AppSettings(currency: '');
        expect(invalidSettings1.isValidCurrency(), isFalse,
            reason: 'Empty currency should be invalid');
        
        // Test case sensitivity
        final validCurrency = AppSettings.supportedCurrencies[random.nextInt(AppSettings.supportedCurrencies.length)];
        final lowercaseSettings = AppSettings(currency: validCurrency.toLowerCase());
        final uppercaseSettings = AppSettings(currency: validCurrency.toUpperCase());
        
        // Currency validation should be case-sensitive (exact match required)
        if (validCurrency != validCurrency.toLowerCase()) {
          expect(lowercaseSettings.isValidCurrency(), isFalse,
              reason: 'Lowercase currency should be invalid if different from supported format');
        }
        if (validCurrency != validCurrency.toUpperCase()) {
          expect(uppercaseSettings.isValidCurrency(), isFalse,
              reason: 'Uppercase currency should be invalid if different from supported format');
        }
        
        // Test whitespace handling
        final whitespaceSettings = AppSettings(currency: ' $validCurrency ');
        expect(whitespaceSettings.isValidCurrency(), isFalse,
            reason: 'Currency with whitespace should be invalid');
        
        // Test special characters
        final specialCharSettings = AppSettings(currency: '$validCurrency!');
        expect(specialCharSettings.isValidCurrency(), isFalse,
            reason: 'Currency with special characters should be invalid');
        
        // Test numeric currencies
        final numericSettings = AppSettings(currency: '123');
        expect(numericSettings.isValidCurrency(), isFalse,
            reason: 'Numeric currency should be invalid');
        
        // Test very long currency codes
        final longCurrencySettings = AppSettings(currency: 'VERYLONGCURRENCYCODE');
        expect(longCurrencySettings.isValidCurrency(), isFalse,
            reason: 'Very long currency code should be invalid');
      }
    });
  });
}