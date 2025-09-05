import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/otp_service.dart';
import '../license_key_activation/widgets/success_animation_widget.dart';
import './widgets/email_input_widget.dart';
import './widgets/otp_input_widget.dart';
import './widgets/resend_button_widget.dart';

class OtpActivationScreen extends StatefulWidget {
  const OtpActivationScreen({super.key});

  @override
  State<OtpActivationScreen> createState() => _OtpActivationScreenState();
}

class _OtpActivationScreenState extends State<OtpActivationScreen>
    with TickerProviderStateMixin {
  // Form and input controllers
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();

  // State management
  bool _isEmailStep = true;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _showSuccess = false;
  String? _errorMessage;
  String _userEmail = '';
  DateTime? _otpExpiresAt;
  int _remainingAnalyses = 50;

  // Animation controllers
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  // OTP Service
  final OtpService _otpService = OtpService.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.primaryDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _sendOtpCode() async {
    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'يرجى إدخال بريد إلكتروني صحيح';
      });
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
      _userEmail = _emailController.text.trim();
    });

    try {
      final result = await _otpService.sendOtpCode(
        email: _userEmail,
        purpose: 'activation',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        // Parse expiry time
        _otpExpiresAt = _otpService.parseExpiryTime(result['expires_at']);

        setState(() {
          _isEmailStep = false;
          _isSendingOtp = false;
        });

        // Animate to OTP step
        _slideController.forward();

        // Focus OTP input after animation
        Future.delayed(const Duration(milliseconds: 500), () {
          _otpFocusNode.requestFocus();
        });

        // Show success feedback
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال كود التفعيل إلى $_userEmail',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(() {
          _isSendingOtp = false;
          _errorMessage = result['error'] ?? 'فشل في إرسال كود التفعيل';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _errorMessage = 'فشل في إرسال كود التفعيل. تحقق من اتصال الإنترنت.';
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _verifyOtpCode() async {
    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = 'يرجى إدخال كود التفعيل المكون من 6 أرقام';
      });
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
      _errorMessage = null;
    });

    try {
      final result = await _otpService.activateUserAccount(
        email: _userEmail,
        otpCode: _otpController.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _isVerifyingOtp = false;
          _showSuccess = true;
        });
        HapticFeedback.mediumImpact();
      } else {
        setState(() {
          _isVerifyingOtp = false;
          _errorMessage = result['error'] ?? 'كود التفعيل غير صحيح';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isVerifyingOtp = false;
        _errorMessage = 'فشل في التحقق من كود التفعيل. حاول مرة أخرى.';
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _resendOtpCode() async {
    await _sendOtpCode();
  }

  void _goBackToEmailStep() {
    setState(() {
      _isEmailStep = true;
      _otpController.clear();
      _errorMessage = null;
    });
    _slideController.reverse();
    Future.delayed(const Duration(milliseconds: 400), () {
      _emailFocusNode.requestFocus();
    });
  }

  void _onSuccessComplete() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main-dashboard',
      (route) => false,
    );
  }

  void _goBack() {
    if (!_isEmailStep) {
      _goBackToEmailStep();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }

  bool _isValidEmail(String email) {
    return _otpService.isValidEmail(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 2.h),

                  // Back Button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _goBack,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'arrow_back_ios',
                            color: AppTheme.textSecondary,
                            size: 5.w,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // App Logo
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.goldColor,
                          AppTheme.goldColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.goldColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CustomIconWidget(
                      iconName: 'trending_up',
                      color: AppTheme.primaryDark,
                      size: 12.w,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Title
                  Text(
                    'Gold Nightmare',
                    style:
                        AppTheme.darkTheme.textTheme.headlineMedium?.copyWith(
                      color: AppTheme.goldColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    'تحليل الذهب بالذكاء الاصطناعي',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 6.h),

                  // Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepIndicator(1, 'البريد الإلكتروني', _isEmailStep),
                      SizedBox(width: 4.w),
                      Container(
                        width: 8.w,
                        height: 2,
                        color: !_isEmailStep
                            ? AppTheme.goldColor
                            : AppTheme.textTertiary,
                      ),
                      SizedBox(width: 4.w),
                      _buildStepIndicator(2, 'كود التفعيل', !_isEmailStep),
                    ],
                  ),

                  SizedBox(height: 6.h),

                  // Content Slider
                  SizedBox(
                    height: 50.h,
                    child: Stack(
                      children: [
                        // Email Step
                        if (_isEmailStep)
                          _buildEmailStep()
                        else
                          SlideTransition(
                            position: _slideAnimation,
                            child: _buildOtpStep(),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Footer
                  Text(
                    'جميع الحقوق محفوظة © 2024 Gold Nightmare',
                    style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),

          // Success Animation Overlay
          if (_showSuccess)
            SuccessAnimationWidget(
              remainingAnalyses: _remainingAnalyses,
              onComplete: _onSuccessComplete,
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, bool isActive) {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppTheme.goldColor : AppTheme.surfaceColor,
            border: Border.all(
              color: isActive ? AppTheme.goldColor : AppTheme.textTertiary,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? AppTheme.primaryDark : AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          title,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: isActive ? AppTheme.goldColor : AppTheme.textTertiary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        // Title
        Text(
          'تفعيل الحساب',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.goldColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        Text(
          'أدخل بريدك الإلكتروني لتلقي كود التفعيل',
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4.h),

        // Email Input
        EmailInputWidget(
          controller: _emailController,
          focusNode: _emailFocusNode,
          isLoading: _isSendingOtp,
          errorMessage: _errorMessage,
          onSubmitted: (value) => _sendOtpCode(),
        ),

        SizedBox(height: 4.h),

        // Send OTP Button
        SizedBox(
          width: double.infinity,
          height: 14.w,
          child: ElevatedButton(
            onPressed: _isSendingOtp ? null : _sendOtpCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: AppTheme.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _isSendingOtp ? 0 : 8,
              shadowColor: AppTheme.goldColor.withValues(alpha: 0.4),
            ),
            child: _isSendingOtp
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: const CircularProgressIndicator(
                      color: AppTheme.primaryDark,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'إرسال كود التفعيل',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        // Title
        Text(
          'تأكيد كود التفعيل',
          style: AppTheme.darkTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.goldColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        Text(
          'تم إرسال كود التفعيل إلى',
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 1.h),

        Text(
          _userEmail,
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.goldColor,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4.h),

        // OTP Input
        OtpInputWidget(
          controller: _otpController,
          focusNode: _otpFocusNode,
          isLoading: _isVerifyingOtp,
          errorMessage: _errorMessage,
          onCompleted: (value) => _verifyOtpCode(),
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
            if (value.length == 6) {
              _verifyOtpCode();
            }
          },
        ),

        SizedBox(height: 3.h),

        // Resend Button
        ResendButtonWidget(
          onPressed: _resendOtpCode,
          expiresAt: _otpExpiresAt,
          isLoading: _isSendingOtp,
        ),

        SizedBox(height: 4.h),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 14.w,
          child: ElevatedButton(
            onPressed: (_isVerifyingOtp || _otpController.text.length != 6)
                ? null
                : _verifyOtpCode,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldColor,
              foregroundColor: AppTheme.primaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _isVerifyingOtp ? 0 : 8,
              shadowColor: AppTheme.goldColor.withValues(alpha: 0.4),
            ),
            child: _isVerifyingOtp
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: const CircularProgressIndicator(
                      color: AppTheme.primaryDark,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'تفعيل الحساب',
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        SizedBox(height: 2.h),

        // Change Email Button
        TextButton(
          onPressed: _goBackToEmailStep,
          child: Text(
            'تغيير البريد الإلكتروني',
            style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
