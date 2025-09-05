import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExistingUserLinkWidget extends StatefulWidget {
  const ExistingUserLinkWidget({super.key});

  @override
  State<ExistingUserLinkWidget> createState() => _ExistingUserLinkWidgetState();
}

class _ExistingUserLinkWidgetState extends State<ExistingUserLinkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                    gradient: AppTheme.luxuryGoldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppTheme.deepNavy,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'تسجيل الدخول',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.luxuryGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.aiBlue.withValues(alpha: 0.1),
                        AppTheme.luxuryGold.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                    border: Border.all(
                      color: AppTheme.aiBlue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppTheme.aiBlue,
                        size: 40,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'تسجيل الدخول بالبريد الإلكتروني',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'إذا كان لديك حساب مسبق، أدخل بريدك الإلكتروني أعلاه وسيتم إرسال رمز تحقق للدخول',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textAccent,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Legacy license key option
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.warningRed.withValues(alpha: 0.1),
                        AppTheme.royalPurple.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                    border: Border.all(
                      color: AppTheme.warningRed.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.key_outlined,
                        color: AppTheme.warningRed,
                        size: 30,
                      ),
                      SizedBox(height: 1.5.h),
                      Text(
                        'لديك مفتاح ترخيص قديم؟',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'سيتم إلغاء نظام المفاتيح قريباً. ننصحك بالتسجيل بالبريد الإلكتروني',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textAccent,
                          height: 1.4,
                          fontSize: 11.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.licenseKeyActivation,
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          backgroundColor: AppTheme.warningRed.withValues(
                            alpha: 0.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: AppTheme.warningRed.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'استخدام مفتاح الترخيص',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppTheme.warningRed,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إغلاق',
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: _showSignInDialog,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.royalSurface.withValues(alpha: 0.7),
                    AppTheme.surfaceColor.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                border: Border.all(
                  color: AppTheme.aiBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.aiBlue.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, color: AppTheme.aiBlue, size: 20),
                  SizedBox(width: 3.w),
                  Text(
                    'لديك حساب مسبق؟',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'اضغط هنا',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.aiBlue,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.aiBlue,
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
}
