import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OtpInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.isLoading = false,
    this.errorMessage,
    this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    // Default theme for OTP input
    final defaultPinTheme = PinTheme(
      width: 12.w,
      height: 12.w,
      textStyle: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    // Focused theme
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.goldColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    // Submitted/Completed theme
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppTheme.goldColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.goldColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    // Error theme
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppTheme.warningRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.warningRed,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningRed.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    return Column(
      children: [
        // OTP Input
        Directionality(
          textDirection: TextDirection.ltr,
          child: Pinput(
            controller: controller,
            focusNode: focusNode,
            enabled: !isLoading,
            length: 6,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            defaultPinTheme: hasError ? errorPinTheme : defaultPinTheme,
            focusedPinTheme: hasError ? errorPinTheme : focusedPinTheme,
            submittedPinTheme: hasError ? errorPinTheme : submittedPinTheme,
            showCursor: true,
            cursor: Container(
              width: 2,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.goldColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            onChanged: onChanged,
            onCompleted: onCompleted,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            autofocus: true,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
          ),
        ),

        SizedBox(height: 2.h),

        // Loading indicator
        if (isLoading)
          SizedBox(
            width: 5.w,
            height: 5.w,
            child: const CircularProgressIndicator(
              color: AppTheme.goldColor,
              strokeWidth: 2,
            ),
          ),

        // Error Message
        if (hasError) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.warningRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.warningRed.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.warningRed,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    errorMessage!,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Helper Text (when no error)
        if (!hasError && !isLoading) ...[
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentGreen.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.accentGreen,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Flexible(
                  child: Text(
                    'أدخل الكود المكون من 6 أرقام الذي تم إرساله إلى بريدك الإلكتروني',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentGreen,
                    ),
                    textAlign: TextAlign.center,
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