import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class OtpInputWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isLoading;
  final bool isValid;

  const OtpInputWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.isLoading,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          Text(
            'أدخل رمز التحقق',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => _buildOtpField(context, index),
            ),
          ),
          SizedBox(height: 2.h),
          if (!isValid && controllers.any((c) => c.text.isNotEmpty))
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, color: AppTheme.warningRed, size: 16),
                SizedBox(width: 1.w),
                Text(
                  'يجب إدخال 6 أرقام',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.warningRed,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOtpField(BuildContext context, int index) {
    return Container(
      width: 12.w,
      height: 6.h,
      decoration: BoxDecoration(
        color: AppTheme.royalSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(
          color: _getBorderColor(index),
          width: _getBorderWidth(index),
        ),
        boxShadow:
            focusNodes[index].hasFocus
                ? [
                  BoxShadow(
                    color: AppTheme.aiBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        enabled: !isLoading,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 20.sp,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < controllers.length - 1) {
            focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Color _getBorderColor(int index) {
    if (isLoading) return AppTheme.textAccent.withValues(alpha: 0.3);
    if (focusNodes[index].hasFocus) return AppTheme.aiBlue;
    if (controllers[index].text.isNotEmpty) {
      return isValid ? AppTheme.luxuryGold : AppTheme.warningRed;
    }
    return AppTheme.textAccent.withValues(alpha: 0.3);
  }

  double _getBorderWidth(int index) {
    if (focusNodes[index].hasFocus) return 2.0;
    if (controllers[index].text.isNotEmpty) return 1.5;
    return 1.0;
  }
}
