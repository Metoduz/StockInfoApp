import '../models/asset_item.dart';
import '../models/enhanced_asset_item.dart';

/// Utility class for converting between AssetItem and EnhancedAssetItem
class AssetConversion {
  /// Convert a regular AssetItem to an EnhancedAssetItem
  /// This provides backward compatibility with existing asset data
  static EnhancedAssetItem toEnhanced(AssetItem asset) {
    return EnhancedAssetItem(
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
      // Enhanced features start empty for backward compatibility
      tags: const [],
      strategies: const [],
      activeTrades: const [],
      closedTrades: const [],
      assetType: _inferAssetType(asset),
    );
  }

  /// Convert an EnhancedAssetItem back to a regular AssetItem
  /// This allows integration with existing systems that expect AssetItem
  static AssetItem toRegular(EnhancedAssetItem enhancedAsset) {
    return AssetItem(
      id: enhancedAsset.id,
      isin: enhancedAsset.isin,
      wkn: enhancedAsset.wkn,
      ticker: enhancedAsset.ticker,
      name: enhancedAsset.name,
      symbol: enhancedAsset.symbol,
      currentValue: enhancedAsset.currentValue,
      previousClose: enhancedAsset.previousClose,
      currency: enhancedAsset.currency,
      hints: enhancedAsset.hints,
      lastUpdated: enhancedAsset.lastUpdated,
      isInWatchlist: enhancedAsset.isInWatchlist,
      primaryIdentifierType: enhancedAsset.primaryIdentifierType,
      dayChange: enhancedAsset.dayChange,
      dayChangePercent: enhancedAsset.dayChangePercent,
    );
  }

  /// Convert a list of AssetItems to EnhancedAssetItems
  static List<EnhancedAssetItem> toEnhancedList(List<AssetItem> assets) {
    return assets.map(toEnhanced).toList();
  }

  /// Convert a list of EnhancedAssetItems to AssetItems
  static List<AssetItem> toRegularList(List<EnhancedAssetItem> enhancedAssets) {
    return enhancedAssets.map(toRegular).toList();
  }

  /// Infer asset type from existing asset data
  /// This is a best-effort approach based on available information
  static AssetType _inferAssetType(AssetItem asset) {
    final symbol = asset.symbol.toUpperCase();
    final name = asset.name.toUpperCase();
    
    // Check for crypto patterns
    if (_isCrypto(symbol, name)) {
      return AssetType.crypto;
    }
    
    // Check for CFD patterns
    if (_isCFD(symbol, name)) {
      return AssetType.cfd;
    }
    
    // Check for resource patterns
    if (_isResource(symbol, name)) {
      return AssetType.resource;
    }
    
    // Default to stock for traditional securities with ISIN
    if (asset.isin != null && asset.isin!.isNotEmpty) {
      return AssetType.stock;
    }
    
    // Default to other for everything else
    return AssetType.other;
  }

  /// Check if the asset is likely a cryptocurrency
  static bool _isCrypto(String symbol, String name) {
    const cryptoSymbols = {
      'BTC', 'ETH', 'ADA', 'DOT', 'SOL', 'AVAX', 'MATIC', 'LINK',
      'UNI', 'AAVE', 'COMP', 'MKR', 'SNX', 'YFI', 'SUSHI', 'CRV',
      'XRP', 'LTC', 'BCH', 'ETC', 'XLM', 'DOGE', 'SHIB', 'USDT',
      'USDC', 'DAI', 'BUSD', 'TUSD', 'FRAX'
    };
    
    const cryptoNames = {
      'BITCOIN', 'ETHEREUM', 'CARDANO', 'POLKADOT', 'SOLANA',
      'AVALANCHE', 'POLYGON', 'CHAINLINK', 'UNISWAP', 'AAVE',
      'COMPOUND', 'MAKER', 'SYNTHETIX', 'YEARN', 'SUSHISWAP',
      'CURVE', 'RIPPLE', 'LITECOIN', 'BITCOIN CASH', 'ETHEREUM CLASSIC',
      'STELLAR', 'DOGECOIN', 'SHIBA INU', 'TETHER', 'USD COIN',
      'DAI', 'BINANCE USD', 'TRUEUSD', 'FRAX'
    };
    
    return cryptoSymbols.contains(symbol) || 
           cryptoNames.any((crypto) => name.contains(crypto));
  }

  /// Check if the asset is likely a CFD
  static bool _isCFD(String symbol, String name) {
    const cfdPatterns = ['CFD', 'CONTRACT FOR DIFFERENCE', 'DIFF'];
    
    return cfdPatterns.any((pattern) => 
        symbol.contains(pattern) || name.contains(pattern));
  }

  /// Check if the asset is likely a resource/commodity
  static bool _isResource(String symbol, String name) {
    const resourceSymbols = {
      'GOLD', 'SILVER', 'OIL', 'GAS', 'COPPER', 'PLATINUM', 'PALLADIUM',
      'CRUDE', 'BRENT', 'WTI', 'NATGAS', 'WHEAT', 'CORN', 'SOYBEAN',
      'COFFEE', 'SUGAR', 'COTTON', 'COCOA'
    };
    
    const resourceNames = {
      'GOLD', 'SILVER', 'OIL', 'GAS', 'COPPER', 'PLATINUM', 'PALLADIUM',
      'CRUDE', 'BRENT', 'NATURAL GAS', 'WHEAT', 'CORN', 'SOYBEAN',
      'COFFEE', 'SUGAR', 'COTTON', 'COCOA', 'COMMODITY', 'RESOURCE'
    };
    
    return resourceSymbols.contains(symbol) || 
           resourceNames.any((resource) => name.contains(resource));
  }
}