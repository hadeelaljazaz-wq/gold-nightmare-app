import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DetailedAnalysisWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const DetailedAnalysisWidget({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysisText = (analysisData['detailed_analysis'] as String?) ?? '';
    final marketSentiment = (analysisData['market_sentiment'] as String?) ?? '';
    final riskLevel = (analysisData['risk_level'] as String?) ?? 'متوسط';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'psychology',
                  color: AppTheme.accentGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'التحليل التفصيلي',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Market Sentiment & Risk Level
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  'معنويات السوق',
                  marketSentiment,
                  _getSentimentColor(marketSentiment),
                  Icons.sentiment_satisfied,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildInfoCard(
                  context,
                  'مستوى المخاطرة',
                  riskLevel,
                  _getRiskColor(riskLevel),
                  Icons.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Detailed Analysis Text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'article',
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'تحليل مفصل',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  analysisText.isNotEmpty
                      ? analysisText
                      : _getDefaultAnalysisText(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // AI Disclaimer
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningRed.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.warningRed,
                  size: 18,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'تنبيه: هذا التحليل مُولد بواسطة الذكاء الاصطناعي ولا يُعتبر نصيحة استثمارية. يرجى إجراء البحث الخاص بك قبل اتخاذ أي قرارات تداول.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningRed,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'إيجابي':
      case 'صاعد':
      case 'متفائل':
        return AppTheme.accentGreen;
      case 'سلبي':
      case 'هابط':
      case 'متشائم':
        return AppTheme.warningRed;
      case 'محايد':
      case 'متوازن':
      default:
        return AppTheme.goldColor;
    }
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'منخفض':
      case 'قليل':
        return AppTheme.accentGreen;
      case 'عالي':
      case 'مرتفع':
        return AppTheme.warningRed;
      case 'متوسط':
      default:
        return AppTheme.goldColor;
    }
  }

  String _getDefaultAnalysisText() {
    return '''بناءً على التحليل الفني الحالي لزوج الذهب مقابل الدولار الأمريكي (XAUUSD)، نلاحظ عدة عوامل مهمة تؤثر على اتجاه السعر:

المؤشرات الفنية تشير إلى وجود زخم إيجابي في السوق، مع كسر مستويات المقاومة الرئيسية. المتوسطات المتحركة تدعم الاتجاه الصاعد الحالي.

من ناحية التحليل الأساسي، العوامل الاقتصادية العالمية والسياسات النقدية تلعب دوراً مهماً في تحديد اتجاه الذهب.

يُنصح بمراقبة مستويات الدعم والمقاومة المحددة، والالتزام بإدارة المخاطر المناسبة عند الدخول في أي صفقات.''';
  }
}
