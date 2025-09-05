import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class UserStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const UserStatisticsWidget({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final totalUsers = statistics['total_users'] ?? 0;
    final unlockedUsers = statistics['unlocked_users'] ?? 0;
    final lockedUsers = statistics['locked_users'] ?? 0;
    final adminUsers = statistics['admin_users'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات المستخدمين',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1D29),
          ),
        ),
        SizedBox(height: 12.sp),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12.sp,
          mainAxisSpacing: 12.sp,
          childAspectRatio: 2.2,
          children: [
            _buildStatCard(
              title: 'إجمالي المستخدمين',
              value: totalUsers.toString(),
              icon: Icons.people_outline,
              color: const Color(0xFF3B82F6),
            ),
            _buildStatCard(
              title: 'المستخدمين المفعلين',
              value: unlockedUsers.toString(),
              icon: Icons.lock_open,
              color: const Color(0xFF10B981),
            ),
            _buildStatCard(
              title: 'المستخدمين المقفلين',
              value: lockedUsers.toString(),
              icon: Icons.lock_outline,
              color: const Color(0xFFF59E0B),
            ),
            _buildStatCard(
              title: 'المسؤولين',
              value: adminUsers.toString(),
              icon: Icons.admin_panel_settings_outlined,
              color: const Color(0xFF8B5CF6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          Row(
            children: [
              Icon(icon, size: 20.sp, color: color),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.sp),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
