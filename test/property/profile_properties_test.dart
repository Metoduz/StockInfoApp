import 'package:flutter_test/flutter_test.dart';
import 'package:stockinfoapp/src/models/user_profile.dart';
import 'package:stockinfoapp/src/services/storage_service.dart';
import 'package:stockinfoapp/src/providers/app_state_provider.dart';
import 'dart:math';

void main() {
  // Initialize Flutter binding for SharedPreferences
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Profile Management Properties', () {
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

    test('Property 6: Profile Data Round Trip - For any valid profile update, the changes should be validated, saved to storage, and reflected throughout the app',
        () async {
      // **Feature: enhanced-navigation, Property 6: Profile Data Round Trip**
      // **Validates: Requirements 4.2, 4.4**
      
      // Test with multiple iterations to verify property holds across different scenarios
      for (int iteration = 0; iteration < 100; iteration++) {
        // Clear all data before each test
        await storageService.clearAllData();
        
        // Generate a random valid profile
        final originalProfile = _generateRandomValidProfile(random);
        
        // Test the round trip: save -> load -> verify
        await appStateProvider.updateUserProfile(originalProfile);
        
        // Verify the profile is immediately available in the provider
        expect(appStateProvider.userProfile, isNotNull,
            reason: 'Profile should be immediately available after update');
        _verifyUserProfileEquality(originalProfile, appStateProvider.userProfile!, 'Provider profile');
        
        // Reload from storage to verify persistence
        await appStateProvider.loadUserProfile();
        
        // Verify the profile persisted correctly
        expect(appStateProvider.userProfile, isNotNull,
            reason: 'Profile should be loaded from storage');
        _verifyUserProfileEquality(originalProfile, appStateProvider.userProfile!, 'Persisted profile');
        
        // Test profile updates (modification round trip)
        final updatedProfile = originalProfile.copyWith(
          name: _generateRandomName(random),
          email: _generateRandomEmail(random),
          profileImagePath: random.nextBool() ? '/new/path/image.jpg' : null,
        ).withUpdatedTimestamp();
        
        // Validate the updated profile
        final validationError = updatedProfile.validate();
        expect(validationError, isNull,
            reason: 'Generated profile should be valid: $validationError');
        
        // Update and verify round trip
        await appStateProvider.updateUserProfile(updatedProfile);
        
        expect(appStateProvider.userProfile, isNotNull,
            reason: 'Updated profile should be immediately available');
        _verifyUserProfileEquality(updatedProfile, appStateProvider.userProfile!, 'Updated provider profile');
        
        // Reload and verify persistence of update
        await appStateProvider.loadUserProfile();
        
        expect(appStateProvider.userProfile, isNotNull,
            reason: 'Updated profile should be loaded from storage');
        _verifyUserProfileEquality(updatedProfile, appStateProvider.userProfile!, 'Updated persisted profile');
        
        // Verify the lastUpdated timestamp was actually updated
        expect(appStateProvider.userProfile!.lastUpdated.isAfter(originalProfile.lastUpdated),
            isTrue, reason: 'Last updated timestamp should be newer after update');
      }
    });

    test('Property 6 Extended: Profile Validation Round Trip - For any profile data, validation should correctly identify valid and invalid profiles',
        () async {
      // **Feature: enhanced-navigation, Property 6: Profile Data Round Trip**
      // **Validates: Requirements 4.2, 4.4**
      
      for (int iteration = 0; iteration < 50; iteration++) {
        // Test valid profiles
        final validProfile = _generateRandomValidProfile(random);
        final validationError = validProfile.validate();
        expect(validationError, isNull,
            reason: 'Valid profile should pass validation: ${validProfile.toString()}');
        
        // Test invalid profiles
        final invalidProfiles = _generateInvalidProfiles(random);
        for (final invalidProfile in invalidProfiles) {
          final error = invalidProfile.validate();
          expect(error, isNotNull,
              reason: 'Invalid profile should fail validation: ${invalidProfile.toString()}');
          expect(error, isA<String>(),
              reason: 'Validation error should be a descriptive string');
          expect(error!.isNotEmpty, isTrue,
              reason: 'Validation error should not be empty');
        }
      }
    });

    test('Property 6 Extended: Profile Completeness Check - For any profile, the completeness check should correctly identify complete and incomplete profiles',
        () async {
      // **Feature: enhanced-navigation, Property 6: Profile Data Round Trip**
      // **Validates: Requirements 4.2, 4.4**
      
      for (int iteration = 0; iteration < 50; iteration++) {
        // Test complete profiles (have name)
        final completeProfile = _generateRandomValidProfile(random);
        expect(completeProfile.isComplete, isTrue,
            reason: 'Profile with name should be complete: ${completeProfile.toString()}');
        
        // Test incomplete profiles (no name or empty name)
        final incompleteProfiles = [
          completeProfile.copyWith(name: null),
          completeProfile.copyWith(name: ''),
          completeProfile.copyWith(name: '   '), // whitespace only
        ];
        
        for (final incompleteProfile in incompleteProfiles) {
          expect(incompleteProfile.isComplete, isFalse,
              reason: 'Profile without proper name should be incomplete: ${incompleteProfile.toString()}');
        }
      }
    });

    test('Property 6 Extended: Profile JSON Serialization Round Trip - For any valid profile, JSON serialization and deserialization should preserve all data',
        () async {
      // **Feature: enhanced-navigation, Property 6: Profile Data Round Trip**
      // **Validates: Requirements 4.2, 4.4**
      
      for (int iteration = 0; iteration < 100; iteration++) {
        final originalProfile = _generateRandomValidProfile(random);
        
        // Serialize to JSON
        final json = originalProfile.toJson();
        expect(json, isA<Map<String, dynamic>>(),
            reason: 'Profile should serialize to JSON map');
        
        // Deserialize from JSON
        final deserializedProfile = UserProfile.fromJson(json);
        
        // Verify round trip equality
        _verifyUserProfileEquality(originalProfile, deserializedProfile, 'JSON round trip');
        
        // Test with null values
        final profileWithNulls = UserProfile(
          name: null,
          email: null,
          profileImagePath: null,
          preferredCurrency: 'EUR',
          createdAt: DateTime.now(),
          lastUpdated: DateTime.now(),
          backendUserId: null,
        );
        
        final nullJson = profileWithNulls.toJson();
        final deserializedNullProfile = UserProfile.fromJson(nullJson);
        
        _verifyUserProfileEquality(profileWithNulls, deserializedNullProfile, 'JSON round trip with nulls');
      }
    });
  });
}

// Helper methods for generating test data
UserProfile _generateRandomValidProfile(Random random) {
  final now = DateTime.now();
  return UserProfile(
    name: _generateRandomName(random),
    email: _generateRandomEmail(random),
    profileImagePath: random.nextBool() ? '/path/to/image_${random.nextInt(1000)}.jpg' : null,
    preferredCurrency: _generateRandomCurrency(random),
    createdAt: now.subtract(Duration(days: random.nextInt(365))),
    lastUpdated: now.subtract(Duration(hours: random.nextInt(24))),
    backendUserId: random.nextBool() ? 'user_${random.nextInt(10000)}' : null,
  );
}

String _generateRandomName(Random random) {
  final firstNames = ['John', 'Jane', 'Bob', 'Alice', 'Charlie', 'Diana', 'Eve', 'Frank'];
  final lastNames = ['Smith', 'Johnson', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor'];
  
  return '${firstNames[random.nextInt(firstNames.length)]} ${lastNames[random.nextInt(lastNames.length)]}';
}

String _generateRandomEmail(Random random) {
  final domains = ['example.com', 'test.org', 'demo.net', 'sample.io'];
  final usernames = ['user', 'test', 'demo', 'sample', 'john', 'jane'];
  
  return '${usernames[random.nextInt(usernames.length)]}${random.nextInt(1000)}@${domains[random.nextInt(domains.length)]}';
}

String _generateRandomCurrency(Random random) {
  final currencies = ['EUR', 'USD', 'GBP', 'CAD'];
  return currencies[random.nextInt(currencies.length)];
}

List<UserProfile> _generateInvalidProfiles(Random random) {
  final now = DateTime.now();
  final validBase = UserProfile(
    name: 'Valid Name',
    email: 'valid@example.com',
    preferredCurrency: 'EUR',
    createdAt: now,
    lastUpdated: now,
  );
  
  return [
    // Invalid name (too long)
    validBase.copyWith(name: 'A' * 101),
    
    // Invalid email formats
    validBase.copyWith(email: 'invalid-email'),
    validBase.copyWith(email: 'missing@domain'),
    validBase.copyWith(email: '@missing-user.com'),
    validBase.copyWith(email: 'spaces in@email.com'),
    validBase.copyWith(email: 'no-tld@domain'),
    
    // Invalid currency
    validBase.copyWith(preferredCurrency: 'INVALID'),
    validBase.copyWith(preferredCurrency: 'JPY'), // Not in supported list
    validBase.copyWith(preferredCurrency: ''),
  ];
}

// Helper method for verifying profile equality
void _verifyUserProfileEquality(UserProfile expected, UserProfile actual, String context) {
  expect(actual.name, equals(expected.name), reason: '$context: Name should match');
  expect(actual.email, equals(expected.email), reason: '$context: Email should match');
  expect(actual.profileImagePath, equals(expected.profileImagePath), reason: '$context: Profile image path should match');
  expect(actual.preferredCurrency, equals(expected.preferredCurrency), reason: '$context: Preferred currency should match');
  expect(actual.createdAt, equals(expected.createdAt), reason: '$context: Created at should match');
  expect(actual.lastUpdated, equals(expected.lastUpdated), reason: '$context: Last updated should match');
  expect(actual.backendUserId, equals(expected.backendUserId), reason: '$context: Backend user ID should match');
}