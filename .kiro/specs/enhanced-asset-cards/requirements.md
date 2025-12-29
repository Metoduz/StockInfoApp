# Requirements Document

## Introduction

This specification defines the enhanced AssetCard component for the Stock Info App. The enhanced AssetCard will provide a comprehensive interface for managing individual assets with detailed information, tags, trading strategies, and active trades management.

## Glossary

- **AssetCard**: The main UI component displaying asset information and management features
- **TradingStrategy**: A specific trading strategy (e.g., Trendline, Elliott Waves, Buy Area)
- **CompositeStrategy**: A combination of multiple TradingStrategies connected with logical operators
- **ActiveTrade**: A currently open trading position with buy/sell tracking
- **Tag**: User-defined labels for categorizing and searching assets
- **Alert**: Notification system for strategy goal achievements
- **StopLoss**: Risk management feature for limiting losses on trades
- **TrailingStop**: Dynamic stop loss that follows price movements

## Requirements

### Requirement 1: Enhanced AssetCard Structure

**User Story:** As an investor, I want to see comprehensive asset information in a structured card layout, so that I can quickly assess all relevant details about my investments.

#### Acceptance Criteria

1. THE AssetCard SHALL be divided into four distinct sections: AssetInformation, Tags, Strategies, and ActiveTrades
2. THE AssetInformation section SHALL always be visible in the watchlist
3. THE AssetInformation section SHALL display Name, ISIN, WKN, and short name on the left side
4. THE AssetInformation section SHALL display an asset type symbol in the upper left corner
5. THE AssetInformation section SHALL support asset types: Stocks, Resources, CFD, Crypto, and other types
6. THE AssetInformation section SHALL display performance metrics on the right side
7. THE performance metrics SHALL include daily performance percentage
8. THE performance metrics SHALL include total performance of all open trades for this asset
9. THE performance metrics SHALL include total performance of all trades (open and closed) for this asset

### Requirement 2: Tag Management System

**User Story:** As an investor, I want to add and manage tags for my assets, so that I can categorize and search for assets efficiently.

#### Acceptance Criteria

1. THE Tags section SHALL display user-defined tags in a horizontal flow layout
2. WHEN tags exceed the available width, THE system SHALL flow tags to the next row
3. THE Tags section SHALL display a maximum of 2 rows of tags
4. WHEN tags exceed 2 rows, THE system SHALL display "..." to indicate more tags exist
5. THE user SHALL be able to add tags during asset creation
6. THE user SHALL be able to search assets by tags
7. THE tags SHALL be displayed side by side with automatic wrapping

### Requirement 3: Trading Strategies Management

**User Story:** As an investor, I want to define and manage trading strategies for each asset, so that I can systematically track my trading approach and receive alerts.

#### Acceptance Criteria

1. THE Strategies section SHALL contain an expandable list activated by a button
2. THE Strategies list SHALL start with an "Add Strategy" button
3. THE system SHALL support two strategy types: TradingStrategy and CompositeStrategy as parent
4. WHEN a strategy has alerts enabled, THE system SHALL display a red alarm clock symbol
5. WHEN a strategy has alerts disabled, THE system SHALL display a gray alarm clock symbol
6. THE user SHALL be able to toggle alerts by clicking the alarm clock symbol
7. THE strategy item SHALL display whether it's a long or short trade
8. WHEN a strategy item is clicked, THE system SHALL open an edit page
9. THE system SHALL support strategy types including: Trendline, Elliott Waves, Buy Area
10. THE CompositeStrategy SHALL allow combination of multiple TradingStrategies or CompositeStrategies with AND/OR operators

### Requirement 4: Composite Strategy Templates

**User Story:** As an investor, I want to save composite strategy combinations as templates, so that I can reuse successful strategy patterns across different assets.

#### Acceptance Criteria

1. THE system SHALL allow saving CompositeStrategy conjunctions as templates
2. THE templates SHALL be accessible from the main menu
3. THE user SHALL be able to apply saved templates to new assets
4. THE templates SHALL preserve the logical operator combinations (AND/OR)

### Requirement 5: Active Trades Management

**User Story:** As an investor, I want to track my active trades with detailed information and risk management features, so that I can monitor my current positions effectively.

#### Acceptance Criteria

1. THE ActiveTrades section SHALL contain an expandable list activated by a button
2. THE ActiveTrades list SHALL start with an "Add Trade" button
3. THE trade item SHALL display long/short trade indicator
4. THE trade item SHALL display quantity and buy value
5. THE trade item SHALL display current winnings/losses in percentage and total amount
6. THE trade item SHALL support stop loss configuration with fixed value option
7. THE trade item SHALL support trailing stop loss with value or percentage
8. THE trade item SHALL support alerts for the stop loss like in the strategies with enabling/disabling feature
9. THE trade item SHALL include a notice section with symbol indicator when filled
10. THE notice text SHALL NOT be visible in the card view
11. THE trade item SHALL include delete and close buttons on the right side
12. WHEN delete is clicked, THE system SHALL show a confirmation dialog
13. WHEN close is clicked, THE user SHALL be able to enter the sell value
14. THE closed trade information SHALL be saved as a transaction for performance metrics
15. EACH new trade item SHALL be included in the transaction view for performance metrics

### Requirement 6: Trade Detail Management

**User Story:** As an investor, I want to view and edit detailed information about my active trades, so that I can manage my positions comprehensively.

#### Acceptance Criteria

1. WHEN an active trade is clicked, THE system SHALL open a detailed edit page
2. THE detail page SHALL display the notice text
3. THE detail page SHALL allow editing all trade parameters
4. THE detail page SHALL allow modification of stop loss settings
5. THE detail page SHALL allow updating trade notices

### Requirement 7: Alert System Integration

**User Story:** As an investor, I want to receive alerts when my trading strategy goals or stop losses are reached, so that I can take timely action on my investments.

#### Acceptance Criteria

1. WHEN a strategy goal is reached, THE system SHALL send an alert notification
2. WHEN a stop loss is reached, THE system SHALL send an alert notification
3. THE alert system SHALL work for both TradingStrategy and CompositeStrategy types
4. THE user SHALL be able to enable/disable alerts per strategy
5. THE alert status SHALL be visually indicated by the alarm clock symbol color
6. THE alert system SHALL work for stop losses in active trades
7. THE user SHALL be able to enable/disable alerts per active trade stop loss

### Requirement 8: Strategy File Organization

**User Story:** As a developer, I want trading strategies organized in a dedicated folder structure, so that the codebase remains maintainable and extensible.

#### Acceptance Criteria

1. THE system SHALL create a dedicated strategies folder
2. THE strategies folder SHALL contain individual strategy implementations
3. THE strategy implementations SHALL include: Trendline, Elliott Waves, Buy Area
4. THE strategy system SHALL be extensible for future strategy types
5. THE strategy SHALL be based on the parent TradingStrategy

### Requirement 9: Transaction History Integration

**User Story:** As an investor, I want my opened and closed trades to be automatically recorded for performance analysis, so that I can track my overall trading success.

#### Acceptance Criteria

1. WHEN a trade is opened, THE system SHALL save the call information
2. WHEN a trade is closed, THE system SHALL save buy and sell information and set the trade as closed
3. THE transaction data SHALL be stored for performance metrics calculation
4. THE closed transactions SHALL include all relevant trade details
5. THE transaction history SHALL support overall performance analytics