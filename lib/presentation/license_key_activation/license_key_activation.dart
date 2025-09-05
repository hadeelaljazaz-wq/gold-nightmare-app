import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/activation_button_widget.dart';
import './widgets/help_section_widget.dart';
import './widgets/license_key_input_widget.dart';
import './widgets/success_animation_widget.dart';

class LicenseKeyActivation extends StatefulWidget {
  const LicenseKeyActivation({super.key});

  @override
  State<LicenseKeyActivation> createState() => _LicenseKeyActivationState();
}

class _LicenseKeyActivationState extends State<LicenseKeyActivation> {
  String _licenseKey = '';
  bool _isValidating = false;
  bool _isValid = false;
  bool _showSuccess = false;
  String? _errorMessage;
  int _remainingAnalyses = 50;

  // Enhanced valid license keys with better validation
  final List<String> _validLicenseKeys = [
    'GOLD2024NIGHTMARE1234567890ABCDEF123456',
    'DEMO2024GOLDANALYSIS7890ABCDEF123456789',
    'TEST2024TRADINGBOT567890ABCDEF1234567890',
    'ACTIVATION2024CODE567890ABCDEF12345678',
    'LICENSE2024KEY7890ABCDEF123456789012345',
    'GOLDAPP2024PREMIUM890ABCDEF123456789012',
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.primaryDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void _onLicenseKeyChanged(String key) {
    setState(() {
      _licenseKey = key;
      _errorMessage = null;
      _isValid = false;
    });

    // Real-time validation as user types
    if (key.length >= 20) {
      _validateLicenseKeyRealTime(key);
    }

    // Full validation when complete
    if (key.length == 40) {
      _validateLicenseKey(key);
    }
  }

  // Real-time validation for better user experience
  void _validateLicenseKeyRealTime(String key) {
    // Check if the entered key matches the beginning of any valid key
    bool isValidStart = _validLicenseKeys
        .any((validKey) => validKey.startsWith(key.toUpperCase()));

    setState(() {
      if (!isValidStart && key.length >= 20) {
        _errorMessage = 'كود التفعيل غير صحيح، تحقق من الكود المُدخل';
      } else {
        _errorMessage = null;
      }
    });
  }

  Future<void> _validateLicenseKey(String key) async {
    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    // Simulate API validation with better error handling
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // Enhanced validation logic
    final isValidCode = _validLicenseKeys
        .any((validKey) => validKey.toUpperCase() == key.toUpperCase());

    setState(() {
      _isValidating = false;
      _isValid = isValidCode;

      if (!_isValid) {
        _errorMessage =
            'كود التفعيل غير صحيح. تأكد من إدخال الكود بشكل صحيح أو تواصل مع الدعم الفني.';
      } else {
        _errorMessage = null;
      }
    });
  }

  Future<void> _activateLicense() async {
    if (_licenseKey.length != 40 || !_isValid) return;

    setState(() {
      _isValidating = true;
      _errorMessage = null;
    });

    try {
      // Enhanced activation logic
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // Better license analysis based on code type
      final upperKey = _licenseKey.toUpperCase();
      if (upperKey.contains('PREMIUM') || upperKey.contains('GOLD')) {
        _remainingAnalyses = 100;
      } else if (upperKey.contains('DEMO') || upperKey.contains('TEST')) {
        _remainingAnalyses = 25;
      } else {
        _remainingAnalyses = 50;
      }

      setState(() {
        _isValidating = false;
        _showSuccess = true;
      });

      // Enhanced haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isValidating = false;
        _errorMessage =
            'فشل في تفعيل الكود. تحقق من الاتصال بالإنترنت وحاول مرة أخرى.';
      });

      HapticFeedback.heavyImpact();
    }
  }

  void _onSuccessComplete() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main-dashboard',
      (route) => false,
    );
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
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

                  // App Logo with enhanced animation
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
                          color: AppTheme.goldColor
                              .withValues(alpha: _isValid ? 0.5 : 0.3),
                          blurRadius: _isValid ? 20 : 15,
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

                  // License Key Input with enhanced feedback
                  LicenseKeyInputWidget(
                    onKeyChanged: _onLicenseKeyChanged,
                    isValidating: _isValidating,
                    isValid: _isValid,
                    errorMessage: _errorMessage,
                    hasInput: _licenseKey.isNotEmpty,
                  ),

                  SizedBox(height: 4.h),

                  // Enhanced Activation Button - More prominent when code is entered
                  ActivationButtonWidget(
                    onPressed: _activateLicense,
                    isLoading: _isValidating,
                    isEnabled: _licenseKey.length == 40 && _isValid,
                    hasInput: _licenseKey.isNotEmpty,
                    licenseKeyLength: _licenseKey.length,
                  ),

                  // Additional help text when user starts typing
                  if (_licenseKey.isNotEmpty && _licenseKey.length < 40) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.accentGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: AppTheme.accentGreen,
                            size: 4.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'استمر في إدخال كود التفعيل (${_licenseKey.length}/40)',
                              style: AppTheme.darkTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.accentGreen,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 6.h),

                  // Help Section
                  const HelpSectionWidget(),

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
}
