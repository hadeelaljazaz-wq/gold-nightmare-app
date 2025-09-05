import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for HapticFeedback
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActivationButtonWidget extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final bool hasInput; // New parameter
  final int licenseKeyLength; // New parameter

  const ActivationButtonWidget({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = false,
    this.hasInput = false, // New parameter
    this.licenseKeyLength = 0, // New parameter
  });

  @override
  State<ActivationButtonWidget> createState() => _ActivationButtonWidgetState();
}

class _ActivationButtonWidgetState extends State<ActivationButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation when enabled
    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ActivationButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Control animation based on state
    if (widget.isEnabled && !oldWidget.isEnabled) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getButtonColor() {
    if (widget.isEnabled) return AppTheme.accentGreen;
    if (widget.hasInput) return AppTheme.goldColor.withValues(alpha: 0.3);
    return AppTheme.surfaceColor;
  }

  Color _getTextColor() {
    if (widget.isEnabled) return AppTheme.primaryDark;
    if (widget.hasInput) return AppTheme.goldColor;
    return AppTheme.textTertiary;
  }

  String _getButtonText() {
    if (widget.isLoading) return 'جاري التفعيل...';
    if (widget.licenseKeyLength == 40) {
      return widget.isEnabled ? 'تأكيد التفعيل ✓' : 'موافق - تفعيل الآن';
    }
    if (widget.hasInput) return 'أكمل إدخال الكود';
    return 'تفعيل الترخيص';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isEnabled ? _scaleAnimation.value : 1.0,
          child: Container(
            width: double.infinity,
            height: 6.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.isEnabled
                  ? LinearGradient(
                      colors: [
                        AppTheme.accentGreen,
                        AppTheme.accentGreen.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : (widget.hasInput
                      ? LinearGradient(
                          colors: [
                            AppTheme.goldColor.withValues(alpha: 0.3),
                            AppTheme.goldColor.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null),
              color: widget.isEnabled || widget.hasInput
                  ? null
                  : AppTheme.surfaceColor,
              boxShadow: widget.isEnabled
                  ? [
                      BoxShadow(
                        color: AppTheme.accentGreen
                            .withValues(alpha: _glowAnimation.value),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : (widget.hasInput
                      ? [
                          BoxShadow(
                            color: AppTheme.goldColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null),
              border: widget.hasInput && !widget.isEnabled
                  ? Border.all(
                      color: AppTheme.goldColor.withValues(alpha: 0.5),
                      width: 1,
                    )
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (widget.isEnabled && !widget.isLoading)
                    ? () {
                        HapticFeedback.mediumImpact();
                        widget.onPressed?.call();
                      }
                    : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading) ...[
                        SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getTextColor(),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                      ],
                      if (!widget.isLoading) ...[
                        CustomIconWidget(
                          iconName: widget.isEnabled
                              ? 'check_circle'
                              : (widget.licenseKeyLength == 40
                                  ? 'vpn_key'
                                  : (widget.hasInput ? 'edit' : 'vpn_key')),
                          color: _getTextColor(),
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                      ],
                      Flexible(
                        child: Text(
                          _getButtonText(),
                          style: AppTheme.darkTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: _getTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}