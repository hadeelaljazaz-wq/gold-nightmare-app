import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

class UploadProgressWidget extends StatelessWidget {
  final double progress;
  final VoidCallback onCancel;

  const UploadProgressWidget({
    super.key,
    required this.progress,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGreen.withAlpha(77),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload,
                  color: AppTheme.accentGreen,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جاري تحليل الشارت...',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'يرجى الانتظار حتى اكتمال التحليل',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التقدم',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGreen.withAlpha(204),
                          AppTheme.accentGreen,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Status steps
          _buildProgressSteps(context),

          SizedBox(height: 3.h),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warningRed,
                side: const BorderSide(
                  color: AppTheme.warningRed,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 18.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'إلغاء التحليل',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.warningRed,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps(BuildContext context) {
    final steps = [
      {'title': 'رفع الصورة', 'progress': 0.2},
      {'title': 'معالجة الصورة', 'progress': 0.4},
      {'title': 'تحليل البيانات', 'progress': 0.6},
      {'title': 'إنتاج التحليل', 'progress': 0.8},
      {'title': 'الانتهاء', 'progress': 1.0},
    ];

    return Column(
      children: steps.map((step) {
        final isCompleted = progress >= (step['progress'] as double);
        final isActive = progress >= (step['progress'] as double) - 0.2 &&
            progress < (step['progress'] as double);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Step indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.accentGreen
                      : isActive
                          ? AppTheme.goldColor
                          : AppTheme.surfaceColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? AppTheme.accentGreen
                        : isActive
                            ? AppTheme.goldColor
                            : AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: 12,
                        color: AppTheme.primaryDark,
                      )
                    : isActive
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.goldColor,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),

              SizedBox(width: 3.w),

              // Step title
              Text(
                step['title'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? AppTheme.accentGreen
                          : isActive
                              ? AppTheme.goldColor
                              : AppTheme.textTertiary,
                      fontWeight: isActive || isCompleted
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}