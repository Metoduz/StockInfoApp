# Implementation Plan: Strategy Creation Dialog

## Overview

This implementation plan breaks down the strategy creation dialog feature into discrete coding tasks that build incrementally. Each task focuses on a specific component or functionality, with testing integrated throughout to ensure correctness.

## Tasks

- [x] 1. Set up strategy category system and metadata
  - Create StrategyCategory enum with display names and icons
  - Add category extension to existing StrategyType enum
  - Create StrategyFieldDefinition and related data models
  - _Requirements: 4.1, 4.2, 4.5_

- [ ]* 1.1 Write property test for strategy category organization
  - **Property 5: Strategy Category Organization**
  - **Validates: Requirements 4.1, 4.2, 4.3, 4.4**

- [x] 2. Create dynamic form field generation system
  - Implement FieldType enum and ValidationRule class
  - Create StrategyFieldDefinition model
  - Add fieldDefinitions extension to StrategyType
  - Implement form field generator utility functions
  - _Requirements: 7.2, 3.1, 3.3_

- [ ]* 2.1 Write property test for dynamic form generation
  - **Property 3: Dynamic Form Generation**
  - **Validates: Requirements 3.1, 3.2, 3.3**

- [ ]* 2.2 Write property test for system integration
  - **Property 8: System Integration and Extensibility**
  - **Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

- [x] 3. Implement CategorySelector widget
  - Create CategorySelector stateful widget
  - Implement dropdown trigger with current selection display
  - Build two-panel dropdown overlay with category and strategy lists
  - Handle category selection and strategy list updates
  - Implement strategy selection and dropdown closure
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

- [ ]* 3.1 Write property test for category selection behavior
  - **Property 2: Category Selection Updates Strategy List**
  - **Validates: Requirements 2.2, 2.3, 2.4, 2.5**

- [x] 4. Create DynamicStrategyForm widget
  - Implement form widget that generates fields based on strategy type
  - Add real-time validation with error display
  - Handle form state management and field value updates
  - Implement form clearing when strategy type changes
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 4.1 Write property test for form validation state
  - **Property 4: Form Validation State Management**
  - **Validates: Requirements 3.4, 3.5, 6.1, 6.2, 6.3, 6.4**

- [x] 5. Checkpoint - Test form components independently
  - Ensure CategorySelector and DynamicStrategyForm work correctly in isolation
  - Verify form field generation for all strategy types
  - Test validation logic with various input scenarios

- [x] 6. Implement main StrategyCreationDialog widget
  - Create main dialog structure with asset context header
  - Integrate CategorySelector and DynamicStrategyForm components
  - Implement dialog state management
  - Add modal behavior and background interaction prevention
  - Handle dialog dismissal (escape key, outside click)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ]* 6.1 Write property test for dialog modal behavior
  - **Property 1: Dialog Modal Behavior**
  - **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**

- [x] 7. Implement strategy creation and persistence logic
  - Add form submission handling with validation
  - Implement strategy factory integration for creating instances
  - Add strategy to asset's strategy list
  - Implement local storage persistence
  - Handle success and error states with appropriate user feedback
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ]* 7.1 Write property test for strategy creation and persistence
  - **Property 6: Strategy Creation and Persistence**
  - **Validates: Requirements 5.1, 5.2, 5.3, 5.4**

- [ ]* 7.2 Write property test for error handling
  - **Property 7: Error Handling and Recovery**
  - **Validates: Requirements 5.5, 6.5**

- [x] 8. Integrate dialog with asset card "Add Strategy" button
  - Modify asset card widget to include "Add Strategy" button
  - Wire button to open StrategyCreationDialog
  - Pass asset context and handle strategy creation callback
  - Update asset card to refresh strategy list after creation
  - _Requirements: 1.1, 5.2_

- [ ]* 8.1 Write integration tests for asset card integration
  - Test complete flow from button click to strategy creation
  - Verify asset strategy list updates correctly
  - Test dialog opening and closing behavior

- [x] 9. Add comprehensive error handling and user feedback
  - Implement validation error display for all field types
  - Add loading states during form submission
  - Create success/error snackbar notifications
  - Handle edge cases (network errors, storage failures)
  - _Requirements: 6.1, 6.2, 6.5, 5.5_

- [ ]* 9.1 Write unit tests for error scenarios
  - Test validation error display
  - Test form submission error handling
  - Test storage failure recovery

- [x] 10. Implement accessibility features
  - Add proper focus management for dialog lifecycle
  - Implement keyboard navigation support
  - Add screen reader announcements for state changes
  - Ensure proper color contrast and visual accessibility
  - _Requirements: 1.5_

- [ ]* 10.1 Write accessibility tests
  - Test focus management during dialog operations
  - Test keyboard navigation functionality
  - Verify screen reader compatibility

- [x] 11. Final checkpoint - Complete integration testing
  - Test all strategy types with their specific form fields
  - Verify end-to-end strategy creation workflow
  - Test error recovery and edge cases
  - Ensure all tests pass and ask user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests ensure components work together correctly
- The implementation follows Flutter/Material Design 3 patterns
- All form validation should provide clear, actionable feedback to users