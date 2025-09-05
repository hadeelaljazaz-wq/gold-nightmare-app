import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SecuritySettingsWidget extends StatelessWidget {
  final Map<String, dynamic> profile;
  final Function(String, bool) onSettingChanged;
  final AnimationController animationController;

  const SecuritySettingsWidget({
    super.key,
    required this.profile,
    required this.onSettingChanged,
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
                        Icons.settings_applications,
                        color: AppTheme.goldColor,
                        size: 6.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Security Settings',
                        style:
                            AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // Authentication Settings
          _buildSettingsSection(
            'Authentication',
            Icons.security,
            [
              _buildSettingTile(
                'Two-Factor Authentication',
                'Add an extra layer of security to your account',
                Icons.verified_user,
                profile['two_factor_enabled'] ?? false,
                (value) => onSettingChanged('two_factor', value),
                true,
              ),
              _buildSettingTile(
                'Biometric Authentication',
                'Use fingerprint or face recognition',
                Icons.fingerprint,
                profile['biometric_enabled'] ?? false,
                (value) => onSettingChanged('biometric', value),
                true,
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Session Settings
          _buildSettingsSection(
            'Session Management',
            Icons.schedule,
            [
              _buildInfoTile(
                'Session Timeout',
                'Sessions expire after 30 days of inactivity',
                Icons.timer,
              ),
              _buildInfoTile(
                'Maximum Devices',
                _getMaxDevicesText(),
                Icons.devices,
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Notification Settings
          _buildSettingsSection(
            'Notifications',
            Icons.notifications,
            [
              _buildSettingTile(
                'Security Notifications',
                'Get notified about security events',
                Icons.notification_important,
                profile['security_notifications'] ?? true,
                (value) => onSettingChanged('notifications', value),
                true,
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Account Information
          _buildAccountInfo(),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - animationController.value), 0),
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
                  // Section Header
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: AppTheme.goldColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        title,
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Section Content
                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool enabled,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.goldColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.goldColor,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppTheme.goldColor,
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.textSecondary,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - animationController.value)),
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
                  Row(
                    children: [
                      Icon(
                        Icons.account_circle,
                        color: AppTheme.goldColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Account Information',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  _buildAccountDetail(
                      'Email', profile['email'] ?? 'Not available'),
                  _buildAccountDetail(
                      'Full Name', profile['full_name'] ?? 'Not available'),
                  _buildAccountDetail('Account Type',
                      _formatRole(profile['role'] ?? 'standard')),
                  _buildAccountDetail('Security Status',
                      _formatSecurityStatus(profile['security_status'])),
                  _buildAccountDetail(
                      'Member Since', _formatDate(profile['created_at'])),
                  _buildAccountDetail(
                      'Last Updated', _formatDate(profile['updated_at'])),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMaxDevicesText() {
    final role = profile['role'] ?? 'standard';
    switch (role) {
      case 'premium':
        return 'Up to 3 devices allowed';
      case 'admin':
        return 'Unlimited devices';
      default:
        return 'Up to 1 device allowed';
    }
  }

  String _formatRole(String role) {
    return role[0].toUpperCase() + role.substring(1);
  }

  String _formatSecurityStatus(String? status) {
    if (status == null) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}