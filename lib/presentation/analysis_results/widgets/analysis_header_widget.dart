import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;
  final VoidCallback onSharePressed;
  final VoidCallback onBackPressed;

  const AnalysisHeaderWidget({
    super.key,
    required this.analysisData,
    required this.onSharePressed,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPrice = (analysisData['current_price'] as double?) ?? 0.0;
    final priceChange = (analysisData['price_change'] as double?) ?? 0.0;
    final priceChangePercent =
        (analysisData['price_change_percent'] as double?) ?? 0.0;
    final analysisType =
        (analysisData['analysis_type'] as String?) ?? 'تحليل شامل';
    final timestamp = analysisData['timestamp'] as DateTime? ?? DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            children: [
              // App Bar Row
              Row(
                children: [
                  GestureDetector(
                    onTap: onBackPressed,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back_ios',
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'نتائج التحليل',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onSharePressed,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.accentGreen,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Analysis Info Row
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analysisType,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _formatTimestamp(timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.goldColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'trending_up',
                                color: AppTheme.goldColor,
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'XAUUSD',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.goldColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    // Price Information
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'السعر الحالي',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              '\$${currentPrice.toStringAsFixed(2)}',
                              style: AppTheme.tradingDataMedium.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.getProfitLossColor(priceChange)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: priceChange >= 0
                                    ? 'keyboard_arrow_up'
                                    : 'keyboard_arrow_down',
                                color: AppTheme.getProfitLossColor(priceChange),
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '${priceChange >= 0 ? '+' : ''}${priceChange.toStringAsFixed(2)} (${priceChangePercent.toStringAsFixed(2)}%)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      AppTheme.getProfitLossColor(priceChange),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
