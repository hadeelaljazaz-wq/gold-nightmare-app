import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class VerifyButtonWidget extends StatefulWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const VerifyButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<VerifyButtonWidget> createState() => _VerifyButtonWidgetState();
}

class _VerifyButtonWidgetState extends State<VerifyButtonWidget>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isEnabled) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VerifyButtonWidget oldWidget) {
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
                      ? AppTheme.luxuryGoldGradient
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
                          color: AppTheme.luxuryGold.withValues(
                            alpha: _glowAnimation.value * 0.4,
                          ),
                          blurRadius: 20 * _glowAnimation.value,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppTheme.aiBlue.withValues(
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
                                AppTheme.deepNavy,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'جاري التحقق...',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: AppTheme.deepNavy,
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
                                      ? AppTheme.deepNavy.withValues(alpha: 0.2)
                                      : AppTheme.textTertiary.withValues(
                                        alpha: 0.2,
                                      ),
                            ),
                            child: Icon(
                              Icons.verified_outlined,
                              color:
                                  widget.isEnabled
                                      ? AppTheme.deepNavy
                                      : AppTheme.textTertiary,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'تأكيد الرمز',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color:
                                  widget.isEnabled
                                      ? AppTheme.deepNavy
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
