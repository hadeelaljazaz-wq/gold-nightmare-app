
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SecurityScoreWidget extends StatelessWidget {
  final int score;
  final Map<String, dynamic> profile;
  final AnimationController animationController;

  const SecurityScoreWidget({
    super.key,
    required this.score,
    required this.profile,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(score);
    final scoreStatus = _getScoreStatus(score);

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * animationController.value),
          child: Opacity(
            opacity: animationController.value,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scoreColor.withValues(alpha: 0.1),
                    scoreColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scoreColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Circular Progress Indicator
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: Stack(
                      children: [
                        // Background circle
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 8,
                            backgroundColor: AppTheme.borderColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.borderColor,
                            ),
                          ),
                        ),
                        // Progress circle
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: TweenAnimationBuilder<double>(
                            duration: Duration(milliseconds: 1500),
                            tween: Tween<double>(
                              begin: 0.0,
                              end: score / 100.0,
                            ),
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 8,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  scoreColor,
                                ),
                              );
                            },
                          ),
                        ),
                        // Score text
                        Positioned.fill(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder<int>(
                                  duration: Duration(milliseconds: 1500),
                                  tween: IntTween(begin: 0, end: score),
                                  builder: (context, value, child) {
                                    return Text(
                                      '$value',
                                      style: AppTheme
                                          .darkTheme.textTheme.headlineMedium
                                          ?.copyWith(
                                        color: scoreColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  'Score',
                                  style: AppTheme.darkTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontSize: 8.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 4.w),

                  // Score details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Status',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                color: scoreColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              scoreStatus,
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: scoreColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _getScoreDescription(score),
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        _buildSecurityBadges(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityBadges() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: [
        if (profile['security_status'] == 'activated')
          _buildBadge('Activated', AppTheme.goldColor, Icons.verified),
        if (profile['two_factor_enabled'])
          _buildBadge('2FA', Colors.blue, Icons.security),
        if (profile['biometric_enabled'])
          _buildBadge('Biometric', Colors.green, Icons.fingerprint),
        if (profile['role'] == 'premium')
          _buildBadge('Premium', Colors.purple, Icons.star),
      ],
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return AppTheme.goldColor;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreStatus(int score) {
    if (score >= 80) return 'Secure';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Attention Needed';
    return 'Security Risk';
  }

  String _getScoreDescription(int score) {
    if (score >= 80)
      return 'Your account is well protected with strong security measures.';
    if (score >= 60)
      return 'Good security setup. Consider enabling additional features.';
    if (score >= 40)
      return 'Security needs improvement. Enable recommended features.';
    return 'Critical security issues detected. Immediate action required.';
  }
}
