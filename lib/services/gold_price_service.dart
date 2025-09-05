import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GoldPriceService {
  static GoldPriceService? _instance;
  static GoldPriceService get instance => _instance ??= GoldPriceService._();
  GoldPriceService._();

  late final Dio _dio;
  Timer? _priceUpdateTimer;
  StreamController<Map<String, dynamic>>? _priceStreamController;

  // Current price data
  Map<String, dynamic> _currentPriceData = {
    'price': 2045.67,
    'change': 12.45,
    'changePercent': 0.61,
    'timestamp': DateTime.now().toIso8601String(),
    'isConnected': true,
    'lastUpdate': 'منذ 5 ثوان',
  };

  void initialize() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ));

    _priceStreamController = StreamController<Map<String, dynamic>>.broadcast();
    _startPriceUpdates();
  }

  // Get current gold price data
  Map<String, dynamic> get currentPriceData =>
      Map<String, dynamic>.from(_currentPriceData);

  // Stream of price updates
  Stream<Map<String, dynamic>> get priceStream {
    _priceStreamController ??=
        StreamController<Map<String, dynamic>>.broadcast();
    return _priceStreamController!.stream;
  }

  // Start real-time price updates
  void _startPriceUpdates() {
    _priceUpdateTimer?.cancel();
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchLatestPrice();
    });
  }

  // Fetch latest gold price from external API or simulate realistic updates
  Future<void> _fetchLatestPrice() async {
    try {
      // For now, simulate realistic price movements
      // In production, replace with real API calls
      final now = DateTime.now();
      final random = now.millisecond / 1000.0;

      // Simulate realistic gold price volatility (±0.5%)
      final volatility = (random - 0.5) * 20; // Max ±$10 per update
      final newPrice = _currentPriceData['price'] + volatility;

      // Calculate change from base price (simulate daily open)
      final basePrice = 2033.22; // Simulated daily open
      final change = newPrice - basePrice;
      final changePercent = (change / basePrice) * 100;

      _currentPriceData = {
        'price': double.parse(newPrice.toStringAsFixed(2)),
        'change': double.parse(change.toStringAsFixed(2)),
        'changePercent': double.parse(changePercent.toStringAsFixed(2)),
        'timestamp': now.toIso8601String(),
        'isConnected': true,
        'lastUpdate': _formatTimeAgo(now),
        'high24h': _currentPriceData['high24h'] ?? newPrice,
        'low24h': _currentPriceData['low24h'] ?? newPrice,
        'volume': (50000 + (random * 20000)).round(),
      };

      // Update 24h high/low
      if (newPrice > (_currentPriceData['high24h'] ?? 0)) {
        _currentPriceData['high24h'] = newPrice;
      }
      if (newPrice < (_currentPriceData['low24h'] ?? double.infinity)) {
        _currentPriceData['low24h'] = newPrice;
      }

      // Emit price update
      _priceStreamController?.add(_currentPriceData);

      debugPrint(
          'Gold price updated: \$${newPrice.toStringAsFixed(2)} (${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)})');
    } catch (error) {
      debugPrint('Error fetching gold price: $error');

      // Update connection status
      _currentPriceData['isConnected'] = false;
      _currentPriceData['lastUpdate'] = 'خطأ في الاتصال';

      _priceStreamController?.add(_currentPriceData);
    }
  }

  // Format time ago in Arabic
  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 30) {
      return 'الآن';
    } else if (difference.inSeconds < 60) {
      return 'منذ ${difference.inSeconds} ثانية';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  // Manually refresh price
  Future<Map<String, dynamic>> refreshPrice() async {
    await _fetchLatestPrice();
    return _currentPriceData;
  }

  // Stop price updates
  void dispose() {
    _priceUpdateTimer?.cancel();
    _priceStreamController?.close();
    _priceStreamController = null;
  }

  // Get historical price data (for charts)
  Future<List<Map<String, dynamic>>> getHistoricalData({
    required String timeframe, // '1h', '4h', '1d', '1w'
    int limit = 100,
  }) async {
    try {
      // Simulate historical data
      final List<Map<String, dynamic>> historicalData = [];
      final now = DateTime.now();
      final currentPrice = _currentPriceData['price'] as double;

      Duration interval;
      switch (timeframe) {
        case '1h':
          interval = const Duration(minutes: 1);
          break;
        case '4h':
          interval = const Duration(minutes: 15);
          break;
        case '1d':
          interval = const Duration(hours: 1);
          break;
        case '1w':
          interval = const Duration(hours: 4);
          break;
        default:
          interval = const Duration(hours: 1);
      }

      for (int i = limit - 1; i >= 0; i--) {
        final timestamp = now.subtract(interval * i);
        final random = (timestamp.millisecond / 1000.0) - 0.5;
        final priceVariation = random * 50; // ±$25 variation

        final price = currentPrice + priceVariation;

        historicalData.add({
          'timestamp': timestamp.toIso8601String(),
          'price': double.parse(price.toStringAsFixed(2)),
          'volume': (30000 + (random.abs() * 40000)).round(),
        });
      }

      return historicalData;
    } catch (error) {
      debugPrint('Error getting historical data: $error');
      return [];
    }
  }

  // Get market status
  Map<String, dynamic> getMarketStatus() {
    final now = DateTime.now();
    final hour = now.hour;

    // Gold markets are generally active 24/5 (Sunday evening to Friday evening)
    bool isMarketOpen = now.weekday < 6; // Monday to Friday

    if (now.weekday == 7) {
      // Sunday
      isMarketOpen = hour >= 18; // Opens Sunday 6 PM
    }

    return {
      'isOpen': isMarketOpen,
      'nextOpen': isMarketOpen ? null : _getNextMarketOpen(),
      'nextClose': isMarketOpen ? _getNextMarketClose() : null,
      'timezone': 'UTC',
    };
  }

  DateTime? _getNextMarketOpen() {
    final now = DateTime.now();
    if (now.weekday == 6) {
      // Saturday
      return DateTime(now.year, now.month, now.day + 1, 18, 0); // Sunday 6 PM
    } else if (now.weekday == 7 && now.hour < 18) {
      // Sunday before 6 PM
      return DateTime(now.year, now.month, now.day, 18, 0);
    }
    return null;
  }

  DateTime? _getNextMarketClose() {
    final now = DateTime.now();
    if (now.weekday == 5) {
      // Friday
      return DateTime(now.year, now.month, now.day, 17, 0); // Friday 5 PM
    }
    return null;
  }

  // Set custom price (for testing)
  void setCustomPrice(double price) {
    final basePrice = 2033.22;
    final change = price - basePrice;
    final changePercent = (change / basePrice) * 100;

    _currentPriceData = {
      'price': price,
      'change': double.parse(change.toStringAsFixed(2)),
      'changePercent': double.parse(changePercent.toStringAsFixed(2)),
      'timestamp': DateTime.now().toIso8601String(),
      'isConnected': true,
      'lastUpdate': 'الآن',
      'high24h': _currentPriceData['high24h'] ?? price,
      'low24h': _currentPriceData['low24h'] ?? price,
      'volume': _currentPriceData['volume'] ?? 50000,
    };

    _priceStreamController?.add(_currentPriceData);
  }
}
