import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TimeRemainingWidget extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimeRemainingWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  State<TimeRemainingWidget> createState() => _TimeRemainingWidgetState();
}

class _TimeRemainingWidgetState extends State<TimeRemainingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildTimeDisplay(context),
          SizedBox(height: 2.h),
          _buildProgressRing(),
          SizedBox(height: 2.h),
          _buildEstimateText(context),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay(BuildContext context) {
    final minutes = widget.remainingSeconds ~/ 60;
    final seconds = widget.remainingSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'schedule',
          color: AppTheme.goldColor,
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Text(
          'الوقت المتبقي',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(width: 4.w),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.goldColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.goldColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: AppTheme.tradingDataMedium.copyWith(
                    color: AppTheme.goldColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressRing() {
    final progress = widget.totalSeconds > 0
        ? (widget.totalSeconds - widget.remainingSeconds) / widget.totalSeconds
        : 0.0;

    return SizedBox(
      width: 20.w,
      height: 20.w,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(20.w, 20.w),
            painter: ProgressRingPainter(
              progress: progress,
              backgroundColor: AppTheme.surfaceColor,
              progressColor: AppTheme.accentGreen,
              strokeWidth: 1.w,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTheme.tradingDataMedium.copyWith(
                    color: AppTheme.accentGreen,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'مكتمل',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 10.sp,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateText(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'info_outline',
            color: AppTheme.textSecondary,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              _getEstimateMessage(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getEstimateMessage() {
    if (widget.remainingSeconds > 60) {
      return 'يتم تحليل البيانات بدقة عالية، يرجى الانتظار';
    } else if (widget.remainingSeconds > 30) {
      return 'جاري إنهاء التحليل وتنسيق النتائج';
    } else {
      return 'التحليل على وشك الانتهاء';
    }
  }
}

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw glow effect
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth + 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
