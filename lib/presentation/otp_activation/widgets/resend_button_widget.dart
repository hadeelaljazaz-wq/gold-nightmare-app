import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/otp_service.dart';

class ResendButtonWidget extends StatefulWidget {
  final VoidCallback onPressed;
  final DateTime? expiresAt;
  final bool isLoading;

  const ResendButtonWidget({
    super.key,
    required this.onPressed,
    this.expiresAt,
    this.isLoading = false,
  });

  @override
  State<ResendButtonWidget> createState() => _ResendButtonWidgetState();
}

class _ResendButtonWidgetState extends State<ResendButtonWidget> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _canResend = false;

  final OtpService _otpService = OtpService.instance;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(ResendButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expiresAt != oldWidget.expiresAt) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();

    if (widget.expiresAt == null) {
      setState(() {
        _canResend = true;
        _remainingSeconds = 0;
      });
      return;
    }

    final now = DateTime.now();
    final difference = widget.expiresAt!.difference(now);

    if (difference.isNegative) {
      setState(() {
        _canResend = true;
        _remainingSeconds = 0;
      });
      return;
    }

    setState(() {
      _remainingSeconds = difference.inSeconds;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '';

    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    if (minutes > 0) {
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '${remainingSeconds} ثانية';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Timer Display
        if (!_canResend && _remainingSeconds > 0) ...[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.accentGreen,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'يمكن إعادة الإرسال خلال ${_formatTime(_remainingSeconds)}',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
        ],

        // Resend Button
        AnimatedOpacity(
          opacity: _canResend ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: _canResend && !widget.isLoading
                  ? [
                      BoxShadow(
                        color: AppTheme.goldColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: TextButton.icon(
              onPressed:
                  (_canResend && !widget.isLoading) ? widget.onPressed : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                backgroundColor: _canResend
                    ? AppTheme.goldColor.withValues(alpha: 0.1)
                    : AppTheme.surfaceColor,
                foregroundColor:
                    _canResend ? AppTheme.goldColor : AppTheme.textTertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: _canResend
                        ? AppTheme.goldColor.withValues(alpha: 0.3)
                        : AppTheme.textTertiary.withValues(alpha: 0.3),
                  ),
                ),
              ),
              icon: widget.isLoading
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        color: AppTheme.goldColor,
                        strokeWidth: 2,
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'refresh',
                      color: _canResend
                          ? AppTheme.goldColor
                          : AppTheme.textTertiary,
                      size: 4.w,
                    ),
              label: Text(
                widget.isLoading
                    ? 'جاري الإرسال...'
                    : _canResend
                        ? 'إعادة إرسال الكود'
                        : 'إعادة إرسال الكود',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color:
                      _canResend ? AppTheme.goldColor : AppTheme.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // Expired Message
        if (_canResend &&
            _remainingSeconds <= 0 &&
            widget.expiresAt != null) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
            decoration: BoxDecoration(
              color: AppTheme.warningRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppTheme.warningRed.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.warningRed,
                  size: 3.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  'انتهت صلاحية الكود',
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningRed,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}