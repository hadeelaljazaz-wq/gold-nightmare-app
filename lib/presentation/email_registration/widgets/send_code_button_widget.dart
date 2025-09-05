import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SendCodeButtonWidget extends StatefulWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const SendCodeButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<SendCodeButtonWidget> createState() => _SendCodeButtonWidgetState();
}

class _SendCodeButtonWidgetState extends State<SendCodeButtonWidget>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SendCodeButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            height: 7.h,
            decoration: BoxDecoration(
              gradient:
                  widget.isEnabled
                      ? AppTheme.royalPrimaryGradient
                      : LinearGradient(
                        colors: [
                          AppTheme.textTertiary,
                          AppTheme.textTertiary.withValues(alpha: 0.7),
                        ],
                      ),
              borderRadius: BorderRadius.circular(AppTheme.largeRadius),
              boxShadow:
                  widget.isEnabled
                      ? [
                        BoxShadow(
                          color: AppTheme.aiBlue.withValues(
                            alpha: _glowAnimation.value * 0.4,
                          ),
                          blurRadius: 20 * _glowAnimation.value,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppTheme.luxuryGold.withValues(
                            alpha: _glowAnimation.value * 0.2,
                          ),
                          blurRadius: 30 * _glowAnimation.value,
                          spreadRadius: 3,
                        ),
                      ]
                      : null,
            ),
            child: ElevatedButton(
              onPressed:
                  widget.isEnabled && !widget.isLoading
                      ? widget.onPressed
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                ),
                padding: EdgeInsets.zero,
              ),
              child:
                  widget.isLoading
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'جاري الإرسال...',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  widget.isEnabled
                                      ? AppTheme.textPrimary.withValues(
                                        alpha: 0.2,
                                      )
                                      : AppTheme.textTertiary.withValues(
                                        alpha: 0.2,
                                      ),
                            ),
                            child: Icon(
                              Icons.send_outlined,
                              color:
                                  widget.isEnabled
                                      ? AppTheme.textPrimary
                                      : AppTheme.textTertiary,
                              size: 18,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'إرسال رمز التحقق',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color:
                                  widget.isEnabled
                                      ? AppTheme.textPrimary
                                      : AppTheme.textTertiary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
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
}
