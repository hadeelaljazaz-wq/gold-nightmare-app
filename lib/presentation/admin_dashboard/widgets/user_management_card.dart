import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class UserManagementCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isSelected;
  final Function(bool) onToggleSelection;
  final Function(bool) onStatusToggle;
  final VoidCallback onViewDetails;

  const UserManagementCard({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onToggleSelection,
    required this.onStatusToggle,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = user['is_unlocked'] == true;
    final isActive = user['is_active'] == true;
    final email = user['email']?.toString() ?? '';
    final fullName = user['full_name']?.toString() ?? '';
    final role = user['role']?.toString() ?? 'standard';
    final createdAt = DateTime.tryParse(user['created_at']?.toString() ?? '');

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color:
            isSelected
                ? const Color(0xFFD4AF37).withAlpha(26)
                : const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              isSelected ? const Color(0xFFD4AF37) : Colors.grey.withAlpha(51),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Header row with selection and status
            Row(
              children: [
                // Selection checkbox
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) => onToggleSelection(value ?? false),
                  activeColor: const Color(0xFFD4AF37),
                ),

                // User avatar and basic info
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 6.w,
                        backgroundColor: const Color(0xFFD4AF37).withAlpha(51),
                        child: Text(
                          fullName.isNotEmpty
                              ? fullName[0].toUpperCase()
                              : email.isNotEmpty
                              ? email[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName.isNotEmpty ? fullName : 'مستخدم جديد',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              email,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Status indicators
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(isUnlocked, isActive),
                    SizedBox(height: 0.5.h),
                    _buildRoleBadge(role),
                  ],
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // User details row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoItem('تاريخ التسجيل:', _formatDate(createdAt)),
                      SizedBox(height: 1.h),
                      _buildInfoItem('الدور:', _getArabicRole(role)),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Action buttons
            Row(
              children: [
                // Approve/Reject toggle
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onStatusToggle(!isUnlocked),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isUnlocked ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      isUnlocked ? Icons.block : Icons.check,
                      size: 4.w,
                    ),
                    label: Text(
                      isUnlocked ? 'حظر' : 'موافقة',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),

                // View details button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      Icons.visibility,
                      size: 4.w,
                      color: const Color(0xFFD4AF37),
                    ),
                    label: Text(
                      'التفاصيل',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isUnlocked, bool isActive) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    if (!isActive) {
      badgeColor = Colors.red;
      badgeText = 'غير نشط';
      badgeIcon = Icons.person_off;
    } else if (!isUnlocked) {
      badgeColor = Colors.orange;
      badgeText = 'بانتظار الموافقة';
      badgeIcon = Icons.hourglass_empty;
    } else {
      badgeColor = Colors.green;
      badgeText = 'تمت الموافقة';
      badgeIcon = Icons.check_circle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(51),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withAlpha(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 3.w, color: badgeColor),
          SizedBox(width: 1.w),
          Text(
            badgeText,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final arabicRole = _getArabicRole(role);
    final roleColor =
        role == 'admin' ? const Color(0xFFD4AF37) : Colors.grey[400];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: roleColor?.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        arabicRole,
        style: GoogleFonts.inter(
          fontSize: 9.sp,
          color: roleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 25.w,
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey[400]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير متاح';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getArabicRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'مسؤول';
      case 'premium':
        return 'مميز';
      case 'standard':
      default:
        return 'عادي';
    }
  }
}