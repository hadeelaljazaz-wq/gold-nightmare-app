import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MarketSentimentWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const MarketSentimentWidget({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidence = (analysisData['confidence'] as double?) ?? 0.75;
    final marketSentiment =
        (analysisData['market_sentiment'] as String?) ?? 'إيجابي';
    final sentimentScore = (analysisData['sentiment_score'] as double?) ?? 0.75;

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
                  iconName: 'sentiment_satisfied',
                  color: AppTheme.accentGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'معنويات السوق',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Sentiment Gauge
          Center(
            child: Container(
              width: 60.w,
              height: 60.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background Circle
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceColor,
                      border: Border.all(
                        color: AppTheme.borderColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  // Progress Circle
                  SizedBox(
                    width: 55.w,
                    height: 55.w,
                    child: CircularProgressIndicator(
                      value: sentimentScore,
                      strokeWidth: 8,
                      backgroundColor:
                          AppTheme.borderColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSentimentColor(sentimentScore),
                      ),
                    ),
                  ),
                  // Center Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(sentimentScore * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: _getSentimentColor(sentimentScore),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        marketSentiment,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        _getSentimentDescription(sentimentScore),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // Sentiment Breakdown
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'analytics',
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'تفصيل المعنويات',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Sentiment Bars
                _buildSentimentBar(
                  context,
                  'إيجابي',
                  _getPositiveSentiment(sentimentScore),
                  AppTheme.accentGreen,
                  Icons.thumb_up,
                ),
                SizedBox(height: 1.h),
                _buildSentimentBar(
                  context,
                  'محايد',
                  _getNeutralSentiment(sentimentScore),
                  AppTheme.goldColor,
                  Icons.remove,
                ),
                SizedBox(height: 1.h),
                _buildSentimentBar(
                  context,
                  'سلبي',
                  _getNegativeSentiment(sentimentScore),
                  AppTheme.warningRed,
                  Icons.thumb_down,
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Market Factors
          Container(
            padding: EdgeInsets.all(3.w),
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
                      iconName: 'trending_up',
                      color: AppTheme.goldColor,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'العوامل المؤثرة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildFactorChip(
                    context, 'السياسة النقدية', AppTheme.accentGreen),
                SizedBox(height: 1.h),
                _buildFactorChip(context, 'التضخم العالمي', AppTheme.goldColor),
                SizedBox(height: 1.h),
                _buildFactorChip(
                    context, 'التوترات الجيوسياسية', AppTheme.warningRed),
                SizedBox(height: 1.h),
                _buildFactorChip(context, 'قوة الدولار', AppTheme.goldColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentBar(
    BuildContext context,
    String label,
    double percentage,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        SizedBox(width: 2.w),
        SizedBox(
          width: 15.w,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.h,
            decoration: BoxDecoration(
              color: AppTheme.borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        SizedBox(
          width: 10.w,
          child: Text(
            '${percentage.toStringAsFixed(0)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildFactorChip(BuildContext context, String factor, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            factor,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSentimentColor(double score) {
    if (score >= 0.7) {
      return AppTheme.accentGreen;
    } else if (score >= 0.4) {
      return AppTheme.goldColor;
    } else {
      return AppTheme.warningRed;
    }
  }

  String _getSentimentDescription(double score) {
    if (score >= 0.8) {
      return 'معنويات إيجابية قوية';
    } else if (score >= 0.6) {
      return 'معنويات إيجابية معتدلة';
    } else if (score >= 0.4) {
      return 'معنويات محايدة';
    } else if (score >= 0.2) {
      return 'معنويات سلبية معتدلة';
    } else {
      return 'معنويات سلبية قوية';
    }
  }

  double _getPositiveSentiment(double score) {
    return score * 100;
  }

  double _getNeutralSentiment(double score) {
    return (1 - score) * 50;
  }

  double _getNegativeSentiment(double score) {
    return (1 - score) * 50;
  }
}
