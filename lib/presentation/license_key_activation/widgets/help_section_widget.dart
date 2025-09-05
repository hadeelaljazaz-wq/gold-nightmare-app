import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HelpSectionWidget extends StatefulWidget {
  const HelpSectionWidget({super.key});

  @override
  State<HelpSectionWidget> createState() => _HelpSectionWidgetState();
}

class _HelpSectionWidgetState extends State<HelpSectionWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'help_outline',
                    color: AppTheme.goldColor,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'كيفية الحصول على مفتاح الترخيص؟',
                      style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: AppTheme.normalAnimation,
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.textSecondary,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: AppTheme.borderColor.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: 3.h),
                  _buildHelpItem(
                    icon: 'phone',
                    title: 'اتصل بنا',
                    description: 'للحصول على مفتاح الترخيص الخاص بك',
                    action: '+966 50 123 4567',
                    actionColor: AppTheme.accentGreen,
                  ),
                  SizedBox(height: 2.h),
                  _buildHelpItem(
                    icon: 'telegram',
                    title: 'تليجرام',
                    description: 'تواصل معنا عبر التليجرام',
                    action: '@GoldNightmareSupport',
                    actionColor: AppTheme.goldColor,
                  ),
                  SizedBox(height: 2.h),
                  _buildHelpItem(
                    icon: 'email',
                    title: 'البريد الإلكتروني',
                    description: 'راسلنا للحصول على المساعدة',
                    action: 'support@goldnightmare.com',
                    actionColor: AppTheme.accentGreen,
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.goldColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.goldColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          color: AppTheme.goldColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'كل مفتاح ترخيص يحتوي على 50 تحليل مجاني. تأكد من حفظ مفتاحك في مكان آمن.',
                            style: AppTheme.darkTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.goldColor,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required String icon,
    required String title,
    required String description,
    required String action,
    required Color actionColor,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: actionColor,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 1.h),
                Text(
                  action,
                  style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                    color: actionColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
