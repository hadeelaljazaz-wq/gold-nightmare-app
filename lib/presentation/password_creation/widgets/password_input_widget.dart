import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PasswordInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final VoidCallback onVisibilityToggled;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const PasswordInputWidget({
    super.key,
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onVisibilityToggled,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل $label',
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
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
            suffixIcon: IconButton(
              onPressed: onVisibilityToggled,
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.textSecondary,
                size: 20.sp,
              ),
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
