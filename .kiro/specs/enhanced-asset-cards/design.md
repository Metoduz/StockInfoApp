# Design Document: Enhanced Asset Cards

## Overview

The Enhanced Asset Cards feature transforms the current simple AssetCard widget into a comprehensive asset management interface. The design implements a four-section expandable card structure that provides detailed asset information, tag management, trading strategy tracking, and active trade monitoring within a single, cohesive UI component.

This design leverages Flutter's Material Design 3 principles and expandable UI patterns to create an intuitive, information-dense interface that scales from basic asset viewing to advanced trading management.

## Architecture

### Component Hierarchy

```
EnhancedAssetCard
├── AssetInformationSection (always visible)
│   ├── AssetTypeIcon
│   ├── AssetIdentifiers (Name, ISIN, WKN, Short Name)
│   └── PerformanceMetrics (Daily, Open Trades, All Trades)
├── TagsSection
│   ├── TagChipList (max 2 rows)
│   └── OverflowIndicator ("...")
├── StrategiesSection (expandable)
│   ├── ExpandButton
│   ├── AddStrategyButton
│   └── StrategyList
│       ├── TradingStrategyItem
│       └── CompositeStrategyItem
└── ActiveTradesSection (expandable)
    ├── ExpandButton
    ├── AddTradeButton
    └── TradeList
        └── ActiveTradeItem
```

### State Management

The component uses Flutter's StatefulWidget pattern with the following state variables:

```dart
class _EnhancedAssetCardState extends State<EnhancedAssetCard> {
  bool _strategiesExpanded = false;
  bool _tradesExpanded = false;
  Map<String, bool> _strategyAlerts = {};
  // Additional state for UI interactions
}
```

## Components and Interfaces

### 1. AssetInformationSection

**Purpose**: Display core asset information that's always visible

**Layout**: 
- Left side: Asset identifiers in vertical stack
- Upper left corner: Asset type icon
- Right side: Performance metrics display with three key values

**Key Features**:
- Asset type icons for visual categorization
- Daily performance percentage display
- Open trades total performance for this asset
- All trades (open + closed) total performance for this asset
- Real-time price and performance data
- Responsive layout for different screen sizes

### 2. TagsSection

**Purpose**: Display and manage user-defined asset tags

**Layout**:
- Horizontal flow layout with automatic wrapping
- Maximum 2 rows with overflow indicator
- Chip-based tag display with consistent styling

**Interaction**:
- Tap to edit tags (opens tag management dialog)
- Visual feedback for tag selection/deselection

### 3. StrategiesSection

**Purpose**: Manage trading strategies with alert capabilities

**Components**:

#### TradingStrategyItem
```dart
class TradingStrategyItem {
  final String id;
  final StrategyType type; // Trendline, ElliotWaves, BuyArea, etc.
  final TradeDirection direction; // Long/Short
  final bool alertEnabled;
  final Map<String, dynamic> parameters;
  final DateTime created;
  final DateTime? lastTriggered;
}
```

#### CompositeStrategyItem
```dart
class CompositeStrategyItem {
  final String id;
  final String name;
  final List<StrategyCondition> conditions;
  final LogicalOperator rootOperator; // AND/OR
  final bool alertEnabled;
  final TradeDirection direction;
}

class StrategyCondition {
  final TradingStrategyItem strategy;
  final LogicalOperator? operator; // AND/OR for chaining
}
```

**Visual Elements**:
- Alert status indicator (red/gray alarm clock)
- Trade direction indicator (long/short badge)
- Strategy type icon
- Expandable details on tap

### 4. ActiveTradesSection

**Purpose**: Track and manage open trading positions

**Components**:

#### ActiveTradeItem
```dart
class ActiveTradeItem {
  final String id;
  final String assetId;
  final TradeDirection direction;
  final double quantity;
  final double buyPrice;
  final DateTime openDate;
  final StopLossConfig? stopLoss;
  final String? notice;
  final TradeStatus status;
}

class StopLossConfig {
  final StopLossType type; // Fixed, Trailing
  final double? fixedValue;
  final double? trailingAmount;
  final bool isPercentage;
}
```

**Visual Elements**:
- P&L indicator with color coding (green/red)
- Trade direction badge
- Quantity and entry price display
- Stop loss indicator
- Notice indicator (icon when present)
- Action buttons (Edit, Close, Delete)

## Data Models

### Enhanced AssetItem

Extends the existing AssetItem model:

```dart
class EnhancedAssetItem extends AssetItem {
  final List<String> tags;
  final List<TradingStrategyItem> strategies;
  final List<ActiveTradeItem> activeTrades;
  final List<ClosedTradeItem> closedTrades;
  final AssetType assetType;
  
  // Additional methods for enhanced functionality
  List<String> getFilteredTags({int maxRows = 2, int itemsPerRow = 4});
  bool hasActiveAlerts();
  double getTotalPositionValue();
  double getTotalPnL();
  double getDailyPerformancePercent();
  double getOpenTradesPerformance();
  double getAllTradesPerformance(); // open + closed
}

enum AssetType {
  stock,
  resource,
  cfd,
  crypto,
  other
}
```

### Strategy System

```dart
abstract class TradingStrategy {
  String get id;
  String get name;
  StrategyType get type;
  Map<String, dynamic> get parameters;
  bool checkTriggerCondition(AssetItem asset);
}

class TrendlineStrategy extends TradingStrategy {
  final double supportLevel;
  final double resistanceLevel;
  final TrendDirection trend;
  
  @override
  bool checkTriggerCondition(AssetItem asset) {
    // Implementation for trendline trigger logic
  }
}

class BuyAreaStrategy extends TradingStrategy {
  final double upperBound;
  final double idealArea;
  final double lowerBound;
  
  @override
  bool checkTriggerCondition(AssetItem asset) {
    // Implementation for buy area trigger logic
  }
}
```

### Template System

```dart
class StrategyTemplate {
  final String id;
  final String name;
  final String description;
  final List<StrategyCondition> conditions;
  final LogicalOperator rootOperator;
  final DateTime created;
  final int usageCount;
}

class TemplateManager {
  static List<StrategyTemplate> getAvailableTemplates();
  static void saveTemplate(CompositeStrategyItem strategy, String name);
  static CompositeStrategyItem applyTemplate(String templateId, String assetId);
}
```

## User Interface Design

### Visual Hierarchy

1. **Primary Level**: Asset information (always visible)
2. **Secondary Level**: Tags (compact, scannable)
3. **Tertiary Level**: Strategies and Trades (expandable, detailed)

### Material Design 3 Integration

- **Cards**: Elevated cards with rounded corners (12dp radius)
- **Colors**: Dynamic color theming with semantic color roles
- **Typography**: Material 3 type scale (headlineSmall, bodyMedium, etc.)
- **Elevation**: Subtle shadows for depth perception
- **Motion**: Smooth expand/collapse animations

### Responsive Design

```dart
class ResponsiveAssetCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }
}
```

### Accessibility Features

- Semantic labels for screen readers
- Sufficient color contrast ratios
- Touch target sizes (minimum 44dp)
- Focus management for keyboard navigation
- Haptic feedback for important actions

## Error Handling

### Strategy Validation

```dart
class StrategyValidator {
  static ValidationResult validateStrategy(TradingStrategy strategy) {
    // Validate strategy parameters
    // Check for conflicting conditions
    // Ensure required fields are present
  }
}
```

### Trade Management Errors

- Invalid trade parameters (negative quantities, invalid prices)
- Network errors during trade operations
- Data synchronization conflicts
- Stop loss validation errors

### User Feedback

- Toast messages for quick feedback
- Error dialogs for critical issues
- Loading states during async operations
- Retry mechanisms for failed operations

## Testing Strategy

### Unit Testing

**Core Logic Tests**:
- Strategy trigger condition evaluation
- P&L calculations
- Tag filtering and display logic
- Template save/load operations

**Model Tests**:
- Data model validation
- Serialization/deserialization
- State transitions
- Business rule enforcement

### Widget Testing

**UI Component Tests**:
- Card expansion/collapse behavior
- Tag overflow handling
- Alert indicator updates
- Responsive layout adaptation

**Interaction Tests**:
- Button tap responses
- Dialog opening/closing
- Form validation
- Navigation flows

### Integration Testing

**End-to-End Flows**:
- Complete strategy creation workflow
- Trade lifecycle management
- Template creation and application
- Alert system integration

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

The following correctness properties will be validated through property-based testing:

#### Property 1: Tag Display Layout Consistency
*For any* list of tags and available display width, the tag layout should flow horizontally with automatic wrapping, display a maximum of 2 rows, and show an overflow indicator ("...") when tags exceed the display capacity.
**Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.7**

#### Property 2: Strategy Alert Visual Indicator Consistency  
*For any* strategy with alert configuration, the alarm clock symbol color should always accurately reflect the alert enabled state (red for enabled, gray for disabled) and be toggleable by user interaction.
**Validates: Requirements 3.4, 3.5, 3.6, 7.4**

#### Property 3: Trade P&L Calculation Accuracy
*For any* active trade with current market price, the calculated profit/loss percentage and absolute values should be mathematically consistent with the entry price, quantity, and trade direction.
**Validates: Requirements 5.5**

#### Property 4: Composite Strategy Logic Evaluation
*For any* composite strategy with multiple conditions and logical operators, the overall trigger evaluation should correctly apply boolean logic (AND/OR) to individual strategy results.
**Validates: Requirements 3.10**

#### Property 5: Strategy Template Round-Trip Integrity
*For any* composite strategy saved as a template and then applied to a new asset, the resulting strategy should preserve all logical operators, condition relationships, and strategy parameters from the original.
**Validates: Requirements 4.1, 4.3, 4.4**

#### Property 6: Asset Information Section Visibility
*For any* card state configuration, the asset information section should always remain visible regardless of the expansion state of other sections.
**Validates: Requirements 1.2**

#### Property 7: Asset Type Support Consistency
*For any* supported asset type (Stocks, Resources, CFD, Crypto, Other), the system should correctly display the appropriate type symbol and handle the asset consistently across all card functions.
**Validates: Requirements 1.5, 3.9**

#### Property 8: Stop Loss Configuration Validation
*For any* stop loss configuration (fixed or trailing), the validation should consistently accept valid configurations and reject invalid ones based on trade direction, current market price, and mathematical constraints.
**Validates: Requirements 5.6, 5.7**

#### Property 9: Trade Information Display Completeness
*For any* active trade, the trade item should display all required information (direction indicator, quantity, buy value, current P&L) and show the notice indicator only when a notice is present.
**Validates: Requirements 5.3, 5.4, 5.8, 5.9**

#### Property 10: Transaction Persistence Completeness
*For any* trade that is closed, all trade details (buy price, sell price, quantity, dates, P&L) should be completely and accurately saved as transaction data for performance metrics.
**Validates: Requirements 5.13, 9.1, 9.2, 9.3**

#### Property 11: Alert System Cross-Strategy Consistency
*For any* strategy type (TradingStrategy or CompositeStrategy) with alerts enabled, when the strategy conditions are met, the system should consistently trigger alert notifications.
**Validates: Requirements 7.1, 7.2, 7.3**

#### Property 12: Performance Metrics Calculation Accuracy
*For any* asset with associated trades, the displayed performance metrics (daily performance, open trades performance, all trades performance) should be mathematically consistent with the underlying trade data and current market prices.
**Validates: Requirements 1.7, 1.8, 1.9**

### Testing Framework Configuration

- **Unit Tests**: Standard Flutter test framework
- **Property Tests**: Using `test` package with custom generators
- **Widget Tests**: Flutter widget testing framework
- **Integration Tests**: Flutter integration test package

**Property Test Configuration**:
- Minimum 100 iterations per property test
- Custom generators for financial data (prices, quantities, percentages)
- Edge case generators for boundary conditions
- Each property test tagged with: **Feature: enhanced-asset-cards, Property {number}: {description}**

## Performance Considerations

### Optimization Strategies

1. **Lazy Loading**: Load strategy and trade details only when sections are expanded
2. **Widget Recycling**: Reuse widgets in scrollable lists
3. **Efficient Rebuilds**: Use const constructors and selective rebuilding
4. **Memory Management**: Dispose of controllers and subscriptions properly

### Caching Strategy

```dart
class AssetDataCache {
  static final Map<String, EnhancedAssetItem> _cache = {};
  static final Duration _cacheTimeout = Duration(minutes: 5);
  
  static EnhancedAssetItem? getCachedAsset(String assetId);
  static void cacheAsset(EnhancedAssetItem asset);
  static void invalidateCache(String assetId);
}
```

### Animation Performance

- Use `AnimatedContainer` for smooth transitions
- Implement custom `Tween` classes for complex animations
- Optimize animation curves for natural motion
- Reduce animation complexity on lower-end devices

## Security Considerations

### Data Protection

- Encrypt sensitive trading data at rest
- Secure transmission of strategy parameters
- Validate all user inputs to prevent injection attacks
- Implement proper authentication for strategy templates

### Privacy

- Local storage of personal trading strategies
- Optional cloud sync with user consent
- Anonymized usage analytics
- Clear data retention policies

## Future Extensibility

### Plugin Architecture

```dart
abstract class StrategyPlugin {
  String get name;
  String get version;
  List<StrategyType> get supportedTypes;
  
  TradingStrategy createStrategy(Map<String, dynamic> config);
  Widget buildConfigurationUI();
}
```

### API Integration Points

- External strategy signal providers
- Real-time market data feeds
- Social trading platform integration
- Portfolio management system APIs

### Customization Framework

- Theme customization for card appearance
- Configurable section visibility
- Custom strategy parameter sets
- Personalized alert preferences

This design provides a comprehensive foundation for implementing the enhanced AssetCard feature while maintaining flexibility for future enhancements and ensuring a robust, user-friendly trading management interface.