import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class BiometricLoginWidget extends StatelessWidget {
  final VoidCallback onBiometricLogin;

  const BiometricLoginWidget({super.key, required this.onBiometricLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'أو',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        OutlinedButton.icon(
          onPressed: onBiometricLogin,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: AppTheme.goldColor.withValues(alpha: 0.3),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          ),
          icon: Icon(Icons.fingerprint, color: AppTheme.goldColor, size: 20.sp),
          label: Text(
            'تسجيل الدخول ببصمة الإصبع',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.goldColor,
            ),
          ),
        ),
      ],
    );
  }
}
