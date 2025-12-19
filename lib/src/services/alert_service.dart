import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/stock_alert.dart';
import '../models/stock_item.dart';
import 'storage_service.dart';

class AlertService extends ChangeNotifier {
  final StorageService _storageService;
  List<StockAlert> _alerts = [];
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  // Mock stock data for demonstration - in real app this would come from API
  final Map<String, StockItem> _mockStockData = {};

  AlertService(this._storageService);

  List<StockAlert> get alerts => List.unmodifiable(_alerts);
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
  Future<void> createAlert(StockAlert alert) async {
    if (!alert.isValid()) {
      throw ArgumentError(alert.getValidationError() ?? 'Invalid alert configuration');
    }

    // Check for duplicate alerts
    final existingAlert = _alerts.where((a) => 
      a.stockId == alert.stockId && 
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
  Future<void> updateAlert(StockAlert updatedAlert) async {
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

  /// Get alerts for a specific stock
  List<StockAlert> getAlertsForStock(String stockId) {
    return _alerts.where((alert) => alert.stockId == stockId).toList();
  }

  /// Get active alerts (enabled and not triggered)
  List<StockAlert> getActiveAlerts() {
    return _alerts.where((alert) => 
      alert.isEnabled && alert.triggeredAt == null
    ).toList();
  }

  /// Get triggered alerts
  List<StockAlert> getTriggeredAlerts() {
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

    for (final alert in activeAlerts) {
      final stockData = _mockStockData[alert.stockId];
      if (stockData == null) continue;

      final shouldTrigger = alert.shouldTrigger(
        stockData.currentValue,
        stockData.previousClose,
        null, // Volume not available in mock data
      );

      if (shouldTrigger) {
        await _triggerAlert(alert);
        hasTriggeredAlerts = true;
      }
    }

    if (hasTriggeredAlerts) {
      await _saveAlerts();
      notifyListeners();
    }
  }

  /// Trigger an alert
  Future<void> _triggerAlert(StockAlert alert) async {
    final index = _alerts.indexWhere((a) => a.id == alert.id);
    if (index == -1) return;

    _alerts[index] = alert.trigger();
    
    // Send notification
    await _sendNotification(alert);
  }

  /// Send notification for triggered alert
  Future<void> _sendNotification(StockAlert alert) async {
    // In a real app, this would integrate with platform notification services
    // For now, we'll just log the notification
    debugPrint('Alert triggered: ${alert.getDescription()}');
    
    // Here you would implement:
    // - Local push notifications
    // - In-app notifications
    // - Email notifications (if configured)
    // - Backend notification sync
  }

  /// Initialize mock stock data for demonstration
  void _initializeMockData() {
    final random = Random();
    
    // Create some sample stocks with fluctuating prices
    final sampleStocks = [
      ('BASF', 'BASF SE', 45.0),
      ('SAP', 'SAP SE', 120.0),
      ('MBG', 'Mercedes-Benz Group AG', 65.0),
      ('SIE', 'Siemens AG', 180.0),
      ('ALV', 'Allianz SE', 250.0),
    ];

    for (final (symbol, name, basePrice) in sampleStocks) {
      // Add some random variation to the price
      final currentPrice = basePrice + (random.nextDouble() - 0.5) * 10;
      final previousClose = basePrice + (random.nextDouble() - 0.5) * 5;
      
      _mockStockData[symbol] = StockItem(
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
        primaryIdentifierType: StockIdentifierType.ticker,
        dayChange: currentPrice - previousClose,
        dayChangePercent: ((currentPrice - previousClose) / previousClose) * 100,
        hints: [],
      );
    }

    // Start a timer to simulate price changes
    Timer.periodic(const Duration(seconds: 10), (_) => _updateMockPrices());
  }

  /// Update mock stock prices to simulate market movement
  void _updateMockPrices() {
    final random = Random();
    
    for (final entry in _mockStockData.entries) {
      final stock = entry.value;
      final priceChange = (random.nextDouble() - 0.5) * 2; // ±1 EUR change
      final newPrice = (stock.currentValue + priceChange).clamp(1.0, 1000.0);
      
      _mockStockData[entry.key] = stock.copyWith(
        currentValue: newPrice,
        lastUpdated: DateTime.now(),
        dayChange: newPrice - (stock.previousClose ?? stock.currentValue),
        dayChangePercent: stock.previousClose != null 
            ? ((newPrice - stock.previousClose!) / stock.previousClose!) * 100
            : 0.0,
      );
    }
  }

  /// Get current stock data (for testing/demo purposes)
  StockItem? getStockData(String stockId) {
    return _mockStockData[stockId];
  }

  /// Get all available stock data
  Map<String, StockItem> getAllStockData() {
    return Map.unmodifiable(_mockStockData);
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