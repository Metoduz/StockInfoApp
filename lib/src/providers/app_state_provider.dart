import 'package:flutter/foundation.dart';
import '../models/asset_item.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

/// Main application state provider for managing shared state across tabs
/// Enhanced with persistent storage integration
class AppStateProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  // Watchlist state
  List<AssetItem> _watchlist = [];
  
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
  List<AssetItem> get watchlist => List.unmodifiable(_watchlist);
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
      final savedWatchlist = await _storageService.loadWatchlist();
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
    final AssetItem item = _watchlist.removeAt(oldIndex);
    _watchlist.insert(newIndex, item);
    notifyListeners();
    await _saveWatchlist();
  }
  
  Future<void> _saveWatchlist() async {
    try {
      await _storageService.saveWatchlist(_watchlist);
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
      AssetItem(
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
      AssetItem(
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