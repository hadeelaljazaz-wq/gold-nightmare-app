import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/email_auth_service.dart';
import './widgets/otp_input_widget.dart';
import './widgets/resend_timer_widget.dart';
import './widgets/verify_button_widget.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({super.key});

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  String _email = '';
  String _otpCode = '';
  bool _isLoading = false;
  bool _isValidOtp = false;
  DateTime? _expiresAt;
  Timer? _timer;
  int _remainingSeconds = 300; // 5 minutes

  final EmailAuthService _authService = EmailAuthService.instance;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _extractArguments();
    _setupOtpListeners();
    _startTimer();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  void _extractArguments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _email = args['email'] ?? '';
          if (args['expires_at'] != null) {
            _expiresAt = DateTime.parse(args['expires_at']);
            final now = DateTime.now();
            final difference = _expiresAt!.difference(now).inSeconds;
            _remainingSeconds = difference > 0 ? difference : 0;
          }
        });
      }
    });
  }

  void _setupOtpListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        _validateOtp();
        _handleOtpInput(i);
      });
    }
  }

  void _handleOtpInput(int index) {
    final value = _otpControllers[index].text;

    if (value.isNotEmpty) {
      // Auto-focus next field
      if (index < _otpControllers.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Auto-focus previous field when deleting
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _validateOtp() {
    final code = _otpControllers.map((c) => c.text).join();
    final isValid = code.length == 6 && code.contains(RegExp(r'^\d+$'));

    if (isValid != _isValidOtp) {
      setState(() {
        _isValidOtp = isValid;
        _otpCode = code;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!_isValidOtp || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print(
        'Starting OTP verification for email: $_email with code: $_otpCode',
      ); // Debug log

      final result = await _authService.verifyOtpAndSignIn(
        email: _email,
        token: _otpCode,
      );

      if (mounted) {
        if (result['success']) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 2.w),
                  Expanded(child: Text(result['message'])),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to main dashboard after a short delay
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.mainDashboard,
              (route) => false,
            );
          }
        } else {
          // Show error message in Arabic
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      result['message'] ?? 'فشل في التحقق من الرمز',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.warningRed,
              duration: const Duration(seconds: 4),
            ),
          );
          // Clear OTP fields on error
          _clearOtpFields();
        }
      }
    } catch (e) {
      print('OTP verification error: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'خطأ في التحقق من الرمز. يرجى المحاولة مرة أخرى',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.warningRed,
            duration: const Duration(seconds: 4),
          ),
        );
        _clearOtpFields();
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _resendOtp() async {
    try {
      final result = await _authService.sendOtpToEmail(_email);

      if (mounted) {
        if (result['success']) {
          setState(() {
            _remainingSeconds = 300; // Reset to 5 minutes
            if (result['expires_at'] != null) {
              _expiresAt = DateTime.parse(result['expires_at']);
            }
          });
          _startTimer();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إرسال رمز جديد إلى بريدك الإلكتروني'),
              backgroundColor: Colors.green,
            ),
          );
          _clearOtpFields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: AppTheme.warningRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إعادة الإرسال: ${e.toString()}'),
            backgroundColor: AppTheme.warningRed,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'تحقق من الرمز',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppTheme.aiBlue),
            onPressed: _showHelpDialog,
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header section
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 3.h),
                        child: Column(
                          children: [
                            Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: BoxDecoration(
                                gradient: AppTheme.aiGlowGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mark_email_read_outlined,
                                color: AppTheme.deepNavy,
                                size: 40,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'تحقق من بريدك الإلكتروني',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.luxuryGold,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 2.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.royalSurface.withValues(
                                  alpha: 0.8,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.largeRadius,
                                ),
                                border: Border.all(
                                  color: AppTheme.aiBlue.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textAccent,
                                    height: 1.5,
                                  ),
                                  children: [
                                    const TextSpan(
                                      text:
                                          'أرسلنا رمز التحقق المكون من 6 أرقام إلى\n',
                                    ),
                                    TextSpan(
                                      text: _email,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.aiBlue,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // OTP input section
                      OtpInputWidget(
                        controllers: _otpControllers,
                        focusNodes: _focusNodes,
                        isLoading: _isLoading,
                        isValid: _isValidOtp,
                      ),

                      SizedBox(height: 4.h),

                      // Timer section
                      ResendTimerWidget(
                        remainingSeconds: _remainingSeconds,
                        onResend: _resendOtp,
                      ),

                      SizedBox(height: 4.h),

                      // Verify button
                      VerifyButtonWidget(
                        isEnabled: _isValidOtp && !_isLoading,
                        isLoading: _isLoading,
                        onPressed: _verifyOtp,
                      ),

                      SizedBox(height: 3.h),

                      // Change email option
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                        child: Text(
                          'تغيير البريد الإلكتروني',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textAccent,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.textAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.royalSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    gradient: AppTheme.aiBlueGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'مساعدة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.aiBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem(
                  '📧',
                  'تحقق من صندوق الوارد',
                  'قد يستغرق وصول الرسالة بضع دقائق',
                ),
                _buildHelpItem(
                  '📁',
                  'تحقق من مجلد الرسائل المزعجة',
                  'أحياناً تصل الرسالة إلى مجلد Spam',
                ),
                _buildHelpItem(
                  '🔄',
                  'إعادة الإرسال',
                  'يمكنك طلب رمز جديد بعد انتهاء الوقت',
                ),
                _buildHelpItem(
                  '⏰',
                  'صالح لمدة 5 دقائق',
                  'الرمز صالح لمدة 5 دقائق فقط',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'فهمت',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.aiBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHelpItem(String emoji, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textAccent,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}