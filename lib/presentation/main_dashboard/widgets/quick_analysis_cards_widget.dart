import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickAnalysisCardsWidget extends StatelessWidget {
  final VoidCallback onQuickAnalysis;
  final VoidCallback onDetailedAnalysis;
  final VoidCallback onScalpingMode;

  const QuickAnalysisCardsWidget({
    super.key,
    required this.onQuickAnalysis,
    required this.onDetailedAnalysis,
    required this.onScalpingMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        children: [
          _buildAnalysisCard(
            title: 'تحليل سريع',
            subtitle: 'نتائج فورية',
            icon: 'flash_on',
            color: AppTheme.accentGreen,
            onTap: onQuickAnalysis,
          ),
          SizedBox(width: 3.w),
          _buildAnalysisCard(
            title: 'تحليل مفصل',
            subtitle: 'تحليل شامل',
            icon: 'analytics',
            color: AppTheme.goldColor,
            onTap: onDetailedAnalysis,
          ),
          SizedBox(width: 3.w),
          _buildAnalysisCard(
            title: 'سكالبينج',
            subtitle: '1-15 دقيقة',
            icon: 'speed',
            color: AppTheme.warningRed,
            onTap: onScalpingMode,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35.w,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
