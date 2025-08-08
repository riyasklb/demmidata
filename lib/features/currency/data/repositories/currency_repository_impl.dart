import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/conversion_result_entity.dart';
import '../../domain/repositories/currency_repository.dart';
import '../models/conversion_result_model.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
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

  @override
  Map<String, String> get availableCurrencies => _currencies;

  @override
  Future<ConversionResultEntity> convertCurrency({
    required String fromCurrency,
    required String toCurrency,
    required double amount,
  }) async {
    if (fromCurrency == toCurrency) {
      return ConversionResultModel.fromApiResponse(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        originalAmount: amount,
        convertedAmount: amount,
        exchangeRate: 1.0,
        timestamp: DateTime.now(),
        isCached: false,
      );
    }

    // Check cache first (cache for 1 hour)
    final cacheKey = '${fromCurrency}_${toCurrency}';
    bool isCached = false;
    double exchangeRate = 1.0;
    DateTime timestamp = DateTime.now();

    if (_rateCache.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey];
      if (cacheTime != null && 
          DateTime.now().difference(cacheTime).inHours < 1) {
        final cachedData = _rateCache[cacheKey]!;
        exchangeRate = cachedData['rate'] as double;
        timestamp = cacheTime;
        isCached = true;
      }
    }

    if (!isCached) {
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
            final apiTimestamp = data['info']['timestamp'] as int;
            
            exchangeRate = quote;
            timestamp = DateTime.fromMillisecondsSinceEpoch(apiTimestamp * 1000);
            
            // Cache the rate
            _rateCache[cacheKey] = {
              'rate': quote,
              'timestamp': apiTimestamp,
            };
            _cacheTimestamps[cacheKey] = DateTime.now();
          } else {
            throw Exception('API Error: ${data['error']?['info'] ?? 'Unknown error'}');
          }
        } else {
          throw Exception('Failed to load exchange rates: ${response.statusCode}');
        }
      } catch (e) {
        // Return cached data if available, even if expired
        if (_rateCache.containsKey(cacheKey)) {
          final cachedData = _rateCache[cacheKey]!;
          exchangeRate = cachedData['rate'] as double;
          timestamp = _cacheTimestamps[cacheKey] ?? DateTime.now();
          isCached = true;
        } else {
          throw Exception('Network error: $e');
        }
      }
    }

    final convertedAmount = amount * exchangeRate;

    return ConversionResultModel.fromApiResponse(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      originalAmount: amount,
      convertedAmount: convertedAmount,
      exchangeRate: exchangeRate,
      timestamp: timestamp,
      isCached: isCached,
    );
  }

  @override
  Future<double> getCurrentRate({
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

  @override
  bool isRateCached(String fromCurrency, String toCurrency) {
    final cacheKey = '${fromCurrency}_${toCurrency}';
    if (!_rateCache.containsKey(cacheKey)) return false;
    
    final cacheTime = _cacheTimestamps[cacheKey];
    if (cacheTime == null) return false;
    
    return DateTime.now().difference(cacheTime).inHours < 1;
  }

  @override
  DateTime? getCacheTimestamp(String fromCurrency, String toCurrency) {
    final cacheKey = '${fromCurrency}_${toCurrency}';
    return _cacheTimestamps[cacheKey];
  }

  @override
  void clearCache() {
    _rateCache.clear();
    _cacheTimestamps.clear();
  }
}
