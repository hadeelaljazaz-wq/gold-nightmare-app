import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/email_auth_service.dart';

class AdminApprovalPending extends StatefulWidget {
  const AdminApprovalPending({super.key});

  @override
  State<AdminApprovalPending> createState() => _AdminApprovalPendingState();
}

class _AdminApprovalPendingState extends State<AdminApprovalPending>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final EmailAuthService _authService = EmailAuthService.instance;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserProfile();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final profile = await _authService.getCurrentUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await _showSignOutDialog();
    if (shouldSignOut == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.emailLogin);
      }
    }
  }

  Future<bool?> _showSignOutDialog() {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.sp),
            ),
            title: Text(
              'تسجيل الخروج',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            content: Text(
              'هل أنت متأكد من تسجيل الخروج؟',
              style: GoogleFonts.inter(fontSize: 14.sp),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: EdgeInsets.all(24.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 80.sp,
                    height: 80.sp,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withAlpha(51),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 40.sp,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),

                  SizedBox(height: 32.sp),

                  // Main Message
                  Text(
                    'حسابك بانتظار موافقة المسؤول',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1D29),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 16.sp),

                  Text(
                    'تم إنشاء حسابك بنجاح! يرجى انتظار موافقة المسؤول لتتمكن من الوصول إلى جميع ميزات التطبيق.',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.sp),

                  // User Info Card
                  if (_userProfile != null) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.sp),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.sp),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: const Color(0xFF6B7280),
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.sp),
                              Text(
                                'معلومات الحساب',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1D29),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.sp),
                          _buildInfoRow(
                            'الاسم',
                            _userProfile!['full_name'] ?? 'غير محدد',
                          ),
                          SizedBox(height: 8.sp),
                          _buildInfoRow(
                            'البريد الإلكتروني',
                            _userProfile!['email'] ?? 'غير محدد',
                          ),
                          SizedBox(height: 8.sp),
                          _buildInfoRow('الحالة', 'في انتظار الموافقة'),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.sp),
                  ],

                  // Status Timeline
                  _buildStatusTimeline(),

                  SizedBox(height: 40.sp),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _handleSignOut,
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16.sp),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                          ),
                          child: Text(
                            'تسجيل الخروج',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.sp),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _loadUserProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            padding: EdgeInsets.symmetric(vertical: 16.sp),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    width: 20.sp,
                                    height: 20.sp,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    'تحديث الحالة',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.sp),

                  // Help Text
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12.sp),
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF0284C7),
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.sp),
                        Expanded(
                          child: Text(
                            'سيتم إشعارك فور موافقة المسؤول على حسابك',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100.sp,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF1A1D29),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline() {
    return Container(
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.sp),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلب',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1D29),
            ),
          ),
          SizedBox(height: 16.sp),
          _buildTimelineItem(
            title: 'تم إنشاء الحساب',
            subtitle: 'تم التسجيل بنجاح',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'في انتظار المراجعة',
            subtitle: 'المسؤول يراجع طلبك',
            isCompleted: false,
            isActive: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'تم القبول',
            subtitle: 'يمكنك الوصول لجميع الميزات',
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isLast,
    bool isActive = false,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20.sp,
              height: 20.sp,
              decoration: BoxDecoration(
                color:
                    isCompleted
                        ? const Color(0xFF10B981)
                        : isActive
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child:
                  isCompleted
                      ? Icon(Icons.check, size: 12.sp, color: Colors.white)
                      : null,
            ),
            if (!isLast) ...[
              Container(
                width: 2.sp,
                height: 24.sp,
                color: const Color(0xFFE5E7EB),
              ),
            ],
          ],
        ),
        SizedBox(width: 12.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      isCompleted || isActive
                          ? const Color(0xFF1A1D29)
                          : const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: const Color(0xFF6B7280),
                ),
              ),
              if (!isLast) SizedBox(height: 16.sp),
            ],
          ),
        ),
      ],
    );
  }
}
