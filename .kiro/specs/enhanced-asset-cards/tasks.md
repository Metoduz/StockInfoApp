# Implementation Plan: Enhanced Asset Cards

## Overview

This implementation plan transforms the current simple AssetCard widget into a comprehensive asset management interface with four distinct sections: AssetInformation, Tags, Strategies, and ActiveTrades. The implementation follows an incremental approach, building core models first, then UI components, and finally integrating the complete enhanced card system.

## Tasks

- [x] 1. Create enhanced data models and enums
  - Create new data models for enhanced asset functionality
  - Define enums for asset types, strategy types, and trade directions
  - Implement serialization methods for data persistence
  - _Requirements: 1.5, 3.9, 5.3, 8.3_

- [x] 1.1 Write property tests for enhanced data models

  - **Property 7: Asset Type Support Consistency**
  - **Validates: Requirements 1.5, 3.9**

- [-] 2. Implement trading strategy system
  - [x] 2.1 Create abstract TradingStrategy base class
    - Define strategy interface with trigger condition methods
    - Implement strategy parameter validation
    - _Requirements: 3.3, 3.9, 8.3_

  - [x] 2.2 Implement concrete strategy classes
    - Create TrendlineStrategy, BuyAreaStrategy, and ElliotWavesStrategy
    - Implement trigger condition logic for each strategy type
    - _Requirements: 3.9, 8.3_

  - [x] 2.3 Write property tests for strategy logic

    - **Property 4: Composite Strategy Logic Evaluation**
    - **Validates: Requirements 3.10**

  - [ ] 2.4 Create CompositeStrategy class
    - Implement logical operator combinations (AND/OR)
    - Create strategy condition evaluation system
    - _Requirements: 3.10_

  - [ ] 2.5 Write property tests for composite strategy evaluation

    - **Property 4: Composite Strategy Logic Evaluation**
    - **Validates: Requirements 3.10**

- [-] 3. Implement strategy template system
  - [ ] 3.1 Create StrategyTemplate model and TemplateManager
    - Implement template save/load functionality
    - Create template application logic
    - _Requirements: 4.1, 4.2, 4.3_

  - [ ] 3.2 Write property tests for template system

    - **Property 5: Strategy Template Round-Trip Integrity**
    - **Validates: Requirements 4.1, 4.3, 4.4**

- [-] 4. Create active trade management system
  - [x] 4.1 Implement ActiveTradeItem and StopLossConfig models
    - Create trade data structures with P&L calculations
    - Implement stop loss validation logic
    - _Requirements: 5.3, 5.4, 5.5, 5.6, 5.7_

  - [ ] 4.2 Write property tests for trade calculations

    - **Property 3: Trade P&L Calculation Accuracy**
    - **Validates: Requirements 5.5**


  - [ ] 4.3 Write property tests for stop loss validation

    - **Property 8: Stop Loss Configuration Validation**
    - **Validates: Requirements 5.6, 5.7**

  - [x] 4.4 Implement transaction persistence system
    - Create transaction data model for closed trades
    - Implement save/load functionality for performance metrics
    - _Requirements: 5.13, 9.1, 9.2, 9.3_

  - [ ] 4.5 Write property tests for transaction persistence

    - **Property 10: Transaction Persistence Completeness**
    - **Validates: Requirements 5.13, 9.1, 9.2, 9.3**

- [ ] 5. Checkpoint - Ensure all core models and business logic tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [-] 6. Create enhanced AssetInformation section
  - [x] 6.1 Implement AssetTypeIcon widget
    - Create icon mapping for different asset types
    - Implement responsive icon display
    - _Requirements: 1.4, 1.5_

  - [x] 6.2 Create enhanced asset identifiers display
    - Layout Name, ISIN, WKN, and short name on left side
    - Implement responsive text layout
    - _Requirements: 1.3_

  - [x] 6.3 Implement PerformanceMetrics widget
    - Create performance metrics display with three values
    - Show daily performance percentage
    - Display open trades total performance for this asset
    - Display all trades (open + closed) total performance
    - _Requirements: 1.6, 1.7, 1.8, 1.9_

  - [ ] 6.4 Write property tests for performance metrics calculation

    - **Property 12: Performance Metrics Calculation Accuracy**
    - **Validates: Requirements 1.7, 1.8, 1.9**

- [-] 7. Implement Tags section
  - [x] 7.1 Create TagsSection widget with flow layout
    - Implement horizontal tag display with wrapping
    - Add maximum 2-row constraint with overflow indicator
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.7_

  - [ ] 7.2 Write property tests for tag display layout

    - **Property 1: Tag Display Layout Consistency**
    - **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.7**

  - [ ] 7.3 Implement tag management functionality
    - Create tag addition/removal during asset creation
    - Implement tag-based search functionality
    - _Requirements: 2.5, 2.6_

- [-] 8. Create Strategies section
  - [x] 8.1 Implement StrategiesSection expandable widget
    - Create expand/collapse functionality with button
    - Add "Add Strategy" button at list start
    - _Requirements: 3.1, 3.2_

  - [x] 8.2 Create TradingStrategyItem widget
    - Implement alert indicator (red/gray alarm clock)
    - Add long/short trade direction display
    - Create click-to-edit functionality
    - _Requirements: 3.4, 3.5, 3.6, 3.7, 3.8_

  - [ ] 8.3 Write property tests for strategy alert indicators

    - **Property 2: Strategy Alert Visual Indicator Consistency**
    - **Validates: Requirements 3.4, 3.5, 3.6, 7.4**

  - [x] 8.4 Create CompositeStrategyItem widget
    - Display composite strategy with logical operators
    - Implement alert functionality for composite strategies
    - _Requirements: 3.10_

- [-] 9. Implement ActiveTrades section
  - [x] 9.1 Create ActiveTradesSection expandable widget
    - Implement expand/collapse functionality
    - Add "Add Trade" button at list start
    - _Requirements: 5.1, 5.2_

  - [x] 9.2 Implement ActiveTradeItem widget
    - Display trade direction, quantity, buy value, and P&L
    - Add notice indicator and action buttons (delete/close)
    - Implement confirmation dialog for delete action
    - _Requirements: 5.3, 5.4, 5.5, 5.8, 5.9, 5.10, 5.11_

  - [ ] 9.3 Write property tests for trade information display

    - **Property 9: Trade Information Display Completeness**
    - **Validates: Requirements 5.3, 5.4, 5.8, 5.9**

  - [x] 9.4 Create trade close functionality
    - Implement sell value input dialog
    - Connect to transaction persistence system
    - _Requirements: 5.12, 5.13_

- [x] 10. Create trade detail management
  - [x] 10.1 Implement TradeDetailPage
    - Create detailed edit page for active trades
    - Display notice text and allow parameter editing
    - Enable stop loss settings modification
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [-] 11. Implement alert system integration
  - [x] 11.1 Create AlertService for strategy notifications
    - Implement alert triggering for strategy goals
    - Support both TradingStrategy and CompositeStrategy alerts
    - Create enable/disable alert functionality
    - _Requirements: 7.1, 7.2, 7.3_

  - [ ] 11.2 Write property tests for alert system

    - **Property 11: Alert System Cross-Strategy Consistency**
    - **Validates: Requirements 7.1, 7.2, 7.3**

- [x] 12. Assemble EnhancedAssetCard widget
  - [x] 12.1 Create main EnhancedAssetCard widget
    - Integrate all four sections (AssetInformation, Tags, Strategies, ActiveTrades)
    - Implement proper section visibility rules
    - Add responsive layout support
    - _Requirements: 1.1, 1.2_

  - [x] 12.2 Write property tests for card section visibility

    - **Property 6: Asset Information Section Visibility**
    - **Validates: Requirements 1.2**

  - [x] 12.3 Integrate with existing watchlist system
    - Replace current AssetCard with EnhancedAssetCard
    - Ensure backward compatibility with existing asset data
    - _Requirements: 1.1_

- [-] 13. Add template management to main menu
  - [ ] 13.1 Create template management UI in main menu
    - Add template access from main menu
    - Implement template browsing and application interface
    - _Requirements: 4.2_

- [-] 14. Final integration and testing
  - [x] 14.1 Integrate enhanced cards with app navigation
    - Ensure proper navigation to edit pages
    - Test all user interaction flows
    - _Requirements: 3.8, 6.1_

  - [-] 14.2 Write integration tests for complete workflows

    - Test strategy creation and alert workflows
    - Test trade lifecycle management
    - Test template creation and application

- [x] 15. Final checkpoint - Ensure all tests pass and functionality works
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- The implementation builds incrementally from models to UI to integration