import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/email_auth_service.dart';
import './widgets/email_input_widget.dart';
import './widgets/existing_user_link_widget.dart';
import './widgets/send_code_button_widget.dart';
import './widgets/terms_checkbox_widget.dart';

class EmailRegistration extends StatefulWidget {
  const EmailRegistration({super.key});

  @override
  State<EmailRegistration> createState() => _EmailRegistrationState();
}

class _EmailRegistrationState extends State<EmailRegistration>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _isValidEmail = false;

  final EmailAuthService _authService = EmailAuthService.instance;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _emailController.addListener(_validateEmail);
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

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isValid = _authService.isValidEmail(email) && email.isNotEmpty;

    if (isValid != _isValidEmail) {
      setState(() {
        _isValidEmail = isValid;
      });
    }
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email is already registered
      final registrationResult = await _authService.registerWithEmail(
        email: email,
        fullName: '', // Will be collected in next step
      );
      
      if (!registrationResult['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(registrationResult['error'] ?? 'فشل في إنشاء الحساب'),
              backgroundColor: AppTheme.warningRed,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Send OTP code
      final result = await _authService.signInWithEmailOtp(email);

      if (mounted) {
        if (result['success']) {
          // Navigate to OTP verification screen
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.otpVerification,
            arguments: {'email': email},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ?? 'فشل في إرسال رمز التحقق'),
              backgroundColor: AppTheme.warningRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ غير متوقع: ${e.toString()}'),
            backgroundColor: AppTheme.warningRed,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
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
          'إنشاء حساب جديد',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // AL KABBUS AI Logo
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Container(
                            width: 25.w,
                            height: 25.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.aiBlue.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CustomImageWidget(
                                imageUrl:
                                    'assets/images/photo_2025-09-02_10-36-06-1756798604953.jpg',
                                fit: BoxFit.cover,
                                width: 25.w,
                                height: 25.w,
                              ),
                            ),
                          ),
                        ),

                        // Welcome title
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppTheme.luxuryGoldGradient,
                            borderRadius: BorderRadius.circular(
                              AppTheme.largeRadius,
                            ),
                          ),
                          child: Text(
                            'مرحباً بك في AL KABBUS AI',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.deepNavy,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Subtitle
                        Text(
                          'أدخل بريدك الإلكتروني لإنشاء حسابك وبدء رحلة التحليل الذكي للذهب',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textAccent,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 5.h),

                        // Email input
                        EmailInputWidget(
                          controller: _emailController,
                          isLoading: _isLoading,
                        ),

                        SizedBox(height: 3.h),

                        // Terms and conditions
                        TermsCheckboxWidget(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                        ),

                        SizedBox(height: 4.h),

                        // Send code button
                        SendCodeButtonWidget(
                          isEnabled:
                              _isValidEmail && _acceptTerms && !_isLoading,
                          isLoading: _isLoading,
                          onPressed: _sendVerificationCode,
                        ),

                        SizedBox(height: 4.h),

                        // Existing user link
                        const ExistingUserLinkWidget(),

                        SizedBox(height: 3.h),

                        // Security notice
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.royalSurface.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(
                              AppTheme.mediumRadius,
                            ),
                            border: Border.all(
                              color: AppTheme.aiBlue.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.security,
                                color: AppTheme.aiBlue,
                                size: 20,
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Text(
                                  'معلوماتك محمية بأعلى معايير الأمان والتشفير',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textAccent,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}