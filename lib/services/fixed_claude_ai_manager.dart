import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';

import './anthropic_service.dart';

enum AnalysisType {
  QUICK,
  DETAILED,
  NIGHTMARE,
}

class GoldPrice {
  final double price;
  final double change_24h;
  final double changePercentage;
  final double low_24h;
  final double high_24h;
  final DateTime timestamp;
  final String source;

  GoldPrice({
    required this.price,
    required this.change_24h,
    required this.changePercentage,
    required this.low_24h,
    required this.high_24h,
    required this.timestamp,
    required this.source,
  });
}

class PerformanceConfig {
  static const int CLAUDE_TIMEOUT = 120;
}

class Config {
  static const String CLAUDE_API_KEY =
      String.fromEnvironment('ANTHROPIC_API_KEY');
  static const String CLAUDE_MODEL = String.fromEnvironment('CLAUDE_MODEL',
      defaultValue: 'claude-3-5-sonnet-20241022');
  static const int CLAUDE_MAX_TOKENS =
      int.fromEnvironment('CLAUDE_MAX_TOKENS', defaultValue: 8000);
  static const double CLAUDE_TEMPERATURE = 0.3;
  static const String NIGHTMARE_TRIGGER = 'الكابوس الكامل';
}

class FixedCacheManager {
  final Map<String, CacheEntry> _cache = {};
  static const int MAX_CACHE_SIZE = 100;
  static const int CACHE_DURATION_HOURS = 2;

  String? getAnalysis(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().difference(entry.timestamp).inHours >
        CACHE_DURATION_HOURS) {
      _cache.remove(key);
      return null;
    }

    return entry.data;
  }

  void setAnalysis(String key, String data) {
    if (_cache.length >= MAX_CACHE_SIZE) {
      // Remove oldest entry
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    _cache[key] = CacheEntry(data: data, timestamp: DateTime.now());
  }

  void clearCache() {
    _cache.clear();
  }
}

class CacheEntry {
  final String data;
  final DateTime timestamp;

  CacheEntry({required this.data, required this.timestamp});
}

class FixedClaudeAIManager {
  static FixedClaudeAIManager? _instance;
  static FixedClaudeAIManager get instance =>
      _instance ??= FixedClaudeAIManager._();
  FixedClaudeAIManager._();

  late final AnthropicClient _client;
  final FixedCacheManager cache = FixedCacheManager();
  final ImagePicker _imagePicker = ImagePicker();

  void initialize() {
    try {
      final anthropicService = AnthropicService();
      _client = AnthropicClient(anthropicService.dio);
      debugPrint('FixedClaudeAIManager initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize FixedClaudeAIManager: $e');
      rethrow;
    }
  }

  Future<String> analyzeGold({
    required String prompt,
    required GoldPrice goldPrice,
    File? imageFile,
    String? imageBase64,
    AnalysisType analysisType = AnalysisType.DETAILED,
    Map<String, dynamic>? userSettings,
  }) async {
    try {
      // Initialize if not already done
      if (!_isInitialized()) {
        initialize();
      }

      // Check cache for text-only analysis
      if (imageFile == null && imageBase64 == null) {
        final cacheKey = _generateCacheKey(prompt, goldPrice, analysisType);
        final cachedResult = cache.getAnalysis(cacheKey);
        if (cachedResult != null) {
          return '$cachedResult\n\n🔥 *من الذاكرة المؤقتة للسرعة*';
        }
      }

      // Check for nightmare analysis
      final isNightmareAnalysis = Config.NIGHTMARE_TRIGGER.contains(prompt) ||
          prompt.contains(Config.NIGHTMARE_TRIGGER);

      if (isNightmareAnalysis) {
        analysisType = AnalysisType.NIGHTMARE;
      }

      final systemPrompt = _buildSystemPrompt(analysisType, goldPrice,
          userSettings, imageFile != null || imageBase64 != null);
      final userPrompt = _buildUserPrompt(prompt, goldPrice, analysisType,
          imageFile != null || imageBase64 != null);

      // Perform analysis with retry mechanism
      const maxRetries = 2;

      for (int attempt = 0; attempt < maxRetries; attempt++) {
        try {
          String result;

          if (imageFile != null || imageBase64 != null) {
            // Image analysis
            result = await _performImageAnalysis(
                userPrompt, systemPrompt, imageFile, imageBase64);
          } else {
            // Text analysis
            result = await _performTextAnalysis(userPrompt, systemPrompt);
          }

          // Cache text-only results
          if (imageFile == null && imageBase64 == null) {
            final cacheKey = _generateCacheKey(prompt, goldPrice, analysisType);
            cache.setAnalysis(cacheKey, result);
          }

          return result;
        } on TimeoutException {
          debugPrint('Claude API timeout - attempt ${attempt + 1}/$maxRetries');
          if (attempt == maxRetries - 1) {
            return imageFile != null || imageBase64 != null
                ? _generateChartFallbackAnalysis(goldPrice)
                : _generateTextFallbackAnalysis(goldPrice, analysisType);
          }
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        } catch (e) {
          final errorStr = e.toString().toLowerCase();

          if (errorStr.contains('overloaded') || errorStr.contains('529')) {
            debugPrint(
                'Claude API overloaded - attempt ${attempt + 1}/$maxRetries');
            if (attempt == maxRetries - 1) {
              return imageFile != null || imageBase64 != null
                  ? _generateChartFallbackAnalysis(goldPrice)
                  : _generateTextFallbackAnalysis(goldPrice, analysisType);
            }
            await Future.delayed(Duration(seconds: 3 * (attempt + 1)));
            continue;
          } else if (errorStr.contains('rate_limit') ||
              errorStr.contains('429')) {
            debugPrint('Claude API rate limited');
            if (attempt == maxRetries - 1) {
              return '⚠️ تم تجاوز الحد المسموح. حاول بعد قليل.';
            }
            await Future.delayed(const Duration(seconds: 5));
            continue;
          } else {
            debugPrint('Claude API error: $e');
            return imageFile != null || imageBase64 != null
                ? _generateChartFallbackAnalysis(goldPrice)
                : '❌ خطأ في التحليل. يرجى المحاولة مرة أخرى.';
          }
        }
      }

      // If all retries failed
      return imageFile != null || imageBase64 != null
          ? _generateChartFallbackAnalysis(goldPrice)
          : _generateTextFallbackAnalysis(goldPrice, analysisType);
    } catch (e) {
      debugPrint('Analysis error: $e');
      return '❌ حدث خطأ في التحليل: ${e.toString()}';
    }
  }

  Future<String> _performImageAnalysis(String userPrompt, String systemPrompt,
      File? imageFile, String? imageBase64) async {
    try {
      String base64Image;

      if (imageFile != null) {
        final imageBytes = await imageFile.readAsBytes();
        base64Image = base64Encode(imageBytes);
      } else {
        base64Image = imageBase64!;
      }

      final message = Message(
        role: 'user',
        content: [
          {
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': 'image/jpeg',
              'data': base64Image,
            },
          },
          {
            'type': 'text',
            'text': userPrompt,
          },
        ],
      );

      final completion = await _client.createChat(
        messages: [message],
        model: Config.CLAUDE_MODEL,
        maxTokens: Config.CLAUDE_MAX_TOKENS,
        temperature: Config.CLAUDE_TEMPERATURE,
      ).timeout(Duration(seconds: PerformanceConfig.CLAUDE_TIMEOUT));

      return completion.text;
    } catch (e) {
      debugPrint('Image analysis error: $e');
      rethrow;
    }
  }

  Future<String> _performTextAnalysis(
      String userPrompt, String systemPrompt) async {
    try {
      final message = Message(role: 'user', content: userPrompt);

      final completion = await _client.createChat(
        messages: [message],
        model: Config.CLAUDE_MODEL,
        maxTokens: Config.CLAUDE_MAX_TOKENS,
        temperature: Config.CLAUDE_TEMPERATURE,
      ).timeout(Duration(seconds: PerformanceConfig.CLAUDE_TIMEOUT));

      return completion.text;
    } catch (e) {
      debugPrint('Text analysis error: $e');
      rethrow;
    }
  }

  // Image selection methods
  Future<File?> selectImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error selecting image from gallery: $e');
      return null;
    }
  }

  Future<File?> captureImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing image from camera: $e');
      return null;
    }
  }

  // Streaming chat for real-time conversation
  Stream<String> streamChat(List<Message> messages) async* {
    try {
      if (!_isInitialized()) {
        initialize();
      }

      yield* _client.streamChat(
        messages: messages,
        model: Config.CLAUDE_MODEL,
        maxTokens: Config.CLAUDE_MAX_TOKENS,
        temperature: Config.CLAUDE_TEMPERATURE,
      );
    } catch (e) {
      debugPrint('Stream chat error: $e');
      yield 'خطأ في المحادثة: ${e.toString()}';
    }
  }

  // Chat conversation method
  Future<String> chatWithAI(List<Message> messages) async {
    try {
      if (!_isInitialized()) {
        initialize();
      }

      final completion = await _client
          .createChat(
            messages: messages,
            model: Config.CLAUDE_MODEL,
            maxTokens: Config.CLAUDE_MAX_TOKENS,
            temperature: Config.CLAUDE_TEMPERATURE,
          )
          .timeout(Duration(seconds: PerformanceConfig.CLAUDE_TIMEOUT));

      return completion.text;
    } catch (e) {
      debugPrint('Chat error: $e');
      return 'حدث خطأ في المحادثة: ${e.toString()}';
    }
  }

  String _generateCacheKey(
      String prompt, GoldPrice goldPrice, AnalysisType analysisType) {
    final combinedString = '$prompt${goldPrice.price}${analysisType.name}';
    return combinedString.hashCode.toString();
  }

  bool _isInitialized() {
    try {
      return _client != null;
    } catch (e) {
      return false;
    }
  }

  String _buildSystemPrompt(AnalysisType analysisType, GoldPrice goldPrice,
      Map<String, dynamic>? userSettings, bool hasImage) {
    String basePrompt =
        '''أنت خبير عالمي في أسواق المعادن الثمينة والذهب مع خبرة +25 سنة في:
• التحليل الفني والكمي المتقدم متعدد الأطر الزمنية
• اكتشاف النماذج الفنية والإشارات المتقدمة
• إدارة المخاطر والمحافظ الاستثمارية المتخصصة
• تحليل نقاط الانعكاس ومستويات الدعم والمقاومة
• تطبيقات الذكاء الاصطناعي والتداول الخوارزمي المتقدم
• تحليل مناطق العرض والطلب والسيولة المؤسسية''';

    if (hasImage) {
      basePrompt += '''
• تحليل الشارت الاحترافي المتقدم
• قراءة النماذج الفنية من الشارت
• تحليل الأحجام والمؤشرات التقنية
• اكتشاف نقاط الدخول والخروج من الشارت''';
    }

    basePrompt += '''

🏆 الانتماء المؤسسي: Gold Nightmare Academy - أكاديمية التحليل المتقدم

البيانات الحية المعتمدة:
🥇 السعر: \$${goldPrice.price} USD/oz
📈 التغيير 24h: ${goldPrice.change_24h >= 0 ? '+' : ''}${goldPrice.change_24h.toStringAsFixed(2)} (${goldPrice.changePercentage >= 0 ? '+' : ''}${goldPrice.changePercentage.toStringAsFixed(2)}%)
📊 المدى: \$${goldPrice.low_24h} - \$${goldPrice.high_24h}
⏰ الوقت: ${goldPrice.timestamp.toString()}
📡 المصدر: ${goldPrice.source}
''';

    if (analysisType == AnalysisType.NIGHTMARE) {
      basePrompt += '''

🔥🔥🔥 **التحليل الشامل المتقدم** 🔥🔥🔥

🎯 **التنسيق المطلوب للتحليل الشامل:**
```
📈 **1. تحليل الأطر الزمنية المتعددة:**
• M5, M15, H1, H4, D1 مع نسب الثقة
• إجماع الأطر الزمنية والتوصية الموحدة

🎯 **2. نقاط الدخول والخروج الدقيقة:**
• نقاط الدخول بالسنت الواحد مع الأسباب
• مستويات الخروج المتدرجة

🛡️ **3. مستويات الدعم والمقاومة:**
• الدعوم والمقاومات مع قوة كل مستوى
• المستويات النفسية المهمة

🔄 **4. نقاط الارتداد المحتملة:**
• مناطق الارتدار عالية الاحتمال
• إشارات التأكيد المطلوبة

⚖️ **5. مناطق العرض والطلب:**
• مناطق العرض المؤسسية
• مناطق الطلب القوية

⚡ **6. استراتيجيات السكالبينج:**
• فرص السكالبينج (1-15 دقيقة)
• نقاط الدخول السريعة

📈 **7. استراتيجيات السوينج:**
• فرص التداول متوسط المدى
• نقاط الدخول الاستراتيجية

🔄 **8. تحليل الانعكاس:**
• نقاط الانعكاس المحتملة
• مؤشرات تأكيد الانعكاس

📊 **9. نسب الثقة المبررة:**
• نسبة ثقة لكل تحليل مع المبررات
• احتمالية نجاح كل سيناريو

ℹ️ **10. توصيات إدارة المخاطر:**
• حجم الصفقة المناسب
• وقف الخسارة المثالي
```''';
    } else if (analysisType == AnalysisType.QUICK) {
      basePrompt += '''

⚡ **التحليل السريع - أقصى 150 كلمة:**

🎯 **التنسيق المطلوب:**
```
🎯 **التوصية:** [BUY/SELL/HOLD]
📈 **السعر الحالي:** \$[السعر]
🔴 **السبب:** [سبب واحد قوي]

📊 **الأهداف:**
🏆 الهدف الأول: \$[السعر]
🔴 وقف الخسارة: \$[السعر]

⏰ **الإطار الزمني:** [المدة المتوقعة]
🔥 **مستوى الثقة:** [نسبة مئوية]%
```''';
    }

    basePrompt += '''

🎯 **متطلبات التنسيق العامة:**
1. استخدام جداول وترتيبات جميلة
2. تقسيم المعلومات إلى أقسام واضحة
3. استخدام رموز تعبيرية مناسبة
4. تنسيق النتائج بطريقة احترافية
5. تقديم نسب ثقة مبررة إحصائياً
6. تحليل احترافي باللغة العربية مع مصطلحات فنية دقيقة
7. نقاط دخول وخروج بالسنت الواحد

⚠️ ملاحظة: هذا تحليل تعليمي وليس نصيحة استثمارية شخصية''';

    return basePrompt;
  }

  String _buildUserPrompt(String prompt, GoldPrice goldPrice,
      AnalysisType analysisType, bool hasImage) {
    String userPrompt = '''
${hasImage ? 'قم بتحليل الشارت المرفق مع البيانات التالية:' : ''}

طلب التحليل: $prompt

البيانات الحالية:
- السعر: \$${goldPrice.price}
- التغيير: ${goldPrice.change_24h >= 0 ? '+' : ''}${goldPrice.change_24h.toStringAsFixed(2)} (${goldPrice.changePercentage >= 0 ? '+' : ''}${goldPrice.changePercentage.toStringAsFixed(2)}%)
- المدى: \$${goldPrice.low_24h} - \$${goldPrice.high_24h}

${hasImage ? 'حلل الشارت واربط التحليل بالبيانات الرقمية المقدمة.' : ''}
''';

    return userPrompt;
  }

  String _generateChartFallbackAnalysis(GoldPrice goldPrice) {
    final trend = goldPrice.changePercentage >= 0 ? 'صاعد' : 'هابط';
    final recommendation = goldPrice.changePercentage >= 1
        ? 'BUY'
        : goldPrice.changePercentage <= -1
            ? 'SELL'
            : 'HOLD';

    return '''
🔄 **تحليل الشارت - نمط احتياطي**

📊 **الوضع الحالي:**
🥇 السعر: \$${goldPrice.price}
📈 الاتجاه: $trend (${goldPrice.changePercentage.toStringAsFixed(2)}%)

🎯 **التوصية الأولية:** $recommendation

📈 **التحليل الفني الأساسي:**
• المستوى الحالي: \$${goldPrice.price}
• الدعم المباشر: \$${(goldPrice.price * 0.995).toStringAsFixed(2)}
• المقاومة المباشرة: \$${(goldPrice.price * 1.005).toStringAsFixed(2)}

⚠️ **ملاحظة:** هذا تحليل أولي. للحصول على تحليل مفصل، يرجى المحاولة مرة أخرى.

🔥 *تم إنتاج هذا التحليل بواسطة Gold Nightmare Academy*
''';
  }

  String _generateTextFallbackAnalysis(
      GoldPrice goldPrice, AnalysisType analysisType) {
    final trend = goldPrice.changePercentage >= 0 ? 'صاعد' : 'هابط';
    final strength = goldPrice.changePercentage.abs() > 1 ? 'قوي' : 'معتدل';

    return '''
📊 **تحليل احتياطي - ${analysisType.name}**

🥇 **البيانات الحالية:**
• السعر: \$${goldPrice.price}
• التغيير: ${goldPrice.changePercentage >= 0 ? '+' : ''}${goldPrice.changePercentage.toStringAsFixed(2)}%
• الاتجاه: $trend $strength

📈 **التحليل الفني:**
• المقاومة: \$${goldPrice.high_24h}
• الدعم: \$${goldPrice.low_24h}
• النطاق: \$${(goldPrice.high_24h - goldPrice.low_24h).toStringAsFixed(2)}

🎯 **التوصية:** ${goldPrice.changePercentage >= 1 ? 'مراقبة للشراء' : goldPrice.changePercentage <= -1 ? 'مراقبة للبيع' : 'انتظار'}

⚠️ **ملاحظة:** تحليل مبسط بسبب ضغط النظام. حاول مرة أخرى للحصول على تحليل مفصل.

🔥 *بواسطة Gold Nightmare Academy*
''';
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      if (!_isInitialized()) {
        initialize();
      }

      final testMessage = Message(role: 'user', content: 'Test connection');
      await _client.createChat(messages: [testMessage], maxTokens: 10);
      return true;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  // Clear cache
  void clearCache() {
    cache.clearCache();
  }
}

// Emoji helper function
String emoji(String name) {
  final emojiMap = {
    'gold': '🥇',
    'chart': '📈',
    'up_arrow': '⬆️',
    'clock': '⏰',
    'signal': '📡',
    'fire': '🔥',
    'target': '🎯',
    'shield': '🛡️',
    'refresh': '🔄',
    'scales': '⚖️',
    'zap': '⚡',
    'info': 'ℹ️',
    'trophy': '🏆',
    'warning': '⚠️',
    'cross': '❌',
    'red_dot': '🔴',
  };
  return emojiMap[name] ?? '•';
}