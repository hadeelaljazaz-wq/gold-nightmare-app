import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final String estimatedTime;
  final String iconName;
  final bool isPremium;
  final bool isAvailable;
  final int usageCount;
  final int maxUsage;
  final double accuracyRate;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AnalysisTypeCard({
    super.key,
    required this.title,
    required this.description,
    required this.estimatedTime,
    required this.iconName,
    this.isPremium = false,
    this.isAvailable = true,
    required this.usageCount,
    required this.maxUsage,
    required this.accuracyRate,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: AppTheme.fastAnimation,
            curve: Curves.easeOut,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppTheme.secondaryDark
                  : AppTheme.surfaceColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAvailable
                    ? AppTheme.borderColor.withValues(alpha: 0.3)
                    : AppTheme.borderColor.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: isAvailable
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                SizedBox(height: 2.h),
                _buildDescription(theme),
                SizedBox(height: 2.h),
                _buildMetrics(theme),
                if (!isAvailable) ...[
                  SizedBox(height: 1.h),
                  _buildUnavailableMessage(theme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isAvailable
                ? AppTheme.accentGreen.withValues(alpha: 0.1)
                : AppTheme.textTertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: isAvailable ? AppTheme.accentGreen : AppTheme.textTertiary,
            size: 6.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isAvailable
                            ? AppTheme.textPrimary
                            : AppTheme.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPremium) ...[
                    SizedBox(width: 2.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.goldColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'lock',
                            color: AppTheme.goldColor,
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Premium',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppTheme.goldColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 0.5.h),
              Text(
                estimatedTime,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isAvailable
                      ? AppTheme.textSecondary
                      : AppTheme.textTertiary,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Text(
      description,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isAvailable ? AppTheme.textSecondary : AppTheme.textTertiary,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetrics(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            theme,
            'Usage',
            '$usageCount/$maxUsage',
            usageCount / maxUsage,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildMetricItem(
            theme,
            'Accuracy',
            '${(accuracyRate * 100).toInt()}%',
            accuracyRate,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(
      ThemeData theme, String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isAvailable
                    ? AppTheme.textSecondary
                    : AppTheme.textTertiary,
                fontSize: 9.sp,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    isAvailable ? AppTheme.textPrimary : AppTheme.textTertiary,
                fontWeight: FontWeight.w600,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Container(
          height: 0.5.h,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: isAvailable
                    ? (label == 'Usage'
                        ? (progress > 0.8
                            ? AppTheme.warningRed
                            : AppTheme.accentGreen)
                        : AppTheme.accentGreen)
                    : AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnavailableMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.warningRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.warningRed.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'schedule',
            color: AppTheme.warningRed,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Limit reached. Next available in 2h 15m',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.warningRed,
                fontSize: 9.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
