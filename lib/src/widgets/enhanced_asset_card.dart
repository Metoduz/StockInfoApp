import 'package:flutter/material.dart';
import '../models/asset_item.dart';
import '../strategies/trading_strategy_base.dart';
import '../models/active_trade.dart';
import 'asset_information_section.dart';
import 'tags_section.dart';
import 'strategies_section.dart';
import 'active_trades_section.dart';

/// Enhanced AssetCard widget that integrates all four sections:
/// AssetInformation, Tags, Strategies, and ActiveTrades
/// 
/// The AssetInformation section is always visible, while other sections
/// can be expanded/collapsed based on user interaction and content availability.
class EnhancedAssetCard extends StatefulWidget {
  final AssetItem asset;
  final VoidCallback? onTap;
  final Function(AssetItem)? onAssetUpdated;
  final VoidCallback? onAddStrategy;
  final VoidCallback? onAddTrade;
  final Function(TradingStrategyItem)? onStrategyTap;
  final Function(String)? onStrategyDelete;
  final Function(String, bool)? onAlertToggle;
  final Function(ActiveTradeItem)? onTradeEdit;
  final Function(ActiveTradeItem)? onTradeDelete;
  final Function(ActiveTradeItem)? onTradeClose;

  const EnhancedAssetCard({
    super.key,
    required this.asset,
    this.onTap,
    this.onAssetUpdated,
    this.onAddStrategy,
    this.onAddTrade,
    this.onStrategyTap,
    this.onStrategyDelete,
    this.onAlertToggle,
    this.onTradeEdit,
    this.onTradeDelete,
    this.onTradeClose,
  });

  @override
  State<EnhancedAssetCard> createState() => _EnhancedAssetCardState();
}

class _EnhancedAssetCardState extends State<EnhancedAssetCard> {
  bool _strategiesExpanded = false;
  bool _activeTradesExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive design: different layouts for different screen sizes
        if (constraints.maxWidth > 600) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  /// Build layout optimized for mobile devices
  Widget _buildMobileLayout() {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AssetInformation section - always visible (Requirement 1.2)
          // Wrapped in InkWell to handle navigation only for this section
          InkWell(
            onTap: widget.onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AssetInformationSection(asset: widget.asset),
          ),
          
          // Divider between sections
          _buildSectionDivider(theme),
          
          // Tags section - visible if tags exist or management is enabled
          if (_shouldShowTagsSection())
            TagsSection(
              asset: widget.asset,
              onAssetUpdated: widget.onAssetUpdated,
              enableManagement: true,
            ),
          
          // Expand/collapse buttons in their own row below tags
          if (_shouldShowStrategiesSection() || _shouldShowActiveTradesSection()) ...[
            _buildSectionDivider(theme),
            _buildExpandCollapseButtons(theme),
            
            // Strategies section - expandable
            if (_shouldShowStrategiesSection() && _strategiesExpanded)
              StrategiesSection(
                asset: widget.asset,
                onAssetUpdated: widget.onAssetUpdated,
                onAddStrategy: widget.onAddStrategy,
                onStrategyTap: widget.onStrategyTap,
                onStrategyDelete: widget.onStrategyDelete,
                onAlertToggle: widget.onAlertToggle,
                isExpanded: true,
              ),
            
            // ActiveTrades section - expandable
            if (_shouldShowActiveTradesSection() && _activeTradesExpanded)
              ActiveTradesSection(
                asset: widget.asset,
                activeTrades: widget.asset.activeTrades,
                onAddTrade: widget.onAddTrade,
                onTradeEdit: widget.onTradeEdit,
                onTradeDelete: widget.onTradeDelete,
                onTradeClose: widget.onTradeClose,
                isExpanded: true,
              ),
          ],
        ],
      ),
    );
  }

  /// Build layout optimized for tablet devices
  Widget _buildTabletLayout() {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AssetInformation section - always visible (Requirement 1.2)
            // Wrapped in InkWell to handle navigation only for this section
            InkWell(
              onTap: widget.onTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AssetInformationSection(asset: widget.asset),
            ),
            
            // Horizontal layout for Tags and other sections on tablets
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: Tags
                if (_shouldShowTagsSection())
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _buildSectionDivider(theme),
                        TagsSection(
                          asset: widget.asset,
                          onAssetUpdated: widget.onAssetUpdated,
                          enableManagement: true,
                        ),
                      ],
                    ),
                  ),
                
                // Right column: Empty space for balance
                if (_shouldShowTagsSection())
                  Expanded(
                    flex: 2,
                    child: Container(),
                  ),
              ],
            ),
            
            // Expand/collapse buttons in their own row below tags
            if (_shouldShowStrategiesSection() || _shouldShowActiveTradesSection()) ...[
              _buildSectionDivider(theme),
              _buildExpandCollapseButtons(theme),
              
              // Strategies section - expandable
              if (_shouldShowStrategiesSection() && _strategiesExpanded)
                StrategiesSection(
                  asset: widget.asset,
                  onAssetUpdated: widget.onAssetUpdated,
                  onAddStrategy: widget.onAddStrategy,
                  onStrategyTap: widget.onStrategyTap,
                  onStrategyDelete: widget.onStrategyDelete,
                  onAlertToggle: widget.onAlertToggle,
                  isExpanded: true,
                ),
              
              // ActiveTrades section - expandable
              if (_shouldShowActiveTradesSection() && _activeTradesExpanded)
                ActiveTradesSection(
                  asset: widget.asset,
                  activeTrades: widget.asset.activeTrades,
                  onAddTrade: widget.onAddTrade,
                  onTradeEdit: widget.onTradeEdit,
                  onTradeDelete: widget.onTradeDelete,
                  onTradeClose: widget.onTradeClose,
                  isExpanded: true,
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build expand/collapse buttons at the top of expandable sections
  Widget _buildExpandCollapseButtons(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Strategies expand/collapse button
          if (_shouldShowStrategiesSection())
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_strategiesExpanded) {
                      _strategiesExpanded = false;
                    } else {
                      _strategiesExpanded = true;
                      _activeTradesExpanded = false; // Collapse the other section
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedRotation(
                        turns: _strategiesExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Strategies',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.asset.strategies.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.asset.strategies.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          
          // Divider between buttons
          if (_shouldShowStrategiesSection() && _shouldShowActiveTradesSection())
            Container(
              height: 40,
              width: 1,
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          
          // ActiveTrades expand/collapse button
          if (_shouldShowActiveTradesSection())
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (_activeTradesExpanded) {
                      _activeTradesExpanded = false;
                    } else {
                      _activeTradesExpanded = true;
                      _strategiesExpanded = false; // Collapse the other section
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedRotation(
                        turns: _activeTradesExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Active Trades',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.asset.activeTrades.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${widget.asset.activeTrades.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build a subtle divider between sections
  Widget _buildSectionDivider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
      indent: 16,
      endIndent: 16,
    );
  }

  /// Determine if the Tags section should be shown
  /// Shows if there are tags or if management is enabled
  bool _shouldShowTagsSection() {
    return widget.asset.tags.isNotEmpty || widget.onAssetUpdated != null;
  }

  /// Determine if the Strategies section should be shown
  /// Shows if there are strategies or if add functionality is available
  bool _shouldShowStrategiesSection() {
    return widget.asset.strategies.isNotEmpty || widget.onAddStrategy != null;
  }

  /// Determine if the ActiveTrades section should be shown
  /// Shows if there are active trades or if add functionality is available
  bool _shouldShowActiveTradesSection() {
    return widget.asset.activeTrades.isNotEmpty || widget.onAddTrade != null;
  }
}