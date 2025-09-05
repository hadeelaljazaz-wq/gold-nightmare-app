import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DeviceManagementWidget extends StatelessWidget {
  final List<Map<String, dynamic>> sessions;
  final Function(String) onRevokeSession;
  final AnimationController animationController;

  const DeviceManagementWidget({
    super.key,
    required this.sessions,
    required this.onRevokeSession,
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
                        Icons.devices,
                        color: AppTheme.goldColor,
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Active Devices',
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
                          color: AppTheme.goldColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.goldColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${sessions.length} Active',
                          style:
                              AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.goldColor,
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

          // Device List
          if (sessions.isEmpty)
            _buildEmptyState()
          else
            ...sessions.asMap().entries.map((entry) {
              final index = entry.key;
              final session = entry.value;

              return AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(100 * (1 - animationController.value), 0),
                    child: Opacity(
                      opacity: animationController.value,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 3.h),
                        child: _buildDeviceCard(session, index),
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
                  Icons.devices_other,
                  size: 15.w,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No Active Devices',
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'No active device sessions found. This may indicate a system issue.',
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

  Widget _buildDeviceCard(Map<String, dynamic> session, int index) {
    final isCurrentDevice = session['is_current'] ?? false;
    final platformIcon = _getPlatformIcon(session['platform'] ?? 'unknown');
    final lastAccess = _formatLastAccess(session['last_access']);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentDevice
              ? AppTheme.goldColor.withValues(alpha: 0.5)
              : AppTheme.borderColor,
        ),
        boxShadow: isCurrentDevice
            ? [
                BoxShadow(
                  color: AppTheme.goldColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Device Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: platformIcon.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  platformIcon.icon,
                  color: platformIcon.color,
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
                        Text(
                          session['device_name'] ?? 'Unknown Device',
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isCurrentDevice) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.goldColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Current',
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 8.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${session['platform']?.toString().toUpperCase() ?? 'UNKNOWN'} • Last access $lastAccess',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCurrentDevice)
                IconButton(
                  icon: Icon(
                    Icons.power_settings_new,
                    color: Colors.red,
                    size: 5.w,
                  ),
                  onPressed: () => _confirmRevoke(session),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Device Details
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow('Device ID', session['device_id'] ?? 'Unknown'),
                if (session['ip_address'] != null)
                  _buildDetailRow('IP Address', session['ip_address']),
                _buildDetailRow(
                    'Session Started', _formatDate(session['created_at'])),
                _buildDetailRow(
                    'Last Activity', _formatDate(session['last_access'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 10.sp,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRevoke(Map<String, dynamic> session) {
    // This would typically show a confirmation dialog
    HapticFeedback.mediumImpact();
    onRevokeSession(session['id']);
  }

  ({IconData icon, Color color}) _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return (icon: Icons.android, color: Colors.green);
      case 'ios':
        return (icon: Icons.phone_iphone, color: Colors.blue);
      case 'macos':
        return (icon: Icons.laptop_mac, color: Colors.grey);
      case 'windows':
        return (icon: Icons.laptop_windows, color: Colors.blue);
      case 'web':
        return (icon: Icons.web, color: Colors.orange);
      default:
        return (icon: Icons.device_unknown, color: AppTheme.textSecondary);
    }
  }

  String _formatLastAccess(String? lastAccess) {
    if (lastAccess == null) return 'Unknown';

    try {
      final date = DateTime.parse(lastAccess);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }
}