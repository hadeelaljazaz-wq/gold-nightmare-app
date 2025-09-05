import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmailInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final String? errorMessage;
  final ValueChanged<String>? onSubmitted;

  const EmailInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.isLoading = false,
    this.errorMessage,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null && errorMessage!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Input Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: hasError
                    ? AppTheme.warningRed.withValues(alpha: 0.2)
                    : AppTheme.goldColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 16.sp,
            ),
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: 'أدخل بريدك الإلكتروني',
              hintStyle: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.textTertiary,
              ),
              filled: true,
              fillColor: AppTheme.surfaceColor,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 4.w,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError
                      ? AppTheme.warningRed
                      : AppTheme.goldColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? AppTheme.warningRed : AppTheme.goldColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.warningRed,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.warningRed,
                  width: 2,
                ),
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'email',
                  color: hasError
                      ? AppTheme.warningRed
                      : focusNode.hasFocus
                          ? AppTheme.goldColor
                          : AppTheme.textTertiary,
                  size: 5.w,
                ),
              ),
              suffixIcon: isLoading
                  ? Padding(
                      padding: EdgeInsets.all(3.w),
                      child: SizedBox(
                        width: 4.w,
                        height: 4.w,
                        child: const CircularProgressIndicator(
                          color: AppTheme.goldColor,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // Error Message
        if (hasError) ...[
          SizedBox(height: 1.h),
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
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.warningRed,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningRed,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Helper Text
        if (!hasError) ...[
          SizedBox(height: 1.h),
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
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.accentGreen,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'سنرسل لك كود التفعيل المكون من 6 أرقام على هذا البريد الإلكتروني',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentGreen,
                    ),
                    textAlign: TextAlign.right,
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