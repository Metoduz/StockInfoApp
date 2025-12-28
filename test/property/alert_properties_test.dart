import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/asset_alert.dart';
import 'package:stockinfoapp/src/services/alert_service.dart';
import 'package:stockinfoapp/src/services/storage_service.dart';
import 'dart:math';

void main() {
  group('Alert Properties', () {
    late AlertService alertService;
    late StorageService storageService;

    setUp(() {
      storageService = StorageService();
      alertService = AlertService(storageService);
    });

    tearDown(() {
      alertService.dispose();
    });

    test('Property 16: Alert Creation and Configuration - For any valid alert configuration, the app should allow setting price thresholds and notification preferences',
        () async {
      // **Feature: enhanced-navigation, Property 16: Alert Creation and Configuration**
      // **Validates: Requirements 8.2**
      
      await alertService.initialize();
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate random valid alert configuration
        final alert = _generateRandomValidAlert(random);
        
        // Verify the alert is valid before creation
        expect(alert.isValid(), isTrue,
            reason: 'Generated alert should be valid');
        expect(alert.getValidationError(), isNull,
            reason: 'Valid alert should have no validation errors');
        
        // Create the alert
        await alertService.createAlert(alert);
        
        // Verify the alert was created and stored
        final alerts = alertService.alerts;
        expect(alerts.any((a) => a.id == alert.id), isTrue,
            reason: 'Created alert should be found in alert list');
        
        final createdAlert = alerts.firstWhere((a) => a.id == alert.id);
        
        // Verify all configuration properties are preserved
        expect(createdAlert.assetId, equals(alert.assetId),
            reason: 'Asset ID should be preserved');
        expect(createdAlert.assetName, equals(alert.assetName),
            reason: 'Asset name should be preserved');
        expect(createdAlert.type, equals(alert.type),
            reason: 'Alert type should be preserved');
        expect(createdAlert.threshold, equals(alert.threshold),
            reason: 'Threshold should be preserved');
        expect(createdAlert.isEnabled, equals(alert.isEnabled),
            reason: 'Enabled status should be preserved');
        expect(createdAlert.notifications.enablePushNotifications, 
            equals(alert.notifications.enablePushNotifications),
            reason: 'Push notification preference should be preserved');
        expect(createdAlert.notifications.enableInAppNotifications, 
            equals(alert.notifications.enableInAppNotifications),
            reason: 'In-app notification preference should be preserved');
        expect(createdAlert.notifications.enableEmailNotifications, 
            equals(alert.notifications.enableEmailNotifications),
            reason: 'Email notification preference should be preserved');
        
        // Clean up for next iteration
        await alertService.deleteAlert(alert.id);
      }
    });

    test('Property 17: Alert Notification Triggering - For any alert whose condition is met, the app should send a notification to the user',
        () async {
      // **Feature: enhanced-navigation, Property 17: Alert Notification Triggering**
      // **Validates: Requirements 8.3**
      
      await alertService.initialize();
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a random alert
        final alert = _generateRandomValidAlert(random);
        await alertService.createAlert(alert);
        
        // Get mock asset data for the alert's asset
        final assetData = alertService.getAssetData(alert.assetId);
        expect(assetData, isNotNull,
            reason: 'Asset data should be available for alert testing');
        
        // Test if alert should trigger based on current conditions
        final shouldTrigger = alert.shouldTrigger(
          assetData!.currentValue,
          assetData.previousClose,
          null, // Volume not available in mock data
        );
        
        if (shouldTrigger) {
          // Start monitoring to trigger the alert
          alertService.startMonitoring();
          
          // Wait for monitoring cycle to process
          await Future.delayed(const Duration(milliseconds: 100));
          
          // Verify the alert was triggered
          final updatedAlerts = alertService.alerts;
          final triggeredAlert = updatedAlerts.firstWhere((a) => a.id == alert.id);
          
          expect(triggeredAlert.triggeredAt, isNotNull,
              reason: 'Alert should be triggered when condition is met');
          expect(triggeredAlert.status, equals(AlertStatus.triggered),
              reason: 'Alert status should be triggered when condition is met');
        } else {
          // Alert should not be triggered
          final updatedAlerts = alertService.alerts;
          final nonTriggeredAlert = updatedAlerts.firstWhere((a) => a.id == alert.id);
          
          expect(nonTriggeredAlert.triggeredAt, isNull,
              reason: 'Alert should not be triggered when condition is not met');
          expect(nonTriggeredAlert.status, equals(AlertStatus.active),
              reason: 'Alert status should remain active when condition is not met');
        }
        
        // Clean up
        alertService.stopMonitoring();
        await alertService.deleteAlert(alert.id);
      }
    });

    test('Property 18: Alert State Management - For any alert that is disabled, the app should stop monitoring that condition',
        () async {
      // **Feature: enhanced-navigation, Property 18: Alert State Management**
      // **Validates: Requirements 8.5**
      
      await alertService.initialize();
      final random = Random();
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Generate a random alert
        final alert = _generateRandomValidAlert(random);
        await alertService.createAlert(alert);
        
        // Verify alert is initially enabled and active
        expect(alert.isEnabled, isTrue,
            reason: 'Alert should be enabled by default');
        expect(alert.status, equals(AlertStatus.active),
            reason: 'Alert should be active when enabled');
        
        // Disable the alert
        await alertService.disableAlert(alert.id);
        
        // Verify the alert is disabled
        final disabledAlerts = alertService.alerts;
        final disabledAlert = disabledAlerts.firstWhere((a) => a.id == alert.id);
        
        expect(disabledAlert.isEnabled, isFalse,
            reason: 'Alert should be disabled after disableAlert call');
        expect(disabledAlert.status, equals(AlertStatus.disabled),
            reason: 'Alert status should be disabled when isEnabled is false');
        
        // Verify disabled alert should not trigger even if condition is met
        final assetData = alertService.getAssetData(alert.assetId);
        expect(assetData, isNotNull,
            reason: 'Asset data should be available for alert testing');
        
        final shouldTrigger = disabledAlert.shouldTrigger(
          assetData!.currentValue,
          assetData.previousClose,
          null,
        );
        
        expect(shouldTrigger, isFalse,
            reason: 'Disabled alert should never trigger regardless of conditions');
        
        // Test re-enabling the alert
        await alertService.enableAlert(alert.id);
        
        final enabledAlerts = alertService.alerts;
        final enabledAlert = enabledAlerts.firstWhere((a) => a.id == alert.id);
        
        expect(enabledAlert.isEnabled, isTrue,
            reason: 'Alert should be enabled after enableAlert call');
        expect(enabledAlert.status, equals(AlertStatus.active),
            reason: 'Alert status should be active when re-enabled');
        
        // Test reset functionality for triggered alerts
        if (enabledAlert.triggeredAt == null) {
          // Manually trigger the alert to test reset
          final triggeredAlert = enabledAlert.trigger();
          await alertService.updateAlert(triggeredAlert);
          
          expect(triggeredAlert.triggeredAt, isNotNull,
              reason: 'Alert should have triggered timestamp');
          expect(triggeredAlert.status, equals(AlertStatus.triggered),
              reason: 'Alert status should be triggered');
          
          // Reset the alert
          await alertService.resetAlert(triggeredAlert.id);
          
          final resetAlerts = alertService.alerts;
          final resetAlert = resetAlerts.firstWhere((a) => a.id == alert.id);
          
          expect(resetAlert.triggeredAt, isNull,
              reason: 'Alert should have no triggered timestamp after reset');
          expect(resetAlert.status, equals(AlertStatus.active),
              reason: 'Alert status should be active after reset');
        }
        
        // Clean up
        await alertService.deleteAlert(alert.id);
      }
    });

    test('Property 16 Extended: Alert Validation - For any invalid alert configuration, the app should reject the alert with appropriate error messages',
        () async {
      // **Feature: enhanced-navigation, Property 16: Alert Creation and Configuration**
      // **Validates: Requirements 8.2**
      
      await alertService.initialize();
      final random = Random();
      
      // Test with multiple iterations of invalid configurations
      for (int iteration = 0; iteration < 50; iteration++) {
        // Generate various types of invalid alerts
        final invalidAlert = _generateRandomInvalidAlert(random);
        
        // Verify the alert is invalid
        expect(invalidAlert.isValid(), isFalse,
            reason: 'Generated invalid alert should be invalid');
        expect(invalidAlert.getValidationError(), isNotNull,
            reason: 'Invalid alert should have validation error message');
        
        // Attempt to create the invalid alert
        expect(
          () async => await alertService.createAlert(invalidAlert),
          throwsA(isA<ArgumentError>()),
          reason: 'Creating invalid alert should throw ArgumentError',
        );
        
        // Verify the alert was not created
        final alerts = alertService.alerts;
        expect(alerts.any((a) => a.id == invalidAlert.id), isFalse,
            reason: 'Invalid alert should not be found in alert list');
      }
    });

    test('Property 17 Extended: Alert Triggering Conditions - For any alert type, the triggering logic should correctly evaluate the specified conditions',
        () async {
      // **Feature: enhanced-navigation, Property 17: Alert Notification Triggering**
      // **Validates: Requirements 8.3**
      
      await alertService.initialize();
      final random = Random();
      
      // Test each alert type with specific conditions
      for (final alertType in AlertType.values) {
        if (alertType == AlertType.newsAlert) continue; // Skip news alerts as they're triggered externally
        
        for (int iteration = 0; iteration < 20; iteration++) {
          final basePrice = 100.0 + random.nextDouble() * 100.0;
          final threshold = _generateValidThreshold(alertType, random);
          
          final alert = AssetAlert(
            id: 'test_${DateTime.now().millisecondsSinceEpoch}_$iteration',
            assetId: 'TEST',
            assetName: 'Test Asset',
            type: alertType,
            threshold: threshold,
            createdAt: DateTime.now(),
          );
          
          // Test various price scenarios
          final testPrices = [
            basePrice - 20.0, // Well below
            basePrice - 5.0,  // Slightly below
            basePrice,        // Equal
            basePrice + 5.0,  // Slightly above
            basePrice + 20.0, // Well above
          ];
          
          for (final testPrice in testPrices) {
            final shouldTrigger = alert.shouldTrigger(testPrice, basePrice, null);
            
            switch (alertType) {
              case AlertType.priceAbove:
                expect(shouldTrigger, equals(testPrice > threshold),
                    reason: 'Price above alert should trigger when price ($testPrice) > threshold ($threshold)');
                break;
              case AlertType.priceBelow:
                expect(shouldTrigger, equals(testPrice < threshold),
                    reason: 'Price below alert should trigger when price ($testPrice) < threshold ($threshold)');
                break;
              case AlertType.percentChange:
                final expectedTrigger = ((testPrice - basePrice).abs() / basePrice * 100) >= threshold;
                expect(shouldTrigger, equals(expectedTrigger),
                    reason: 'Percent change alert should trigger when change >= threshold ($threshold%)');
                break;
              case AlertType.volumeSpike:
                // Volume spike requires volume data, test with mock volume
                final mockVolume = threshold + 1000;
                final shouldTriggerWithVolume = alert.shouldTrigger(testPrice, basePrice, mockVolume);
                expect(shouldTriggerWithVolume, isTrue,
                    reason: 'Volume spike alert should trigger when volume ($mockVolume) > threshold ($threshold)');
                break;
              case AlertType.newsAlert:
                // News alerts are handled externally
                break;
            }
          }
        }
      }
    });
  });
}

AssetAlert _generateRandomValidAlert(Random random) {
  final assetIds = ['BASF', 'SAP', 'MBG', 'SIE', 'ALV'];
  final assetNames = ['BASF SE', 'SAP SE', 'Mercedes-Benz Group AG', 'Siemens AG', 'Allianz SE'];
  final alertTypes = AlertType.values;
  
  final assetIndex = random.nextInt(assetIds.length);
  final alertType = alertTypes[random.nextInt(alertTypes.length)];
  final threshold = _generateValidThreshold(alertType, random);
  
  return AssetAlert(
    id: 'alert_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(1000)}',
    assetId: assetIds[assetIndex],
    assetName: assetNames[assetIndex],
    type: alertType,
    threshold: threshold,
    isEnabled: random.nextBool(),
    createdAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    notifications: NotificationSettings(
      enablePushNotifications: random.nextBool(),
      enableEmailNotifications: random.nextBool(),
      enableInAppNotifications: random.nextBool(),
      notificationTimes: _generateRandomNotificationTimes(random),
      enableWeekendNotifications: random.nextBool(),
    ),
    source: random.nextBool() ? AlertSource.local : AlertSource.backend,
    metadata: random.nextBool() ? {'test': 'data'} : null,
  );
}

AssetAlert _generateRandomInvalidAlert(Random random) {
  final invalidTypes = [
    'empty_id',
    'empty_asset_id',
    'empty_asset_name',
    'negative_threshold',
    'invalid_percentage',
  ];
  
  final invalidType = invalidTypes[random.nextInt(invalidTypes.length)];
  
  switch (invalidType) {
    case 'empty_id':
      return AssetAlert(
        id: '', // Invalid: empty ID
        assetId: 'BASF',
        assetName: 'BASF SE',
        type: AlertType.priceAbove,
        threshold: 100.0,
        createdAt: DateTime.now(),
      );
    case 'empty_asset_id':
      return AssetAlert(
        id: 'valid_id',
        assetId: '', // Invalid: empty asset ID
        assetName: 'BASF SE',
        type: AlertType.priceAbove,
        threshold: 100.0,
        createdAt: DateTime.now(),
      );
    case 'empty_asset_name':
      return AssetAlert(
        id: 'valid_id',
        assetId: 'BASF',
        assetName: '', // Invalid: empty asset name
        type: AlertType.priceAbove,
        threshold: 100.0,
        createdAt: DateTime.now(),
      );
    case 'negative_threshold':
      return AssetAlert(
        id: 'valid_id',
        assetId: 'BASF',
        assetName: 'BASF SE',
        type: AlertType.priceAbove,
        threshold: -10.0, // Invalid: negative threshold
        createdAt: DateTime.now(),
      );
    case 'invalid_percentage':
      return AssetAlert(
        id: 'valid_id',
        assetId: 'BASF',
        assetName: 'BASF SE',
        type: AlertType.percentChange,
        threshold: 150.0, // Invalid: percentage > 100
        createdAt: DateTime.now(),
      );
    default:
      throw ArgumentError('Unknown invalid type: $invalidType');
  }
}

double _generateValidThreshold(AlertType type, Random random) {
  switch (type) {
    case AlertType.priceAbove:
    case AlertType.priceBelow:
      return 50.0 + random.nextDouble() * 200.0; // 50-250 EUR
    case AlertType.percentChange:
      return random.nextDouble() * 50.0; // 0-50%
    case AlertType.volumeSpike:
      return 1000.0 + random.nextDouble() * 10000.0; // 1000-11000 volume
    case AlertType.newsAlert:
      return 0.0; // News alerts don't use threshold
  }
}

List<String> _generateRandomNotificationTimes(Random random) {
  final times = ['09:00', '12:00', '15:00', '18:00', '21:00'];
  final count = random.nextInt(3); // 0-2 notification times
  final selectedTimes = <String>[];
  
  for (int i = 0; i < count; i++) {
    final time = times[random.nextInt(times.length)];
    if (!selectedTimes.contains(time)) {
      selectedTimes.add(time);
    }
  }
  
  return selectedTimes;
}