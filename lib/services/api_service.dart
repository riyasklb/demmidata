import 'dart:convert';
import 'package:http/http.dart' as http;
import '../currency_converter/models/currency_model.dart';
import '../currency_converter/models/rate_cache.dart';

class ApiService {
  static const String _baseUrl = 'http://api.currencylayer.com/convert';
  static const String _accessKey = 'eeab945f4428e23372f1e6b6baf7baa0';
  
  static const Map<String, String> _currencies = {
    'USD': 'US Dollar',
    'INR': 'Indian Rupee',
    'EUR': 'Euro',
    'AED': 'UAE Dirham',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'NZD': 'New Zealand Dollar',
    'SGD': 'Singapore Dollar',
  };

  // Cache for exchange rates
  static final Map<String, RateCache> _rateCache = {};
  
  // Cache duration constants
  static const int _freshCacheMinutes = 5; // Rate is fresh for 5 minutes
  static const int _staleCacheMinutes = 30; // Rate is usable for 30 minutes

  static Map<String, String> get availableCurrencies => _currencies;

  static Future<CurrencyModel> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (fromCurrency == toCurrency) {
      return CurrencyModel(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        originalAmount: amount,
        convertedAmount: amount,
        exchangeRate: 1.0,
        timestamp: DateTime.now(),
        isCached: false,
        isStale: false,
      );
    }

    // Check cache first with proper time validation
    final cacheKey = '${fromCurrency}_${toCurrency}';
    bool isCached = false;
    bool isStale = false;
    double exchangeRate = 1.0;
    DateTime timestamp = DateTime.now();

    if (_rateCache.containsKey(cacheKey)) {
      final cache = _rateCache[cacheKey]!;
      final timeDifference = DateTime.now().difference(cache.timestamp);
      
      if (timeDifference.inMinutes < _freshCacheMinutes) {
        // Rate is fresh (less than 5 minutes old)
        exchangeRate = cache.rate;
        timestamp = cache.timestamp;
        isCached = true;
      } else if (timeDifference.inMinutes < _staleCacheMinutes) {
        // Rate is stale but still usable (less than 30 minutes old)
        exchangeRate = cache.rate;
        timestamp = cache.timestamp;
        isCached = true;
        isStale = true;
      }
    }

    // Only fetch from API if we don't have fresh cache
    if (!isCached || isStale) {
      try {
        final uri = Uri.parse(_baseUrl).replace(queryParameters: {
          'access_key': _accessKey,
          'from': fromCurrency,
          'to': toCurrency,
          'amount': amount.toString(),
          'format': '1',
        });

        final response = await http.get(uri);
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['success'] == true) {
            final quote = data['info']['quote'] as double;
            final apiTimestamp = data['info']['timestamp'] as int;
            
            exchangeRate = quote;
            timestamp = DateTime.fromMillisecondsSinceEpoch(apiTimestamp * 1000);
            isCached = false; // This is fresh data from API
            isStale = false;
            
            // Cache the rate
            _rateCache[cacheKey] = RateCache(
              rate: quote,
              timestamp: DateTime.now(),
            );
          } else {
            throw Exception('API Error: ${data['error']?['info'] ?? 'Unknown error'}');
          }
        } else {
          throw Exception('Failed to load exchange rates: ${response.statusCode}');
        }
      } catch (e) {
        // If API fails and we have stale cache, use it with warning
        if (isStale) {
          // Keep the stale cached data
          final cache = _rateCache[cacheKey]!;
          exchangeRate = cache.rate;
          timestamp = cache.timestamp;
          isCached = true;
          isStale = true;
        } else if (!isCached) {
          // No cache available and API failed
          throw Exception('Network error: $e');
        }
      }
    }

    final convertedAmount = amount * exchangeRate;

    return CurrencyModel(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      originalAmount: amount,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      timestamp: timestamp,
      isCached: isCached,
      isStale: isStale,
    );
  }

  static Future<double> getCurrentRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) {
      return 1.0;
    }

    // Use a small amount to get the rate
    const testAmount = 1.0;
    final result = await convertCurrency(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: testAmount,
    );
    
    return result.exchangeRate;
  }

  /// Get the best available rate for a currency pair
  /// Tries API first, falls back to cached value if under 30 minutes old
  /// Returns null if no rate is available
  static Future<Map<String, dynamic>?> getBestRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) {
      return {
        'rate': 1.0,
        'timestamp': DateTime.now(),
        'isCached': false,
        'isStale': false,
      };
    }

    final cacheKey = '${fromCurrency}_${toCurrency}';
    
    try {
      // Try to get fresh rate from API
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'access_key': _accessKey,
        'from': fromCurrency,
        'to': toCurrency,
        'amount': '1',
        'format': '1',
      });

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final quote = data['info']['quote'] as double;
          final apiTimestamp = data['info']['timestamp'] as int;
          final timestamp = DateTime.fromMillisecondsSinceEpoch(apiTimestamp * 1000);
          
          // Cache the fresh rate
          _rateCache[cacheKey] = RateCache(
            rate: quote,
            timestamp: DateTime.now(),
          );
          
          return {
            'rate': quote,
            'timestamp': timestamp,
            'isCached': false,
            'isStale': false,
          };
        }
      }
    } catch (e) {
      // API failed, try cached data
    }

    // Check if we have cached data under 30 minutes old
    if (_rateCache.containsKey(cacheKey)) {
      final cache = _rateCache[cacheKey]!;
      final timeDifference = DateTime.now().difference(cache.timestamp);
      
      if (timeDifference.inMinutes < _staleCacheMinutes) {
        final isStale = timeDifference.inMinutes >= _freshCacheMinutes;
        
        return {
          'rate': cache.rate,
          'timestamp': cache.timestamp,
          'isCached': true,
          'isStale': isStale,
        };
      }
    }

    // No rate available
    return null;
  }

  static bool isRateCached(String fromCurrency, String toCurrency) {
    final cacheKey = '${fromCurrency}_${toCurrency}';
    if (!_rateCache.containsKey(cacheKey)) return false;
    
    final cache = _rateCache[cacheKey]!;
    return DateTime.now().difference(cache.timestamp).inMinutes < _freshCacheMinutes;
  }

  static DateTime? getCacheTimestamp(String fromCurrency, String toCurrency) {
    final cacheKey = '${fromCurrency}_${toCurrency}';
    return _rateCache[cacheKey]?.timestamp;
  }

  static void clearCache() {
    _rateCache.clear();
  }
}
