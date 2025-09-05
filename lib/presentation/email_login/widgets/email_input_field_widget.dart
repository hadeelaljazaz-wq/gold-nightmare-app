import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class EmailInputFieldWidget extends StatelessWidget {
  final TextEditingController controller;

  const EmailInputFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'البريد الإلكتروني',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),

        SizedBox(height: 1.h),

        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            color: AppTheme.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'يرجى إدخال بريد إلكتروني صحيح';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'أدخل بريدك الإلكتروني',
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppTheme.goldColor,
              size: 20.sp,
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
