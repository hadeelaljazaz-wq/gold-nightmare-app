import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class UserManagementService {
  static UserManagementService? _instance;
  static UserManagementService get instance =>
      _instance ??= UserManagementService._();
  UserManagementService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Get all users for admin dashboard
  Future<List<Map<String, dynamic>>> getAllUsersForAdmin() async {
    try {
      final response = await _client.rpc('get_all_users_for_admin');

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }

      return [];
    } catch (error) {
      debugPrint('Get all users error: $error');
      throw Exception('Failed to fetch users: $error');
    }
  }

  /// Update user unlock status (admin only)
  Future<bool> updateUserUnlockStatus({
    required String userId,
    required bool isUnlocked,
  }) async {
    try {
      final response = await _client.rpc(
        'update_user_unlock_status',
        params: {'target_user_id': userId, 'unlock_status': isUnlocked},
      );

      return response == true;
    } catch (error) {
      debugPrint('Update unlock status error: $error');
      throw Exception('Failed to update user status: $error');
    }
  }

  /// Check if current user is unlocked and active
  Future<bool> isUserUnlockedAndActive() async {
    try {
      final response = await _client.rpc('is_user_unlocked_and_active');
      return response == true;
    } catch (error) {
      debugPrint('Check unlock status error: $error');
      return false;
    }
  }

  /// Get current user profile with unlock status
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .single();

      return response;
    } catch (error) {
      debugPrint('Get current user profile error: $error');
      return null;
    }
  }

  /// Send notification to user about status change
  Future<void> notifyUserStatusChange({
    required String userId,
    required bool isUnlocked,
  }) async {
    try {
      // Get user email
      final userProfile =
          await _client
              .from('user_profiles')
              .select('email, full_name')
              .eq('id', userId)
              .single();

      // Here you could integrate with a notification service
      // For now, we'll just log it
      debugPrint(
        'Status changed for ${userProfile['full_name']} (${userProfile['email']}): '
        '${isUnlocked ? "Unlocked" : "Locked"}',
      );
        } catch (error) {
      debugPrint('Notification error: $error');
      // Don't throw - notification failure shouldn't block the main operation
    }
  }

  /// Check if user is admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final response =
          await _client
              .from('user_profiles')
              .select('role')
              .eq('id', user.id)
              .single();

      return response['role'] == 'admin';
    } catch (error) {
      debugPrint('Check admin status error: $error');
      return false;
    }
  }

  /// Get user statistics for admin dashboard
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final totalUsers = await _client.from('user_profiles').select().count();

      final unlockedUsers =
          await _client
              .from('user_profiles')
              .select()
              .eq('is_unlocked', true)
              .count();

      final activeUsers =
          await _client
              .from('user_profiles')
              .select()
              .eq('is_active', true)
              .count();

      final adminUsers =
          await _client
              .from('user_profiles')
              .select()
              .eq('role', 'admin')
              .count();

      return {
        'total_users': totalUsers.count ?? 0,
        'unlocked_users': unlockedUsers.count ?? 0,
        'active_users': activeUsers.count ?? 0,
        'admin_users': adminUsers.count ?? 0,
        'locked_users': (totalUsers.count ?? 0) - (unlockedUsers.count ?? 0),
      };
    } catch (error) {
      debugPrint('Get user statistics error: $error');
      return {
        'total_users': 0,
        'unlocked_users': 0,
        'active_users': 0,
        'admin_users': 0,
        'locked_users': 0,
      };
    }
  }

  /// Search users by email or name
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final users = await getAllUsersForAdmin();

      if (query.isEmpty) return users;

      final lowercaseQuery = query.toLowerCase();
      return users.where((user) {
        final email = (user['email'] as String? ?? '').toLowerCase();
        final name = (user['full_name'] as String? ?? '').toLowerCase();
        return email.contains(lowercaseQuery) || name.contains(lowercaseQuery);
      }).toList();
    } catch (error) {
      debugPrint('Search users error: $error');
      return [];
    }
  }

  /// Get user activity summary
  String getUserActivitySummary(Map<String, dynamic> user) {
    final isActive = user['is_active'] as bool? ?? false;
    final isUnlocked = user['is_unlocked'] as bool? ?? false;
    final lastSignIn = user['last_sign_in_at'] as String?;

    if (!isActive) return 'حساب معطل';
    if (!isUnlocked) return 'في انتظار موافقة المسؤول';

    if (lastSignIn != null) {
      final lastSignInDate = DateTime.parse(lastSignIn);
      final daysDiff = DateTime.now().difference(lastSignInDate).inDays;

      if (daysDiff == 0) return 'نشط اليوم';
      if (daysDiff == 1) return 'نشط أمس';
      if (daysDiff <= 7) return 'نشط هذا الأسبوع';
      if (daysDiff <= 30) return 'نشط هذا الشهر';
      return 'غير نشط لفترة طويلة';
    }

    return 'لم يسجل دخول من قبل';
  }
}
