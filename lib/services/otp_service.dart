import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class OtpService {
  static OtpService? _instance;
  static OtpService get instance => _instance ??= OtpService._();
  OtpService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  /// Send OTP code to email
  Future<Map<String, dynamic>> sendOtpCode({
    required String email,
    String purpose = 'activation',
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-otp-email',
        body: {
          'email': email,
          'purpose': purpose,
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to send OTP: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        debugPrint('OTP sent successfully to: $email');
        return {
          'success': true,
          'message': data['message'],
          'expires_at': data['expires_at'],
        };
      } else {
        throw Exception(data['error'] ?? 'Unknown error occurred');
      }
    } catch (error) {
      debugPrint('Send OTP error: $error');
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  /// Verify OTP code
  Future<Map<String, dynamic>> verifyOtpCode({
    required String email,
    required String otpCode,
    String purpose = 'activation',
  }) async {
    try {
      final response = await _client.rpc(
        'verify_otp_code',
        params: {
          'user_email': email,
          'provided_otp': otpCode,
          'verification_purpose': purpose,
        },
      );

      final isValid = response as bool;

      if (isValid) {
        debugPrint('OTP verified successfully for: $email');
        return {
          'success': true,
          'message': 'OTP verified successfully',
        };
      } else {
        return {
          'success': false,
          'error': 'Invalid or expired OTP code',
        };
      }
    } catch (error) {
      debugPrint('Verify OTP error: $error');
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  /// Activate user account with OTP
  Future<Map<String, dynamic>> activateUserAccount({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _client.rpc(
        'activate_user_account',
        params: {
          'user_email': email,
          'provided_otp': otpCode,
        },
      );

      if (response.isEmpty) {
        return {
          'success': false,
          'error': 'No response from activation service',
        };
      }

      final result = response[0] as Map<String, dynamic>;

      if (result['success'] == true) {
        debugPrint('Account activated successfully for: $email');
        return {
          'success': true,
          'message': result['message'],
          'user_id': result['user_id'],
        };
      } else {
        return {
          'success': false,
          'error': result['message'],
        };
      }
    } catch (error) {
      debugPrint('Account activation error: $error');
      return {
        'success': false,
        'error': error.toString(),
      };
    }
  }

  /// Request password reset OTP
  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    return await sendOtpCode(
      email: email,
      purpose: 'password_reset',
    );
  }

  /// Verify password reset OTP
  Future<Map<String, dynamic>> verifyPasswordResetOtp({
    required String email,
    required String otpCode,
  }) async {
    return await verifyOtpCode(
      email: email,
      otpCode: otpCode,
      purpose: 'password_reset',
    );
  }

  /// Check if email is valid format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Format time remaining for OTP expiry
  String formatTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'منتهي الصلاحية';
    }

    final minutes = difference.inMinutes;
    final seconds = difference.inSeconds % 60;

    if (minutes > 0) {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${seconds} ثانية';
    }
  }

  /// Parse expiry time from API response
  DateTime? parseExpiryTime(dynamic expiresAt) {
    if (expiresAt == null) return null;

    try {
      if (expiresAt is String) {
        return DateTime.parse(expiresAt).toLocal();
      } else if (expiresAt is DateTime) {
        return expiresAt.toLocal();
      }
    } catch (e) {
      debugPrint('Failed to parse expiry time: $e');
    }

    return null;
  }
}
