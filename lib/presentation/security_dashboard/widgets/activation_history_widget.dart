import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ActivationHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> attempts;
  final AnimationController animationController;

  const ActivationHistoryWidget({
    super.key,
    required this.attempts,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animationController.value)),
          child: Opacity(
            opacity: animationController.value,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: AppTheme.goldColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Activation History',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildStatsChip(),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // History List
                  if (attempts.isEmpty)
                    _buildEmptyHistory()
                  else
                    ...attempts.map((attempt) => _buildHistoryItem(attempt)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsChip() {
    final successCount = attempts.where((a) => a['success'] == true).length;
    final failureCount = attempts.length - successCount;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.goldColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${attempts.length} Total',
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.goldColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (attempts.isNotEmpty) ...[
            SizedBox(width: 1.w),
            Text(
              '($successCount success, $failureCount failed)',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 8.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Column(
        children: [
          Icon(
            Icons.timeline,
            size: 10.w,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 1.h),
          Text(
            'No Activation History',
            style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Activation attempts will appear here',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> attempt) {
    final isSuccess = attempt['success'] ?? false;
    final statusColor = isSuccess ? Colors.green : Colors.red;
    final statusIcon = isSuccess ? Icons.check_circle : Icons.cancel;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Status and Code Row
          Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSuccess ? 'Activation Successful' : 'Activation Failed',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isSuccess && attempt['failure_reason'] != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        attempt['failure_reason'],
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                _formatDate(attempt['created_at']),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Attempt Details
          Row(
            children: [
              // Code preview (masked)
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _maskActivationCode(attempt['attempted_code'] ?? ''),
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),

              SizedBox(width: 2.w),

              // Additional info
              if (attempt['ip_address'] != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    attempt['ip_address'],
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      fontSize: 8.sp,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _maskActivationCode(String code) {
    if (code.length <= 8) return code;

    final start = code.substring(0, 4);
    final end = code.substring(code.length - 4);
    final middle = '*' * (code.length - 8);

    return '$start$middle$end';
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}