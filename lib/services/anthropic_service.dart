import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AnthropicService {
  static final AnthropicService _instance = AnthropicService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('ANTHROPIC_API_KEY');
  static const String model = String.fromEnvironment('CLAUDE_MODEL',
      defaultValue: 'claude-3-5-sonnet-20241022');
  static const int maxTokens =
      int.fromEnvironment('CLAUDE_MAX_TOKENS', defaultValue: 8000);
  static const double temperature = 0.3;

  factory AnthropicService() {
    return _instance;
  }

  AnthropicService._internal() {
    _initializeService();
  }

  void _initializeService() {
    if (apiKey.isEmpty) {
      throw Exception(
          'مفتاح API غير موجود: يجب إضافة ANTHROPIC_API_KEY في ملف env.json');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.anthropic.com/v1',
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
          'anthropic-dangerous-direct-browser-access': 'true'
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
      ),
    );

    debugPrint('✅ Anthropic Service initialized successfully');
    debugPrint('🔑 API Key: ${apiKey.isNotEmpty ? "Configured" : "Missing"}');
    debugPrint('🤖 Model: $model');
  }

  Dio get dio => _dio;
}

class AnthropicClient {
  final Dio dio;

  AnthropicClient(this.dio);

  Future<Completion> createChat({
    required List<Message> messages,
    String? model,
    int? maxTokens,
    double? temperature,
  }) async {
    try {
      final response = await dio.post(
        '/messages',
        data: {
          'model': model ?? AnthropicService.model,
          'max_tokens': maxTokens ?? AnthropicService.maxTokens,
          'messages': messages
              .map((m) => {
                    'role': m.role,
                    'content': m.content is String ? m.content : m.content,
                  })
              .toList(),
          if ((temperature ?? AnthropicService.temperature) != 1.0)
            'temperature': temperature ?? AnthropicService.temperature,
        },
      );
      final text = response.data['content'][0]['text'];
      return Completion(text: text);
    } on DioException catch (e) {
      debugPrint(
          'Anthropic API error: ${e.response?.statusCode} - ${e.response?.data}');
      throw AnthropicException(
        statusCode: e.response?.statusCode ?? 500,
        message: _getArabicErrorMessage(e),
      );
    } catch (e) {
      debugPrint('Unexpected error in Anthropic API: $e');
      throw AnthropicException(
        statusCode: 500,
        message: 'خطأ غير متوقع في النظام',
      );
    }
  }

  Stream<String> streamChat({
    required List<Message> messages,
    String? model,
    int? maxTokens,
    double? temperature,
  }) async* {
    try {
      final response = await dio.post(
        '/messages',
        data: {
          'model': model ?? AnthropicService.model,
          'max_tokens': maxTokens ?? AnthropicService.maxTokens,
          'messages': messages
              .map((m) => {
                    'role': m.role,
                    'content': m.content is String ? m.content : m.content,
                  })
              .toList(),
          'stream': true,
          if ((temperature ?? AnthropicService.temperature) != 1.0)
            'temperature': temperature ?? AnthropicService.temperature,
        },
        options: Options(responseType: ResponseType.stream),
      );
      final stream = response.data as ResponseBody;
      await for (var line
          in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
        if (line.startsWith('data: ') && !line.contains('[DONE]')) {
          final data = line.substring(6);
          if (data.isNotEmpty) {
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              if (json['type'] == 'content_block_delta') {
                final text = json['delta']['text'];
                if (text != null) yield text;
              }
            } catch (e) {
              // Skip malformed JSON
              continue;
            }
          }
        }
      }
    } on DioException catch (e) {
      throw AnthropicException(
        statusCode: e.response?.statusCode ?? 500,
        message: _getArabicErrorMessage(e),
      );
    }
  }

  Future<Completion> createMultimodal({
    required String prompt,
    required Uint8List imageBytes,
    String? model,
    int? maxTokens,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      String mediaType = 'image/jpeg';

      // Detect image format from bytes
      if (imageBytes.length > 4) {
        if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50) {
          mediaType = 'image/png';
        } else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
          mediaType = 'image/jpeg';
        } else if (imageBytes[0] == 0x47 && imageBytes[1] == 0x49) {
          mediaType = 'image/gif';
        } else if (imageBytes[0] == 0x57 && imageBytes[1] == 0x45) {
          mediaType = 'image/webp';
        }
      }

      final message = Message(
        role: 'user',
        content: [
          {
            'type': 'image',
            'source': {
              'type': 'base64',
              'media_type': mediaType,
              'data': base64Image,
            },
          },
          {
            'type': 'text',
            'text': prompt,
          },
        ],
      );

      return createChat(
          messages: [message],
          model: model ?? AnthropicService.model,
          maxTokens: maxTokens ?? AnthropicService.maxTokens);
    } catch (e) {
      debugPrint('Error in createMultimodal: $e');
      throw AnthropicException(
        statusCode: 500,
        message: 'خطأ في معالجة الصورة: تأكد من أن الصورة صالحة',
      );
    }
  }

  Future<List<String>> listModels() async {
    return [
      'claude-3-5-sonnet-20241022',
      'claude-3-5-haiku-20241022',
      'claude-3-opus-20240229',
      'claude-3-sonnet-20240229',
      'claude-3-haiku-20240307',
    ];
  }

  Future<Balance> getUserBalance() async {
    throw UnimplementedError(
        'Anthropic API does not support balance retrieval.');
  }

  String _getArabicErrorMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;

    switch (statusCode) {
      case 401:
        return 'مفتاح API غير صالح: تحقق من ANTHROPIC_API_KEY في ملف env.json';
      case 429:
        return 'تم تجاوز حد الاستخدام: حاول مرة أخرى بعد قليل';
      case 403:
        return 'وصول مرفوض: تحقق من صلاحيات المفتاح';
      case 500:
      case 502:
      case 503:
        return 'خطأ في خادم Anthropic: حاول مرة أخرى بعد قليل';
      case 400:
        String details = '';
        if (responseData != null && responseData['error'] != null) {
          details = responseData['error']['message'] ?? '';
        }
        return 'طلب غير صالح: $details';
      default:
        String message = 'خطأ في الاتصال';
        if (responseData != null && responseData['error'] != null) {
          message = responseData['error']['message'] ?? message;
        }
        return message;
    }
  }
}

class Message {
  final String role;
  final dynamic content; // String or List<Map<String, dynamic>>

  Message({required this.role, required this.content});
}

class Completion {
  final String text;

  Completion({required this.text});
}

class Balance {
  final String info;

  Balance({required this.info});
}

class AnthropicException implements Exception {
  final int statusCode;
  final String message;

  AnthropicException({required this.statusCode, required this.message});

  @override
  String toString() => 'AnthropicException: $statusCode - $message';
}
