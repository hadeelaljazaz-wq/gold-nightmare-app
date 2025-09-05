import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final String password;
  final ValueChanged<String> onStrengthChanged;

  const PasswordStrengthWidget({
    super.key,
    required this.password,
    required this.onStrengthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);

    // Notify parent of strength change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onStrengthChanged(strength);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'قوة كلمة المرور',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),

        SizedBox(height: 1.h),

        // Strength indicator bar
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 0.8.h,
                margin: EdgeInsets.only(right: index < 2 ? 2.w : 0),
                decoration: BoxDecoration(
                  color: _getStrengthColor(strength, index),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),

        SizedBox(height: 1.h),

        // Strength text
        Text(
          _getStrengthText(strength),
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: _getStrengthTextColor(strength),
          ),
        ),
      ],
    );
  }

  String _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 'none';

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Character variety checks
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score < 3) return 'weak';
    if (score < 5) return 'medium';
    return 'strong';
  }

  Color _getStrengthColor(String strength, int index) {
    switch (strength) {
      case 'weak':
        return index == 0
            ? Colors.red
            : AppTheme.textSecondary.withValues(alpha: 0.3);
      case 'medium':
        return index <= 1
            ? Colors.orange
            : AppTheme.textSecondary.withValues(alpha: 0.3);
      case 'strong':
        return AppTheme.goldColor;
      default:
        return AppTheme.textSecondary.withValues(alpha: 0.3);
    }
  }

  String _getStrengthText(String strength) {
    switch (strength) {
      case 'weak':
        return 'ضعيفة';
      case 'medium':
        return 'متوسطة';
      case 'strong':
        return 'قوية';
      default:
        return '';
    }
  }

  Color _getStrengthTextColor(String strength) {
    switch (strength) {
      case 'weak':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'strong':
        return AppTheme.goldColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}
