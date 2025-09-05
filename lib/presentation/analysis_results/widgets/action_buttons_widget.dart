import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> analysisData;
  final VoidCallback onSharePressed;
  final VoidCallback onSavePressed;
  final VoidCallback onAlertPressed;
  final VoidCallback onExportPressed;

  const ActionButtonsWidget({
    super.key,
    required this.analysisData,
    required this.onSharePressed,
    required this.onSavePressed,
    required this.onAlertPressed,
    required this.onExportPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Primary Actions Row
          Row(
            children: [
              Expanded(
                child: _buildPrimaryButton(
                  context,
                  'مشاركة التحليل',
                  Icons.share,
                  AppTheme.accentGreen,
                  onSharePressed,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildPrimaryButton(
                  context,
                  'تنبيه السعر',
                  Icons.notifications,
                  AppTheme.goldColor,
                  onAlertPressed,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Secondary Actions Row
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  context,
                  'حفظ في المفضلة',
                  Icons.bookmark,
                  onSavePressed,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSecondaryButton(
                  context,
                  'تصدير PDF',
                  Icons.picture_as_pdf,
                  onExportPressed,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // Quick Actions
          Container(
            padding: EdgeInsets.all(3.w),
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
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'flash_on',
                      color: AppTheme.goldColor,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'إجراءات سريعة',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                // Quick Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(
                      context,
                      'نسخ التوصية',
                      Icons.content_copy,
                      () => _copyRecommendation(context),
                    ),
                    _buildQuickActionButton(
                      context,
                      'نسخ المستويات',
                      Icons.format_list_numbered,
                      () => _copyLevels(context),
                    ),
                    _buildQuickActionButton(
                      context,
                      'فتح الرسم البياني',
                      Icons.show_chart,
                      () => _openChart(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Swipe Hint
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'swipe',
                  color: AppTheme.textTertiary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'اسحب يميناً للمشاركة • اسحب يساراً للحفظ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryDark,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderColor.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onPressed();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.textSecondary,
              size: 18,
            ),
            SizedBox(height: 0.5.h),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _copyRecommendation(BuildContext context) {
    final recommendation =
        (analysisData['recommendation'] as String?) ?? 'HOLD';
    final confidence = (analysisData['confidence'] as double?) ?? 0.0;
    final arabicRecommendation = _getArabicRecommendation(recommendation);

    final text =
        'التوصية: $arabicRecommendation\nمستوى الثقة: ${(confidence * 100).toStringAsFixed(0)}%';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ التوصية'),
        backgroundColor: AppTheme.accentGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyLevels(BuildContext context) {
    final entryPrice = (analysisData['entry_price'] as double?) ?? 0.0;
    final takeProfitLevels = (analysisData['take_profit'] as List?) ?? [];
    final stopLoss = (analysisData['stop_loss'] as double?) ?? 0.0;

    String levelsText = 'المستويات الرئيسية:\n';

    if (entryPrice > 0) {
      levelsText += 'نقطة الدخول: \$${entryPrice.toStringAsFixed(2)}\n';
    }

    if (takeProfitLevels.isNotEmpty) {
      levelsText += 'أهداف الربح:\n';
      for (int i = 0; i < takeProfitLevels.length; i++) {
        final level = takeProfitLevels[i] as double;
        levelsText += 'الهدف ${i + 1}: \$${level.toStringAsFixed(2)}\n';
      }
    }

    if (stopLoss > 0) {
      levelsText += 'وقف الخسارة: \$${stopLoss.toStringAsFixed(2)}';
    }

    Clipboard.setData(ClipboardData(text: levelsText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ المستويات'),
        backgroundColor: AppTheme.accentGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openChart(BuildContext context) {
    // Navigate to chart screen or open external chart
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فتح الرسم البياني...'),
        backgroundColor: AppTheme.goldColor,
        duration: Duration(seconds: 2),
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
