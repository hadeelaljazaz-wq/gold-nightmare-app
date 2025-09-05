import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/gold_price_service.dart';
import '../../theme/app_theme.dart';
import '../main_dashboard/main_dashboard.dart';
import '../otp_activation/otp_activation_screen.dart';
import './widgets/biometric_login_widget.dart';
import './widgets/email_input_field_widget.dart';
import './widgets/login_button_widget.dart';
import './widgets/password_input_field_widget.dart';

class EmailLogin extends StatefulWidget {
  const EmailLogin({super.key});

  @override
  State<EmailLogin> createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _passwordVisible = false;
  String _goldPrice = 'جاري التحميل...';

  @override
  void initState() {
    super.initState();
    _loadGoldPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // App logo and header
                _buildHeader(),

                SizedBox(height: 6.h),

                // Email input
                EmailInputFieldWidget(controller: _emailController),

                SizedBox(height: 3.h),

                // Password input
                PasswordInputFieldWidget(
                  controller: _passwordController,
                  isVisible: _passwordVisible,
                  onVisibilityToggled: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),

                SizedBox(height: 2.h),

                // Remember me & forgot password
                _buildOptionsRow(),

                SizedBox(height: 4.h),

                // Login button
                LoginButtonWidget(isLoading: _isLoading, onPressed: _signIn),

                SizedBox(height: 3.h),

                // Biometric login option
                BiometricLoginWidget(onBiometricLogin: _handleBiometricLogin),

                SizedBox(height: 4.h),

                // Create account link
                _buildCreateAccountLink(),

                SizedBox(height: 3.h),

                // Help section
                _buildHelpSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
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
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.trending_up,
            color: AppTheme.primaryDark,
            size: 12.w,
          ),
        ),

        SizedBox(height: 3.h),

        Text(
          'تسجيل الدخول',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
        ),

        SizedBox(height: 1.h),

        // Gold price ticker
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.goldColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timeline, color: AppTheme.goldColor, size: 16.sp),

              SizedBox(width: 2.w),

              Text(
                'سعر الذهب الحالي: $_goldPrice',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me checkbox
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: AppTheme.goldColor,
              checkColor: AppTheme.primaryDark,
            ),

            Text(
              'تذكرني',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),

        // Forgot password link
        TextButton(
          onPressed: _showForgotPasswordDialog,
          child: Text(
            'نسيت كلمة المرور؟',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: AppTheme.goldColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لا تملك حساباً؟ ',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),

        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OtpActivationScreen(),
              ),
            );
          },
          child: Text(
            'إنشاء حساب جديد',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.goldColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpSection() {
    return TextButton.icon(
      onPressed: _showHelpDialog,
      icon: Icon(
        Icons.help_outline,
        color: AppTheme.textSecondary,
        size: 18.sp,
      ),
      label: Text(
        'تحتاج مساعدة؟',
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Future<void> _loadGoldPrice() async {
    try {
      final priceData = await GoldPriceService.instance.refreshPrice();
      final price = priceData['price'] as double;
      if (mounted) {
        setState(() {
          _goldPrice = '\$${price.toStringAsFixed(2)}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _goldPrice = 'غير متوفر';
        });
      }
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.instance.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result.user != null && result.session != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم تسجيل الدخول بنجاح!',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.goldColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Navigate to main dashboard
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainDashboard()),
            (route) => false,
          );
        }
      }
    } catch (error) {
      if (mounted) {
        String errorMessage = 'فشل تسجيل الدخول. تحقق من البيانات المدخلة.';

        if (error.toString().contains('Invalid login credentials')) {
          errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else if (error.toString().contains('Email not confirmed')) {
          errorMessage = 'يرجى تأكيد البريد الإلكتروني أولاً';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    // Placeholder for biometric authentication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'المصادقة البيومترية ستكون متاحة قريباً',
          style: GoogleFonts.inter(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.goldColor,
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: Text(
              'استعادة كلمة المرور',
              style: GoogleFonts.inter(
                color: AppTheme.goldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'سيتم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني',
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'إلغاء',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Handle password reset
                  _handlePasswordReset();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldColor,
                ),
                child: Text(
                  'إرسال',
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: Text(
              'المساعدة',
              style: GoogleFonts.inter(
                color: AppTheme.goldColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'للمساعدة في تسجيل الدخول أو إنشاء حساب جديد، يرجى التواصل مع الدعم الفني',
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldColor,
                ),
                child: Text(
                  'موافق',
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handlePasswordReset() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال البريد الإلكتروني أولاً',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await AuthService.instance.resetPasswordWithOtp(
        _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال رمز استعادة كلمة المرور إلى بريدك الإلكتروني',
              style: GoogleFonts.inter(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTheme.goldColor,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل في إرسال رمز الاستعادة',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}