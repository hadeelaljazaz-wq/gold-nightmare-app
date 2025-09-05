import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SubscriptionTierWidget extends StatelessWidget {
  final String currentTier;
  final int remainingAnalyses;
  final int totalAnalyses;
  final VoidCallback onUpgrade;

  const SubscriptionTierWidget({
    super.key,
    required this.currentTier,
    required this.remainingAnalyses,
    required this.totalAnalyses,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usageProgress = (totalAnalyses - remainingAnalyses) / totalAnalyses;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryDark,
            AppTheme.surfaceColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTierColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTierHeader(theme),
          SizedBox(height: 2.h),
          _buildUsageProgress(theme, usageProgress),
          SizedBox(height: 2.h),
          _buildBenefits(theme),
          if (currentTier == 'Basic') ...[
            SizedBox(height: 2.h),
            _buildUpgradeButton(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildTierHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: _getTierColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: _getTierIcon(),
            color: _getTierColor(),
            size: 6.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$currentTier Plan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                '$remainingAnalyses analyses remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: _getTierColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            currentTier.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: _getTierColor(),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageProgress(ThemeData theme, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Monthly Usage',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${totalAnalyses - remainingAnalyses}/$totalAnalyses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1.h,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: progress > 0.8
                      ? [
                          AppTheme.warningRed,
                          AppTheme.warningRed.withValues(alpha: 0.8)
                        ]
                      : [
                          AppTheme.accentGreen,
                          AppTheme.accentGreen.withValues(alpha: 0.8)
                        ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits(ThemeData theme) {
    final benefits = _getTierBenefits();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Benefits',
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...benefits.map((benefit) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.accentGreen,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      benefit,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildUpgradeButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onUpgrade,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldColor,
          foregroundColor: AppTheme.primaryDark,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'upgrade',
              color: AppTheme.primaryDark,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Upgrade to Premium',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor() {
    switch (currentTier.toLowerCase()) {
      case 'basic':
        return AppTheme.textSecondary;
      case 'premium':
        return AppTheme.goldColor;
      case 'vip':
        return AppTheme.accentGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getTierIcon() {
    switch (currentTier.toLowerCase()) {
      case 'basic':
        return 'person';
      case 'premium':
        return 'star';
      case 'vip':
        return 'diamond';
      default:
        return 'person';
    }
  }

  List<String> _getTierBenefits() {
    switch (currentTier.toLowerCase()) {
      case 'basic':
        return [
          '50 analyses per month',
          'Quick & Detailed analysis',
          'Basic market insights',
          'Email support',
        ];
      case 'premium':
        return [
          '200 analyses per month',
          'All analysis types',
          'Advanced AI insights',
          'Priority support',
          'Export reports',
        ];
      case 'vip':
        return [
          'Unlimited analyses',
          'All premium features',
          'Real-time alerts',
          'Dedicated support',
          'Custom strategies',
        ];
      default:
        return [];
    }
  }
}
