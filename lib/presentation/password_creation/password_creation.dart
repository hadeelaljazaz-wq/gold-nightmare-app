import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../main_dashboard/main_dashboard.dart';
import './widgets/password_input_widget.dart';
import './widgets/password_requirements_widget.dart';
import './widgets/password_strength_widget.dart';

class PasswordCreation extends StatefulWidget {
  const PasswordCreation({super.key});

  @override
  State<PasswordCreation> createState() => _PasswordCreationState();
}

class _PasswordCreationState extends State<PasswordCreation> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _passwordStrength = 'weak';
  bool _passwordsMatch = false;
  String? _verifiedEmail;
  String? _fullName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get email and name from navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    _verifiedEmail = args?['email'] ?? '';
    _fullName = args?['fullName'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Progress indicator
            Container(
              height: 0.5.h,
              width: 100.w,
              color: AppTheme.surfaceColor,
              child: LinearProgressIndicator(
                value: 1.0, // Final step
                backgroundColor: AppTheme.surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
              ),
            ),

            // Main content
            SingleChildScrollView(
              padding: EdgeInsets.all(6.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),

                    // Header
                    _buildHeader(),

                    SizedBox(height: 4.h),

                    // Email confirmation
                    _buildEmailConfirmation(),

                    SizedBox(height: 4.h),

                    // Password inputs
                    _buildPasswordInputs(),

                    SizedBox(height: 3.h),

                    // Password strength indicator
                    PasswordStrengthWidget(
                      password: _passwordController.text,
                      onStrengthChanged: (strength) {
                        setState(() {
                          _passwordStrength = strength;
                        });
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Requirements checklist
                    PasswordRequirementsWidget(
                      password: _passwordController.text,
                      passwordsMatch: _passwordsMatch,
                    ),

                    SizedBox(height: 4.h),

                    // Create account button
                    _buildCreateAccountButton(),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إنشاء كلمة المرور',
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.goldColor,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'أنشئ كلمة مرور قوية لحماية حسابك',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailConfirmation() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.verified, color: AppTheme.goldColor, size: 20.sp),

          SizedBox(width: 3.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'البريد الإلكتروني المُفعّل',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),

                Text(
                  _verifiedEmail ?? 'البريد الإلكتروني',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.goldColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInputs() {
    return Column(
      children: [
        PasswordInputWidget(
          controller: _passwordController,
          label: 'كلمة المرور الجديدة',
          isVisible: _passwordVisible,
          onVisibilityToggled: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
          onChanged: (value) {
            setState(() {
              _passwordsMatch = value == _confirmPasswordController.text;
            });
          },
        ),

        SizedBox(height: 3.h),

        PasswordInputWidget(
          controller: _confirmPasswordController,
          label: 'تأكيد كلمة المرور',
          isVisible: _confirmPasswordVisible,
          onVisibilityToggled: () {
            setState(() {
              _confirmPasswordVisible = !_confirmPasswordVisible;
            });
          },
          onChanged: (value) {
            setState(() {
              _passwordsMatch = value == _passwordController.text;
            });
          },
          validator: (value) {
            if (value != _passwordController.text) {
              return 'كلمات المرور غير متطابقة';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    final isButtonEnabled =
        _passwordStrength == 'strong' &&
        _passwordsMatch &&
        _passwordController.text.length >= 8;

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isButtonEnabled && !_isLoading ? _createAccount : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isButtonEnabled ? AppTheme.goldColor : AppTheme.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isButtonEnabled ? 8 : 0,
          shadowColor: AppTheme.goldColor.withValues(alpha: 0.3),
        ),
        child: Text(
          _isLoading ? 'إنشاء الحساب...' : 'إنشاء الحساب',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppTheme.primaryDark.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 15.w,
                height: 15.w,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldColor),
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                'إنشاء حسابك...',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.goldColor,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                'جاري تأمين بياناتك وإعداد الحساب',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create account with email and password
      final result = await AuthService.instance.signUp(
        email: _verifiedEmail!,
        password: _passwordController.text,
        fullName: _fullName,
      );

      if (result.user != null) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إنشاء حسابك بنجاح! مرحباً بك في Gold Nightmare',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.goldColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }

        // Navigate to main dashboard
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainDashboard()),
            (route) => false,
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ في إنشاء الحساب. يرجى المحاولة مرة أخرى',
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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
