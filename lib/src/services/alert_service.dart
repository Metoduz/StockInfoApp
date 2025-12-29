import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/asset_alert.dart';
import '../models/asset_item.dart';
import '../models/active_trade.dart';
import '../strategies/trading_strategy_base.dart';
import 'storage_service.dart';

class AlertService extends ChangeNotifier {
  final StorageService _storageService;
  List<AssetAlert> _alerts = [];
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  // Mock asset data for demonstration - in real app this would come from API
  final Map<String, AssetItem> _mockAssetData = {};
  
  // Enhanced asset data for strategy monitoring
  final Map<String, AssetItem> _enhancedAssetData = {};

  AlertService(this._storageService);

  List<AssetAlert> get alerts => List.unmodifiable(_alerts);
  bool get isMonitoring => _isMonitoring;

  /// Initialize the alert service
  Future<void> initialize() async {
    await loadAlerts();
    _initializeMockData();
    startMonitoring();
  }

  /// Load alerts from storage
  Future<void> loadAlerts() async {
    try {
      _alerts = await _storageService.loadAlerts();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load alerts: $e');
      _alerts = [];
    }
  }

  /// Save alerts to storage
  Future<void> _saveAlerts() async {
    try {
      await _storageService.saveAlerts(_alerts);
    } catch (e) {
      debugPrint('Failed to save alerts: $e');
    }
  }

  /// Create a new alert
  Future<void> createAlert(AssetAlert alert) async {
    if (!alert.isValid()) {
      throw ArgumentError(alert.getValidationError() ?? 'Invalid alert configuration');
    }

    // Check for duplicate alerts
    final existingAlert = _alerts.where((a) => 
      a.assetId == alert.assetId && 
      a.type == alert.type && 
      a.threshold == alert.threshold
    ).firstOrNull;

    if (existingAlert != null) {
      throw ArgumentError('An alert with the same configuration already exists');
    }

    _alerts.add(alert);
    await _saveAlerts();
    notifyListeners();
  }

  /// Update an existing alert
  Future<void> updateAlert(AssetAlert updatedAlert) async {
    if (!updatedAlert.isValid()) {
      throw ArgumentError(updatedAlert.getValidationError() ?? 'Invalid alert configuration');
    }

    final index = _alerts.indexWhere((a) => a.id == updatedAlert.id);
    if (index == -1) {
      throw ArgumentError('Alert not found');
    }

    _alerts[index] = updatedAlert;
    await _saveAlerts();
    notifyListeners();
  }

  /// Delete an alert
  Future<void> deleteAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) {
      throw ArgumentError('Alert not found');
    }

    _alerts.removeAt(index);
    await _saveAlerts();
    notifyListeners();
  }

  /// Enable an alert
  Future<void> enableAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) {
      throw ArgumentError('Alert not found');
    }

    _alerts[index] = _alerts[index].enable();
    await _saveAlerts();
    notifyListeners();
  }

  /// Disable an alert
  Future<void> disableAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) {
      throw ArgumentError('Alert not found');
    }

    _alerts[index] = _alerts[index].disable();
    await _saveAlerts();
    notifyListeners();
  }

  /// Reset a triggered alert
  Future<void> resetAlert(String alertId) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index == -1) {
      throw ArgumentError('Alert not found');
    }

    _alerts[index] = _alerts[index].reset();
    await _saveAlerts();
    notifyListeners();
  }

  /// Get alerts for a specific asset
  List<AssetAlert> getAlertsForAsset(String assetId) {
    return _alerts.where((alert) => alert.assetId == assetId).toList();
  }

  /// Get active alerts (enabled and not triggered)
  List<AssetAlert> getActiveAlerts() {
    return _alerts.where((alert) => 
      alert.isEnabled && alert.triggeredAt == null
    ).toList();
  }

  /// Get triggered alerts
  List<AssetAlert> getTriggeredAlerts() {
    return _alerts.where((alert) => alert.triggeredAt != null).toList();
  }

  /// Start monitoring alerts
  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 30), // Check every 30 seconds
      (_) => _checkAlerts(),
    );
    notifyListeners();
  }

  /// Stop monitoring alerts
  void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    notifyListeners();
  }

  /// Check all active alerts
  Future<void> _checkAlerts() async {
    final activeAlerts = getActiveAlerts();
    bool hasTriggeredAlerts = false;

    // Check traditional price/volume alerts
    for (final alert in activeAlerts) {
      final assetData = _mockAssetData[alert.assetId];
      if (assetData == null) continue;

      final shouldTrigger = alert.shouldTrigger(
        assetData.currentValue,
        assetData.previousClose,
        null, // Volume not available in mock data
      );

      if (shouldTrigger) {
        await _triggerAlert(alert);
        hasTriggeredAlerts = true;
      }
    }

    // Check strategy alerts
    await _checkStrategyAlerts();

    // Check stop loss alerts
    await _checkStopLossAlerts();

    if (hasTriggeredAlerts) {
      await _saveAlerts();
      notifyListeners();
    }
  }

  /// Check strategy alerts for all enhanced assets
  Future<void> _checkStrategyAlerts() async {
    bool hasTriggeredAlerts = false;

    for (final asset in _enhancedAssetData.values) {
      for (final strategy in asset.strategies) {
        if (!strategy.alertEnabled) continue;

        // Prepare asset data for strategy evaluation
        final assetData = {
          'currentValue': asset.currentValue,
          'previousClose': asset.previousClose,
          'dayChange': asset.dayChange,
          'dayChangePercent': asset.dayChangePercent,
          'lastUpdated': asset.lastUpdated,
        };

        // Check if strategy conditions are met
        final shouldTrigger = strategy.checkTriggerCondition(assetData);

        if (shouldTrigger) {
          await _triggerStrategyAlert(asset, strategy);
          hasTriggeredAlerts = true;
        }
      }
    }

    if (hasTriggeredAlerts) {
      await _saveEnhancedAssets();
      notifyListeners();
    }
  }

  /// Check stop loss alerts for all active trades
  Future<void> _checkStopLossAlerts() async {
    bool hasTriggeredAlerts = false;

    for (final asset in _enhancedAssetData.values) {
      for (final trade in asset.activeTrades) {
        if (trade.stopLoss?.alertEnabled != true) continue;

        final shouldTrigger = trade.shouldTriggerStopLoss(asset.currentValue);

        if (shouldTrigger) {
          await _triggerStopLossAlert(asset, trade);
          hasTriggeredAlerts = true;
        }
      }
    }

    if (hasTriggeredAlerts) {
      await _saveEnhancedAssets();
      notifyListeners();
    }
  }

  /// Trigger a strategy alert
  Future<void> _triggerStrategyAlert(AssetItem asset, TradingStrategyItem strategy) async {
    // Mark strategy as triggered
    final updatedStrategy = strategy.markTriggered();
    final strategyIndex = asset.strategies.indexWhere((s) => s.id == strategy.id);
    
    if (strategyIndex != -1) {
      final updatedStrategies = List<TradingStrategyItem>.from(asset.strategies);
      updatedStrategies[strategyIndex] = updatedStrategy;
      
      final updatedAsset = asset.copyWith(strategies: updatedStrategies);
      _enhancedAssetData[asset.id] = updatedAsset;
      _mockAssetData[asset.id] = updatedAsset;
    }

    // Send notification
    await _sendStrategyNotification(asset, strategy);
  }

  /// Trigger a stop loss alert
  Future<void> _triggerStopLossAlert(AssetItem asset, ActiveTradeItem trade) async {
    // Send notification
    await _sendStopLossNotification(asset, trade);
  }

  /// Send notification for triggered strategy alert
  Future<void> _sendStrategyNotification(AssetItem asset, TradingStrategyItem strategy) async {
    final strategyName = strategy.strategy.type.displayName;
    final direction = strategy.direction.displayName;
    
    final message = 'Strategy Alert: $strategyName ($direction) triggered for ${asset.name} (${asset.symbol})';
    
    debugPrint('Strategy Alert: $message');
    
    // Here you would implement:
    // - Local push notifications
    // - In-app notifications
    // - Email notifications (if configured)
    // - Backend notification sync
  }

  /// Send notification for triggered stop loss alert
  Future<void> _sendStopLossNotification(AssetItem asset, ActiveTradeItem trade) async {
    final direction = trade.direction.displayName;
    final stopLossType = trade.stopLoss?.type.displayName ?? 'Unknown';
    
    final message = 'Stop Loss Alert: $stopLossType stop loss triggered for $direction trade in ${asset.name} (${asset.symbol})';
    
    debugPrint('Stop Loss Alert: $message');
    
    // Here you would implement:
    // - Local push notifications
    // - In-app notifications
    // - Email notifications (if configured)
    // - Backend notification sync
  }

  /// Trigger an alert
  Future<void> _triggerAlert(AssetAlert alert) async {
    final index = _alerts.indexWhere((a) => a.id == alert.id);
    if (index == -1) return;

    _alerts[index] = alert.trigger();
    
    // Send notification
    await _sendNotification(alert);
  }

  /// Send notification for triggered alert
  Future<void> _sendNotification(AssetAlert alert) async {
    // In a real app, this would integrate with platform notification services
    // For now, we'll just log the notification
    debugPrint('Alert triggered: ${alert.getDescription()}');
    
    // Here you would implement:
    // - Local push notifications
    // - In-app notifications
    // - Email notifications (if configured)
    // - Backend notification sync
  }

  /// Initialize mock asset data for demonstration
  void _initializeMockData() {
    final random = Random();
    
    // Create some sample assets with fluctuating prices
    final sampleAssets = [
      ('BASF', 'BASF SE', 45.0),
      ('SAP', 'SAP SE', 120.0),
      ('MBG', 'Mercedes-Benz Group AG', 65.0),
      ('SIE', 'Siemens AG', 180.0),
      ('ALV', 'Allianz SE', 250.0),
    ];

    for (final (symbol, name, basePrice) in sampleAssets) {
      // Add some random variation to the price
      final currentPrice = basePrice + (random.nextDouble() - 0.5) * 10;
      final previousClose = basePrice + (random.nextDouble() - 0.5) * 5;
      
      _mockAssetData[symbol] = AssetItem(
        id: symbol,
        isin: 'DE000${symbol}001',
        wkn: '${symbol}001',
        ticker: symbol,
        name: name,
        symbol: symbol,
        currentValue: currentPrice,
        previousClose: previousClose,
        currency: 'EUR',
        lastUpdated: DateTime.now(),
        isInWatchlist: true,
        primaryIdentifierType: AssetIdentifierType.ticker,
        dayChange: currentPrice - previousClose,
        dayChangePercent: ((currentPrice - previousClose) / previousClose) * 100,
        hints: [],
      );
    }

    // Start a timer to simulate price changes
    Timer.periodic(const Duration(seconds: 10), (_) => _updateMockPrices());
  }

  /// Update mock asset prices to simulate market movement
  void _updateMockPrices() {
    final random = Random();
    
    for (final entry in _mockAssetData.entries) {
      final asset = entry.value;
      final priceChange = (random.nextDouble() - 0.5) * 2; // ±1 EUR change
      final newPrice = (asset.currentValue + priceChange).clamp(1.0, 1000.0);
      
      _mockAssetData[entry.key] = asset.copyWith(
        currentValue: newPrice,
        lastUpdated: DateTime.now(),
        dayChange: newPrice - (asset.previousClose ?? asset.currentValue),
        dayChangePercent: asset.previousClose != null 
            ? ((newPrice - asset.previousClose!) / asset.previousClose!) * 100
            : 0.0,
      );
    }
  }

  /// Get current asset data (for testing/demo purposes)
  AssetItem? getAssetData(String assetId) {
    return _mockAssetData[assetId];
  }

  /// Get all available asset data
  Map<String, AssetItem> getAllAssetData() {
    return Map.unmodifiable(_mockAssetData);
  }

  /// Register enhanced asset data for strategy monitoring
  void registerEnhancedAsset(AssetItem asset) {
    _enhancedAssetData[asset.id] = asset;
    
    // Also update the basic asset data
    _mockAssetData[asset.id] = asset;
    
    notifyListeners();
  }

  /// Update enhanced asset data
  void updateEnhancedAsset(AssetItem asset) {
    _enhancedAssetData[asset.id] = asset;
    _mockAssetData[asset.id] = asset;
    notifyListeners();
  }

  /// Remove enhanced asset data
  void removeEnhancedAsset(String assetId) {
    _enhancedAssetData.remove(assetId);
    _mockAssetData.remove(assetId);
    notifyListeners();
  }

  /// Get enhanced asset data
  AssetItem? getEnhancedAsset(String assetId) {
    return _enhancedAssetData[assetId];
  }

  /// Get all enhanced asset data
  Map<String, AssetItem> getAllEnhancedAssets() {
    return Map.unmodifiable(_enhancedAssetData);
  }

  /// Enable strategy alert for a specific asset and strategy
  Future<void> enableStrategyAlert(String assetId, String strategyId) async {
    final asset = _enhancedAssetData[assetId];
    if (asset == null) {
      throw ArgumentError('Asset not found: $assetId');
    }

    final strategyIndex = asset.strategies.indexWhere((s) => s.id == strategyId);
    if (strategyIndex == -1) {
      throw ArgumentError('Strategy not found: $strategyId');
    }

    final updatedStrategy = asset.strategies[strategyIndex].toggleAlert();
    final updatedStrategies = List<TradingStrategyItem>.from(asset.strategies);
    updatedStrategies[strategyIndex] = updatedStrategy;

    final updatedAsset = asset.copyWith(strategies: updatedStrategies);
    _enhancedAssetData[assetId] = updatedAsset;
    _mockAssetData[assetId] = updatedAsset;

    // Save to storage if needed
    await _saveEnhancedAssets();
    notifyListeners();
  }

  /// Disable strategy alert for a specific asset and strategy
  Future<void> disableStrategyAlert(String assetId, String strategyId) async {
    final asset = _enhancedAssetData[assetId];
    if (asset == null) {
      throw ArgumentError('Asset not found: $assetId');
    }

    final strategyIndex = asset.strategies.indexWhere((s) => s.id == strategyId);
    if (strategyIndex == -1) {
      throw ArgumentError('Strategy not found: $strategyId');
    }

    final strategy = asset.strategies[strategyIndex];
    if (!strategy.alertEnabled) return; // Already disabled

    final updatedStrategy = strategy.toggleAlert();
    final updatedStrategies = List<TradingStrategyItem>.from(asset.strategies);
    updatedStrategies[strategyIndex] = updatedStrategy;

    final updatedAsset = asset.copyWith(strategies: updatedStrategies);
    _enhancedAssetData[assetId] = updatedAsset;
    _mockAssetData[assetId] = updatedAsset;

    // Save to storage if needed
    await _saveEnhancedAssets();
    notifyListeners();
  }

  /// Toggle strategy alert (enable if disabled, disable if enabled)
  Future<void> toggleStrategyAlert(String assetId, String strategyId) async {
    final asset = _enhancedAssetData[assetId];
    if (asset == null) {
      throw ArgumentError('Asset not found: $assetId');
    }

    final strategy = asset.strategies.firstWhere(
      (s) => s.id == strategyId,
      orElse: () => throw ArgumentError('Strategy not found: $strategyId'),
    );

    if (strategy.alertEnabled) {
      await disableStrategyAlert(assetId, strategyId);
    } else {
      await enableStrategyAlert(assetId, strategyId);
    }
  }

  /// Enable stop loss alert for a specific trade
  Future<void> enableStopLossAlert(String assetId, String tradeId) async {
    final asset = _enhancedAssetData[assetId];
    if (asset == null) {
      throw ArgumentError('Asset not found: $assetId');
    }

    final tradeIndex = asset.activeTrades.indexWhere((t) => t.id == tradeId);
    if (tradeIndex == -1) {
      throw ArgumentError('Trade not found: $tradeId');
    }

    final trade = asset.activeTrades[tradeIndex];
    if (trade.stopLoss == null) {
      throw ArgumentError('Trade does not have stop loss configured');
    }

    final updatedStopLoss = trade.stopLoss!.copyWith(alertEnabled: true);
    final updatedTrade = trade.copyWith(stopLoss: updatedStopLoss);
    final updatedTrades = List<ActiveTradeItem>.from(asset.activeTrades);
    updatedTrades[tradeIndex] = updatedTrade;

    final updatedAsset = asset.copyWith(activeTrades: updatedTrades);
    _enhancedAssetData[assetId] = updatedAsset;
    _mockAssetData[assetId] = updatedAsset;

    await _saveEnhancedAssets();
    notifyListeners();
  }

  /// Disable stop loss alert for a specific trade
  Future<void> disableStopLossAlert(String assetId, String tradeId) async {
    final asset = _enhancedAssetData[assetId];
    if (asset == null) {
      throw ArgumentError('Asset not found: $assetId');
    }

    final tradeIndex = asset.activeTrades.indexWhere((t) => t.id == tradeId);
    if (tradeIndex == -1) {
      throw ArgumentError('Trade not found: $tradeId');
    }

    final trade = asset.activeTrades[tradeIndex];
    if (trade.stopLoss == null || !trade.stopLoss!.alertEnabled) return;

    final updatedStopLoss = trade.stopLoss!.copyWith(alertEnabled: false);
    final updatedTrade = trade.copyWith(stopLoss: updatedStopLoss);
    final updatedTrades = List<ActiveTradeItem>.from(asset.activeTrades);
    updatedTrades[tradeIndex] = updatedTrade;

    final updatedAsset = asset.copyWith(activeTrades: updatedTrades);
    _enhancedAssetData[assetId] = updatedAsset;
    _mockAssetData[assetId] = updatedAsset;

    await _saveEnhancedAssets();
    notifyListeners();
  }

  /// Toggle stop loss alert for a specific trade
  Future<void> toggleStopLossAlert(String assetId, String tradeId) async {
    final asset = _enhancedAssetData[assetId];
    if (asset == null) {
      throw ArgumentError('Asset not found: $assetId');
    }

    final trade = asset.activeTrades.firstWhere(
      (t) => t.id == tradeId,
      orElse: () => throw ArgumentError('Trade not found: $tradeId'),
    );

    if (trade.stopLoss?.alertEnabled == true) {
      await disableStopLossAlert(assetId, tradeId);
    } else {
      await enableStopLossAlert(assetId, tradeId);
    }
  }

  /// Get all assets with active strategy alerts
  List<AssetItem> getAssetsWithStrategyAlerts() {
    return _enhancedAssetData.values
        .where((asset) => asset.strategies.any((s) => s.alertEnabled))
        .toList();
  }

  /// Get all assets with active stop loss alerts
  List<AssetItem> getAssetsWithStopLossAlerts() {
    return _enhancedAssetData.values
        .where((asset) => asset.activeTrades.any((t) => t.stopLoss?.alertEnabled == true))
        .toList();
  }

  /// Save enhanced assets to storage
  Future<void> _saveEnhancedAssets() async {
    try {
      // In a real implementation, this would save to storage
      // For now, we'll just log the save operation
      debugPrint('Saving ${_enhancedAssetData.length} enhanced assets to storage');
    } catch (e) {
      debugPrint('Failed to save enhanced assets: $e');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }

  /// Generate a unique ID for alerts
  static String generateAlertId() {
    return 'alert_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
}