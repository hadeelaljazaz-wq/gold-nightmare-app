import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class EmergencyLockoutWidget extends StatefulWidget {
  final VoidCallback onConfirm;

  const EmergencyLockoutWidget({
    super.key,
    required this.onConfirm,
  });

  @override
  State<EmergencyLockoutWidget> createState() => _EmergencyLockoutWidgetState();
}

class _EmergencyLockoutWidgetState extends State<EmergencyLockoutWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _confirmationController;
  bool _showConfirmation = false;
  int _confirmationStep = 0;

  final List<String> _confirmationSteps = [
    'This will lock your account immediately',
    'All active sessions will be terminated',
    'You will need to reactivate your account',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _confirmationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  void _startConfirmation() {
    HapticFeedback.mediumImpact();
    setState(() {
      _showConfirmation = true;
      _confirmationStep = 0;
    });
    _confirmationController.forward();
  }

  void _nextConfirmationStep() {
    HapticFeedback.lightImpact();
    if (_confirmationStep < _confirmationSteps.length - 1) {
      setState(() {
        _confirmationStep++;
      });
    } else {
      _performEmergencyLockout();
    }
  }

  void _performEmergencyLockout() {
    HapticFeedback.heavyImpact();
    Navigator.of(context).pop();
    widget.onConfirm();
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75.h,
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 100 * (1 - _animationController.value)),
            child: Opacity(
              opacity: _animationController.value,
              child: _showConfirmation
                  ? _buildConfirmationView()
                  : _buildInitialView(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialView() {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          // Handle
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: 4.h),

          // Warning Icon
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.emergency,
              color: Colors.red,
              size: 15.w,
            ),
          ),

          SizedBox(height: 4.h),

          // Title
          Text(
            'Emergency Lockout',
            style: AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Description
          Text(
            'This will immediately lock your account and terminate all active sessions. Use this feature only if you suspect unauthorized access.',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Warning List
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Important Warning',
                      style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                ..._confirmationSteps.map((step) => Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.orange,
                            size: 2.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              step,
                              style: AppTheme.darkTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const Spacer(),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColor,
                    foregroundColor: AppTheme.textPrimary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppTheme.borderColor),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _startConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    return AnimatedBuilder(
      animation: _confirmationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _confirmationController.value,
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                SizedBox(height: 4.h),

                // Progress Indicator
                LinearProgressIndicator(
                  value: (_confirmationStep + 1) / _confirmationSteps.length,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),

                SizedBox(height: 4.h),

                // Step Icon
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.red,
                    size: 8.w,
                  ),
                ),

                SizedBox(height: 3.h),

                // Step Title
                Text(
                  'Confirmation Step ${_confirmationStep + 1}',
                  style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 2.h),

                // Current Step
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _confirmationSteps[_confirmationStep],
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(),

                // Confirmation Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextConfirmationStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _confirmationStep == _confirmationSteps.length - 1
                          ? 'Lock Account Now'
                          : 'I Understand',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),

                // Cancel Button
                TextButton(
                  onPressed: _cancel,
                  child: Text(
                    'Cancel',
                    style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}