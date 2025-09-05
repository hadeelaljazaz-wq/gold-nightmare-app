import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';
import './otp_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;
  OtpService get _otpService => OtpService.instance;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email and password (traditional method)
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null && response.session != null) {
        debugPrint('User signed up successfully: ${response.user!.email}');
      }

      return response;
    } catch (error) {
      debugPrint('Sign up error: $error');
      rethrow;
    }
  }

  // Sign up with OTP activation (new method)
  Future<Map<String, dynamic>> signUpWithOtp({
    required String email,
    String? fullName,
  }) async {
    try {
      // Send OTP code to email
      final otpResult = await _otpService.sendOtpCode(
        email: email,
        purpose: 'activation',
      );

      if (otpResult['success'] == true) {
        return {
          'success': true,
          'message': 'OTP code sent to email',
          'expires_at': otpResult['expires_at'],
          'email': email,
        };
      } else {
        return {
          'success': false,
          'error': otpResult['error'] ?? 'Failed to send OTP code',
        };
      }
    } catch (error) {
      debugPrint('Sign up with OTP error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  // Complete OTP activation and create account
  Future<Map<String, dynamic>> completeOtpActivation({
    required String email,
    required String otpCode,
    String? fullName,
  }) async {
    try {
      // First verify OTP code
      final verificationResult = await _otpService.verifyOtpCode(
        email: email,
        otpCode: otpCode,
        purpose: 'activation',
      );

      if (verificationResult['success'] != true) {
        return verificationResult;
      }

      // Create Supabase auth account
      final authResponse = await _client.auth.signUp(
        email: email,
        password: 'temp_password_${DateTime.now().millisecondsSinceEpoch}',
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (authResponse.user != null) {
        // User profile will be created automatically via trigger
        // But they will be created with is_unlocked = false (default)
        return {
          'success': true,
          'message': 'Account created successfully. Awaiting admin approval.',
          'user': authResponse.user,
          'session': authResponse.session,
          'requires_admin_approval': true,
        };
      } else {
        return {'success': false, 'error': 'Failed to create account'};
      }
    } catch (error) {
      debugPrint('Complete OTP activation error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        debugPrint('User signed in successfully: ${response.user!.email}');
      }

      return response;
    } catch (error) {
      debugPrint('Sign in error: $error');
      rethrow;
    }
  }

  // Sign in with OTP (passwordless)
  Future<Map<String, dynamic>> signInWithOtp({required String email}) async {
    try {
      // Check if user exists and is active
      final userProfile = await getUserProfileByEmail(email);
      if (userProfile == null) {
        return {
          'success': false,
          'error': 'No account found with this email address',
        };
      }

      if (userProfile['is_active'] != true) {
        return {
          'success': false,
          'error': 'Account is not active. Please contact support.',
        };
      }

      // Check if user is unlocked (admin approved)
      if (userProfile['is_unlocked'] != true) {
        return {
          'success': false,
          'error': 'Account is awaiting admin approval',
          'requires_admin_approval': true,
        };
      }

      // Send OTP for login
      final otpResult = await _otpService.sendOtpCode(
        email: email,
        purpose: 'login',
      );

      return otpResult;
    } catch (error) {
      debugPrint('Sign in with OTP error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  // Verify OTP and sign in
  Future<Map<String, dynamic>> verifyOtpSignIn({
    required String email,
    required String otpCode,
  }) async {
    try {
      // Verify OTP code
      final verificationResult = await _otpService.verifyOtpCode(
        email: email,
        otpCode: otpCode,
        purpose: 'login',
      );

      if (verificationResult['success'] != true) {
        return verificationResult;
      }

      // Create a temporary session by signing in with email
      final tempPassword =
          'temp_password_${DateTime.now().millisecondsSinceEpoch}';

      // First, update the user's password temporarily
      try {
        // Get the user to update password
        final response = await _client.auth.signInWithPassword(
          email: email,
          password: tempPassword,
        );

        if (response.user != null) {
          return {
            'success': true,
            'message': 'OTP verified successfully',
            'user': response.user,
            'session': response.session,
            'email': email,
            'verified_at': DateTime.now().toIso8601String(),
          };
        }
      } catch (e) {
        // If password signin fails, try OTP signin from Supabase
        await _client.auth.signInWithOtp(email: email);
        return {
          'success': true,
          'message': 'OTP verified successfully',
          'email': email,
          'verified_at': DateTime.now().toIso8601String(),
        };
      }

      return {
        'success': true,
        'message': 'OTP verified successfully',
        'email': email,
        'verified_at': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      debugPrint('Verify OTP sign in error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('User signed out successfully');
    } catch (error) {
      debugPrint('Sign out error: $error');
      rethrow;
    }
  }

  // Reset password with OTP
  Future<Map<String, dynamic>> resetPasswordWithOtp(String email) async {
    try {
      final result = await _otpService.requestPasswordReset(email);
      return result;
    } catch (error) {
      debugPrint('Reset password error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  // Verify password reset OTP
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final result = await _otpService.verifyPasswordResetOtp(
        email: email,
        otpCode: otpCode,
      );

      if (result['success'] == true) {
        // Generate password reset token or handle reset logic
        return {
          'success': true,
          'message': 'OTP verified. You can now set a new password.',
          'reset_token': 'verified_$email',
        };
      }

      return result;
    } catch (error) {
      debugPrint('Verify password reset OTP error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  // Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      debugPrint('Password updated successfully');
      return response;
    } catch (error) {
      debugPrint('Update password error: $error');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isLoggedIn) return null;

      final response =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', currentUser!.id)
              .single();

      return response;
    } catch (error) {
      debugPrint('Get user profile error: $error');
      return null;
    }
  }

  // Get user profile by email
  Future<Map<String, dynamic>?> getUserProfileByEmail(String email) async {
    try {
      final response =
          await _client
              .from('user_profiles')
              .select()
              .eq('email', email)
              .single();

      return response;
    } catch (error) {
      debugPrint('Get user profile by email error: $error');
      return null;
    }
  }

  // Check if user is unlocked (admin approved)
  Future<bool> isUserUnlocked() async {
    try {
      if (!isLoggedIn) return false;

      final result = await _client
          .rpc('is_user_unlocked')
          .eq('user_uuid', currentUser!.id);

      return result == true;
    } catch (error) {
      debugPrint('Check user unlock status error: $error');
      return false;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>?> updateUserProfile({
    String? fullName,
    String? role,
  }) async {
    try {
      if (!isLoggedIn) return null;

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (role != null) updates['role'] = role;

      if (updates.isEmpty) return null;

      updates['updated_at'] = DateTime.now().toIso8601String();

      final response =
          await _client
              .from('user_profiles')
              .update(updates)
              .eq('id', currentUser!.id)
              .select()
              .single();

      debugPrint('User profile updated successfully');
      return response;
    } catch (error) {
      debugPrint('Update user profile error: $error');
      rethrow;
    }
  }

  // Admin functions
  Future<List<Map<String, dynamic>>> getAllUsersForAdmin() async {
    try {
      final result = await _client.rpc('admin_get_all_users');
      return List<Map<String, dynamic>>.from(result);
    } catch (error) {
      debugPrint('Get all users for admin error: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>> toggleUserUnlockStatus(
    String userId,
    bool unlockStatus,
  ) async {
    try {
      final result = await _client.rpc(
        'admin_toggle_user_unlock',
        params: {'target_user_id': userId, 'unlock_status': unlockStatus},
      );

      if (result != null && result.isNotEmpty) {
        final response = result[0];
        return {
          'success': response['success'] ?? false,
          'message': response['message'] ?? 'Unknown error',
        };
      } else {
        return {'success': false, 'message': 'No response from server'};
      }
    } catch (error) {
      debugPrint('Toggle user unlock status error: $error');
      return {'success': false, 'message': error.toString()};
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Check if user has specific role
  Future<bool> hasRole(String role) async {
    try {
      final profile = await getUserProfile();
      return profile?['role'] == role;
    } catch (error) {
      debugPrint('Check role error: $error');
      return false;
    }
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    return await hasRole('admin');
  }

  // Check if user is premium
  Future<bool> isPremium() async {
    return await hasRole('premium');
  }

  // Validate email format
  bool isValidEmail(String email) {
    return _otpService.isValidEmail(email);
  }
}