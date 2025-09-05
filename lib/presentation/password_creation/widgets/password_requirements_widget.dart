import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PasswordRequirementsWidget extends StatelessWidget {
  final String password;
  final bool passwordsMatch;

  const PasswordRequirementsWidget({
    super.key,
    required this.password,
    required this.passwordsMatch,
  });

  @override
  Widget build(BuildContext context) {
    final requirements = _getRequirements(password, passwordsMatch);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'متطلبات كلمة المرور',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),

        SizedBox(height: 2.h),

        ...requirements.map(
          (requirement) => _buildRequirementItem(requirement),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(PasswordRequirement requirement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(
            requirement.isMet
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color:
                requirement.isMet ? AppTheme.goldColor : AppTheme.textSecondary,
            size: 18.sp,
          ),

          SizedBox(width: 3.w),

          Expanded(
            child: Text(
              requirement.text,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color:
                    requirement.isMet
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                decoration:
                    requirement.isMet ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PasswordRequirement> _getRequirements(
    String password,
    bool passwordsMatch,
  ) {
    return [
      PasswordRequirement(
        text: 'على الأقل 8 أحرف',
        isMet: password.length >= 8,
      ),
      PasswordRequirement(
        text: 'حرف كبير واحد على الأقل (A-Z)',
        isMet: RegExp(r'[A-Z]').hasMatch(password),
      ),
      PasswordRequirement(
        text: 'حرف صغير واحد على الأقل (a-z)',
        isMet: RegExp(r'[a-z]').hasMatch(password),
      ),
      PasswordRequirement(
        text: 'رقم واحد على الأقل (0-9)',
        isMet: RegExp(r'[0-9]').hasMatch(password),
      ),
      PasswordRequirement(
        text: 'رمز خاص واحد على الأقل (!@#\$%^&*)',
        isMet: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password),
      ),
      PasswordRequirement(
        text: 'كلمتا المرور متطابقتان',
        isMet: passwordsMatch && password.isNotEmpty,
      ),
    ];
  }
}

class PasswordRequirement {
  final String text;
  final bool isMet;

  PasswordRequirement({required this.text, required this.isMet});
}
