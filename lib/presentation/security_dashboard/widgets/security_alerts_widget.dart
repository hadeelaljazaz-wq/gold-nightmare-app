import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SecurityAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final AnimationController animationController;

  const SecurityAlertsWidget({
    super.key,
    required this.alerts,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - animationController.value)),
                child: Opacity(
                  opacity: animationController.value,
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: AppTheme.goldColor,
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Security Alerts',
                        style:
                            AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getAlertCountColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getAlertCountColor().withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${alerts.length} Alerts',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: _getAlertCountColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 3.h),

          // Severity Filter Chips
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-100 * (1 - animationController.value), 0),
                child: Opacity(
                  opacity: animationController.value,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSeverityChip('All', _getAllAlertsCount()),
                        SizedBox(width: 2.w),
                        _buildSeverityChip(
                            'Critical', _getCriticalCount(), Colors.red),
                        SizedBox(width: 2.w),
                        _buildSeverityChip(
                            'High', _getHighCount(), Colors.orange),
                        SizedBox(width: 2.w),
                        _buildSeverityChip(
                            'Medium', _getMediumCount(), AppTheme.goldColor),
                        SizedBox(width: 2.w),
                        _buildSeverityChip('Low', _getLowCount(), Colors.green),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 3.h),

          // Alerts List
          if (alerts.isEmpty)
            _buildEmptyState()
          else
            ...alerts.asMap().entries.map((entry) {
              final index = entry.key;
              final alert = entry.value;

              return AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(50 * (1 - animationController.value), 0),
                    child: Opacity(
                      opacity: animationController.value,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        child: _buildAlertCard(alert, index),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildSeverityChip(String label, int count, [Color? color]) {
    final chipColor = color ?? AppTheme.textSecondary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (count > 0) ...[
            SizedBox(width: 1.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 8.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: animationController.value,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.security,
                  size: 15.w,
                  color: Colors.green,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No Security Alerts',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Great! No security alerts have been detected. Your account is secure.',
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index) {
    final severity = alert['severity'] ?? 'low';
    final alertInfo = _getAlertInfo(severity);
    final isResolved = alert['resolved'] ?? false;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isResolved
              ? AppTheme.borderColor
              : alertInfo.color.withValues(alpha: 0.5),
        ),
        boxShadow: isResolved
            ? null
            : [
                BoxShadow(
                  color: alertInfo.color.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alert Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: alertInfo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  alertInfo.icon,
                  color: alertInfo.color,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatAlertType(alert['alert_type'] ?? ''),
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: alertInfo.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: alertInfo.color.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            severity.toUpperCase(),
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: alertInfo.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _formatDate(alert['created_at']),
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Alert Message
          Text(
            alert['message'] ?? 'No message available',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),

          // Metadata
          if (alert['metadata'] != null && alert['metadata'].isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Additional Info: ${alert['metadata']}',
                style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],

          // Resolution Status
          if (isResolved) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Resolved on ${_formatDate(alert['resolved_at'])}',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  ({IconData icon, Color color}) _getAlertInfo(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return (icon: Icons.error, color: Colors.red);
      case 'high':
        return (icon: Icons.warning, color: Colors.orange);
      case 'medium':
        return (icon: Icons.info, color: AppTheme.goldColor);
      case 'low':
      default:
        return (icon: Icons.info_outline, color: Colors.green);
    }
  }

  String _formatAlertType(String alertType) {
    return alertType
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Color _getAlertCountColor() {
    final criticalCount = _getCriticalCount();
    final highCount = _getHighCount();

    if (criticalCount > 0) return Colors.red;
    if (highCount > 0) return Colors.orange;
    if (alerts.isNotEmpty) return AppTheme.goldColor;
    return Colors.green;
  }

  int _getAllAlertsCount() => alerts.length;
  int _getCriticalCount() =>
      alerts.where((a) => a['severity'] == 'critical').length;
  int _getHighCount() => alerts.where((a) => a['severity'] == 'high').length;
  int _getMediumCount() =>
      alerts.where((a) => a['severity'] == 'medium').length;
  int _getLowCount() => alerts.where((a) => a['severity'] == 'low').length;
}