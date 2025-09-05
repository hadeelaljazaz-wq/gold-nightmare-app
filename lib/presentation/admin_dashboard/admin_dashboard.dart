import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/gold_price_service.dart';
import './widgets/batch_operations_panel.dart';
import './widgets/statistics_card.dart';
import './widgets/user_details_modal.dart';
import './widgets/user_management_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService.instance;
  final GoldPriceService _goldPriceService = GoldPriceService.instance;

  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<String> selectedUserIds = [];
  String searchQuery = '';
  String filterStatus = 'all'; // all, pending, approved, rejected
  bool isLoading = true;
  double? currentGoldPrice;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUsers();
    await _loadGoldPrice();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);

    try {
      final users = await _authService.getAllUsersForAdmin();
      setState(() {
        allUsers = users;
        filteredUsers = users;
        isLoading = false;
      });
      _applyFilters();
    } catch (error) {
      setState(() => isLoading = false);
      _showErrorSnackBar('خطأ في تحميل المستخدمين: ${error.toString()}');
    }
  }

  Future<void> _loadGoldPrice() async {
    try {
      final goldPriceData = _goldPriceService.currentPriceData;
      setState(() => currentGoldPrice = goldPriceData['price'] as double?);
    } catch (error) {
      debugPrint('Error loading gold price: $error');
    }
  }

  void _applyFilters() {
    setState(() {
      filteredUsers =
          allUsers.where((user) {
            // Search filter
            if (searchQuery.isNotEmpty) {
              final query = searchQuery.toLowerCase();
              final email = user['email'].toString().toLowerCase();
              final name = user['full_name'].toString().toLowerCase();
              if (!email.contains(query) && !name.contains(query)) {
                return false;
              }
            }

            // Status filter
            if (filterStatus != 'all') {
              switch (filterStatus) {
                case 'pending':
                  return user['is_unlocked'] == false;
                case 'approved':
                  return user['is_unlocked'] == true;
                case 'inactive':
                  return user['is_active'] == false;
              }
            }

            return true;
          }).toList();
    });
  }

  Future<void> _toggleUserStatus(String userId, bool newStatus) async {
    try {
      final result = await _authService.toggleUserUnlockStatus(
        userId,
        newStatus,
      );

      if (result['success'] == true) {
        await _loadUsers();
        _showSuccessSnackBar(
          result['message'] ?? 'تم تحديث حالة المستخدم بنجاح',
        );
      } else {
        _showErrorSnackBar(result['message'] ?? 'فشل في تحديث حالة المستخدم');
      }
    } catch (error) {
      _showErrorSnackBar('خطأ: ${error.toString()}');
    }
  }

  Future<void> _batchApprove(List<String> userIds) async {
    for (String userId in userIds) {
      await _toggleUserStatus(userId, true);
    }
    setState(() => selectedUserIds.clear());
  }

  Future<void> _batchReject(List<String> userIds) async {
    for (String userId in userIds) {
      await _toggleUserStatus(userId, false);
    }
    setState(() => selectedUserIds.clear());
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder:
          (context) => UserDetailsModal(
            user: user,
            onStatusToggle:
                (userId, newStatus) => _toggleUserStatus(userId, newStatus),
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: _buildAppBar(),
      body:
          isLoading
              ? _buildLoadingState()
              : Column(
                children: [
                  // Statistics cards
                  _buildStatisticsSection(),

                  // Search and filter controls
                  _buildSearchAndFilters(),

                  // Batch operations (if any users selected)
                  if (selectedUserIds.isNotEmpty) _buildBatchOperations(),

                  // Users list
                  Expanded(child: _buildUsersList()),
                ],
              ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF2D2D2D),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'لوحة إدارة المستخدمين',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
          if (currentGoldPrice != null)
            Text(
              'سعر الذهب: \$${currentGoldPrice!.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _loadUsers,
          icon: Icon(Icons.refresh, color: const Color(0xFFD4AF37), size: 6.w),
        ),
        IconButton(
          onPressed:
              () => Navigator.pushNamed(context, AppRoutes.mainDashboard),
          icon: Icon(
            Icons.dashboard,
            color: const Color(0xFFD4AF37),
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
    );
  }

  Widget _buildStatisticsSection() {
    final totalUsers = allUsers.length;
    final pendingUsers =
        allUsers.where((u) => u['is_unlocked'] == false).length;
    final approvedUsers =
        allUsers.where((u) => u['is_unlocked'] == true).length;
    final inactiveUsers = allUsers.where((u) => u['is_active'] == false).length;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Expanded(
            child: StatisticsCard(
              title: 'إجمالي المستخدمين',
              value: totalUsers.toString(),
              color: Colors.blue,
              icon: Icons.people,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: StatisticsCard(
              title: 'بانتظار الموافقة',
              value: pendingUsers.toString(),
              color: Colors.orange,
              icon: Icons.hourglass_empty,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: StatisticsCard(
              title: 'تمت الموافقة',
              value: approvedUsers.toString(),
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() => searchQuery = value);
              _applyFilters();
            },
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'البحث بالبريد الإلكتروني أو الاسم...',
              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              filled: true,
              fillColor: const Color(0xFF2D2D2D),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                SizedBox(width: 2.w),
                _buildFilterChip('بانتظار الموافقة', 'pending'),
                SizedBox(width: 2.w),
                _buildFilterChip('تمت الموافقة', 'approved'),
                SizedBox(width: 2.w),
                _buildFilterChip('غير نشط', 'inactive'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = filterStatus == value;
    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey[300],
          fontSize: 12.sp,
        ),
      ),
      selectedColor: const Color(0xFFD4AF37),
      backgroundColor: const Color(0xFF2D2D2D),
      onSelected: (selected) {
        setState(() => filterStatus = value);
        _applyFilters();
      },
    );
  }

  Widget _buildBatchOperations() {
    return BatchOperationsPanel(
      selectedCount: selectedUserIds.length,
      onApproveAll: () => _batchApprove(selectedUserIds),
      onRejectAll: () => _batchReject(selectedUserIds),
      onClearSelection: () => setState(() => selectedUserIds.clear()),
    );
  }

  Widget _buildUsersList() {
    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 15.w, color: Colors.grey[600]),
            SizedBox(height: 2.h),
            Text(
              searchQuery.isNotEmpty || filterStatus != 'all'
                  ? 'لا توجد نتائج للبحث'
                  : 'لا يوجد مستخدمين',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        final userId = user['id'].toString();
        final isSelected = selectedUserIds.contains(userId);

        return UserManagementCard(
          user: user,
          isSelected: isSelected,
          onToggleSelection: (selected) {
            setState(() {
              if (selected) {
                selectedUserIds.add(userId);
              } else {
                selectedUserIds.remove(userId);
              }
            });
          },
          onStatusToggle: (newStatus) => _toggleUserStatus(userId, newStatus),
          onViewDetails: () => _showUserDetails(user),
        );
      },
    );
  }
}