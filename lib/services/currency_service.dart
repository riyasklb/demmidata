import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
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
  static final Map<String, Map<String, dynamic>> _rateCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Get available currencies
  static Map<String, String> get availableCurrencies => _currencies;

  // Get currency name by code
  static String getCurrencyName(String code) {
    return _currencies[code] ?? code;
  }

  // Convert currency using CurrencyLayer API
  static Future<double> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    // Check cache first (cache for 1 hour)
    final cacheKey = '${fromCurrency}_${toCurrency}';
    if (_rateCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null && 
          DateTime.now().difference(cacheTime).inHours < 1) {
        final cachedRate = _rateCache[cacheKey]!['rate'] as double;
        return amount * cachedRate;
      }
    }

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
          final result = data['result'] as double;
          final quote = data['info']['quote'] as double;
          final timestamp = data['info']['timestamp'] as int;
          
          // Cache the rate
          _rateCache[cacheKey] = {
            'rate': quote,
            'timestamp': timestamp,
          };
          _cacheTimestamps[cacheKey] = DateTime.now();
          
          return result;
        } else {
          throw Exception('API Error: ${data['error']?['info'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      // Return cached data if available, even if expired
      if (_rateCache.containsKey(cacheKey)) {
        final cachedRate = _rateCache[cacheKey]!['rate'] as double;
        return amount * cachedRate;
      }
      throw Exception('Network error: $e');
    }
  }

  // Get current rate between two currencies
  static Future<double> getCurrentRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    if (fromCurrency == toCurrency) {
      return 1.0;
    }

    // Use a small amount to get the rate
    const testAmount = 1.0;
    final convertedAmount = await convertCurrency(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: testAmount,
    );
    
    return convertedAmount / testAmount;
  }

  // Fetch exchange rates for a base currency (for compatibility)
  static Future<Map<String, double>> getExchangeRates(String baseCurrency) async {
    final rates = <String, double>{};
    
    for (final currency in _currencies.keys) {
      if (currency != baseCurrency) {
        try {
          final rate = await getCurrentRate(
            fromCurrency: baseCurrency,
            toCurrency: currency,
          );
          rates[currency] = rate;
        } catch (e) {
          // Skip currencies that fail
          continue;
        }
      }
    }
    
    return rates;
  }

  // Check if rate is cached
  static bool isRateCached(String fromCurrency, String toCurrency) {
    final cacheKey = '${fromCurrency}_${toCurrency}';
    if (!_rateCache.containsKey(cacheKey)) return false;
    
    final cacheTime = _cacheTimestamps[cacheKey];
    if (cacheTime == null) return false;
    
    return DateTime.now().difference(cacheTime).inHours < 1;
  }

  // Get cache timestamp
  static DateTime? getCacheTimestamp(String fromCurrency, String toCurrency) {
    final cacheKey = '${fromCurrency}_${toCurrency}';
    return _cacheTimestamps[cacheKey];
  }

  // Clear cache
  static void clearCache() {
    _rateCache.clear();
    _cacheTimestamps.clear();
  }

  // Validate amount
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= 100000;
  }

  // Get validation error message
  static String? getAmountValidationError(double amount) {
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 100000) {
      return 'Amount cannot exceed 100,000';
    }
    return null;
  }
}
