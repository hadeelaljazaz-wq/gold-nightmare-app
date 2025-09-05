import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> analyses;
  final Function(int) onShare;
  final Function(int) onDelete;
  final VoidCallback onRefresh;

  const AnalysisHistoryWidget({
    super.key,
    required this.analyses,
    required this.onShare,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: AppTheme.accentGreen,
      backgroundColor: AppTheme.secondaryDark,
      child: analyses.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              itemCount: analyses.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final analysis = analyses[index];
                return _buildAnalysisCard(context, analysis, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.textTertiary,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'لا توجد تحليلات حتى الآن',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'ابدأ أول تحليل لك الآن',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textTertiary,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(
      BuildContext context, Map<String, dynamic> analysis, int index) {
    final String type = analysis['type'] as String;
    final String recommendation = analysis['recommendation'] as String;
    final double confidence = (analysis['confidence'] as num).toDouble();
    final String timestamp = analysis['timestamp'] as String;
    final double entryPrice = (analysis['entry_price'] as num).toDouble();
    final double? takeProfit = analysis['take_profit'] != null
        ? (analysis['take_profit'] as num).toDouble()
        : null;
    final double? stopLoss = analysis['stop_loss'] != null
        ? (analysis['stop_loss'] as num).toDouble()
        : null;

    final bool isBuy = recommendation.toLowerCase() == 'buy';
    final Color recommendationColor =
        isBuy ? AppTheme.accentGreen : AppTheme.warningRed;

    return Dismissible(
      key: Key('analysis_$index'),
      background: Container(
        decoration: BoxDecoration(
          color: AppTheme.accentGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'share',
              color: AppTheme.textPrimary,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'مشاركة',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: AppTheme.warningRed,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.textPrimary,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'حذف',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onShare(index);
        } else {
          onDelete(index);
        }
      },
      child: GestureDetector(
        onLongPress: () => _showContextMenu(context, index),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.borderColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: recommendationColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: recommendationColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      type,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: recommendationColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    timestamp,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Recommendation
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: recommendationColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      recommendation.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryDark,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مستوى الثقة',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: confidence / 100,
                                backgroundColor: AppTheme.borderColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  confidence >= 70
                                      ? AppTheme.accentGreen
                                      : confidence >= 50
                                          ? AppTheme.goldColor
                                          : AppTheme.warningRed,
                                ),
                                minHeight: 4,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${confidence.toInt()}%',
                              style: AppTheme.tradingDataSmall.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Price Levels
              Row(
                children: [
                  Expanded(
                    child: _buildPriceLevel(
                      'سعر الدخول',
                      '\$${entryPrice.toStringAsFixed(2)}',
                      AppTheme.textPrimary,
                    ),
                  ),
                  if (takeProfit != null) ...[
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildPriceLevel(
                        'هدف الربح',
                        '\$${takeProfit.toStringAsFixed(2)}',
                        AppTheme.accentGreen,
                      ),
                    ),
                  ],
                  if (stopLoss != null) ...[
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildPriceLevel(
                        'وقف الخسارة',
                        '\$${stopLoss.toStringAsFixed(2)}',
                        AppTheme.warningRed,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceLevel(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.tradingDataSmall.copyWith(
            color: color,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showContextMenu(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.accentGreen,
                size: 24,
              ),
              title: Text(
                'مشاركة التحليل',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onShare(index);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: AppTheme.goldColor,
                size: 24,
              ),
              title: Text(
                'تصدير التحليل',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Export functionality would be implemented here
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications',
                color: AppTheme.textSecondary,
                size: 24,
              ),
              title: Text(
                'إنشاء تنبيه',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Alert creation functionality would be implemented here
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.warningRed,
                size: 24,
              ),
              title: Text(
                'حذف التحليل',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDelete(index);
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
