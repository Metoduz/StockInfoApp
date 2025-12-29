import 'package:flutter/foundation.dart';
import '../models/asset_item.dart';
import '../models/enhanced_asset_item.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

/// Main application state provider for managing shared state across tabs
/// Enhanced with persistent storage integration
class AppStateProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  // Watchlist state - now using EnhancedAssetItem
  List<EnhancedAssetItem> _watchlist = [];
  
  // User profile state
  UserProfile? _userProfile;
  
  // App settings state
  AppSettings? _appSettings;
  
  // Navigation state
  int _currentTabIndex = 0;
  
  // Loading states
  bool _isLoadingWatchlist = false;
  bool _isLoadingProfile = false;
  bool _isLoadingSettings = false;
  
  // Getters
  List<EnhancedAssetItem> get watchlist => List.unmodifiable(_watchlist);
  UserProfile? get userProfile => _userProfile;
  AppSettings? get appSettings => _appSettings;
  int get currentTabIndex => _currentTabIndex;
  bool get isLoadingWatchlist => _isLoadingWatchlist;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isLoadingSettings => _isLoadingSettings;
  
  // Navigation methods
  void setCurrentTab(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }
  
  // Initialize app data on startup
  Future<void> initializeAppData() async {
    await Future.wait([
      loadWatchlist(),
      loadUserProfile(),
      loadAppSettings(),
    ]);
  }
  
  // Watchlist management methods with persistent storage
  Future<void> loadWatchlist() async {
    _isLoadingWatchlist = true;
    notifyListeners();
    
    try {
      final savedWatchlist = await _storageService.loadEnhancedWatchlist();
      _watchlist = savedWatchlist;
    } catch (e) {
      // Use default data if loading fails
      _initializeDefaultWatchlist();
    } finally {
      _isLoadingWatchlist = false;
      notifyListeners();
    }
  }
  
  Future<void> addToWatchlist(AssetItem asset) async {
    // Convert AssetItem to EnhancedAssetItem for backward compatibility
    final enhancedAsset = EnhancedAssetItem(
      id: asset.id,
      isin: asset.isin,
      wkn: asset.wkn,
      ticker: asset.ticker,
      name: asset.name,
      symbol: asset.symbol,
      currentValue: asset.currentValue,
      previousClose: asset.previousClose,
      currency: asset.currency,
      hints: asset.hints,
      lastUpdated: asset.lastUpdated,
      isInWatchlist: asset.isInWatchlist,
      primaryIdentifierType: asset.primaryIdentifierType,
      dayChange: asset.dayChange,
      dayChangePercent: asset.dayChangePercent,
    );
    
    if (!_watchlist.any((item) => item.id == enhancedAsset.id)) {
      _watchlist.add(enhancedAsset);
      notifyListeners();
      await _saveWatchlist();
    }
  }
  
  Future<void> addEnhancedToWatchlist(EnhancedAssetItem asset) async {
    if (!_watchlist.any((item) => item.id == asset.id)) {
      _watchlist.add(asset);
      notifyListeners();
      await _saveWatchlist();
    }
  }
  
  Future<void> removeFromWatchlist(String assetId) async {
    _watchlist.removeWhere((item) => item.id == assetId);
    notifyListeners();
    await _saveWatchlist();
  }
  
  Future<void> reorderWatchlist(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final EnhancedAssetItem item = _watchlist.removeAt(oldIndex);
    _watchlist.insert(newIndex, item);
    notifyListeners();
    await _saveWatchlist();
  }
  
  Future<void> updateAsset(AssetItem updatedAsset) async {
    // Convert AssetItem to EnhancedAssetItem for backward compatibility
    final enhancedAsset = EnhancedAssetItem(
      id: updatedAsset.id,
      isin: updatedAsset.isin,
      wkn: updatedAsset.wkn,
      ticker: updatedAsset.ticker,
      name: updatedAsset.name,
      symbol: updatedAsset.symbol,
      currentValue: updatedAsset.currentValue,
      previousClose: updatedAsset.previousClose,
      currency: updatedAsset.currency,
      hints: updatedAsset.hints,
      lastUpdated: updatedAsset.lastUpdated,
      isInWatchlist: updatedAsset.isInWatchlist,
      primaryIdentifierType: updatedAsset.primaryIdentifierType,
      dayChange: updatedAsset.dayChange,
      dayChangePercent: updatedAsset.dayChangePercent,
    );
    
    final index = _watchlist.indexWhere((item) => item.id == enhancedAsset.id);
    if (index != -1) {
      // Preserve existing enhanced features (tags, strategies, trades)
      final existingAsset = _watchlist[index];
      final updatedEnhancedAsset = enhancedAsset.copyWith(
        tags: existingAsset.tags,
        strategies: existingAsset.strategies,
        activeTrades: existingAsset.activeTrades,
        closedTrades: existingAsset.closedTrades,
        assetType: existingAsset.assetType,
      );
      
      _watchlist[index] = updatedEnhancedAsset;
      notifyListeners();
      await _saveWatchlist();
    }
  }
  
  Future<void> updateEnhancedAsset(EnhancedAssetItem updatedAsset) async {
    final index = _watchlist.indexWhere((item) => item.id == updatedAsset.id);
    if (index != -1) {
      _watchlist[index] = updatedAsset;
      notifyListeners();
      await _saveWatchlist();
    }
  }
  
  Future<void> _saveWatchlist() async {
    try {
      await _storageService.saveEnhancedWatchlist(_watchlist);
    } catch (e) {
      // Handle save error - could show notification to user
      debugPrint('Failed to save watchlist: $e');
    }
  }
  
  // User Profile management methods
  Future<void> loadUserProfile() async {
    _isLoadingProfile = true;
    notifyListeners();
    
    try {
      _userProfile = await _storageService.loadUserProfile();
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
      _userProfile = null;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }
  
  Future<void> updateUserProfile(UserProfile profile) async {
    _userProfile = profile;
    notifyListeners();
    
    try {
      await _storageService.saveUserProfile(profile);
    } catch (e) {
      debugPrint('Failed to save user profile: $e');
    }
  }
  
  // App Settings management methods
  Future<void> loadAppSettings() async {
    _isLoadingSettings = true;
    notifyListeners();
    
    try {
      _appSettings = await _storageService.loadAppSettings();
      if (_appSettings == null) {
        // Initialize with default settings
        _appSettings = const AppSettings();
        await _storageService.saveAppSettings(_appSettings!);
      }
    } catch (e) {
      debugPrint('Failed to load app settings: $e');
      _appSettings = const AppSettings();
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }
  
  Future<void> updateAppSettings(AppSettings settings) async {
    _appSettings = settings;
    notifyListeners();
    
    try {
      await _storageService.saveAppSettings(settings);
    } catch (e) {
      debugPrint('Failed to save app settings: $e');
    }
  }
  
  // Initialize with default data when storage fails
  void _initializeDefaultWatchlist() {
    _watchlist = [
      EnhancedAssetItem(
        id: 'BASF11',
        isin: 'DE000BASF111',
        name: 'BASF SE',
        symbol: 'BAS',
        currentValue: 45.32,
        currency: 'EUR',
        hints: [],
        lastUpdated: DateTime.now(),
        isInWatchlist: true,
        primaryIdentifierType: AssetIdentifierType.isin,
      ),
      EnhancedAssetItem(
        id: 'SAP',
        isin: 'DE0007164600',
        name: 'SAP SE',
        symbol: 'SAP',
        currentValue: 234.50,
        currency: 'EUR',
        hints: [],
        lastUpdated: DateTime.now(),
        isInWatchlist: true,
        primaryIdentifierType: AssetIdentifierType.isin,
      ),
    ];
  }
  
  // Check if storage is available
  Future<bool> isStorageAvailable() async {
    try {
      return await _storageService.isStorageAvailable();
    } catch (e) {
      return false;
    }
  }
}