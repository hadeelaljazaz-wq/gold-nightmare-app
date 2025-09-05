import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';
import './user_management_service.dart';

class EmailAuthService {
  static EmailAuthService? _instance;
  static EmailAuthService get instance => _instance ??= EmailAuthService._();
  EmailAuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Sign in with email and OTP
  Future<Map<String, dynamic>> signInWithEmailOtp(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);

      return {
        'success': true,
        'message': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      };
    } catch (error) {
      debugPrint('Email OTP sign-in error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  /// Verify OTP and sign in
  Future<Map<String, dynamic>> verifyOtpAndSignIn({
    required String email,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );

      if (response.user != null) {
        // Check if user is unlocked and active
        final isUnlocked =
            await UserManagementService.instance.isUserUnlockedAndActive();

        if (!isUnlocked) {
          return {
            'success': false,
            'error': 'pending_approval',
            'message': 'حسابك بانتظار موافقة المسؤول',
            'user': response.user,
          };
        }

        return {
          'success': true,
          'message': 'تم تسجيل الدخول بنجاح',
          'user': response.user,
          'session': response.session,
        };
      } else {
        return {
          'success': false,
          'error': 'رمز التحقق غير صحيح أو منتهي الصلاحية',
        };
      }
    } catch (error) {
      debugPrint('OTP verification error: $error');
      String errorMessage = 'خطأ في التحقق من الرمز';

      if (error.toString().contains('invalid_otp')) {
        errorMessage = 'رمز التحقق غير صحيح';
      } else if (error.toString().contains('expired')) {
        errorMessage = 'رمز التحقق منتهي الصلاحية';
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Register new user with email and create profile
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String fullName,
  }) async {
    try {
      // First, sign up the user
      final response = await _client.auth.signUp(
        email: email,
        password: _generateTempPassword(), // Generate temporary password
      );

      if (response.user != null) {
        // Create user profile with locked status
        final profileResult = await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
        );

        if (profileResult['success']) {
          return {
            'success': true,
            'message': 'تم إنشاء الحساب بنجاح. في انتظار موافقة المسؤول.',
            'user': response.user,
            'requires_verification': true,
          };
        } else {
          return {'success': false, 'error': 'فشل في إنشاء ملف المستخدم'};
        }
      } else {
        return {'success': false, 'error': 'فشل في إنشاء الحساب'};
      }
    } catch (error) {
      debugPrint('Email registration error: $error');
      String errorMessage = 'خطأ في إنشاء الحساب';

      if (error.toString().contains('already_registered')) {
        errorMessage = 'البريد الإلكتروني مسجل مسبقاً';
      }

      return {'success': false, 'error': errorMessage};
    }
  }

  /// Create user profile in database
  Future<Map<String, dynamic>> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      await _client.from('user_profiles').insert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'role': 'standard',
        'is_active': true,
        'is_unlocked': false, // New users start locked
      });

      return {'success': true};
    } catch (error) {
      debugPrint('Create profile error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  /// Generate temporary password for registration
  String _generateTempPassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = DateTime.now().millisecondsSinceEpoch;
    return chars.split('').take(12).join() + random.toString().substring(0, 4);
  }

  /// Check authentication status and unlock status
  Future<Map<String, dynamic>> checkAuthStatus() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        return {'authenticated': false, 'unlocked': false};
      }

      final isUnlocked =
          await UserManagementService.instance.isUserUnlockedAndActive();

      return {'authenticated': true, 'unlocked': isUnlocked, 'user': user};
    } catch (error) {
      debugPrint('Check auth status error: $error');
      return {'authenticated': false, 'unlocked': false};
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      debugPrint('Sign out error: $error');
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    return await UserManagementService.instance.getCurrentUserProfile();
  }

  /// Check if user email is valid format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Send OTP to email (for resending OTP)
  Future<Map<String, dynamic>> sendOtpToEmail(String email) async {
    try {
      await _client.auth.signInWithOtp(email: email);

      return {
        'success': true,
        'message': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
        'expires_at':
            DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
      };
    } catch (error) {
      debugPrint('Send OTP to email error: $error');
      String errorMessage = 'فشل في إرسال رمز التحقق';

      if (error.toString().contains('rate_limit')) {
        errorMessage =
            'تم إرسال رموز كثيرة. يرجى الانتظار قبل المحاولة مرة أخرى';
      } else if (error.toString().contains('invalid_email')) {
        errorMessage = 'البريد الإلكتروني غير صحيح';
      }

      return {'success': false, 'error': errorMessage, 'message': errorMessage};
    }
  }
}
