import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CancelAnalysisButton extends StatefulWidget {
  final bool isVisible;
  final VoidCallback onCancel;

  const CancelAnalysisButton({
    super.key,
    required this.isVisible,
    required this.onCancel,
  });

  @override
  State<CancelAnalysisButton> createState() => _CancelAnalysisButtonState();
}

class _CancelAnalysisButtonState extends State<CancelAnalysisButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CancelAnalysisButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleCancel() {
    HapticFeedback.mediumImpact();
    _showCancelConfirmation();
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.warningRed,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'إلغاء التحليل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من إلغاء التحليل الحالي؟ سيتم فقدان التقدم المحرز.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'متابعة التحليل',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onCancel();
            },
            child: Text(
              'إلغاء',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.warningRed,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.isVisible ? _buildButton() : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    return Container(
      width: 70.w,
      margin: EdgeInsets.symmetric(horizontal: 15.w),
      child: ElevatedButton(
        onPressed: _handleCancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.warningRed.withValues(alpha: 0.1),
          foregroundColor: AppTheme.warningRed,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: AppTheme.warningRed.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'cancel',
              color: AppTheme.warningRed,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'إلغاء التحليل',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.warningRed,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
