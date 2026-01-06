import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../strategies/trading_strategy_base.dart';

/// A custom dropdown widget for selecting strategy categories and types
/// Features a two-panel interface with categories on the left and strategies on the right
class CategorySelector extends StatefulWidget {
  final StrategyCategory? selectedCategory;
  final StrategyType? selectedStrategy;
  final Function(StrategyCategory) onCategoryChanged;
  final Function(StrategyType) onStrategyChanged;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    this.selectedStrategy,
    required this.onCategoryChanged,
    required this.onStrategyChanged,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  bool _isExpanded = false;
  StrategyCategory? _currentCategory;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  
  // Focus management for accessibility
  late final FocusNode _triggerFocusNode;
  late final FocusNode _categoryPanelFocusNode;
  late final FocusNode _strategyPanelFocusNode;

  @override
  void initState() {
    super.initState();
    // Default to first category if none selected
    _currentCategory = widget.selectedCategory ?? StrategyCategory.values.first;
    
    // Initialize focus nodes
    _triggerFocusNode = FocusNode();
    _categoryPanelFocusNode = FocusNode();
    _strategyPanelFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _removeOverlay();
    _triggerFocusNode.dispose();
    _categoryPanelFocusNode.dispose();
    _strategyPanelFocusNode.dispose();
    super.dispose();
  }

  /// Toggle the dropdown expansion state
  void _toggleDropdown() {
    if (_isExpanded) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  /// Open the dropdown overlay
  void _openDropdown() {
    setState(() {
      _isExpanded = true;
    });

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    
    // Announce dropdown opened for screen readers
    SemanticsService.announce(
      'Strategy selector opened. Use arrow keys to navigate categories and strategies.',
      TextDirection.ltr,
    );
    
    // Focus the category panel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _categoryPanelFocusNode.requestFocus();
    });
  }

  /// Close the dropdown overlay
  void _closeDropdown() {
    setState(() {
      _isExpanded = false;
    });
    _removeOverlay();
    
    // Return focus to trigger
    _triggerFocusNode.requestFocus();
    
    // Announce dropdown closed
    SemanticsService.announce(
      'Strategy selector closed.',
      TextDirection.ltr,
    );
  }

  /// Remove the overlay entry
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Create the overlay entry for the dropdown panel
  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final screenPadding = MediaQuery.of(context).padding;
    
    // Calculate available space
    final availableWidth = screenSize.width - 32; // 16px padding on each side
    final availableHeight = screenSize.height - screenPadding.top - screenPadding.bottom - 100;
    
    // Determine dropdown width (minimum 280, maximum available width, prefer trigger width)
    final dropdownWidth = (size.width < 280) 
        ? (availableWidth < 280 ? availableWidth : 280.0)
        : (size.width > availableWidth ? availableWidth : size.width);
    
    // Determine dropdown height based on screen size
    final dropdownHeight = availableHeight < 300 
        ? (availableHeight < 200 ? availableHeight : availableHeight)
        : 300.0;
    
    // Calculate position to keep dropdown on screen
    double left = offset.dx;
    double top = offset.dy + size.height + 4;
    
    // Adjust horizontal position if dropdown would go off screen
    if (left + dropdownWidth > screenSize.width - 16) {
      left = screenSize.width - dropdownWidth - 16;
    }
    if (left < 16) {
      left = 16;
    }
    
    // Adjust vertical position if dropdown would go off screen
    if (top + dropdownHeight > screenSize.height - screenPadding.bottom - 16) {
      // Show above the trigger if there's more space
      final spaceAbove = offset.dy - screenPadding.top - 16;
      final spaceBelow = screenSize.height - screenPadding.bottom - (offset.dy + size.height) - 16;
      
      if (spaceAbove > spaceBelow && spaceAbove > 150) {
        top = offset.dy - dropdownHeight - 4;
      } else {
        // Keep below but position at bottom of available space
        top = offset.dy + size.height + 4;
      }
    }

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier that closes dropdown when tapped, but excludes trigger area
          Positioned.fill(
            child: GestureDetector(
              onTapDown: (details) {
                final tapPosition = details.globalPosition;
                
                // Define trigger button area
                final triggerRect = Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
                
                // Define dropdown area
                final dropdownRect = Rect.fromLTWH(left, top, dropdownWidth, dropdownHeight);
                
                // Only close if tap is outside both areas
                if (!triggerRect.contains(tapPosition) && !dropdownRect.contains(tapPosition)) {
                  _closeDropdown();
                }
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // The actual dropdown
          Positioned(
            left: left,
            top: top,
            width: dropdownWidth,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: dropdownHeight,
                    minHeight: dropdownHeight < 200 ? dropdownHeight : 200,
                    maxWidth: dropdownWidth,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: _buildDropdownContent(dropdownWidth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the two-panel dropdown content
  Widget _buildDropdownContent(double availableWidth) {
    // Determine if we should show compact category view (icon only)
    final isCompact = availableWidth < 320;
    
    return Row(
      children: [
        // Left panel - Categories
        Expanded(
          flex: isCompact ? 1 : 2,
          child: _buildCategoryPanel(isCompact),
        ),
        // Divider
        Container(
          width: 1,
          color: Theme.of(context).colorScheme.outline,
        ),
        // Right panel - Strategies
        Expanded(
          flex: isCompact ? 3 : 3,
          child: _buildStrategyPanel(),
        ),
      ],
    );
  }

  /// Build the left panel with category list
  Widget _buildCategoryPanel(bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCompact)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Categories',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: StrategyCategory.values.length,
              itemBuilder: (context, index) {
                final category = StrategyCategory.values[index];
                final isSelected = category == _currentCategory;

                return _buildCategoryItem(category, isSelected, isCompact);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single category item
  Widget _buildCategoryItem(StrategyCategory category, bool isSelected, bool isCompact) {
    return Semantics(
      label: '${category.displayName} category. ${category.strategies.length} strategies available.',
      button: true,
      selected: isSelected,
      child: InkWell(
        onTap: () => _selectCategory(category),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12, 
            vertical: 8
          ),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: isCompact 
              ? Center(
                  child: Icon(
                    category.icon,
                    size: 24,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                    semanticLabel: '${category.displayName} icon',
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      category.icon,
                      size: 20,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                      semanticLabel: '${category.displayName} icon',
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w500 : null,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Build the right panel with strategy list
  Widget _buildStrategyPanel() {
    final strategies = _currentCategory?.strategies ?? [];

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Strategies',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: strategies.isEmpty
                ? Center(
                    child: Text(
                      'No strategies available',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: strategies.length,
                    itemBuilder: (context, index) {
                      final strategy = strategies[index];
                      return _buildStrategyItem(strategy);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build a single strategy item
  Widget _buildStrategyItem(StrategyType strategy) {
    return Semantics(
      label: '${strategy.displayName} strategy. Select to configure this strategy.',
      button: true,
      child: InkWell(
        onTap: () => _selectStrategy(strategy),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            strategy.displayName,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ),
    );
  }

  /// Handle category selection
  void _selectCategory(StrategyCategory category) {
    setState(() {
      _currentCategory = category;
    });
    widget.onCategoryChanged(category);
    
    // Rebuild the overlay with the new category
    if (_isExpanded && _overlayEntry != null) {
      _removeOverlay();
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
    
    // Announce category selection
    SemanticsService.announce(
      'Category ${category.displayName} selected. ${category.strategies.length} strategies available.',
      TextDirection.ltr,
    );
  }

  /// Handle strategy selection and close dropdown
  void _selectStrategy(StrategyType strategy) {
    widget.onStrategyChanged(strategy);
    _closeDropdown();
    
    // Announce strategy selection
    SemanticsService.announce(
      'Strategy ${strategy.displayName} selected.',
      TextDirection.ltr,
    );
  }

  /// Get the display text for the dropdown trigger
  String get _displayText {
    if (widget.selectedStrategy != null) {
      return widget.selectedStrategy!.displayName;
    }
    return 'Strategy';
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Semantics(
        label: widget.selectedStrategy != null 
            ? 'Strategy selector. Currently selected: ${widget.selectedStrategy!.displayName}'
            : 'Strategy selector. No strategy selected',
        button: true,
        expanded: _isExpanded,
        child: InkWell(
          focusNode: _triggerFocusNode,
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isExpanded 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: _isExpanded ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _displayText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: widget.selectedStrategy != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  semanticLabel: _isExpanded ? 'Collapse dropdown' : 'Expand dropdown',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}