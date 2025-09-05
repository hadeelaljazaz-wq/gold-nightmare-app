import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/license_model.dart';
import './auth_service.dart';
import './security_service.dart';
import './supabase_service.dart';

class LicenseService {
  static LicenseService? _instance;
  static LicenseService get instance => _instance ??= LicenseService._();
  LicenseService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Enhanced method to validate license with expiration check
  static Future<Map<String, dynamic>> validateLicenseKey(
      String licenseKey) async {
    try {
      // First, check for expired licenses
      await _checkLicenseExpiration();

      final response = await SupabaseService.instance.client
          .from('license_keys')
          .select('*, user_profiles!inner(*)')
          .eq('key_value', licenseKey)
          .maybeSingle();

      if (response == null) {
        return {
          'success': false,
          'message': 'Invalid license key',
        };
      }

      final license = LicenseModel.fromJson(response);

      // Check if license is expired
      if (license.status == 'expired') {
        return {
          'success': false,
          'message': 'License key has expired',
        };
      }

      // Check if license is already used (unless it's an admin code)
      if (license.userId != null && !license.isFixedAdmin) {
        return {
          'success': false,
          'message': 'License key is already in use',
        };
      }

      return {
        'success': true,
        'license': license,
        'message': 'Valid license key',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error validating license: $e',
      };
    }
  }

  // New method to check license expiration
  static Future<void> _checkLicenseExpiration() async {
    try {
      await SupabaseService.instance.client.rpc('check_license_expiration');
    } catch (e) {
      print('Error checking license expiration: $e');
    }
  }

  // New method to get license statistics
  static Future<Map<String, dynamic>> getLicenseStatistics() async {
    try {
      final response = await SupabaseService.instance.client
          .from('license_statistics')
          .select('*')
          .single();

      return {
        'success': true,
        'statistics': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching license statistics: $e',
      };
    }
  }

  // New method to generate activation codes batch
  static Future<Map<String, dynamic>> generateActivationCodesBatch({
    required int count,
    required String planType,
    int usageLimit = 100,
  }) async {
    try {
      final response = await SupabaseService.instance.client.rpc(
        'generate_activation_codes_batch',
        params: {
          'code_count': count,
          'plan_type_param': planType,
          'usage_limit_param': usageLimit,
        },
      );

      return {
        'success': true,
        'codes': response,
        'message': 'Generated $count activation codes successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error generating activation codes: $e',
      };
    }
  }

  // New method to create fixed admin code
  static Future<Map<String, dynamic>> createFixedAdminCode() async {
    try {
      final response =
          await SupabaseService.instance.client.rpc('create_fixed_admin_code');

      return {
        'success': true,
        'adminCode': response,
        'message': 'Fixed admin code created successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating fixed admin code: $e',
      };
    }
  }

  // Enhanced method to activate license with device management
  static Future<Map<String, dynamic>> activateLicense({
    required String licenseKey,
    required String userId,
    String? deviceInfo,
  }) async {
    try {
      // Validate the license first
      final validation = await validateLicenseKey(licenseKey);
      if (!validation['success']) {
        return validation;
      }

      final license = validation['license'] as LicenseModel;

      // For admin codes, allow multiple activations
      if (license.isFixedAdmin) {
        // Update user profile with admin role
        await SupabaseService.instance.client.from('user_profiles').update({
          'role': 'admin',
          'license_key_id': license.id,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        return {
          'success': true,
          'message': 'Admin license activated successfully',
          'license': license,
        };
      }

      // For regular codes, check device limits and activate
      await SupabaseService.instance.client.from('license_keys').update({
        'user_id': userId,
        'used_at': DateTime.now().toIso8601String(),
        'status': 'used',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', license.id);

      // Update user profile
      await SupabaseService.instance.client.from('user_profiles').update({
        'role': license.planType,
        'license_key_id': license.id,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return {
        'success': true,
        'message': 'License activated successfully',
        'license': license,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error activating license: $e',
      };
    }
  }

  // Activate license key using the security service
  Future<Map<String, dynamic>?> activateLicenseKey(String licenseKey) async {
    try {
      final result = await SecurityService.instance.activateApp(licenseKey);

      if (result['success']) {
        debugPrint('License activated via SecurityService: $licenseKey');
        return result;
      } else {
        throw Exception(result['message']);
      }
    } catch (error) {
      debugPrint('License activation error: $error');
      rethrow;
    }
  }

  // Get user's active license
  Future<Map<String, dynamic>?> getUserActiveLicense() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return null;

      final response = await _client.rpc(
        'get_user_active_license',
        params: {'user_uuid': currentUser.id},
      );

      return response.isNotEmpty ? response.first : null;
    } catch (error) {
      debugPrint('Get user license error: $error');
      return null;
    }
  }

  // Check if user can perform analysis
  Future<bool> canPerformAnalysis() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return false;

      // First check if app is activated
      final isActivated = await SecurityService.instance.isAppActivated();
      if (!isActivated) return false;

      final result = await _client.rpc(
        'can_perform_analysis',
        params: {'user_uuid': currentUser.id},
      );

      return result == true;
    } catch (error) {
      debugPrint('Check analysis permission error: $error');
      return false;
    }
  }

  // Get license usage statistics
  Future<Map<String, dynamic>?> getLicenseUsage() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return null;

      final response = await _client
          .from('license_keys')
          .select('usage_count, usage_limit, plan_type, expires_at')
          .eq('user_id', currentUser.id)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      final license = response.first;
      final remaining =
          (license['usage_limit'] as int) - (license['usage_count'] as int);

      return {
        'used': license['usage_count'],
        'total': license['usage_limit'],
        'remaining': remaining,
        'plan_type': license['plan_type'],
        'expires_at': license['expires_at'],
      };
    } catch (error) {
      debugPrint('Get license usage error: $error');
      return null;
    }
  }

  // Increment license usage (called after analysis)
  Future<void> incrementUsage(String analysisId) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return;

      // Check if user can still perform analysis
      final canPerform = await canPerformAnalysis();
      if (!canPerform) {
        throw Exception('Analysis limit reached or license expired');
      }

      // Get active license
      final licenseResponse = await _client
          .from('license_keys')
          .select('id, usage_count')
          .eq('user_id', currentUser.id)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1);

      if (licenseResponse.isEmpty) {
        throw Exception('No active license found');
      }

      final license = licenseResponse.first;

      // Create usage tracking entry
      await _client.from('usage_tracking').insert({
        'user_id': currentUser.id,
        'license_key_id': license['id'],
        'analysis_id': analysisId,
      });

      // Increment usage count
      await _client.from('license_keys').update({
        'usage_count': (license['usage_count'] as int) + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', license['id']);

      debugPrint('License usage incremented for analysis: $analysisId');
    } catch (error) {
      debugPrint('Increment usage error: $error');
      rethrow;
    }
  }

  // Get user's license history
  Future<List<Map<String, dynamic>>> getLicenseHistory() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return [];

      final response = await _client
          .from('license_keys')
          .select()
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Get license history error: $error');
      return [];
    }
  }

  // Check license expiration
  Future<bool> isLicenseExpired() async {
    try {
      final license = await getUserActiveLicense();
      if (license == null) return true;

      final expiresAt = license['expires_at'];
      if (expiresAt == null) return false; // No expiration

      final expiryDate = DateTime.parse(expiresAt);
      return expiryDate.isBefore(DateTime.now());
    } catch (error) {
      debugPrint('Check license expiration error: $error');
      return true;
    }
  }

  // Get days until expiration
  Future<int?> getDaysUntilExpiration() async {
    try {
      final license = await getUserActiveLicense();
      if (license == null) return null;

      final expiresAt = license['expires_at'];
      if (expiresAt == null) return null; // No expiration

      final expiryDate = DateTime.parse(expiresAt);
      final now = DateTime.now();

      if (expiryDate.isBefore(now)) return 0; // Already expired

      return expiryDate.difference(now).inDays;
    } catch (error) {
      debugPrint('Get expiration days error: $error');
      return null;
    }
  }

  // Get available activation codes count (for admin)
  Future<int> getAvailableCodesCount() async {
    try {
      final response = await _client
          .from('license_keys')
          .select('id')
          .eq('status', 'active')
          .isFilter('user_id', null);

      return response.length;
    } catch (error) {
      debugPrint('Get available codes count error: $error');
      return 0;
    }
  }

  // Get all activation codes with user details (admin only)
  Future<List<Map<String, dynamic>>> getAllActivationCodesWithDetails() async {
    try {
      final response = await _client.from('license_keys').select('''
            id, key_value, plan_type, status, usage_count, usage_limit,
            created_at, activated_at, expires_at, user_id,
            user_profiles(full_name, email)
          ''').order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Get all activation codes error: $error');
      return [];
    }
  }

  // Get activation codes statistics (admin only)
  Future<Map<String, int>> getActivationCodesStatistics() async {
    try {
      final allCodes = await _client
          .from('license_keys')
          .select('user_id, plan_type, status')
          .eq('status', 'active');

      final total = allCodes.length;
      final used = allCodes.where((code) => code['user_id'] != null).length;
      final unused = total - used;
      final premium =
          allCodes.where((code) => code['plan_type'] == 'premium').length;
      final standard =
          allCodes.where((code) => code['plan_type'] == 'standard').length;

      return {
        'total': total,
        'used': used,
        'unused': unused,
        'premium': premium,
        'standard': standard,
      };
    } catch (error) {
      debugPrint('Get activation statistics error: $error');
      return {'total': 0, 'used': 0, 'unused': 0, 'premium': 0, 'standard': 0};
    }
  }

  // Enhanced activation statistics
  Future<Map<String, int>> getEnhancedActivationStatistics() async {
    try {
      final response = await _client.rpc('get_activation_code_statistics');

      if (response != null && response.isNotEmpty) {
        final stats = response.first as Map<String, dynamic>;
        return {
          'total': stats['total_codes'] ?? 0,
          'active': stats['active_codes'] ?? 0,
          'expired': stats['expired_codes'] ?? 0,
          'used': stats['used_codes'] ?? 0,
          'unused': stats['unused_codes'] ?? 0,
          'admin': stats['admin_codes'] ?? 0,
          'expiring_soon': stats['codes_expiring_soon'] ?? 0,
        };
      }

      return {
        'total': 0,
        'active': 0,
        'expired': 0,
        'used': 0,
        'unused': 0,
        'admin': 0,
        'expiring_soon': 0,
      };
    } catch (error) {
      debugPrint('Get enhanced statistics error: $error');
      return {
        'total': 0,
        'active': 0,
        'expired': 0,
        'used': 0,
        'unused': 0,
        'admin': 0,
        'expiring_soon': 0,
      };
    }
  }

  // Check if code is admin code with special privileges
  Future<bool> isAdminCode(String licenseKey) async {
    try {
      final response = await _client
          .from('license_keys')
          .select('is_fixed_admin, plan_type')
          .eq('key_value', licenseKey)
          .eq('status', 'active')
          .limit(1);

      if (response.isNotEmpty) {
        final license = response.first;
        return license['is_fixed_admin'] == true ||
            license['plan_type'] == 'admin';
      }

      return false;
    } catch (error) {
      debugPrint('Check admin code error: $error');
      return false;
    }
  }

  // Get codes expiring within specified days
  Future<List<Map<String, dynamic>>> getCodesExpiringSoon({
    int days = 3,
  }) async {
    try {
      final expirationDate = DateTime.now().add(Duration(days: days));

      final response = await _client
          .from('license_keys')
          .select('''
            id, key_value, plan_type, expires_at, user_id,
            user_profiles(full_name, email)
          ''')
          .eq('status', 'active')
          .lt('expires_at', expirationDate.toIso8601String())
          .order('expires_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('Get expiring codes error: $error');
      return [];
    }
  }

  // Force check license expiration
  Future<void> checkAndUpdateExpiredLicenses() async {
    try {
      await _client.rpc('check_license_expiration');
      debugPrint('License expiration check completed');
    } catch (error) {
      debugPrint('Check expiration error: $error');
    }
  }
}