import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ResendTimerWidget extends StatefulWidget {
  final int remainingSeconds;
  final VoidCallback onResend;

  const ResendTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.onResend,
  });

  @override
  State<ResendTimerWidget> createState() => _ResendTimerWidgetState();
}

class _ResendTimerWidgetState extends State<ResendTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ResendTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingSeconds == 0 && oldWidget.remainingSeconds > 0) {
      _pulseController.repeat(reverse: true);
    } else if (widget.remainingSeconds > 0 && oldWidget.remainingSeconds == 0) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final canResend = widget.remainingSeconds == 0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.royalSurface.withValues(alpha: 0.8),
            AppTheme.surfaceColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(
          color:
              canResend
                  ? AppTheme.aiBlue.withValues(alpha: 0.5)
                  : AppTheme.royalBlue.withValues(alpha: 0.3),
          width: canResend ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color:
                canResend
                    ? AppTheme.aiBlue.withValues(alpha: 0.2)
                    : AppTheme.royalBlue.withValues(alpha: 0.1),
            blurRadius: canResend ? 15 : 10,
            spreadRadius: canResend ? 3 : 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer display
          if (!canResend) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    gradient: AppTheme.aiGlowGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوقت المتبقي',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textAccent,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatTime(widget.remainingSeconds),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.aiBlue,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Progress bar
            Container(
              width: double.infinity,
              height: 0.8.h,
              decoration: BoxDecoration(
                color: AppTheme.royalBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                widthFactor:
                    widget.remainingSeconds / 300, // 5 minutes = 300 seconds
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.aiGlowGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            Text(
              'لم تستلم الرمز؟ يمكنك إعادة الإرسال بعد انتهاء الوقت',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textAccent,
                fontSize: 10.sp,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Resend button
          if (canResend) ...[
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          gradient: AppTheme.luxuryGoldGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.luxuryGold.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.refresh,
                          color: AppTheme.deepNavy,
                          size: 25,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'انتهت صلاحية الرمز',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.warningRed,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppTheme.aiGlowGradient,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.aiBlue.withValues(alpha: 0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: widget.onResend,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 1.8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, color: Colors.white, size: 18),
                              SizedBox(width: 2.w),
                              Text(
                                'إرسال رمز جديد',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}