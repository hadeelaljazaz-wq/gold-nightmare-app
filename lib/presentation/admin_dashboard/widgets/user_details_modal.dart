import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class UserDetailsModal extends StatelessWidget {
  final Map<String, dynamic> user;
  final Function(String, bool) onStatusToggle;

  const UserDetailsModal({
    super.key,
    required this.user,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    final userId = user['id']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final fullName = user['full_name']?.toString() ?? '';
    final role = user['role']?.toString() ?? 'standard';
    final isUnlocked = user['is_unlocked'] == true;
    final isActive = user['is_active'] == true;
    final createdAt = DateTime.tryParse(user['created_at']?.toString() ?? '');

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h, maxWidth: 90.w),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD4AF37).withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFFFEB3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: const Color(0xFF1A1A1A),
                    size: 6.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'تفاصيل المستخدم',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: const Color(0xFF1A1A1A),
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User avatar and basic info
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 10.w,
                            backgroundColor: const Color(
                              0xFFD4AF37,
                            ).withAlpha(51),
                            child: Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : email.isNotEmpty
                                  ? email[0].toUpperCase()
                                  : 'U',
                              style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            fullName.isNotEmpty ? fullName : 'مستخدم جديد',
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          _buildStatusBadge(isUnlocked, isActive),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // User information
                    _buildSectionTitle('المعلومات الأساسية'),
                    SizedBox(height: 2.h),

                    _buildInfoCard([
                      _buildInfoRow('البريد الإلكتروني:', email),
                      _buildInfoRow(
                        'الاسم الكامل:',
                        fullName.isNotEmpty ? fullName : 'غير محدد',
                      ),
                      _buildInfoRow('الدور:', _getArabicRole(role)),
                      _buildInfoRow('معرف المستخدم:', userId),
                    ]),

                    SizedBox(height: 3.h),

                    // Account status
                    _buildSectionTitle('حالة الحساب'),
                    SizedBox(height: 2.h),

                    _buildInfoCard([
                      _buildInfoRow('الحساب نشط:', isActive ? 'نعم' : 'لا'),
                      _buildInfoRow('تمت الموافقة:', isUnlocked ? 'نعم' : 'لا'),
                      _buildInfoRow('تاريخ التسجيل:', _formatDate(createdAt)),
                      _buildInfoRow(
                        'الحالة العامة:',
                        _getOverallStatus(isActive, isUnlocked),
                      ),
                    ]),

                    SizedBox(height: 4.h),

                    // Action buttons
                    _buildActionButtons(context, userId, isUnlocked),
                  ],
                ),
              ),
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
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 4.w, color: badgeColor),
          SizedBox(width: 2.w),
          Text(
            badgeText,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFD4AF37),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(51), width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    String userId,
    bool isUnlocked,
  ) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onStatusToggle(userId, !isUnlocked);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isUnlocked ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              isUnlocked ? Icons.block : Icons.check_circle,
              size: 5.w,
            ),
            label: Text(
              isUnlocked ? 'حظر المستخدم' : 'الموافقة على المستخدم',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFD4AF37)),
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'إغلاق',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
              ),
            ),
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

  String _getOverallStatus(bool isActive, bool isUnlocked) {
    if (!isActive) return 'حساب غير نشط';
    if (!isUnlocked) return 'بانتظار الموافقة';
    return 'حساب فعال ومعتمد';
  }
}
