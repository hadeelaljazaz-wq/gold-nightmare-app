import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import './supabase_service.dart';
import './auth_service.dart';

class SecurityService {
  static SecurityService? _instance;
  static SecurityService get instance => _instance ??= SecurityService._();

  SecurityService._();

  static const String _activationStatusKey = 'app_activation_status';
  static const String _deviceIdKey = 'device_id';
  static const String _sessionTokenKey = 'session_token';

  // App lockdown status
  bool _isAppLocked = true;
  bool get isAppLocked => _isAppLocked;

  // Initialize security system
  Future<void> initialize() async {
    try {
      await _checkActivationStatus();
      await _checkSecuritySession();
    } catch (error) {
      debugPrint('Security initialization error: $error');
      _isAppLocked = true;
    }
  }

  // Check if app is activated
  Future<bool> isAppActivated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActivated = prefs.getBool(_activationStatusKey) ?? false;

      if (!isActivated) {
        _isAppLocked = true;
        return false;
      }

      // Double-check with server
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        _isAppLocked = true;
        return false;
      }

      final response = await SupabaseService.instance.client
          .from('user_profiles')
          .select('security_status')
          .eq('id', currentUser.id)
          .single();

      final isServerActivated = response['security_status'] == 'activated';

      if (!isServerActivated) {
        await _lockApp();
        return false;
      }

      _isAppLocked = false;
      return true;
    } catch (error) {
      debugPrint('Check activation error: $error');
      _isAppLocked = true;
      return false;
    }
  }

  // Activate app with security code
  Future<Map<String, dynamic>> activateApp(String activationCode) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to activate');
      }

      // Validate activation code through database function
      final result = await SupabaseService.instance.client
          .rpc('validate_activation_code', params: {
        'code_input': activationCode,
        'user_uuid': currentUser.id,
      });

      if (result['valid'] == true) {
        await _activateAppLocally();
        await _createSecuritySession();

        _isAppLocked = false;

        return {
          'success': true,
          'message': result['message'],
          'plan_type': result['plan_type'],
          'usage_limit': result['usage_limit'],
        };
      } else {
        await _createSecurityAlert('failed_activation',
            'Failed activation attempt with code: $activationCode', 'medium');

        return {
          'success': false,
          'message': result['message'] ?? 'Invalid activation code',
        };
      }
    } catch (error) {
      debugPrint('Activation error: $error');
      return {
        'success': false,
        'message': 'Activation failed. Please try again.',
      };
    }
  }

  // Get security dashboard data
  Future<Map<String, dynamic>> getSecurityDashboard() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      // Get user security profile
      final profileResponse = await SupabaseService.instance.client
          .from('user_profiles')
          .select('*')
          .eq('id', currentUser.id)
          .single();

      // Get active sessions
      final sessionsResponse = await SupabaseService.instance.client
          .from('security_sessions')
          .select('*')
          .eq('user_id', currentUser.id)
          .eq('is_active', true)
          .order('last_access', ascending: false);

      // Get recent alerts
      final alertsResponse = await SupabaseService.instance.client
          .from('security_alerts')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(10);

      // Get activation attempts
      final attemptsResponse = await SupabaseService.instance.client
          .from('activation_attempts')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .limit(5);

      // Calculate security score
      final securityScore = await SupabaseService.instance.client
          .rpc('calculate_security_score', params: {
        'user_uuid': currentUser.id,
      });

      return {
        'profile': profileResponse,
        'sessions': sessionsResponse,
        'alerts': alertsResponse,
        'attempts': attemptsResponse,
        'security_score': securityScore,
        'is_activated': profileResponse['security_status'] == 'activated',
      };
    } catch (error) {
      debugPrint('Get security dashboard error: $error');
      rethrow;
    }
  }

  // Lock app and clear local data
  Future<void> lockApp() async {
    await _lockApp();
    _isAppLocked = true;
  }

  // Enable two-factor authentication
  Future<void> enableTwoFactor() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await SupabaseService.instance.client
          .from('user_profiles')
          .update({'two_factor_enabled': true}).eq('id', currentUser.id);

      await _createSecurityAlert(
          'security_update', 'Two-factor authentication enabled', 'low');
    } catch (error) {
      debugPrint('Enable 2FA error: $error');
      rethrow;
    }
  }

  // Enable biometric authentication
  Future<void> enableBiometric() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) throw Exception('User not authenticated');

      await SupabaseService.instance.client
          .from('user_profiles')
          .update({'biometric_enabled': true}).eq('id', currentUser.id);

      await _createSecurityAlert(
          'security_update', 'Biometric authentication enabled', 'low');
    } catch (error) {
      debugPrint('Enable biometric error: $error');
      rethrow;
    }
  }

  // Revoke device session
  Future<void> revokeDeviceSession(String sessionId) async {
    try {
      await SupabaseService.instance.client
          .from('security_sessions')
          .update({'is_active': false}).eq('id', sessionId);

      await _createSecurityAlert(
          'session_revoked', 'Device session revoked manually', 'medium');
    } catch (error) {
      debugPrint('Revoke session error: $error');
      rethrow;
    }
  }

  // Get device fingerprint
  Future<String> _getDeviceFingerprint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);

      return deviceId ?? 'unknown-device';
    } catch (error) {
      debugPrint('Device fingerprint error: $error');
      return 'unknown-device';
    }
  }

  // Private methods
  Future<void> _checkActivationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAppLocked = !(prefs.getBool(_activationStatusKey) ?? false);
    } catch (error) {
      _isAppLocked = true;
    }
  }

  Future<void> _checkSecuritySession() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) {
        _isAppLocked = true;
        return;
      }

      final deviceId = await _getDeviceFingerprint();

      // Check if device has active session
      final sessionResponse = await SupabaseService.instance.client
          .from('security_sessions')
          .select('*')
          .eq('user_id', currentUser.id)
          .eq('device_id', deviceId)
          .eq('is_active', true)
          .order('last_access', ascending: false)
          .limit(1);

      if (sessionResponse.isEmpty) {
        _isAppLocked = true;
      } else {
        // Update session last access
        await SupabaseService.instance.client
            .from('security_sessions')
            .update({'last_access': DateTime.now().toIso8601String()}).eq(
                'id', sessionResponse.first['id']);
      }
    } catch (error) {
      debugPrint('Check security session error: $error');
      _isAppLocked = true;
    }
  }

  Future<void> _activateAppLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_activationStatusKey, true);
    } catch (error) {
      debugPrint('Local activation error: $error');
    }
  }

  Future<void> _lockApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_activationStatusKey, false);
      await prefs.remove(_sessionTokenKey);
    } catch (error) {
      debugPrint('Lock app error: $error');
    }
  }

  Future<void> _createSecuritySession() async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return;

      final deviceId = await _getDeviceFingerprint();
      final sessionToken = sha256
          .convert(utf8.encode(
              '${currentUser.id}-${deviceId}-${DateTime.now().millisecondsSinceEpoch}'))
          .toString();

      await SupabaseService.instance.client.from('security_sessions').insert({
        'user_id': currentUser.id,
        'device_id': deviceId,
        'device_name': _getDeviceName(),
        'platform': _getPlatform(),
        'session_token': sessionToken,
        'is_active': true,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionTokenKey, sessionToken);
    } catch (error) {
      debugPrint('Create security session error: $error');
    }
  }

  Future<void> _createSecurityAlert(
      String type, String message, String severity) async {
    try {
      final currentUser = AuthService.instance.currentUser;
      if (currentUser == null) return;

      await SupabaseService.instance.client.from('security_alerts').insert({
        'user_id': currentUser.id,
        'alert_type': type,
        'severity': severity,
        'message': message,
      });
    } catch (error) {
      debugPrint('Create security alert error: $error');
    }
  }

  String _getDeviceName() {
    if (kIsWeb) return 'Web Browser';
    if (defaultTargetPlatform == TargetPlatform.android)
      return 'Android Device';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'iOS Device';
    return 'Unknown Device';
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'unknown';
  }
}