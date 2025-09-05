import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PasswordInputFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onVisibilityToggled;

  const PasswordInputFieldWidget({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onVisibilityToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة المرور',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),

        SizedBox(height: 1.h),

        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: AppTheme.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال كلمة المرور';
            }
            if (value.length < 6) {
              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'أدخل كلمة المرور',
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AppTheme.goldColor,
              size: 20.sp,
            ),
            suffixIcon: IconButton(
              onPressed: onVisibilityToggled,
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.textSecondary,
                size: 20.sp,
              ),
            ),
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.goldColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
          ),
        ),
      ],
    );
  }
}
