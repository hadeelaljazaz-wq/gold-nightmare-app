import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PriceAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final Function(int, bool) onToggleAlert;
  final VoidCallback onAddAlert;

  const PriceAlertsWidget({
    super.key,
    required this.alerts,
    required this.onToggleAlert,
    required this.onAddAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تنبيهات الأسعار',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              GestureDetector(
                onTap: onAddAlert,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.accentGreen.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: 'add',
                    color: AppTheme.accentGreen,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (alerts.isEmpty)
            _buildEmptyState()
          else
            ...alerts.asMap().entries.map((entry) {
              final index = entry.key;
              final alert = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: _buildAlertCard(alert, index),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'notifications_off',
            color: AppTheme.textTertiary,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'لا توجد تنبيهات نشطة',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'أضف تنبيه لتتلقى إشعارات عند الوصول لمستويات مهمة',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index) {
    final double targetPrice = (alert['target_price'] as num).toDouble();
    final String type = alert['type'] as String;
    final bool isActive = alert['is_active'] as bool;
    final String condition = alert['condition'] as String; // 'above' or 'below'

    final bool isAbove = condition == 'above';
    final Color alertColor =
        isAbove ? AppTheme.accentGreen : AppTheme.warningRed;
    final String conditionText = isAbove ? 'أعلى من' : 'أقل من';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? alertColor.withValues(alpha: 0.3)
              : AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Alert Icon
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: isAbove ? 'trending_up' : 'trending_down',
              color: alertColor,
              size: 24,
            ),
          ),

          SizedBox(width: 3.w),

          // Alert Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.accentGreen.withValues(alpha: 0.1)
                            : AppTheme.textTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'نشط' : 'متوقف',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isActive
                              ? AppTheme.accentGreen
                              : AppTheme.textTertiary,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 14.sp,
                    ),
                    children: [
                      TextSpan(text: conditionText),
                      TextSpan(text: ' '),
                      TextSpan(
                        text: '\$${targetPrice.toStringAsFixed(2)}',
                        style: AppTheme.tradingDataMedium.copyWith(
                          color: alertColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Toggle Switch
          Switch(
            value: isActive,
            onChanged: (value) => onToggleAlert(index, value),
            activeColor: AppTheme.accentGreen,
            inactiveThumbColor: AppTheme.textTertiary,
            inactiveTrackColor: AppTheme.borderColor,
          ),
        ],
      ),
    );
  }
}
