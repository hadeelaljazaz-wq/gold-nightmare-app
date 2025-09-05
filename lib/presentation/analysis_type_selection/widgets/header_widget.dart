import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HeaderWidget extends StatelessWidget {
  final VoidCallback onClose;
  final int remainingAnalyses;

  const HeaderWidget({
    super.key,
    required this.onClose,
    required this.remainingAnalyses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildDragHandle(),
            SizedBox(height: 2.h),
            _buildHeader(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 12.w,
      height: 0.5.h,
      decoration: BoxDecoration(
        color: AppTheme.borderColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر نوع التحليل',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Select Analysis Type',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: remainingAnalyses > 10
                    ? AppTheme.accentGreen.withValues(alpha: 0.1)
                    : AppTheme.warningRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: remainingAnalyses > 10
                      ? AppTheme.accentGreen.withValues(alpha: 0.3)
                      : AppTheme.warningRed.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'analytics',
                    color: remainingAnalyses > 10
                        ? AppTheme.accentGreen
                        : AppTheme.warningRed,
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '$remainingAnalyses',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: remainingAnalyses > 10
                          ? AppTheme.accentGreen
                          : AppTheme.warningRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Remaining',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.textTertiary,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
        SizedBox(width: 3.w),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onClose,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.textSecondary,
                size: 6.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
