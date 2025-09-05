import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './license_service.dart';
import './supabase_service.dart';
import './anthropic_service.dart';

class AnalysisService {
  static AnalysisService? _instance;
  static AnalysisService get instance => _instance ??= AnalysisService._();
  AnalysisService._();

  SupabaseClient get _client => SupabaseService.instance.client;
  late final AnthropicClient _anthropicClient;

  // Initialize Anthropic client
  void _initializeAnthropicClient() {
    try {
      final anthropicService = AnthropicService();
      _anthropicClient = AnthropicClient(anthropicService.dio);
    } catch (e) {
      debugPrint('Failed to initialize Anthropic client: $e');
      rethrow;
    }
  }

  // Create new analysis with AI processing
  Future<Map<String, dynamic>?> createAnalysis({
    required String type,
    required double price,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to create analysis');
      }

      // Check if user can perform analysis
      final canAnalyze = await LicenseService.instance.canPerformAnalysis();
      if (!canAnalyze) {
        throw Exception('License limit reached or no active license');
      }

      // Create analysis record
      final response = await _client
          .from('analyses')
          .insert({
            'user_id': currentUser.id,
            'type': type,
            'price': price,
            'metadata': metadata ?? {},
            'status': 'pending',
          })
          .select()
          .single();

      debugPrint('Analysis created: ${response['id']}');

      // Start AI analysis in background
      _performAIAnalysis(response['id'], type, price, metadata);

      return response;
    } catch (error) {
      debugPrint('Create analysis error: $error');
      rethrow;
    }
  }

  // Perform AI analysis using Anthropic
  Future<void> _performAIAnalysis(String analysisId, String type, double price,
      Map<String, dynamic>? metadata) async {
    try {
      // Initialize Anthropic client if not already done
      _initializeAnthropicClient();

      // Update status to processing
      await startAnalysisProcessing(analysisId);

      // Perform AI analysis
      final aiResult = await _anthropicClient.analyzeGoldPrice(
        currentPrice: price,
        analysisType: type,
        marketData: metadata,
      );

      // Complete analysis with AI results
      await completeAnalysis(
        analysisId: analysisId,
        result: aiResult,
      );
    } catch (error) {
      debugPrint('AI Analysis error: $error');
      await failAnalysis(analysisId, error.toString());
    }
  }

  // Start processing analysis
  Future<Map<String, dynamic>?> startAnalysisProcessing(
      String analysisId) async {
    try {
      final response = await _client
          .from('analyses')
          .update({
            'status': 'processing',
            'processing_started_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', analysisId)
          .select()
          .single();

      debugPrint('Analysis processing started: $analysisId');
      return response;
    } catch (error) {
      debugPrint('Start processing error: $error');
      rethrow;
    }
  }

  // Complete analysis with results
  Future<Map<String, dynamic>?> completeAnalysis({
    required String analysisId,
    required Map<String, dynamic> result,
    String? chartImageUrl,
  }) async {
    try {
      final response = await _client
          .from('analyses')
          .update({
            'status': 'completed',
            'result': result,
            'chart_image_url': chartImageUrl,
            'completed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', analysisId)
          .select()
          .single();

      // Increment license usage
      await LicenseService.instance.incrementUsage(analysisId);

      debugPrint('Analysis completed: $analysisId');
      return response;
    } catch (error) {
      debugPrint('Complete analysis error: $error');
      rethrow;
    }
  }

  // Mark analysis as failed
  Future<Map<String, dynamic>?> failAnalysis(
      String analysisId, String errorMessage) async {
    try {
      final response = await _client
          .from('analyses')
          .update({
            'status': 'failed',
            'result': {'error': errorMessage},
            'completed_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', analysisId)
          .select()
          .single();

      debugPrint('Analysis failed: $analysisId - $errorMessage');
      return response;
    } catch (error) {
      debugPrint('Fail analysis error: $error');
      rethrow;
    }
  }

  // Get real-time analysis using streaming
  Stream<String> getStreamingAnalysis({
    required String type,
    required double price,
    Map<String, dynamic>? metadata,
  }) async* {
    try {
      _initializeAnthropicClient();

      final prompt = '''
Analyze gold price at \$${price.toStringAsFixed(2)} per ounce for $type analysis.
Market data: ${metadata != null ? metadata.toString() : 'Standard analysis'}

Provide streaming analysis focusing on immediate market conditions and actionable insights.
''';

      final message = Message(role: 'user', content: prompt);

      yield* _anthropicClient.streamChat(
        messages: [message],
        maxTokens: type == 'comprehensive'
            ? 4000
            : type == 'detailed'
                ? 2000
                : 1000,
      );
    } catch (error) {
      debugPrint('Streaming analysis error: $error');
      yield 'Error: ${error.toString()}';
    }
  }

  // Get user's analyses
  Future<List<Map<String, dynamic>>> getUserAnalyses({
    int? limit,
    String? status,
  }) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return [];

      var query = _client
          .from('analyses')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      if (status != null) {
        query = query.eq('status', status);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Get user analyses error: $error');
      return [];
    }
  }

  // Get analysis by ID
  Future<Map<String, dynamic>?> getAnalysisById(String analysisId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return null;

      final response = await _client
          .from('analyses')
          .select()
          .eq('id', analysisId)
          .eq('user_id', currentUser.id)
          .single();

      return response;
    } catch (error) {
      debugPrint('Get analysis error: $error');
      return null;
    }
  }

  // Get analysis statistics
  Future<Map<String, dynamic>> getAnalysisStatistics() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        return {
          'total': 0,
          'completed': 0,
          'pending': 0,
          'processing': 0,
          'failed': 0,
          'total_spent': 0.0,
        };
      }

      final analyses = await getUserAnalyses();

      final stats = {
        'total': analyses.length,
        'completed': 0,
        'pending': 0,
        'processing': 0,
        'failed': 0,
        'total_spent': 0.0,
      };

      for (final analysis in analyses) {
        final status = analysis['status'] as String;
        stats[status] = (stats[status] as int) + 1;

        if (status == 'completed') {
          stats['total_spent'] =
              (stats['total_spent'] as double) + (analysis['price'] ?? 0.0);
        }
      }

      return stats;
    } catch (error) {
      debugPrint('Get analysis statistics error: $error');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'processing': 0,
        'failed': 0,
        'total_spent': 0.0,
      };
    }
  }

  // Get recent analyses
  Future<List<Map<String, dynamic>>> getRecentAnalyses({int limit = 5}) async {
    try {
      return await getUserAnalyses(limit: limit);
    } catch (error) {
      debugPrint('Get recent analyses error: $error');
      return [];
    }
  }

  // Delete analysis
  Future<bool> deleteAnalysis(String analysisId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return false;

      await _client
          .from('analyses')
          .delete()
          .eq('id', analysisId)
          .eq('user_id', currentUser.id);

      debugPrint('Analysis deleted: $analysisId');
      return true;
    } catch (error) {
      debugPrint('Delete analysis error: $error');
      return false;
    }
  }

  // Get analysis pricing
  static Map<String, double> getAnalysisPricing() {
    return {
      'quick': 9.99,
      'detailed': 19.99,
      'comprehensive': 29.99,
    };
  }

  // Get analysis type description
  static Map<String, String> getAnalysisTypeDescriptions() {
    return {
      'quick':
          'Basic technical analysis with key indicators powered by Claude AI',
      'detailed': 'Advanced analysis with multiple timeframes using Claude AI',
      'comprehensive':
          'Complete market analysis with AI predictions and insights',
    };
  }

  // Test Anthropic connection
  Future<bool> testAnthropicConnection() async {
    try {
      _initializeAnthropicClient();
      final models = await _anthropicClient.listModels();
      debugPrint('Anthropic connection successful. Available models: $models');
      return true;
    } catch (error) {
      debugPrint('Anthropic connection test failed: $error');
      return false;
    }
  }
}
