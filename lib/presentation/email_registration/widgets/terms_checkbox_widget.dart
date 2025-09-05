import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TermsCheckboxWidget extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TermsCheckboxWidget> createState() => _TermsCheckboxWidgetState();
}

class _TermsCheckboxWidgetState extends State<TermsCheckboxWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showTermsExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.royalSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            ),
            title: Text(
              'الشروط والأحكام',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.luxuryGold,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 80.w,
              height: 60.h,
              child: SingleChildScrollView(
                child: Text(
                  '''
شروط وأحكام استخدام تطبيق AL KABBUS AI

1. قبول الشروط
باستخدامك لتطبيق AL KABBUS AI، فإنك توافق على الالتزام بهذه الشروط والأحكام.

2. وصف الخدمة
AL KABBUS AI هو نظام ذكي لتحليل أسعار الذهب باستخدام تقنيات الذكاء الاصطناعي.

3. استخدام الخدمة
• يجب أن تكون بالغاً من العمر 18 عاماً أو أكثر
• يجب استخدام التطبيق لأغراض قانونية فقط
• لا يجوز مشاركة حسابك مع آخرين

4. دقة المعلومات
• التحليلات المقدمة للأغراض التعليمية فقط
• لا نضمن دقة التوقعات المالية
• المستخدم مسؤول عن قراراته الاستثمارية

5. الخصوصية
نحن نحترم خصوصيتك ونحمي بياناتك الشخصية وفقاً لسياسة الخصوصية.

6. القيود
• لا يجوز نسخ أو توزيع المحتوى
• لا يجوز إجراء هندسة عكسية للتطبيق
• لا يجوز استخدام التطبيق للأنشطة الضارة

7. إخلاء المسؤولية
AL KABBUS AI غير مسؤول عن أي خسائر مالية قد تنتج عن استخدام التطبيق.

8. التعديلات
نحتفظ بالحق في تعديل هذه الشروط في أي وقت.

9. الاتصال
للاستفسارات: support@alkabbusai.com

تاريخ آخر تحديث: ديسمبر 2025
              ''',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
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
    return GestureDetector(
      onTap: () {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        widget.onChanged(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.royalSurface.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                border: Border.all(
                  color:
                      widget.value
                          ? AppTheme.luxuryGold
                          : AppTheme.royalBlue.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow:
                    widget.value
                        ? [
                          BoxShadow(
                            color: AppTheme.luxuryGold.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ]
                        : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom checkbox
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          widget.value
                              ? AppTheme.luxuryGold
                              : Colors.transparent,
                      border: Border.all(
                        color:
                            widget.value
                                ? AppTheme.luxuryGold
                                : AppTheme.textAccent,
                        width: 2,
                      ),
                    ),
                    child:
                        widget.value
                            ? Icon(
                              Icons.check,
                              color: AppTheme.deepNavy,
                              size: 16,
                            )
                            : null,
                  ),

                  SizedBox(width: 3.w),

                  // Terms text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textAccent,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'أوافق على '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: _showTermsDialog,
                                  child: Text(
                                    'الشروط والأحكام',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.luxuryGold,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppTheme.luxuryGold,
                                    ),
                                  ),
                                ),
                              ),
                              const TextSpan(text: ' و'),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: _showPrivacyDialog,
                                  child: Text(
                                    'سياسة الخصوصية',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.luxuryGold,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppTheme.luxuryGold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (widget.value) ...[
                          SizedBox(height: 1.h),
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.luxuryGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppTheme.smallRadius,
                              ),
                            ),
                            child: Text(
                              '✓ شكراً لموافقتك على الشروط والأحكام',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: AppTheme.luxuryGold,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.royalSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            ),
            title: Text(
              'سياسة الخصوصية',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.luxuryGold,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: 80.w,
              height: 60.h,
              child: SingleChildScrollView(
                child: Text(
                  '''
سياسة الخصوصية لتطبيق AL KABBUS AI

1. المعلومات التي نجمعها
• البريد الإلكتروني للتسجيل
• بيانات الاستخدام والتفضيلات
• معلومات الجهاز والموقع (اختيارية)

2. كيفية استخدام المعلومات
• تقديم خدمات التحليل المخصصة
• التواصل معك حول التحديثات
• تحسين جودة الخدمة

3. مشاركة المعلومات
• لا نبيع معلوماتك الشخصية لأطراف ثالثة
• قد نشارك بيانات مجمعة وغير مُعرِّفة للإحصاءات
• نشارك المعلومات فقط عند الضرورة القانونية

4. أمان البيانات
• نستخدم التشفير المتقدم لحماية بياناتك
• خوادم آمنة ومحمية بأحدث التقنيات
• مراقبة مستمرة للأنشطة المشبوهة

5. حقوقك
• الحق في الوصول إلى بياناتك
• الحق في تصحيح المعلومات الخاطئة
• الحق في حذف حسابك وبياناتك

6. ملفات تعريف الارتباط
• نستخدم ملفات تعريف الارتباط لتحسين التجربة
• يمكنك تعطيلها من إعدادات المتصفح

7. تحديثات السياسة
سيتم إشعارك بأي تغييرات جوهرية في سياسة الخصوصية.

8. الاتصال
لأي استفسارات: privacy@alkabbusai.com

تاريخ آخر تحديث: ديسمبر 2025
              ''',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),
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
}
