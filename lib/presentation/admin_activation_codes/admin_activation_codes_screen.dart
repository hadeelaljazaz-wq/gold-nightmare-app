import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/license_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';

class AdminActivationCodesScreen extends StatefulWidget {
  const AdminActivationCodesScreen({super.key});

  @override
  State<AdminActivationCodesScreen> createState() =>
      _AdminActivationCodesScreenState();
}

class _AdminActivationCodesScreenState
    extends State<AdminActivationCodesScreen> {
  List<Map<String, dynamic>> _activationCodes = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _filterStatus = 'all';
  String _filterTier = 'all';
  Map<String, dynamic>? _statistics;
  bool _isLoadingStatistics = false;
  int _codeCount = 1;
  String _selectedPlanType = 'standard';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadActivationCodes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Query all license keys with user information
      final response =
          await SupabaseService.instance.client.from('license_keys').select('''
            id, key_value, plan_type, status, usage_count, usage_limit,
            created_at, activated_at, expires_at,
            user_id,
            user_profiles(full_name, email)
          ''').order('created_at', ascending: false);

      setState(() {
        _activationCodes = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'خطأ في تحميل أكواد التفعيل: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStatistics = true;
    });

    try {
      final result = await LicenseService.getLicenseStatistics();
      if (result['success']) {
        setState(() {
          _statistics = result['statistics'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading statistics: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingStatistics = false;
      });
    }
  }

  Future<void> _generateActivationCodes() async {
    // Show dialog to select count and type
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Activation Codes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Number of codes',
                hintText: 'Enter count (1-100)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _codeCount = int.tryParse(value) ?? 1,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Plan Type'),
              value: _selectedPlanType,
              items: const [
                DropdownMenuItem(value: 'standard', child: Text('Standard')),
                DropdownMenuItem(value: 'premium', child: Text('Premium')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) => _selectedPlanType = value ?? 'standard',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'count': _codeCount,
              'planType': _selectedPlanType,
            }),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      final generateResult = await LicenseService.generateActivationCodesBatch(
        count: result['count'],
        planType: result['planType'],
        usageLimit: result['planType'] == 'admin' ? 9999 : 100,
      );

      setState(() {
        _isLoading = false;
      });

      if (generateResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(generateResult['message'])),
        );
        _loadActivationCodes();
        _loadStatistics();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(generateResult['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createFixedAdminCode() async {
    setState(() {
      _isLoading = true;
    });

    final result = await LicenseService.createFixedAdminCode();

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fixed admin code created: ${result['adminCode']}'),
          duration: const Duration(seconds: 5),
        ),
      );
      _loadActivationCodes();
      _loadStatistics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredCodes {
    return _activationCodes.where((code) {
      final matchesSearch = code['key_value'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      final matchesStatus = _filterStatus == 'all' ||
          (_filterStatus == 'unused' && code['user_id'] == null) ||
          (_filterStatus == 'used' && code['user_id'] != null);

      final matchesTier =
          _filterTier == 'all' || code['plan_type'] == _filterTier;

      return matchesSearch && matchesStatus && matchesTier;
    }).toList();
  }

  void _copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Fluttertoast.showToast(
      msg: 'تم نسخ الكود: $code',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showCodeDetails(Map<String, dynamic> code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تفاصيل كود التفعيل',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('الكود:', code['key_value']),
              _buildDetailRow(
                'نوع الخطة:',
                _getPlanTypeArabic(code['plan_type']),
              ),
              _buildDetailRow('الحالة:', _getStatusArabic(code['status'])),
              _buildDetailRow(
                'حد الاستخدام:',
                '${code['usage_limit']} تحليل',
              ),
              _buildDetailRow('المستخدم:', code['usage_count'].toString()),
              if (code['user_profiles'] != null) ...[
                _buildDetailRow(
                  'المستخدم:',
                  code['user_profiles']['full_name'] ?? 'غير محدد',
                ),
                _buildDetailRow(
                  'البريد الإلكتروني:',
                  code['user_profiles']['email'] ?? 'غير محدد',
                ),
              ] else
                _buildDetailRow('المستخدم:', 'غير مستخدم'),
              _buildDetailRow(
                'تاريخ الإنشاء:',
                _formatDate(code['created_at']),
              ),
              if (code['activated_at'] != null)
                _buildDetailRow(
                  'تاريخ التفعيل:',
                  _formatDate(code['activated_at']),
                ),
              if (code['expires_at'] != null)
                _buildDetailRow(
                  'تاريخ الانتهاء:',
                  _formatDate(code['expires_at']),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إغلاق', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyToClipboard(code['key_value']);
            },
            child: Text('نسخ الكود', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.inter(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }

  String _getPlanTypeArabic(String planType) {
    switch (planType) {
      case 'premium':
        return 'بريميوم';
      case 'standard':
        return 'عادي';
      case 'admin':
        return 'إداري';
      default:
        return planType;
    }
  }

  String _getStatusArabic(String status) {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'expired':
        return 'منتهي الصلاحية';
      case 'suspended':
        return 'معلق';
      case 'pending':
        return 'في الانتظار';
      default:
        return status;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'تاريخ غير صالح';
    }
  }

  Widget _buildStatisticsCard() {
    if (_isLoadingStatistics) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_statistics == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No statistics available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'License Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Total', _statistics!['total_codes']?.toString() ?? '0'),
                _buildStatItem(
                    'Active', _statistics!['active_codes']?.toString() ?? '0'),
                _buildStatItem(
                    'Used', _statistics!['used_codes']?.toString() ?? '0'),
                _buildStatItem(
                    'Admin', _statistics!['admin_codes']?.toString() ?? '0'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Expired',
                    _statistics!['expired_codes']?.toString() ?? '0'),
                _buildStatItem(
                    'Unused', _statistics!['unused_codes']?.toString() ?? '0'),
                _buildStatItem('Expiring Soon',
                    _statistics!['codes_expiring_soon']?.toString() ?? '0'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'إدارة أكواد التفعيل (${_activationCodes.length})',
        showBackButton: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'generate50') {
                _generateActivationCodes();
              } else if (value == 'createAdmin') {
                _createFixedAdminCode();
              } else if (value == 'refresh') {
                _loadActivationCodes();
                _loadStatistics();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'generate50',
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.green),
                    SizedBox(width: 8.w),
                    Text('إنشاء 50 كود (14 يوم)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'createAdmin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.blue),
                    SizedBox(width: 8.w),
                    Text('إنشاء كود إداري'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.grey),
                    SizedBox(width: 8.w),
                    Text('تحديث البيانات'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Add statistics card at the top
          _buildStatisticsCard(),
          const SizedBox(height: 16),

          // Add action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateActivationCodes,
                icon: const Icon(Icons.add),
                label: const Text('Generate Codes'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _createFixedAdminCode,
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Create Admin Code'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadStatistics,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'البحث في أكواد التفعيل...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SizedBox(height: 12.h),
                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterStatus,
                        decoration: InputDecoration(
                          labelText: 'فلترة حسب الحالة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('الكل'),
                          ),
                          DropdownMenuItem(
                            value: 'unused',
                            child: Text('غير مستخدم'),
                          ),
                          DropdownMenuItem(
                            value: 'used',
                            child: Text('مستخدم'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterStatus = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _filterTier,
                        decoration: InputDecoration(
                          labelText: 'فلترة حسب النوع',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('الكل'),
                          ),
                          DropdownMenuItem(
                            value: 'premium',
                            child: Text('بريميوم'),
                          ),
                          DropdownMenuItem(
                            value: 'standard',
                            child: Text('عادي'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filterTier = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Statistics Row
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'إجمالي الأكواد',
                    _activationCodes.length.toString(),
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'الأكواد المستخدمة',
                    _activationCodes
                        .where((c) => c['user_id'] != null)
                        .length
                        .toString(),
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildStatCard(
                    'الأكواد المتاحة',
                    _activationCodes
                        .where((c) => c['user_id'] == null)
                        .length
                        .toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          // Codes List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadActivationCodes,
              child: _filteredCodes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.vpn_key_off,
                            size: 64.w,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد أكواد تفعيل مطابقة للبحث',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _filteredCodes.length,
                      itemBuilder: (context, index) {
                        final code = _filteredCodes[index];
                        return _buildCodeCard(code);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4.w)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(Map<String, dynamic> code) {
    final isUsed = code['user_id'] != null;
    final planType = code['plan_type'] as String;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        title: Row(
          children: [
            // Plan Type Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: planType == 'premium'
                    ? Colors.purple.withAlpha(26)
                    : Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getPlanTypeArabic(planType),
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: planType == 'premium' ? Colors.purple : Colors.blue,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // Usage Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isUsed
                    ? Colors.green.withAlpha(26)
                    : Colors.orange.withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isUsed ? 'مستخدم' : 'متاح',
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: isUsed ? Colors.green : Colors.orange,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            // Activation Code
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code['key_value'],
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(code['key_value']),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            // Usage Info
            Row(
              children: [
                Icon(Icons.analytics, size: 16.w, color: Colors.grey[600]),
                SizedBox(width: 4.w),
                Text(
                  '${code['usage_count']} / ${code['usage_limit']} تحليل',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                if (isUsed && code['user_profiles'] != null) ...[
                  SizedBox(width: 16.w),
                  Icon(Icons.person, size: 16.w, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      code['user_profiles']['full_name'] ?? 'مستخدم غير محدد',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showCodeDetails(code),
        ),
        onTap: () => _showCodeDetails(code),
      ),
    );
  }
}