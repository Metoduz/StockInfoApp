# Implementation Plan: Enhanced Navigation

## Overview

This implementation plan transforms the current single-screen Stock Info App into a comprehensive multi-tab application with user personalization features. The implementation follows an incremental approach, building core navigation first, then adding features progressively while maintaining functionality at each step.

## Tasks

- [x] 1. Set up enhanced project structure and dependencies
  - Add required dependencies to pubspec.yaml (shared_preferences, provider)
  - Create new directory structure for enhanced navigation components
  - Set up provider for state management across tabs
  - _Requirements: 9.1, 9.2_

- [-] 2. Implement core navigation shell
  - [x] 2.1 Create NavigationShell widget with bottom navigation
    - Implement bottom navigation bar with three tabs (Main, News, Alerts)
    - Use IndexedStack to preserve state across tab switches
    - _Requirements: 1.1, 1.5_

  - [ ] 2.2 Write property test for tab navigation consistency
    - **Property 1: Tab Navigation Consistency**
    - **Validates: Requirements 1.2, 1.3, 1.4, 1.6**

  - [ ] 2.3 Write property test for state preservation
    - **Property 2: State Preservation Across Navigation**
    - **Validates: Requirements 1.5**

  - [ ] 2.4 Integrate NavigationShell into main app
    - Replace StockListView as home with NavigationShell
    - Update app.dart to use new navigation structure
    - _Requirements: 1.1_

- [-] 3. Implement side drawer menu
  - [x] 3.1 Create DrawerMenu widget
    - Design drawer with user profile section and menu options
    - Include navigation to User Profile, Settings, Trading History, Legal Info
    - _Requirements: 3.1, 3.2, 3.4_

  - [ ] 3.2 Write property test for menu navigation
    - **Property 5: Menu Navigation Consistency**
    - **Validates: Requirements 3.3**

  - [ ] 3.3 Integrate drawer into NavigationShell
    - Add drawer to Scaffold in NavigationShell
    - Ensure drawer works across all tabs
    - _Requirements: 3.1, 3.5_

- [ ] 4. Checkpoint - Ensure navigation structure works
  - Ensure all tests pass, ask the user if questions arise.

- [-] 5. Enhance watchlist functionality
  - [x] 5.1 Create enhanced WatchlistScreen
    - Convert existing StockListView to new WatchlistScreen
    - Add reordering capability with ReorderableListView
    - Implement add/remove stock functionality
    - _Requirements: 2.1, 2.6_

  - [ ] 5.2 Write property tests for watchlist management
    - **Property 3: Watchlist Persistence Round Trip**
    - **Validates: Requirements 2.3, 2.4**

  - [ ] 5.3 Write property test for watchlist reordering
    - **Property 4: Watchlist Reordering Preservation**
    - **Validates: Requirements 2.6**

  - [ ] 5.4 Create stock search and selection dialog
    - Implement stock search interface for adding stocks
    - Include stock validation and duplicate prevention
    - _Requirements: 2.2_

  - [ ] 5.5 Write unit tests for stock search functionality
    - Test search validation and duplicate handling
    - Test empty watchlist state display
    - _Requirements: 2.2, 2.5_

- [x] 6. Implement data persistence layer
  - [x] 6.1 Create StorageService class
    - Implement SharedPreferences-based storage for all user data
    - Include methods for watchlist, profile, settings, and trading history
    - _Requirements: 9.1, 9.2, 9.3_

  - [x] 6.2 Write property tests for data persistence
    - **Property 19: Data Persistence Consistency**
    - **Validates: Requirements 9.2, 9.3**

  - [x] 6.3 Write property test for storage error handling
    - **Property 20: Storage Error Handling**
    - **Validates: Requirements 9.4**

  - [x] 6.4 Integrate StorageService with existing components
    - Update WatchlistScreen to use persistent storage
    - Implement data loading on app startup
    - _Requirements: 9.1_

- [-] 7. Create user profile management
  - [x] 7.1 Create UserProfile data model
    - Define UserProfile class with validation
    - Include fields for name, email, profile picture, preferences
    - _Requirements: 4.3_

  - [x] 7.2 Implement UserProfileScreen
    - Create editable profile form with validation
    - Include profile picture upload functionality
    - _Requirements: 4.1, 4.3_

  - [ ] 7.3 Write property tests for profile management
    - **Property 6: Profile Data Round Trip**
    - **Validates: Requirements 4.2, 4.4**

  - [ ] 7.4 Write property test for user feedback
    - **Property 7: User Feedback for Operations**
    - **Validates: Requirements 4.5**

- [-] 8. Implement app settings
  - [x] 8.1 Create AppSettings data model
    - Define settings structure with currency, theme, notifications
    - Include validation for settings values
    - _Requirements: 5.5_

  - [x] 8.2 Create SettingsScreen
    - Implement currency selection with EUR, USD, GBP support
    - Add theme selection and notification preferences
    - _Requirements: 5.1, 5.5_

  - [ ] 8.3 Write property tests for currency settings
    - **Property 8: Currency Conversion Consistency**
    - **Validates: Requirements 5.2, 5.4**

  - [ ] 8.4 Write property test for currency persistence
    - **Property 9: Currency Settings Persistence**
    - **Validates: Requirements 5.3**

- [ ] 9. Checkpoint - Ensure core features work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Implement news feed functionality
  - [x] 10.1 Create NewsArticle data model
    - Define news article structure with all required fields
    - Include methods for filtering by related stocks
    - _Requirements: 7.1_

  - [x] 10.2 Create NewsService for data fetching
    - Implement news fetching with caching capability
    - Include error handling and retry logic
    - _Requirements: 7.1, 7.4, 7.5_

  - [x] 10.3 Create NewsScreen
    - Implement news feed with pull-to-refresh
    - Add article detail view and watchlist prioritization
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [x] 10.4 Write property tests for news functionality
    - **Property 13: News Prioritization**
    - **Validates: Requirements 7.2**

  - [x] 10.5 Write property tests for news navigation and error handling
    - **Property 14: News Article Navigation**
    - **Property 15: News Error Handling**
    - **Validates: Requirements 7.3, 7.5**

- [-] 11. Implement alerts system
  - [x] 11.1 Create StockAlert data model
    - Define alert structure with thresholds and notification settings
    - Include alert validation and state management
    - _Requirements: 8.4_

  - [x] 11.2 Create AlertService
    - Implement alert monitoring and notification logic
    - Include alert persistence and state management
    - _Requirements: 8.3, 8.5_

  - [x] 11.3 Create AlertsScreen
    - Implement alert creation and management interface
    - Include alert configuration and status display
    - _Requirements: 8.1, 8.2_

  - [-] 11.4 Write property tests for alert functionality
    - **Property 16: Alert Creation and Configuration**
    - **Property 17: Alert Notification Triggering**
    - **Property 18: Alert State Management**
    - **Validates: Requirements 8.2, 8.3, 8.5**

- [x] 12. Implement trading history
  - [x] 12.1 Create Transaction data model
    - Define transaction structure with all required fields
    - Include performance calculation methods
    - _Requirements: 6.1_

  - [x] 12.2 Create TradingHistoryScreen
    - Implement transaction list with filtering capabilities
    - Add performance metrics display and transaction entry
    - _Requirements: 6.1, 6.5_

  - [x] 12.3 Write property tests for trading history
    - **Property 10: Transaction Display Completeness**
    - **Property 11: Performance Metrics Calculation**
    - **Property 12: Trading History Filtering**
    - **Validates: Requirements 6.2, 6.3, 6.4, 6.5**

- [x] 13. Implement legal and compliance features
  - [x] 13.1 Create LegalInfoScreen
    - Implement legal document display with proper formatting
    - Include terms of service, privacy policy, and disclaimers
    - _Requirements: 10.1, 10.2, 10.4_

  - [x] 13.2 Write property test for legal document updates
    - **Property 21: Legal Document Updates**
    - **Validates: Requirements 10.5**

  - [x] 13.3 Add data export functionality
    - Implement user data export for backup purposes
    - Include proper data formatting and privacy considerations
    - _Requirements: 9.5_

- [-] 14. Integration and final wiring
  - [x] 14.1 Connect all screens to navigation system
    - Ensure all screens are properly integrated with NavigationShell
    - Implement proper routing and deep linking support
    - _Requirements: 1.1, 3.3_

  - [x] 14.2 Implement cross-component data sharing
    - Use Provider for sharing data between tabs and screens
    - Ensure data consistency across all components
    - _Requirements: 4.4, 5.2_

  - [ ] 14.3 Write integration tests
    - Test complete user flows across multiple screens
    - Test data persistence across app restarts
    - _Requirements: All requirements_

- [ ] 15. Final checkpoint - Ensure all features work together
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- All tasks are required for comprehensive implementation
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation and user feedback
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Implementation uses Dart/Flutter with Material Design 3
- SharedPreferences used for local data persistence
- Provider pattern used for state management across components