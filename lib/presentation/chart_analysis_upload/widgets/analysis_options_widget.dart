import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../theme/app_theme.dart';

class AnalysisOptionsWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;
  final String? question;
  final Function(String?) onQuestionChanged;

  const AnalysisOptionsWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.question,
    required this.onQuestionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.tune,
                color: AppTheme.accentGreen,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'خيارات التحليل',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Analysis type selection
          Text(
            'نوع التحليل',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),

          SizedBox(height: 1.h),

          Column(
            children: [
              _buildAnalysisTypeCard(
                'quick',
                'تحليل سريع',
                'تحليل أساسي للاتجاه والمستويات المهمة (2-3 دقائق)',
                Icons.flash_on,
                AppTheme.goldColor,
              ),
              SizedBox(height: 1.h),
              _buildAnalysisTypeCard(
                'detailed',
                'تحليل مفصل',
                'تحليل شامل مع المؤشرات والتوصيات (5-8 دقائق)',
                Icons.analytics,
                AppTheme.accentGreen,
              ),
              SizedBox(height: 1.h),
              _buildAnalysisTypeCard(
                'comprehensive',
                'تحليل كامل',
                'تحليل عميق مع سيناريوهات متعددة (8-12 دقيقة)',
                Icons.assessment,
                AppTheme.warningRed,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Optional question input
          Text(
            'سؤال إضافي (اختياري)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
          ),

          SizedBox(height: 1.h),

          TextFormField(
            initialValue: question,
            onChanged: onQuestionChanged,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'مثال: ما هو أفضل وقت للدخول في الصفقة؟',
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.borderColor.withAlpha(128),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.borderColor.withAlpha(128),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.accentGreen,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.help_outline,
                color: AppTheme.textTertiary,
                size: 20.sp,
              ),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTypeCard(
    String type,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final bool isSelected = selectedType == type;

    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: AppTheme.fastAnimation,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(26) : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color.withAlpha(128)
                : AppTheme.borderColor.withAlpha(77),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppTheme.borderColor,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: AppTheme.primaryDark,
                    )
                  : null,
            ),

            SizedBox(width: 3.w),

            // Icon
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 5.w,
              ),
            ),

            SizedBox(width: 3.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}