import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '../models/asset_item.dart';
import '../strategies/trading_strategy_base.dart';
import '../strategies/trendline_strategy.dart';
import '../strategies/buy_area_strategy.dart';
import '../strategies/elliot_waves_strategy.dart';
import '../strategies/composite_strategy.dart';
import 'category_selector.dart';
import 'dynamic_strategy_form.dart';

/// Custom exception for strategy creation errors
class StrategyCreationException implements Exception {
  final String message;
  const StrategyCreationException(this.message);
  
  @override
  String toString() => 'StrategyCreationException: $message';
}

/// Custom exception for storage-related errors
class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
  
  @override
  String toString() => 'StorageException: $message';
}

/// Main dialog widget for creating new trading strategies
/// Features modal behavior, asset context display, and integrated form components
class StrategyCreationDialog extends StatefulWidget {
  final AssetItem asset;
  final Function(TradingStrategyItem) onStrategyCreated;

  const StrategyCreationDialog({
    super.key,
    required this.asset,
    required this.onStrategyCreated,
  });

  @override
  State<StrategyCreationDialog> createState() => _StrategyCreationDialogState();

  /// Show the strategy creation dialog as a modal overlay
  static Future<void> show({
    required BuildContext context,
    required AssetItem asset,
    required Function(TradingStrategyItem) onStrategyCreated,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return StrategyCreationDialog(
          asset: asset,
          onStrategyCreated: onStrategyCreated,
        );
      },
    );
  }
}

class _StrategyCreationDialogState extends State<StrategyCreationDialog> {
  // State variables for dialog management
  StrategyCategory? _selectedCategory;
  StrategyType? _selectedStrategyType;
  final Map<String, dynamic> _formData = {};
  final Map<String, String> _validationErrors = {};
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Accessibility focus management
  late final FocusNode _dialogFocusNode;
  late final FocusNode _closeButtonFocusNode;
  late final FocusNode _createButtonFocusNode;
  late final FocusNode _cancelButtonFocusNode;

  @override
  void initState() {
    super.initState();
    // Default to first category
    _selectedCategory = StrategyCategory.values.first;
    
    // Initialize focus nodes for accessibility
    _dialogFocusNode = FocusNode();
    _closeButtonFocusNode = FocusNode();
    _createButtonFocusNode = FocusNode();
    _cancelButtonFocusNode = FocusNode();
    
    // Set initial focus to dialog after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialFocus();
      _announceDialogOpened();
    });
  }

  @override
  void dispose() {
    // Dispose focus nodes
    _dialogFocusNode.dispose();
    _closeButtonFocusNode.dispose();
    _createButtonFocusNode.dispose();
    _cancelButtonFocusNode.dispose();
    super.dispose();
  }

  /// Set initial focus for accessibility
  void _setInitialFocus() {
    if (mounted) {
      _dialogFocusNode.requestFocus();
    }
  }

  /// Announce dialog opened for screen readers
  void _announceDialogOpened() {
    if (mounted) {
      SemanticsService.announce(
        'Strategy creation dialog opened for ${widget.asset.name}. Use tab to navigate between fields.',
        TextDirection.ltr,
      );
    }
  }

  /// Announce state changes for screen readers
  void _announceStateChange(String message) {
    if (mounted) {
      SemanticsService.announce(message, TextDirection.ltr);
    }
  }

  /// Handle category selection changes
  void _onCategoryChanged(StrategyCategory category) {
    setState(() {
      _selectedCategory = category;
      // Clear strategy selection when category changes
      if (_selectedStrategyType?.category != category) {
        _selectedStrategyType = null;
        _formData.clear();
        _validationErrors.clear();
      }
    });
    
    // Announce category change for screen readers
    _announceStateChange('Category changed to ${category.displayName}');
  }

  /// Handle strategy type selection changes
  void _onStrategyChanged(StrategyType strategyType) {
    setState(() {
      _selectedStrategyType = strategyType;
      _selectedCategory = strategyType.category;
      // Form will be cleared and reset by DynamicStrategyForm
      _validationErrors.clear();
    });
    
    // Announce strategy selection for screen readers
    _announceStateChange('Strategy selected: ${strategyType.displayName}. Form fields updated.');
  }

  /// Handle form field value changes
  void _onFieldChanged(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
      // Clear validation error for this field
      _validationErrors.remove(key);
    });
  }

  /// Handle form state changes (validation updates)
  void _onFormChanged() {
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _updateValidationErrors();
        });
      }
    });
  }

  /// Update validation errors based on current form state
  void _updateValidationErrors() {
    if (_selectedStrategyType != null) {
      final errors = DynamicStrategyFormValidation.getValidationErrors(
        strategyType: _selectedStrategyType,
        formData: _formData,
      );
      _validationErrors.clear();
      _validationErrors.addAll(errors);
    }
  }

  /// Check if the form is valid and can be submitted
  bool get _isFormValid {
    return _selectedStrategyType != null &&
           DynamicStrategyFormValidation.isFormValid(
             strategyType: _selectedStrategyType,
             formData: _formData,
           ) &&
           _validationErrors.isEmpty;
  }

  /// Handle form submission and strategy creation
  Future<void> _handleSubmit() async {
    if (!_isFormValid || _selectedStrategyType == null) {
      _showValidationErrorSnackBar();
      _announceStateChange('Form has validation errors. Please fix them before creating the strategy.');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    
    // Announce loading state
    _announceStateChange('Creating strategy. Please wait.');

    try {
      // Validate form one more time before submission
      final validationErrors = DynamicStrategyFormValidation.getValidationErrors(
        strategyType: _selectedStrategyType,
        formData: _formData,
      );
      
      if (validationErrors.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _validationErrors.clear();
          _validationErrors.addAll(validationErrors);
        });
        _showValidationErrorSnackBar();
        _announceStateChange('Validation failed. Please fix the errors.');
        return;
      }

      // Create strategy instance using factory method
      final strategy = _createStrategyInstance();
      
      // Create strategy item wrapper
      final strategyItem = TradingStrategyItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        strategy: strategy,
        direction: TradeDirection.long, // Default direction
        alertEnabled: false,
        created: DateTime.now(),
      );

      // Simulate potential storage operation with error handling
      await _persistStrategy(strategyItem);

      // Call success callback with the strategy item
      widget.onStrategyCreated(strategyItem);

      // Close dialog with success
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar(strategy.name);
        _announceStateChange('Strategy ${strategy.name} created successfully. Dialog closed.');
      }
    } on StrategyCreationException catch (e) {
      // Handle specific strategy creation errors
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Strategy Creation Error', e.message);
        _announceStateChange('Strategy creation failed: ${e.message}');
      }
    } on StorageException catch (e) {
      // Handle storage-related errors
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Storage Error', e.message);
        _announceStateChange('Storage error: ${e.message}');
      }
    } catch (error) {
      // Handle unexpected errors
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Unexpected Error', 'An unexpected error occurred: ${error.toString()}');
        _announceStateChange('Unexpected error occurred. Please try again.');
      }
    }
  }

  /// Simulate strategy persistence with error handling
  Future<void> _persistStrategy(TradingStrategyItem strategyItem) async {
    try {
      // Simulate storage delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulate potential storage failures (uncomment to test error handling)
      // if (DateTime.now().millisecond % 3 == 0) {
      //   throw StorageException('Failed to save strategy to local storage');
      // }
      
      // In a real implementation, this would save to local storage
      // await StorageService.saveStrategy(widget.asset.id, strategyItem);
      
    } catch (e) {
      if (e is StorageException) {
        rethrow;
      }
      throw StorageException('Failed to persist strategy: ${e.toString()}');
    }
  }

  /// Create strategy instance based on selected type and form data
  TradingStrategy _createStrategyInstance() {
    try {
    switch (_selectedStrategyType!) {
      case StrategyType.trendline:
        return TrendlineStrategy(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _formData['name'] ?? 'Trendline Strategy',
          supportLevel: _formData['supportLevel']?.toDouble() ?? 0.0,
          resistanceLevel: _formData['resistanceLevel']?.toDouble() ?? 0.0,
          trendDirection: TrendDirection.values.firstWhere(
            (e) => e.name == _formData['trendDirection'],
            orElse: () => TrendDirection.upward,
          ),
        );
      case StrategyType.buyArea:
        return BuyAreaStrategy(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _formData['name'] ?? 'Buy Area Strategy',
          lowerBound: _formData['lowerBound']?.toDouble() ?? 0.0,
          idealArea: _formData['idealArea']?.toDouble() ?? 0.0,
          upperBound: _formData['upperBound']?.toDouble() ?? 0.0,
        );
      case StrategyType.elliotWaves:
        return ElliotWavesStrategy(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _formData['name'] ?? 'Elliott Waves Strategy',
          currentWave: _formData['currentWave']?.toInt() ?? 1,
          waveTarget: _formData['waveTarget']?.toDouble() ?? 0.0,
          waveLevels: [], // Start with empty wave levels
        );
      case StrategyType.composite:
        return CompositeStrategy(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _formData['name'] ?? 'Composite Strategy',
          rootOperator: LogicalOperator.values.firstWhere(
            (e) => e.name == _formData['rootOperator'],
            orElse: () => LogicalOperator.and,
          ),
          conditions: [], // Start with empty conditions
        );
    }
    } catch (e) {
      throw StrategyCreationException('Failed to create strategy instance: ${e.toString()}');
    }
  }

  /// Show success snackbar
  void _showSuccessSnackBar(String strategyName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Strategy "$strategyName" created successfully'),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar with detailed error information
  void _showErrorSnackBar(String title, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onError,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show validation error snackbar
  void _showValidationErrorSnackBar() {
    final errorCount = _validationErrors.length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorCount == 1 
                    ? 'Please fix the validation error before creating the strategy'
                    : 'Please fix $errorCount validation errors before creating the strategy',
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Handle dialog dismissal
  void _handleDismiss() {
    _announceStateChange('Strategy creation dialog closed without saving.');
    Navigator.of(context).pop();
  }

  /// Handle escape key press and other keyboard navigation
  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.escape:
          _handleDismiss();
          return true;
        case LogicalKeyboardKey.enter:
          // If create button is focused and enabled, submit form
          if (_createButtonFocusNode.hasFocus && _isFormValid && !_isLoading) {
            _handleSubmit();
            return true;
          }
          break;
        case LogicalKeyboardKey.tab:
          // Handle tab navigation within dialog
          if (HardwareKeyboard.instance.isShiftPressed) {
            _handleShiftTab();
          } else {
            _handleTab();
          }
          return true;
      }
    }
    return false;
  }

  /// Handle tab key navigation (forward)
  void _handleTab() {
    final currentFocus = FocusScope.of(context).focusedChild;
    
    // If no focus or at the end, cycle to beginning
    if (currentFocus == null || currentFocus == _createButtonFocusNode) {
      _closeButtonFocusNode.requestFocus();
    }
  }

  /// Handle shift+tab navigation (backward)
  void _handleShiftTab() {
    final currentFocus = FocusScope.of(context).focusedChild;
    
    // If at the beginning, cycle to end
    if (currentFocus == null || currentFocus == _closeButtonFocusNode) {
      _createButtonFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _dialogFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: Semantics(
        label: 'Strategy creation dialog for ${widget.asset.name}',
        child: Stack(
          children: [
            Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16.0),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                  maxHeight: 700,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dialog Header
                    _buildDialogHeader(),
                    
                    // Dialog Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Asset Context Display
                            _buildAssetContext(),
                            
                            const SizedBox(height: 24),
                            
                            // Category Selector
                            _buildCategorySection(),
                            
                            const SizedBox(height: 24),
                            
                            // Dynamic Strategy Form
                            _buildFormSection(),
                          ],
                        ),
                      ),
                    ),
                    
                    // Dialog Actions
                    _buildDialogActions(),
                  ],
                ),
              ),
            ),
            
            // Loading Overlay
            if (_isLoading)
              _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  /// Build the dialog header with title and close button
  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_chart,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
            semanticLabel: 'Strategy creation',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Create Trading Strategy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Semantics(
            label: 'Close dialog',
            button: true,
            child: IconButton(
              focusNode: _closeButtonFocusNode,
              onPressed: _handleDismiss,
              icon: const Icon(Icons.close),
              tooltip: 'Close dialog (Escape)',
            ),
          ),
        ],
      ),
    );
  }

  /// Build asset context display
  Widget _buildAssetContext() {
    return Semantics(
      label: 'Asset context: ${widget.asset.name}, symbol ${widget.asset.symbol}, current value ${widget.asset.currentValue.toStringAsFixed(2)} ${widget.asset.currency}',
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.trending_up,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
                semanticLabel: 'Asset indicator',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.asset.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.asset.symbol} • ${widget.asset.currentValue.toStringAsFixed(2)} ${widget.asset.currency}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build category selection section
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strategy Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a strategy category and type to configure',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        CategorySelector(
          selectedCategory: _selectedCategory,
          selectedStrategy: _selectedStrategyType,
          onCategoryChanged: _onCategoryChanged,
          onStrategyChanged: _onStrategyChanged,
        ),
      ],
    );
  }

  /// Build form section
  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strategy Configuration',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure the parameters for your selected strategy',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        DynamicStrategyForm(
          strategyType: _selectedStrategyType,
          formData: _formData,
          validationErrors: _validationErrors,
          onFieldChanged: _onFieldChanged,
          formKey: _formKey,
          onFormChanged: _onFormChanged,
        ),
      ],
    );
  }

  /// Build dialog action buttons
  Widget _buildDialogActions() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16.0),
          bottomRight: Radius.circular(16.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel Button
          Semantics(
            label: 'Cancel strategy creation',
            button: true,
            child: TextButton(
              focusNode: _cancelButtonFocusNode,
              onPressed: _isLoading ? null : _handleDismiss,
              child: const Text('Cancel'),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Create Button
          Semantics(
            label: _isFormValid 
                ? 'Create strategy with current configuration'
                : 'Create strategy (disabled - form has errors)',
            button: true,
            enabled: _isFormValid && !_isLoading,
            child: FilledButton(
              focusNode: _createButtonFocusNode,
              onPressed: _isLoading || !_isFormValid ? null : _handleSubmit,
              child: _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Text('Create Strategy'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading overlay during form submission
  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Semantics(
        label: 'Creating strategy, please wait',
        liveRegion: true,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: 'Loading indicator',
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Creating Strategy...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we save your strategy',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}