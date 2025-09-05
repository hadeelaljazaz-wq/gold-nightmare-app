import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/security_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/activation_history_widget.dart';
import './widgets/device_management_widget.dart';
import './widgets/emergency_lockout_widget.dart';
import './widgets/security_alerts_widget.dart';
import './widgets/security_score_widget.dart';
import './widgets/security_settings_widget.dart';

class SecurityDashboard extends StatefulWidget {
  const SecurityDashboard({super.key});

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _tabTitles = ['Overview', 'Devices', 'Alerts', 'Settings'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadSecurityDashboard();
    _animationController.forward();
  }

  Future<void> _loadSecurityDashboard() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final data = await SecurityService.instance.getSecurityDashboard();

      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshDashboard() async {
    HapticFeedback.lightImpact();
    await _loadSecurityDashboard();
  }

  void _showEmergencyLockout() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmergencyLockoutWidget(
        onConfirm: _performEmergencyLockout,
      ),
    );
  }

  Future<void> _performEmergencyLockout() async {
    try {
      await SecurityService.instance.lockApp();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Emergency lockout activated'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to activation screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/license-key-activation',
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lockout failed: ${error.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: CustomAppBar(
        title: 'Security Dashboard',
        backgroundColor: AppTheme.primaryDark,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppTheme.textPrimary,
              size: 6.w,
            ),
            onPressed: _refreshDashboard,
          ),
          IconButton(
            icon: Icon(
              Icons.emergency,
              color: Colors.red,
              size: 6.w,
            ),
            onPressed: _showEmergencyLockout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(12.h),
          child: Column(
            children: [
              // Security Score Header
              if (_dashboardData != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: SecurityScoreWidget(
                    score: _dashboardData!['security_score'] ?? 0,
                    profile: _dashboardData!['profile'],
                    animationController: _animationController,
                  ),
                ),
              ],

              // Tab Bar
              CustomTabBar(
                controller: _tabController,
                tabs: _tabTitles.map((title) => CustomTab(text: title)).toList(),
                backgroundColor: AppTheme.surfaceColor,
                indicatorColor: AppTheme.goldColor,
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 12.w,
              height: 12.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Loading Security Dashboard...',
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 15.w,
              color: Colors.red,
            ),
            SizedBox(height: 2.h),
            Text(
              'Security Dashboard Error',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                _errorMessage!,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _refreshDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldColor,
                foregroundColor: AppTheme.primaryDark,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_dashboardData == null) {
      return const Center(
        child: Text('No security data available'),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // Overview Tab
        _buildOverviewTab(),

        // Devices Tab
        DeviceManagementWidget(
          sessions: _dashboardData!['sessions'] ?? [],
          onRevokeSession: _revokeDeviceSession,
          animationController: _animationController,
        ),

        // Alerts Tab
        SecurityAlertsWidget(
          alerts: _dashboardData!['alerts'] ?? [],
          animationController: _animationController,
        ),

        // Settings Tab
        SecuritySettingsWidget(
          profile: _dashboardData!['profile'],
          onSettingChanged: _handleSecuritySettingChange,
          animationController: _animationController,
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activation History
          ActivationHistoryWidget(
            attempts: _dashboardData!['attempts'] ?? [],
            animationController: _animationController,
          ),

          SizedBox(height: 3.h),

          // Recent Alerts Summary
          _buildRecentAlertsCard(),

          SizedBox(height: 3.h),

          // Security Recommendations
          _buildSecurityRecommendations(),
        ],
      ),
    );
  }

  Widget _buildRecentAlertsCard() {
    final alerts = (_dashboardData!['alerts'] as List).take(3).toList();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
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
                        Icons.notifications_active,
                        color: AppTheme.goldColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Recent Alerts',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  if (alerts.isEmpty)
                    Text(
                      'No recent security alerts',
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    )
                  else
                    ...alerts.map((alert) => _buildAlertItem(alert)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    Color severityColor;
    IconData severityIcon;

    switch (alert['severity']) {
      case 'high':
      case 'critical':
        severityColor = Colors.red;
        severityIcon = Icons.error;
        break;
      case 'medium':
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        break;
      default:
        severityColor = Colors.green;
        severityIcon = Icons.info;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(
            severityIcon,
            color: severityColor,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              alert['message'] ?? '',
              style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatDate(alert['created_at']),
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textTertiary,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityRecommendations() {
    final profile = _dashboardData!['profile'];
    final recommendations = <String>[];

    if (!profile['two_factor_enabled']) {
      recommendations.add('Enable two-factor authentication');
    }

    if (!profile['biometric_enabled']) {
      recommendations.add('Enable biometric authentication');
    }

    if (profile['security_score'] < 80) {
      recommendations.add('Improve security score by updating settings');
    }

    if (recommendations.isEmpty) {
      recommendations.add('All security recommendations are implemented');
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _animationController.value)),
          child: Opacity(
            opacity: _animationController.value,
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
                        Icons.security,
                        color: AppTheme.goldColor,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Security Recommendations',
                        style:
                            AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  ...recommendations.map((rec) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: AppTheme.goldColor,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                rec,
                                style: AppTheme.darkTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _revokeDeviceSession(String sessionId) async {
    try {
      await SecurityService.instance.revokeDeviceSession(sessionId);
      await _refreshDashboard();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Device session revoked successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to revoke session: ${error.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSecuritySettingChange(String setting, bool value) async {
    try {
      switch (setting) {
        case 'two_factor':
          if (value) await SecurityService.instance.enableTwoFactor();
          break;
        case 'biometric':
          if (value) await SecurityService.instance.enableBiometric();
          break;
      }

      await _refreshDashboard();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Security setting updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update setting: ${error.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 60) {
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
}