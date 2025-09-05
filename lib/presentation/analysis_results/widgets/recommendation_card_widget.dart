import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecommendationCardWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const RecommendationCardWidget({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recommendation =
        (analysisData['recommendation'] as String?) ?? 'HOLD';
    final confidence = (analysisData['confidence'] as double?) ?? 0.0;
    final isBuy = recommendation.toUpperCase() == 'BUY';
    final isSell = recommendation.toUpperCase() == 'SELL';

    final backgroundColor = isBuy
        ? AppTheme.accentGreen
        : isSell
            ? AppTheme.warningRed
            : AppTheme.surfaceColor;

    final textColor =
        (isBuy || isSell) ? AppTheme.primaryDark : AppTheme.textPrimary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Recommendation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: isBuy
                      ? 'trending_up'
                      : isSell
                          ? 'trending_down'
                          : 'remove',
                  color: textColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التوصية',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _getArabicRecommendation(recommendation),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 24.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Confidence Section
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'مستوى الثقة',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(confidence * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                // Confidence Progress Bar
                Container(
                  height: 1.h,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: confidence,
                    child: Container(
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _getConfidenceDescription(confidence),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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

  String _getConfidenceDescription(double confidence) {
    if (confidence >= 0.9) {
      return 'ثقة عالية جداً - إشارة قوية للغاية';
    } else if (confidence >= 0.8) {
      return 'ثقة عالية - إشارة قوية';
    } else if (confidence >= 0.7) {
      return 'ثقة جيدة - إشارة موثوقة';
    } else if (confidence >= 0.6) {
      return 'ثقة متوسطة - توخي الحذر';
    } else {
      return 'ثقة منخفضة - انتظار إشارات أوضح';
    }
  }
}
