import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/user_management_service.dart';

class UserStatusCardWidget extends StatelessWidget {
  final Map<String, dynamic> user;
  final Function(String, bool) onToggleStatus;

  const UserStatusCardWidget({
    super.key,
    required this.user,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = user['is_unlocked'] as bool? ?? false;
    final isActive = user['is_active'] as bool? ?? false;
    final role = user['role'] as String? ?? 'standard';
    final email = user['email'] as String? ?? '';
    final fullName = user['full_name'] as String? ?? 'غير محدد';
    final createdAt = user['created_at'] as String?;
    final userId = user['id'] as String? ?? '';

    // Format creation date
    String formattedDate = 'غير محدد';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        // Handle parsing error
      }
    }

    // Get activity summary
    final activitySummary = UserManagementService.instance
        .getUserActivitySummary(user);

    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(
          color: isUnlocked ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info and toggle button
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1D29),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        _buildRoleBadge(role),
                      ],
                    ),
                    SizedBox(height: 4.sp),
                    Text(
                      email,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.sp),
              _buildToggleButton(userId, isUnlocked),
            ],
          ),

          SizedBox(height: 16.sp),

          // Status indicators
          Row(
            children: [
              _buildStatusIndicator(
                'الحالة',
                isActive ? 'نشط' : 'معطل',
                isActive ? Colors.green : Colors.red,
              ),
              SizedBox(width: 16.sp),
              _buildStatusIndicator(
                'التفعيل',
                isUnlocked ? 'مفعل' : 'مقفل',
                isUnlocked ? Colors.green : Colors.orange,
              ),
            ],
          ),

          SizedBox(height: 12.sp),

          // Additional info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تاريخ الانضمام: $formattedDate',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    SizedBox(height: 2.sp),
                    Text(
                      'النشاط: $activitySummary',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (role.toLowerCase()) {
      case 'admin':
        backgroundColor = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF7C3AED);
        displayText = 'مسؤول';
        break;
      case 'premium':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFF59E0B);
        displayText = 'مميز';
        break;
      default:
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        displayText = 'عادي';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.sp),
      ),
      child: Text(
        displayText,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.sp,
          height: 8.sp,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.sp),
        Text(
          '$label: $value',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String userId, bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.sp),
          onTap: () => onToggleStatus(userId, isUnlocked),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 8.sp),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUnlocked ? Icons.lock_outline : Icons.lock_open,
                  size: 16.sp,
                  color:
                      isUnlocked
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF22C55E),
                ),
                SizedBox(width: 6.sp),
                Text(
                  isUnlocked ? 'قفل' : 'إلغاء قفل',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color:
                        isUnlocked
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
