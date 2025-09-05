import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/user_management_service.dart';
import './widgets/search_bar_widget.dart';
import './widgets/user_list_widget.dart';
import './widgets/user_statistics_widget.dart';

class UserStatusManagement extends StatefulWidget {
  const UserStatusManagement({super.key});

  @override
  State<UserStatusManagement> createState() => _UserStatusManagementState();
}

class _UserStatusManagementState extends State<UserStatusManagement> {
  final UserManagementService _userService = UserManagementService.instance;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, unlocked, locked, admin

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final users = await _userService.getAllUsersForAdmin();
      final stats = await _userService.getUserStatistics();

      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _statistics = stats;
        _isLoading = false;
      });

      _applyFilters();
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('فشل في تحميل البيانات: $error');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredUsers =
          _allUsers.where((user) {
            // Apply search filter
            if (_searchQuery.isNotEmpty) {
              final email = (user['email'] as String? ?? '').toLowerCase();
              final name = (user['full_name'] as String? ?? '').toLowerCase();
              final query = _searchQuery.toLowerCase();

              if (!email.contains(query) && !name.contains(query)) {
                return false;
              }
            }

            // Apply status filter
            switch (_selectedFilter) {
              case 'unlocked':
                return user['is_unlocked'] == true;
              case 'locked':
                return user['is_unlocked'] == false;
              case 'admin':
                return user['role'] == 'admin';
              default:
                return true;
            }
          }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  void _onFilterChanged(String filter) {
    setState(() => _selectedFilter = filter);
    _applyFilters();
  }

  Future<void> _toggleUserStatus(String userId, bool currentStatus) async {
    try {
      final success = await _userService.updateUserUnlockStatus(
        userId: userId,
        isUnlocked: !currentStatus,
      );

      if (success) {
        // Notify user about status change
        await _userService.notifyUserStatusChange(
          userId: userId,
          isUnlocked: !currentStatus,
        );

        // Refresh data
        await _loadData();

        _showSuccessSnackBar(
          !currentStatus ? 'تم إلغاء قفل الحساب بنجاح' : 'تم قفل الحساب بنجاح',
        );
      } else {
        throw Exception('فشل في تحديث حالة المستخدم');
      }
    } catch (error) {
      _showErrorSnackBar('خطأ في تحديث الحالة: $error');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إدارة حالات المستخدمين',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1D29),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF6B7280)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
            onPressed: _loadData,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Section
                      UserStatisticsWidget(statistics: _statistics),

                      SizedBox(height: 24.sp),

                      // Search and Filter Section
                      SearchBarWidget(
                        onSearchChanged: _onSearchChanged,
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _onFilterChanged,
                      ),

                      SizedBox(height: 20.sp),

                      // Users List Section
                      Text(
                        'قائمة المستخدمين (${_filteredUsers.length})',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1D29),
                        ),
                      ),

                      SizedBox(height: 12.sp),

                      if (_filteredUsers.isEmpty)
                        _buildEmptyState()
                      else
                        UserListWidget(
                          users: _filteredUsers,
                          onToggleStatus: _toggleUserStatus,
                        ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.sp),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 48.sp, color: const Color(0xFF9CA3AF)),
          SizedBox(height: 16.sp),
          Text(
            'لا توجد نتائج',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8.sp),
          Text(
            'جرب تغيير الفلتر أو البحث',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}
