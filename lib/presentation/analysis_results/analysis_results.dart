import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/analysis_header_widget.dart';
import './widgets/detailed_analysis_widget.dart';
import './widgets/key_levels_widget.dart';
import './widgets/market_sentiment_widget.dart';
import './widgets/recommendation_card_widget.dart';
import './widgets/technical_indicators_widget.dart';

class AnalysisResults extends StatefulWidget {
  const AnalysisResults({super.key});

  @override
  State<AnalysisResults> createState() => _AnalysisResultsState();
}

class _AnalysisResultsState extends State<AnalysisResults> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // Mock analysis data
  final Map<String, dynamic> _analysisData = {
    'id': 'analysis_001',
    'analysis_type': 'تحليل شامل',
    'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
    'current_price': 2658.75,
    'price_change': 12.50,
    'price_change_percent': 0.47,
    'recommendation': 'BUY',
    'confidence': 0.85,
    'entry_price': 2660.00,
    'take_profit': [2675.00, 2690.00, 2705.00],
    'stop_loss': 2645.00,
    'market_sentiment': 'إيجابي',
    'sentiment_score': 0.78,
    'risk_level': 'متوسط',
    'detailed_analysis':
        '''بناءً على التحليل الفني الشامل لزوج الذهب مقابل الدولار الأمريكي (XAUUSD)، نلاحظ تكون نموذج صاعد قوي مع كسر مستوى المقاومة الرئيسي عند 2650 دولار.

المؤشرات الفنية تدعم الاتجاه الصاعد:
• مؤشر القوة النسبية (RSI) يشير إلى زخم إيجابي عند مستوى 65
• مؤشر الماكد (MACD) يظهر إشارة شراء قوية
• المتوسطات المتحركة تدعم الاتجاه الصاعد

العوامل الأساسية المؤثرة:
• ضعف الدولار الأمريكي مقابل العملات الرئيسية
• التوقعات بخفض أسعار الفائدة من البنك الفيدرالي
• التوترات الجيوسياسية تدعم الطلب على الملاذات الآمنة

التوصية: شراء عند المستويات الحالية مع الالتزام بمستويات وقف الخسارة المحددة.''',
    'technical_indicators': {
      'rsi': 65.2,
      'macd': 0.85,
      'ma20': 2652.30,
      'ma50': 2645.80,
      'stochastic': 72.5,
      'bollinger_position': 0.75,
    },
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe right - Share
            _handleShare();
          } else if (details.primaryVelocity! < 0) {
            // Swipe left - Save
            _handleSave();
          }
        },
        child: Column(
          children: [
            // Sticky Header
            AnalysisHeaderWidget(
              analysisData: _analysisData,
              onSharePressed: _handleShare,
              onBackPressed: _handleBack,
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 1.h),
                    // Main Recommendation Card
                    RecommendationCardWidget(
                      analysisData: _analysisData,
                    ),
                    // Key Levels Section
                    KeyLevelsWidget(
                      analysisData: _analysisData,
                    ),
                    // Technical Indicators
                    TechnicalIndicatorsWidget(
                      analysisData: _analysisData,
                    ),
                    // Market Sentiment
                    MarketSentimentWidget(
                      analysisData: _analysisData,
                    ),
                    // Detailed Analysis
                    DetailedAnalysisWidget(
                      analysisData: _analysisData,
                    ),
                    // Action Buttons
                    ActionButtonsWidget(
                      analysisData: _analysisData,
                      onSharePressed: _handleShare,
                      onSavePressed: _handleSave,
                      onAlertPressed: _handlePriceAlert,
                      onExportPressed: _handleExport,
                    ),
                    // Bottom Padding
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    HapticFeedback.lightImpact();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main-dashboard',
      (route) => false,
    );
  }

  void _handleShare() {
    HapticFeedback.mediumImpact();

    final recommendation =
        (_analysisData['recommendation'] as String?) ?? 'HOLD';
    final confidence = (_analysisData['confidence'] as double?) ?? 0.0;
    final currentPrice = (_analysisData['current_price'] as double?) ?? 0.0;
    final entryPrice = (_analysisData['entry_price'] as double?) ?? 0.0;
    final takeProfitLevels = (_analysisData['take_profit'] as List?) ?? [];
    final stopLoss = (_analysisData['stop_loss'] as double?) ?? 0.0;

    String shareText = '''🔥 تحليل الذهب XAUUSD - Gold Nightmare App 🔥

📊 التوصية: ${_getArabicRecommendation(recommendation)}
🎯 مستوى الثقة: ${(confidence * 100).toStringAsFixed(0)}%
💰 السعر الحالي: \$${currentPrice.toStringAsFixed(2)}

📈 المستويات الرئيسية:
🔹 نقطة الدخول: \$${entryPrice.toStringAsFixed(2)}''';

    if (takeProfitLevels.isNotEmpty) {
      shareText += '\n🎯 أهداف الربح:';
      for (int i = 0; i < takeProfitLevels.length; i++) {
        final level = takeProfitLevels[i] as double;
        shareText += '\n   الهدف ${i + 1}: \$${level.toStringAsFixed(2)}';
      }
    }

    if (stopLoss > 0) {
      shareText += '\n🛑 وقف الخسارة: \$${stopLoss.toStringAsFixed(2)}';
    }

    shareText +=
        '\n\n⚠️ تنبيه: هذا التحليل مُولد بواسطة الذكاء الاصطناعي ولا يُعتبر نصيحة استثمارية.';

    // Copy to clipboard as sharing functionality
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ التحليل للمشاركة'),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'إغلاق',
          textColor: AppTheme.primaryDark,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _handleSave() {
    HapticFeedback.mediumImpact();

    // Simulate saving to favorites
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'bookmark',
              color: AppTheme.primaryDark,
              size: 20,
            ),
            SizedBox(width: 2.w),
            const Text('تم حفظ التحليل في المفضلة'),
          ],
        ),
        backgroundColor: AppTheme.accentGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handlePriceAlert() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildPriceAlertSheet(),
    );
  }

  void _handleExport() {
    HapticFeedback.lightImpact();

    // Simulate PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'picture_as_pdf',
              color: AppTheme.primaryDark,
              size: 20,
            ),
            SizedBox(width: 2.w),
            const Text('جاري تصدير التحليل كـ PDF...'),
          ],
        ),
        backgroundColor: AppTheme.goldColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildPriceAlertSheet() {
    final theme = Theme.of(context);
    final TextEditingController priceController = TextEditingController();

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          // Title
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.goldColor,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'إعداد تنبيه السعر',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Price Input
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'السعر المستهدف',
              hintText: '2700.00',
              prefixText: '\$ ',
              suffixIcon: CustomIconWidget(
                iconName: 'trending_up',
                color: AppTheme.goldColor,
                size: 20,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إعداد تنبيه السعر بنجاح'),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                  },
                  child: const Text('إعداد التنبيه'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  String _getArabicRecommendation(String recommendation) {
    switch (recommendation.toUpperCase()) {
      case 'BUY':
        return 'شراء';
      case 'SELL':
        return 'بيع';
      case 'HOLD':
        return 'انتظار';
      case 'STRONG_BUY':
        return 'شراء قوي';
      case 'STRONG_SELL':
        return 'بيع قوي';
      default:
        return 'انتظار';
    }
  }
}
