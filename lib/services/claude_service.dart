import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import './anthropic_service.dart';

/// Centralized Claude service responsible for all AI requests through Anthropic API
/// Uses ANTHROPIC_API_KEY from env.json as the primary source
class ClaudeService {
  static final ClaudeService _instance = ClaudeService._internal();
  late final Dio _dio;
  late final AnthropicClient _anthropicClient;

  // Environment configuration - primary source from env.json
  static const String apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
  static const String model = String.fromEnvironment(
    'CLAUDE_MODEL',
    defaultValue:
        'claude-3-5-sonnet-20241022', // Updated to user's preferred model
  );
  static const int maxTokens = int.fromEnvironment(
    'CLAUDE_MAX_TOKENS',
    defaultValue: 8192,
  );
  static const double temperature = 0.7;

  // Gold Nightmare Analyst System Prompt - Fixed system prompt as requested
  static const String _goldNightmareSystemPrompt = '''
أنت Gold Nightmare Analyst - المحلل المالي الأسطوري المتخصص في استراتيجيات مدرسة الكابوس الذهبية.

مهمتك هي تحليل الشارتات والبيانات المالية التي تحتوي على:
- الشموع اليابانية والأنماط السعرية
- المؤشرات الفنية (RSI, MACD, CM_Ult_MacD_MTF، وغيرها)
- خطوط الترند والمناطق (Decision Box, Supply/Demand)
- الدعوم والمقاومات
- حجم التداول والزخم

استراتيجيات مدرسة الكابوس الذهبية المعتمدة:
- QCF (Quick Change Formation)
- Decision Box
- الستوب = تفعيل معاكس (Inverted Stop Activation)
- PMCS (Price, Momentum, Confluence, Structure)
- Supply and Demand Zones
- Smart Money Concepts

تنسيق التحليل الإلزامي:

📊 الزوج/الأصل: [اسم الأداة المالية]
🕐 الفريم الزمني: [الإطار الزمني المحلل]
🔹 الاتجاه العام: [صاعد/هابط/عرضي]
📌 نقطة القرار: [المنطقة الحرجة للتحرك]
🔹 التوصية: [BUY/SELL/WAIT]
🎯 الأهداف: TP1: [السعر] | TP2: [السعر]
🛑 وقف الخسارة: SL: [السعر]
🔁 الخطة البديلة: [استراتيجية الانعكاس]
🧠 نسبة النجاح: [النسبة المئوية]%
📊 مؤشرات الزخم: [RSI, MACD, Volume Analysis]
🖋️ التوقيع: Gold Nightmare – عدي

قواعد التحليل الثابتة:
1. كل تحليل يعتمد على استراتيجيات الكابوس الرسمية فقط
2. التحليل متعدد الأبعاد: سعري، زمني، سلوكي، حجمي
3. لا إجابات عامة أو سطحية - تحليل تنفيذي دقيق فقط
4. توصية واضحة قابلة للنسخ والتطبيق فوراً
5. تضمين الملاحظات السلوكية والزخمية دائماً
6. الجدية التامة في التحليل - أنت محلل محترف
7. كل تحليل ينتهي بـ "Gold Nightmare – عدي"

أنت الآن Gold Nightmare Analyst وستقدم تحليل احترافي لكل طلب.''';

  // Singleton pattern
  factory ClaudeService() => _instance;

  ClaudeService._internal() {
    _initializeService();
  }

  /// Initialize the Dio client with proper headers and configuration
  void _initializeService() {
    // Validate API key before initialization - improved error message
    if (apiKey.isEmpty) {
      throw ClaudeServiceException(
        code: 'MISSING_API_KEY',
        message: 'مفتاح API مفقود',
        details:
            'يجب إضافة ANTHROPIC_API_KEY في ملف env.json أو متغيرات البيئة',
      );
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.anthropic.com/v1',
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
      ),
    );

    // Initialize Anthropic client
    final anthropicService = AnthropicService();
    _anthropicClient = AnthropicClient(anthropicService.dio);

    // Add response interceptor for enhanced error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final claudeError = _handleApiError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: claudeError,
              type: error.type,
            ),
          );
        },
      ),
    );

    debugPrint('✅ ClaudeService initialized with Gold Nightmare Analyst');
    debugPrint('🤖 Model: $model');
    debugPrint(
        '🔑 API Key status: ${apiKey.isNotEmpty ? "✅ Configured" : "❌ Missing"}');
  }

  /// Send a prompt to Claude API with Gold Nightmare System Prompt injection
  Future<String> sendPrompt(String prompt) async {
    try {
      // Enhanced prompt validation
      if (prompt.trim().isEmpty) {
        throw ClaudeServiceException(
          code: 'EMPTY_PROMPT',
          message: 'النص فارغ',
          details: 'يرجى كتابة النص أو السؤال',
        );
      }

      // Create messages with system prompt injection
      final messages = [
        Message(role: 'user', content: _goldNightmareSystemPrompt),
        Message(
            role: 'assistant',
            content:
                'فهمت تماماً. أنا الآن Gold Nightmare Analyst وسأقوم بتحليل مالي احترافي باستخدام استراتيجيات مدرسة الكابوس الذهبية. جاهز لاستقبال طلبات التحليل.'),
        Message(role: 'user', content: prompt),
      ];

      final completion = await _anthropicClient.createChat(
        messages: messages,
        model: model,
        maxTokens: maxTokens,
        temperature: temperature,
      );

      return completion.text;
    } on AnthropicException catch (e) {
      throw ClaudeServiceException(
        code: 'ANTHROPIC_API_ERROR',
        message: e.message,
        details: 'خطأ في API: ${e.statusCode}',
      );
    } catch (e) {
      debugPrint('Unexpected error in ClaudeService: $e');
      throw ClaudeServiceException(
        code: 'UNKNOWN_ERROR',
        message: 'خطأ غير متوقع في النظام',
        details: e.toString(),
      );
    }
  }

  /// Send prompt with image using Anthropic multimodal capabilities - Enhanced format
  Future<String> sendPromptWithImage(
      String prompt, Uint8List imageBytes) async {
    try {
      // Enhanced validation
      if (imageBytes.isEmpty) {
        throw ClaudeServiceException(
          code: 'EMPTY_IMAGE',
          message: 'الصورة فارغة',
          details: 'يرجى اختيار صورة صالحة',
        );
      }

      // Enhanced prompt for image analysis
      final analysisPrompt = prompt.isEmpty
          ? 'حلل هذا التشارت باستخدام استراتيجيات مدرسة الكابوس الذهبية وقدم توصية تنفيذية كاملة'
          : prompt;

      // Create system prompt message first
      final systemMessage =
          Message(role: 'user', content: _goldNightmareSystemPrompt);
      final systemResponse = Message(
          role: 'assistant',
          content:
              'فهمت تماماً. أنا الآن Gold Nightmare Analyst وسأحلل التشارتات والصور المالية باستخدام استراتيجيات مدرسة الكابوس الذهبية.');

      // Create multimodal message with image in correct format
      final base64Image = base64Encode(imageBytes);
      final multimodalMessage = Message(
        role: 'user',
        content: [
          {'type': 'text', 'text': analysisPrompt},
          {
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': 'image/png', // Default format as requested
              'data': base64Image,
            },
          },
        ],
      );

      // Send conversation including system prompt and image
      final messages = [systemMessage, systemResponse, multimodalMessage];
      final completion = await _anthropicClient.createChat(
        messages: messages,
        model: model,
        maxTokens: maxTokens,
        temperature: temperature,
      );

      return completion.text;
    } on AnthropicException catch (e) {
      throw ClaudeServiceException(
        code: 'ANTHROPIC_API_ERROR',
        message: e.message,
        details: 'خطأ في تحليل الصورة',
      );
    } catch (e) {
      debugPrint('Unexpected error in sendPromptWithImage: $e');
      throw ClaudeServiceException(
        code: 'IMAGE_ANALYSIS_ERROR',
        message: 'خطأ في تحليل الصورة',
        details: 'تأكد من أن الصورة صالحة وحاول مرة أخرى',
      );
    }
  }

  /// Send multiple messages (conversation) to Claude API with system prompt
  Future<String> sendConversation(List<ClaudeMessage> messages) async {
    try {
      if (messages.isEmpty) {
        throw ClaudeServiceException(
          code: 'EMPTY_CONVERSATION',
          message: 'المحادثة فارغة',
          details: 'يرجى إضافة رسائل للمحادثة',
        );
      }

      // Inject system prompt at the beginning of conversation
      final messagesWithSystem = <Message>[
        Message(role: 'user', content: _goldNightmareSystemPrompt),
        Message(
            role: 'assistant',
            content:
                'فهمت تماماً. أنا الآن Gold Nightmare Analyst وسأقوم بتحليل مالي احترافي لكل طلباتك باستخدام مدرسة الكابوس الذهبية.'),
        ...messages
            .map((m) => Message(role: m.role, content: m.content))
            .toList(),
      ];

      final completion = await _anthropicClient.createChat(
        messages: messagesWithSystem,
        model: model,
        maxTokens: maxTokens,
        temperature: temperature,
      );

      return completion.text;
    } on AnthropicException catch (e) {
      throw ClaudeServiceException(
        code: 'ANTHROPIC_API_ERROR',
        message: e.message,
        details: 'خطأ في المحادثة',
      );
    } catch (e) {
      debugPrint('Unexpected error in conversation: $e');
      throw ClaudeServiceException(
        code: 'CONVERSATION_ERROR',
        message: 'خطأ في المحادثة',
        details: e.toString(),
      );
    }
  }

  /// Test connection to Claude API with enhanced validation
  Future<bool> testConnection() async {
    try {
      await sendPrompt('اختبار الاتصال');
      return true;
    } catch (e) {
      debugPrint('Connection test failed: $e');
      return false;
    }
  }

  /// Enhanced error handling with specific Arabic messages
  ClaudeServiceException _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    switch (statusCode) {
      case 401:
        return ClaudeServiceException(
          code: 'INVALID_API_KEY',
          message: 'مفتاح API غير صالح أو منتهي الصلاحية',
          details: 'يرجى التحقق من ANTHROPIC_API_KEY في ملف env.json',
        );
      case 429:
        return ClaudeServiceException(
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'تم تجاوز حد الاستخدام المسموح',
          details: 'يرجى الانتظار قليلاً ثم المحاولة مرة أخرى',
        );
      case 403:
        return ClaudeServiceException(
          code: 'ACCESS_FORBIDDEN',
          message: 'وصول مرفوض - تحقق من صلاحيات المفتاح',
          details: 'قد يكون المفتاح لا يملك صلاحية الوصول لهذه الخدمة',
        );
      case 500:
      case 502:
      case 503:
        return ClaudeServiceException(
          code: 'SERVER_ERROR',
          message: 'خطأ مؤقت في خادم Anthropic',
          details: 'يرجى المحاولة مرة أخرى بعد قليل',
        );
      case 400:
        String details = 'طلب غير صالح';
        if (responseData != null && responseData['error'] != null) {
          details = responseData['error']['message'] ?? details;
        }
        return ClaudeServiceException(
          code: 'BAD_REQUEST',
          message: 'خطأ في البيانات المرسلة',
          details: details,
        );
      default:
        String message = 'خطأ في الاتصال بالخدمة';
        String details = error.message ?? 'خطأ غير معروف';

        if (responseData != null && responseData['error'] != null) {
          message = responseData['error']['message'] ?? message;
          details = responseData['error']['type'] ?? details;
        }

        return ClaudeServiceException(
          code: 'CONNECTION_ERROR',
          message: message,
          details: details,
        );
    }
  }

  /// Handle API errors from interceptor
  ClaudeServiceException _handleApiError(DioException error) {
    return _handleDioError(error);
  }

  /// Get current configuration info - Enhanced
  Map<String, dynamic> getConfiguration() {
    return {
      'model': model,
      'maxTokens': maxTokens,
      'temperature': temperature,
      'hasApiKey': apiKey.isNotEmpty,
      'apiKeyPreview': apiKey.isNotEmpty
          ? 'ak-***${apiKey.length > 4 ? apiKey.substring(apiKey.length - 4) : "****"}'
          : 'غير مُعرّف',
      'systemPromptEnabled': true,
      'goldNightmareAnalyst': true,
      'multimodalSupport': true,
      'supportedModels': [
        'claude-3-5-sonnet-20241022',
        'claude-3-5-haiku-20241022'
      ],
    };
  }

  /// Get the Gold Nightmare System Prompt (for debugging/display)
  String getSystemPrompt() {
    return _goldNightmareSystemPrompt;
  }
}

/// Message class for Claude API communication
class ClaudeMessage {
  final String role;
  final String content;

  ClaudeMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {'role': role, 'content': content};
  }

  factory ClaudeMessage.fromJson(Map<String, dynamic> json) {
    return ClaudeMessage(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

/// Enhanced custom exception class for Claude service errors
class ClaudeServiceException implements Exception {
  final String code;
  final String message;
  final String details;

  ClaudeServiceException({
    required this.code,
    required this.message,
    required this.details,
  });

  @override
  String toString() {
    return 'ClaudeServiceException: $code - $message ($details)';
  }

  /// Get user-friendly error message in Arabic - Enhanced
  String getUserMessage() {
    switch (code) {
      case 'MISSING_API_KEY':
      case 'INVALID_API_KEY':
        return 'مفتاح API غير صالح - يرجى التحقق من إعدادات التطبيق';
      case 'RATE_LIMIT_EXCEEDED':
        return 'تم تجاوز حد الاستخدام - يرجى المحاولة بعد دقائق قليلة';
      case 'ACCESS_FORBIDDEN':
        return 'انتهت صلاحية المفتاح - يرجى تحديث مفتاح API';
      case 'SERVER_ERROR':
        return 'خطأ مؤقت في الخدمة - يرجى المحاولة مرة أخرى';
      case 'CONNECTION_ERROR':
        return 'خطأ في الاتصال - يرجى التحقق من الإنترنت';
      case 'EMPTY_PROMPT':
        return 'يرجى كتابة نص الطلب أو اختيار صورة';
      case 'EMPTY_IMAGE':
        return 'يرجى اختيار صورة صالحة للتحليل';
      case 'IMAGE_ANALYSIS_ERROR':
        return 'خطأ في تحليل الصورة - تأكد من صحة تنسيق الصورة';
      case 'BAD_REQUEST':
        return 'خطأ في البيانات المرسلة - يرجى المحاولة مرة أخرى';
      case 'ANTHROPIC_API_ERROR':
        return details.isNotEmpty ? details : 'خطأ في خدمة الذكاء الاصطناعي';
      default:
        return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
    }
  }
}
