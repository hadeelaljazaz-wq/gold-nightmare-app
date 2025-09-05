import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';

// Add this import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _glowAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _backgroundFadeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _rotationAnimation;

  bool _isInitialized = false;
  String _loadingText = 'جاري التحميل...';
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation controller
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Glow animation controller
    _glowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Logo scale animation with royal bounce
    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Background fade animation
    _backgroundFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    // AI glow animation
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Subtle rotation animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _logoAnimationController.forward();
        _glowAnimationController.repeat(reverse: true);
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style for royal splash
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.deepNavy,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Simulate initialization tasks with royal messaging
      await _performInitializationTasks();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });

        // Navigate after successful initialization
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          _navigateToNextScreen();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingText = 'فشل في التحميل';
          _showRetryButton = true;
        });

        // Auto retry after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && _showRetryButton) {
            _retryInitialization();
          }
        });
      }
    }
  }

  Future<void> _performInitializationTasks() async {
    // Task 1: تهيئة نظام AL KABBUS AI
    setState(() {
      _loadingText = 'تهيئة AL KABBUS AI...';
    });
    await Future.delayed(const Duration(milliseconds: 900));

    // Task 2: تحميل النماذج الذكية
    setState(() {
      _loadingText = 'تحميل النماذج الذكية...';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    // Task 3: الاتصال بخوادم التحليل الملكية
    setState(() {
      _loadingText = 'الاتصال بالخوادم الملكية...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Task 4: تجهيز واجهة المستخدم الفاخرة
    setState(() {
      _loadingText = 'تجهيز الواجهة الفاخرة...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _loadingText = 'AL KABBUS AI جاهز للاستخدام';
    });
  }

  void _retryInitialization() {
    setState(() {
      _showRetryButton = false;
      _loadingText = 'إعادة تهيئة النظام...';
    });
    _initializeApp();
  }

  void _navigateToNextScreen() {
    // Updated navigation logic for email-based authentication
    final bool isAuthenticated = _checkAuthenticationStatus();
    final String? userEmail = _getUserEmail();

    if (isAuthenticated && userEmail != null) {
      // Authenticated users with verified email go to main dashboard
      Navigator.pushReplacementNamed(context, '/main-dashboard');
    } else {
      // New users or unverified users see email registration screen
      Navigator.pushReplacementNamed(context, '/email-registration');
    }
  }

  bool _checkLicenseStatus() {
    // Legacy license check - will be phased out
    return true;
  }

  bool _checkAuthenticationStatus() {
    // Check if user has valid Supabase session
    return false; // For now, always redirect to email registration
  }

  String? _getUserEmail() {
    // Get authenticated user email from Supabase session
    return null; // For now, return null to trigger email registration
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      body: AnimatedBuilder(
        animation: _backgroundFadeAnimation,
        builder: (context, child) {
          return Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.deepNavy.withValues(
                    alpha: _backgroundFadeAnimation.value,
                  ),
                  AppTheme.royalBlue.withValues(
                    alpha: _backgroundFadeAnimation.value * 0.3,
                  ),
                  AppTheme.royalPurple.withValues(
                    alpha: _backgroundFadeAnimation.value * 0.2,
                  ),
                  AppTheme.deepNavy.withValues(
                    alpha: _backgroundFadeAnimation.value,
                  ),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Background geometric patterns
                _buildGeometricBackground(),

                // Main content
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Spacer to push content to center
                      const Spacer(flex: 2),

                      // AL KABBUS AI Logo section
                      _buildAlKabbusAISection(),

                      SizedBox(height: 8.h),

                      // Loading section
                      _buildLoadingSection(),

                      // Spacer to maintain center alignment
                      const Spacer(flex: 2),

                      // Bottom royal branding
                      _buildRoyalBottomBranding(),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeometricBackground() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: GeometricPatternPainter(
              glowIntensity: _glowAnimation.value,
              royalBlue: AppTheme.royalBlue,
              luxuryGold: AppTheme.luxuryGold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlKabbusAISection() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoScaleAnimation,
        _logoFadeAnimation,
        _glowAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _logoFadeAnimation.value,
          child: Transform.scale(
            scale: _logoScaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Column(
                children: [
                  // AL KABBUS AI Image with royal effects
                  Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.aiBlue.withValues(
                            alpha: _glowAnimation.value * 0.6,
                          ),
                          blurRadius: 30 * _glowAnimation.value,
                          spreadRadius: 10 * _glowAnimation.value,
                        ),
                        BoxShadow(
                          color: AppTheme.luxuryGold.withValues(
                            alpha: _glowAnimation.value * 0.4,
                          ),
                          blurRadius: 50 * _glowAnimation.value,
                          spreadRadius: 5 * _glowAnimation.value,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl:
                            'assets/images/photo_2025-09-02_10-36-06-1756798604953.jpg',
                        fit: BoxFit.cover,
                        width: 35.w,
                        height: 35.w,
                      ),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // AL KABBUS AI Royal Title
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.luxuryGoldGradient,
                      borderRadius: BorderRadius.circular(
                        AppTheme.luxuryRadius,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.luxuryGold.withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'AL KABBUS AI',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.deepNavy,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                            color: AppTheme.royalBlue.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Royal subtitle
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.royalSurface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(
                        AppTheme.mediumRadius,
                      ),
                      border: Border.all(
                        color: AppTheme.aiBlue.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'نظام التحليل الملكي للذهب بالذكاء الاصطناعي',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textAccent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.royalSurface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(
          color: AppTheme.royalBlue.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalBlue.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Royal loading indicator
          if (!_showRetryButton) ...[
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.aiBlue.withValues(
                          alpha: _glowAnimation.value * 0.5,
                        ),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircularProgressIndicator(
                    strokeWidth: 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.aiBlue),
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),
          ],

          // Royal loading text
          AnimatedSwitcher(
            duration: AppTheme.normalAnimation,
            child: Text(
              _loadingText,
              key: ValueKey(_loadingText),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Royal retry button
          if (_showRetryButton) ...[
            SizedBox(height: 3.h),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.royalPrimaryGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.royalBlue.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _retryInitialization,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 1.5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoyalBottomBranding() {
    return Column(
      children: [
        // Royal version info
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.royalSurface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.luxuryGold.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            'الإصدار الملكي 1.0.0',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textAccent,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Royal Social Media Contact Links
        Container(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.royalSurface.withValues(alpha: 0.8),
                AppTheme.surfaceColor.withValues(alpha: 0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            border: Border.all(
              color: AppTheme.luxuryGold.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                'تواصل مع الفريق الملكي',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 4.w,
                runSpacing: 1.h,
                alignment: WrapAlignment.center,
                children: [
                  _buildRoyalSocialMediaButton(
                    'المشرف الملكي',
                    'https://t.me/Odai_xau',
                    AppTheme.aiBlue,
                    Icons.admin_panel_settings,
                  ),
                  _buildRoyalSocialMediaButton(
                    'التوصيات الذهبية',
                    'https://t.me/odai_xau_usd',
                    AppTheme.luxuryGold,
                    Icons.diamond,
                  ),
                  _buildRoyalSocialMediaButton(
                    'المناقشات الملكية',
                    'https://t.me/odai_xauusdt',
                    AppTheme.royalPurple,
                    Icons.forum,
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Royal Copyright
        Text(
          '© 2025 AL KABBUS AI - النظام الملكي لتحليل الذهب',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 9.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoyalSocialMediaButton(
    String label,
    String url,
    Color color,
    IconData icon,
  ) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _launchUrl(url),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: _glowAnimation.value * 0.3),
                  blurRadius: 15 * _glowAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 16),
                SizedBox(width: 1.5.w),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('لا يمكن فتح الرابط: $url'),
              backgroundColor: AppTheme.warningRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ في فتح الرابط'),
            backgroundColor: AppTheme.warningRed,
          ),
        );
      }
    }
  }
}

// Custom painter for geometric background patterns
class GeometricPatternPainter extends CustomPainter {
  final double glowIntensity;
  final Color royalBlue;
  final Color luxuryGold;

  GeometricPatternPainter({
    required this.glowIntensity,
    required this.royalBlue,
    required this.luxuryGold,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Draw subtle geometric patterns
    for (int i = 0; i < 5; i++) {
      final double opacity = (glowIntensity * 0.1 * (i + 1)).clamp(0.0, 0.3);

      paint.color = royalBlue.withValues(alpha: opacity);

      // Hexagonal patterns
      final double radius = size.width * 0.1 * (i + 1);
      final Offset center = Offset(
        size.width * (0.2 + i * 0.15),
        size.height * (0.3 + i * 0.1),
      );

      _drawHexagon(canvas, paint, center, radius);

      // Circuit-like patterns
      paint.color = luxuryGold.withValues(alpha: opacity * 0.6);
      _drawCircuitPattern(canvas, paint, size, i);
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = (i * 60) * (3.14159 / 180);
      final double x = center.dx + radius * cos(angle);
      final double y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCircuitPattern(Canvas canvas, Paint paint, Size size, int index) {
    final double startX = size.width * (0.1 + index * 0.2);
    final double startY = size.height * (0.6 + index * 0.05);
    final double endX = startX + size.width * 0.15;
    final double endY = startY + size.height * 0.1;

    canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    canvas.drawCircle(Offset(endX, endY), 3, paint..style = PaintingStyle.fill);
    paint.style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
