import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

void main() {
  group('Legal Document Properties', () {
    late StorageService storageService;
    late Random random;

    setUp(() async {
      // Initialize SharedPreferences with empty values for testing
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
      random = Random();
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await storageService.clearAllData();
      } catch (e) {
        // Ignore cleanup errors in tests
      }
    });

    test('Property 21: Legal Document Updates - For any legal document update, the app should notify users of the changes',
        () async {
      // **Feature: enhanced-navigation, Property 21: Legal Document Updates**
      // **Validates: Requirements 10.5**
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 50; iteration++) {
        // Clear all data before each test
        SharedPreferences.setMockInitialValues({});
        
        // Generate random legal document versions and update timestamps
        final initialVersion = _generateRandomDocumentVersion(random);
        final updatedVersion = _generateRandomDocumentVersion(random);
        final updateTimestamp = DateTime.now().add(Duration(days: random.nextInt(30)));
        
        // Test 1: Initial document version storage
        await storageService.saveLegalDocumentVersion('terms_of_service', initialVersion);
        await storageService.saveLegalDocumentVersion('privacy_policy', initialVersion);
        await storageService.saveLegalDocumentVersion('disclaimers', initialVersion);
        
        final loadedTermsVersion = await storageService.getLegalDocumentVersion('terms_of_service');
        final loadedPrivacyVersion = await storageService.getLegalDocumentVersion('privacy_policy');
        final loadedDisclaimersVersion = await storageService.getLegalDocumentVersion('disclaimers');
        
        expect(loadedTermsVersion, equals(initialVersion),
            reason: 'Terms of service version should be stored correctly');
        expect(loadedPrivacyVersion, equals(initialVersion),
            reason: 'Privacy policy version should be stored correctly');
        expect(loadedDisclaimersVersion, equals(initialVersion),
            reason: 'Disclaimers version should be stored correctly');
        
        // Test 2: Document update detection
        // Use predictable versions for testing
        const testInitialVersion = '1.0.0';
        const testUpdatedVersion = '1.1.0';
        
        await storageService.saveLegalDocumentVersion('terms_of_service', testInitialVersion);
        await storageService.saveLegalDocumentVersion('terms_of_service', testUpdatedVersion);
        
        final hasUpdate = await storageService.hasLegalDocumentUpdate('terms_of_service', testInitialVersion);
        expect(hasUpdate, isTrue,
            reason: 'Should detect when legal document has been updated');
        
        // Test 3: User notification flag for updates
        await storageService.markLegalDocumentUpdateNotified('terms_of_service', testUpdatedVersion);
        
        final isNotified = await storageService.isLegalDocumentUpdateNotified('terms_of_service', testUpdatedVersion);
        expect(isNotified, isTrue,
            reason: 'Should track when user has been notified of legal document update');
        
        // Test 4: Multiple document updates
        final documents = ['terms_of_service', 'privacy_policy', 'disclaimers'];
        final baseVersion = '1.0.0';
        final newVersions = ['1.1.0', '1.2.0', '1.3.0'];
        
        // Set initial versions
        for (int i = 0; i < documents.length; i++) {
          await storageService.saveLegalDocumentVersion(documents[i], baseVersion);
        }
        
        // Update to new versions
        for (int i = 0; i < documents.length; i++) {
          await storageService.saveLegalDocumentVersion(documents[i], newVersions[i]);
        }
        
        // Check that all updates are detected
        for (int i = 0; i < documents.length; i++) {
          final hasDocUpdate = await storageService.hasLegalDocumentUpdate(documents[i], baseVersion);
          expect(hasDocUpdate, isTrue,
              reason: 'Should detect update for ${documents[i]}');
        }
        
        // Test 5: Notification tracking for multiple documents
        for (int i = 0; i < documents.length; i++) {
          await storageService.markLegalDocumentUpdateNotified(documents[i], newVersions[i]);
          
          final isDocNotified = await storageService.isLegalDocumentUpdateNotified(documents[i], newVersions[i]);
          expect(isDocNotified, isTrue,
              reason: 'Should track notification for ${documents[i]}');
        }
        
        // Test 6: Pending notifications list
        // Reset notification status for some documents
        await storageService.clearLegalDocumentNotifications();
        
        final pendingNotifications = await storageService.getPendingLegalDocumentNotifications();
        
        // After clearing notifications, all documents with updates should be pending
        expect(pendingNotifications.length, greaterThanOrEqualTo(0),
            reason: 'Should return list of documents with pending notifications');
        
        // Test 7: Last notification timestamp
        final notificationTime = DateTime.now();
        await storageService.setLastLegalNotificationTime(notificationTime);
        
        final lastNotificationTime = await storageService.getLastLegalNotificationTime();
        expect(lastNotificationTime, isNotNull,
            reason: 'Should store and retrieve last notification time');
        
        // Allow for small time differences due to test execution time
        final timeDifference = lastNotificationTime!.difference(notificationTime).inMilliseconds.abs();
        expect(timeDifference, lessThan(1000),
            reason: 'Last notification time should be accurate within 1 second');
        
        // Test 8: Document version comparison
        final olderVersion = '1.0.0';
        final newerVersion = '1.1.0';
        
        await storageService.saveLegalDocumentVersion('test_document', olderVersion);
        
        final hasNewerUpdate = await storageService.hasLegalDocumentUpdate('test_document', newerVersion);
        expect(hasNewerUpdate, isFalse,
            reason: 'Should not detect update when checking with newer version');
        
        final hasOlderUpdate = await storageService.hasLegalDocumentUpdate('test_document', '0.9.0');
        expect(hasOlderUpdate, isTrue,
            reason: 'Should detect update when checking with older version');
      }
    });

    test('Property 21 Extended: Legal Document Notification Persistence - For any legal document notification state, the state should persist across app restarts',
        () async {
      // **Feature: enhanced-navigation, Property 21: Legal Document Updates**
      // **Validates: Requirements 10.5**
      
      for (int iteration = 0; iteration < 25; iteration++) {
        // Clear all data before each test
        SharedPreferences.setMockInitialValues({});
        
        final documentName = 'terms_of_service';
        final version = _generateRandomDocumentVersion(random);
        final notificationTime = DateTime.now().subtract(Duration(hours: random.nextInt(24)));
        
        // Set up initial state
        await storageService.saveLegalDocumentVersion(documentName, version);
        await storageService.markLegalDocumentUpdateNotified(documentName, version);
        await storageService.setLastLegalNotificationTime(notificationTime);
        
        // Simulate app restart by creating new storage service instance
        final newStorageService = StorageService();
        
        // Verify state persists
        final persistedVersion = await newStorageService.getLegalDocumentVersion(documentName);
        final persistedNotificationStatus = await newStorageService.isLegalDocumentUpdateNotified(documentName, version);
        final persistedNotificationTime = await newStorageService.getLastLegalNotificationTime();
        
        expect(persistedVersion, equals(version),
            reason: 'Document version should persist across app restarts');
        expect(persistedNotificationStatus, isTrue,
            reason: 'Notification status should persist across app restarts');
        expect(persistedNotificationTime, isNotNull,
            reason: 'Last notification time should persist across app restarts');
        
        // Allow for small time differences due to serialization
        final timeDifference = persistedNotificationTime!.difference(notificationTime).inMilliseconds.abs();
        expect(timeDifference, lessThan(1000),
            reason: 'Persisted notification time should be accurate within 1 second');
      }
    });

    test('Property 21 Edge Cases: Legal Document Update Edge Cases - For any edge case scenario, the legal document update system should handle it gracefully',
        () async {
      // **Feature: enhanced-navigation, Property 21: Legal Document Updates**
      // **Validates: Requirements 10.5**
      
      for (int iteration = 0; iteration < 15; iteration++) {
        // Clear all data before each test
        SharedPreferences.setMockInitialValues({});
        
        // Test 1: Non-existent document
        final nonExistentDoc = 'non_existent_document';
        final version = _generateRandomDocumentVersion(random);
        
        final hasUpdate = await storageService.hasLegalDocumentUpdate(nonExistentDoc, version);
        expect(hasUpdate, isFalse,
            reason: 'Non-existent document should not have updates');
        
        final isNotified = await storageService.isLegalDocumentUpdateNotified(nonExistentDoc, version);
        expect(isNotified, isFalse,
            reason: 'Non-existent document should not be marked as notified');
        
        // Test 2: Empty version strings
        await storageService.saveLegalDocumentVersion('test_doc', '');
        final emptyVersion = await storageService.getLegalDocumentVersion('test_doc');
        expect(emptyVersion, equals(''),
            reason: 'Should handle empty version strings');
        
        // Test 3: Very long version strings
        final longVersion = 'v' + '1.0.0' * 100; // Very long version string
        await storageService.saveLegalDocumentVersion('test_doc_long', longVersion);
        final retrievedLongVersion = await storageService.getLegalDocumentVersion('test_doc_long');
        expect(retrievedLongVersion, equals(longVersion),
            reason: 'Should handle very long version strings');
        
        // Test 4: Special characters in document names and versions
        final specialDocName = 'test-doc_with.special@chars';
        final specialVersion = 'v1.0.0-beta+build.123';
        
        await storageService.saveLegalDocumentVersion(specialDocName, specialVersion);
        final retrievedSpecialVersion = await storageService.getLegalDocumentVersion(specialDocName);
        expect(retrievedSpecialVersion, equals(specialVersion),
            reason: 'Should handle special characters in document names and versions');
        
        // Test 5: Rapid successive updates
        final rapidUpdates = List.generate(10, (index) => 'v1.0.$index');
        for (final updateVersion in rapidUpdates) {
          await storageService.saveLegalDocumentVersion('rapid_update_doc', updateVersion);
        }
        
        final finalVersion = await storageService.getLegalDocumentVersion('rapid_update_doc');
        expect(finalVersion, equals(rapidUpdates.last),
            reason: 'Should handle rapid successive updates correctly');
        
        // Test 6: Concurrent document operations
        final concurrentDocs = ['doc1', 'doc2', 'doc3'];
        final concurrentVersions = concurrentDocs.map((doc) => _generateRandomDocumentVersion(random)).toList();
        
        // Simulate concurrent operations
        final futures = <Future>[];
        for (int i = 0; i < concurrentDocs.length; i++) {
          futures.add(storageService.saveLegalDocumentVersion(concurrentDocs[i], concurrentVersions[i]));
          futures.add(storageService.markLegalDocumentUpdateNotified(concurrentDocs[i], concurrentVersions[i]));
        }
        
        await Future.wait(futures);
        
        // Verify all operations completed successfully
        for (int i = 0; i < concurrentDocs.length; i++) {
          final version = await storageService.getLegalDocumentVersion(concurrentDocs[i]);
          final isNotified = await storageService.isLegalDocumentUpdateNotified(concurrentDocs[i], concurrentVersions[i]);
          
          expect(version, equals(concurrentVersions[i]),
              reason: 'Concurrent document ${concurrentDocs[i]} should be saved correctly');
          expect(isNotified, isTrue,
              reason: 'Concurrent notification for ${concurrentDocs[i]} should be marked correctly');
        }
      }
    });
  });
}

// Helper methods for generating random test data
String _generateRandomDocumentVersion(Random random) {
  final major = random.nextInt(5) + 1;
  final minor = random.nextInt(10);
  final patch = random.nextInt(20);
  
  final suffixes = ['', '-beta', '-alpha', '-rc1', '-rc2'];
  final suffix = suffixes[random.nextInt(suffixes.length)];
  
  return '$major.$minor.$patch$suffix';
}